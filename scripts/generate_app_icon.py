#!/usr/bin/env python3
"""Regenerates every platform launcher icon from the master glyph.

assets/images/app_icon.png is the canonical 1024x1024 flattened icon (green
background, white mosque/crescent/community/book glyph) — hand-verified
against the app's reference artwork. Everything else is derived from it:

  - assets/images/app_icon_background.png / app_icon_foreground.png
    (Android adaptive icon layers, consumed by flutter_launcher_icons)
  - android/**/mipmap-*/ic_launcher.png (legacy icon, all densities)
  - android/**/drawable-*/ic_launcher_{background,foreground}.png
    (adaptive icon layers, all densities)
  - ios/**/AppIcon.appiconset/*.png (all declared sizes)
  - web/icons/Icon-{,maskable-}{192,512}.png, web/favicon.png

Pure stdlib (zlib + struct) since no Pillow/ImageMagick is available in this
environment — see the git history of this file for why.

Fixes a real bug: app_icon_foreground.png had been regenerated (outside of
this script) at a scale/crop that dropped everything except the three-person
glyph — the crescent, dome and book were entirely missing from the Android
adaptive icon. This script re-derives the foreground from the known-good
flattened icon instead, sized to fit Android's adaptive safe zone.
"""
import glob
import math
import os
import struct
import zlib

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MASTER = os.path.join(REPO_ROOT, 'assets/images/app_icon.png')

BG_COLOR = (14, 124, 96)  # matches AppColors.primaryDeep; sampled from the master.
WHITE = (255, 255, 255)

# Android adaptive icons render only the centered 66%-diameter circle of the
# 108dp foreground/background layers reliably across launchers (masks vary
# shape, but all guarantee that circle) - https://developer.android.com/develop/ui/views/launch/icon_design_adaptive
ADAPTIVE_SAFE_RADIUS_RATIO = 0.33
# PWA maskable icons guarantee a centered 80%-diameter safe zone.
MASKABLE_SAFE_RADIUS_RATIO = 0.40


# ---------------------------------------------------------------------------
# Minimal PNG codec (read RGB/RGBA, write RGBA), pure stdlib.
# ---------------------------------------------------------------------------

def _unfilter(raw, w, h, bpp):
    stride = w * bpp
    prev = bytearray(stride)
    rows = []
    idx = 0
    for _ in range(h):
        filt = raw[idx]
        idx += 1
        row = bytearray(raw[idx:idx + stride])
        idx += stride
        if filt == 1:
            for i in range(stride):
                a = row[i - bpp] if i >= bpp else 0
                row[i] = (row[i] + a) & 0xFF
        elif filt == 2:
            for i in range(stride):
                row[i] = (row[i] + prev[i]) & 0xFF
        elif filt == 3:
            for i in range(stride):
                a = row[i - bpp] if i >= bpp else 0
                row[i] = (row[i] + ((a + prev[i]) // 2)) & 0xFF
        elif filt == 4:
            for i in range(stride):
                a = row[i - bpp] if i >= bpp else 0
                b = prev[i]
                c = prev[i - bpp] if i >= bpp else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                row[i] = (row[i] + pr) & 0xFF
        rows.append(row)
        prev = row
    return rows


def read_png_rgba(path):
    """Returns (w, h, pixels) where pixels[y][x] = (r, g, b, a)."""
    with open(path, 'rb') as f:
        data = f.read()
    pos = 8
    idat = b''
    w = h = bpp = color_type = None
    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos + 4])[0]
        tag = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + length]
        if tag == b'IHDR':
            w, h, bd, color_type = struct.unpack('>IIBB', chunk[0:10])
            bpp = {2: 3, 6: 4, 0: 1}[color_type]
        if tag == b'IDAT':
            idat += chunk
        pos += 8 + length + 4
    rows = _unfilter(zlib.decompress(idat), w, h, bpp)
    pixels = []
    for row in rows:
        line = []
        for x in range(w):
            o = x * bpp
            if bpp == 4:
                line.append((row[o], row[o + 1], row[o + 2], row[o + 3]))
            elif bpp == 3:
                line.append((row[o], row[o + 1], row[o + 2], 255))
            else:
                v = row[o]
                line.append((v, v, v, 255))
        pixels.append(line)
    return w, h, pixels


def _chunk(tag, data):
    return (
        struct.pack('>I', len(data)) + tag + data
        + struct.pack('>I', zlib.crc32(tag + data) & 0xFFFFFFFF)
    )


def write_png_rgba(path, w, h, pixels):
    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        row = pixels[y]
        for x in range(w):
            raw.extend(row[x])
    idat = zlib.compress(bytes(raw), 9)
    with open(path, 'wb') as f:
        f.write(sig)
        f.write(_chunk(b'IHDR', ihdr))
        f.write(_chunk(b'IDAT', idat))
        f.write(_chunk(b'IEND', b''))


# ---------------------------------------------------------------------------
# Glyph extraction + resampling.
# ---------------------------------------------------------------------------

def load_glyph_alpha(master_path):
    """Reads the flattened master and returns (w, h, alpha) where alpha[y][x]
    is the glyph's opacity (0..255) at that pixel — 255 on pure white glyph,
    0 on pure background green, interpolated across anti-aliased edges."""
    w, h, pixels = read_png_rgba(master_path)
    span = [WHITE[i] - BG_COLOR[i] for i in range(3)]
    alpha = [[0] * w for _ in range(h)]
    for y in range(h):
        row = pixels[y]
        out = alpha[y]
        for x in range(w):
            r, g, b, _ = row[x]
            # Project onto the green->white axis; every real pixel in this
            # flat, two-tone glyph lies on (or extremely near) that line.
            t = sum((row[x][i] - BG_COLOR[i]) * span[i] for i in range(3)) / sum(s * s for s in span)
            out[x] = max(0, min(255, round(t * 255)))
    return w, h, alpha


def glyph_bounds(w, h, alpha, threshold=32):
    xmin, xmax, ymin, ymax = w, -1, h, -1
    for y in range(h):
        row = alpha[y]
        for x in range(w):
            if row[x] >= threshold:
                if x < xmin:
                    xmin = x
                if x > xmax:
                    xmax = x
                if y < ymin:
                    ymin = y
                if y > ymax:
                    ymax = y
    return xmin, ymin, xmax, ymax


def farthest_corner_radius(cx, cy, xmin, ymin, xmax, ymax):
    corners = [(xmin, ymin), (xmax, ymin), (xmin, ymax), (xmax, ymax)]
    return max(math.hypot(px - cx, py - cy) for px, py in corners)


def resample_alpha(src_w, src_h, src_alpha, dst_size, scale, offset_x, offset_y):
    """Nearest-with-2x2-supersample resample of the alpha mask into a
    dst_size x dst_size canvas. (sx, sy) = ((dx - offset_x) / scale, ...)
    maps a destination pixel back into source space."""
    dst = [[0] * dst_size for _ in range(dst_size)]
    for dy in range(dst_size):
        row = dst[dy]
        for dx in range(dst_size):
            total = 0
            for oy in (0.25, 0.75):
                sy = (dy + oy - offset_y) / scale
                if sy < 0 or sy >= src_h - 1:
                    continue
                y0 = int(sy)
                fy = sy - y0
                for ox in (0.25, 0.75):
                    sx = (dx + ox - offset_x) / scale
                    if sx < 0 or sx >= src_w - 1:
                        continue
                    x0 = int(sx)
                    fx = sx - x0
                    a00 = src_alpha[y0][x0]
                    a10 = src_alpha[y0][x0 + 1]
                    a01 = src_alpha[y0 + 1][x0]
                    a11 = src_alpha[y0 + 1][x0 + 1]
                    a = (a00 * (1 - fx) + a10 * fx) * (1 - fy) + (a01 * (1 - fx) + a11 * fx) * fy
                    total += a
            row[dx] = round(total / 4)
    return dst


def alpha_to_rgba(alpha, size, color):
    pixels = []
    for y in range(size):
        row = alpha[y]
        pixels.append([(color[0], color[1], color[2], row[x]) for x in range(size)])
    return pixels


def composite_on_bg(alpha, size, fg_color, bg_color):
    pixels = []
    for y in range(size):
        row = alpha[y]
        line = []
        for x in range(size):
            t = row[x] / 255.0
            r = round(bg_color[0] + (fg_color[0] - bg_color[0]) * t)
            g = round(bg_color[1] + (fg_color[1] - bg_color[1]) * t)
            b = round(bg_color[2] + (fg_color[2] - bg_color[2]) * t)
            line.append((r, g, b, 255))
        pixels.append(line)
    return pixels


def solid(size, color):
    row = [(*color, 255)] * size
    return [list(row) for _ in range(size)]


def downsample_box(pixels, src_size, dst_size):
    """Simple box-filter downsample (also handles upsampling via nearest)."""
    if dst_size == src_size:
        return pixels
    out = []
    for dy in range(dst_size):
        y0 = dy * src_size / dst_size
        y1 = (dy + 1) * src_size / dst_size
        line = []
        for dx in range(dst_size):
            x0 = dx * src_size / dst_size
            x1 = (dx + 1) * src_size / dst_size
            if dst_size < src_size:
                # Average source pixels covered by this destination cell.
                iy0, iy1 = int(y0), max(int(math.ceil(y1)), int(y0) + 1)
                ix0, ix1 = int(x0), max(int(math.ceil(x1)), int(x0) + 1)
                iy1 = min(iy1, src_size)
                ix1 = min(ix1, src_size)
                rs = gs = bs = as_ = n = 0
                for sy in range(iy0, iy1):
                    row = pixels[sy]
                    for sx in range(ix0, ix1):
                        r, g, b, a = row[sx]
                        rs += r
                        gs += g
                        bs += b
                        as_ += a
                        n += 1
                line.append((round(rs / n), round(gs / n), round(bs / n), round(as_ / n)))
            else:
                sx = min(int(x0), src_size - 1)
                sy = min(int(y0), src_size - 1)
                line.append(pixels[sy][sx])
        out.append(line)
    return out


# ---------------------------------------------------------------------------
# Output targets.
# ---------------------------------------------------------------------------

ANDROID_MIPMAP_SIZES = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
ANDROID_ADAPTIVE_SIZES = {'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432}
IOS_SIZES = {
    'Icon-App-20x20@1x.png': 20, 'Icon-App-20x20@2x.png': 40, 'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29, 'Icon-App-29x29@2x.png': 58, 'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40, 'Icon-App-40x40@2x.png': 80, 'Icon-App-40x40@3x.png': 120,
    'Icon-App-50x50@1x.png': 50, 'Icon-App-50x50@2x.png': 100,
    'Icon-App-57x57@1x.png': 57, 'Icon-App-57x57@2x.png': 114,
    'Icon-App-60x60@2x.png': 120, 'Icon-App-60x60@3x.png': 180,
    'Icon-App-72x72@1x.png': 72, 'Icon-App-72x72@2x.png': 144,
    'Icon-App-76x76@1x.png': 76, 'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
}


def main():
    w, h, alpha = load_glyph_alpha(MASTER)
    cx, cy = w / 2, h / 2
    xmin, ymin, xmax, ymax = glyph_bounds(w, h, alpha)
    r_flat = farthest_corner_radius(cx, cy, xmin, ymin, xmax, ymax)
    print(f'master glyph bbox: ({xmin},{ymin})-({xmax},{ymax}), '
          f'farthest-corner radius {r_flat:.1f}px of {w}px canvas')

    images_dir = os.path.join(REPO_ROOT, 'assets/images')

    # --- Flattened icon (legacy Android + iOS + web): master, unchanged. ---
    flat_rgba = composite_on_bg(alpha, w, WHITE, BG_COLOR)

    # --- Adaptive background: flat brand color, full bleed. ---
    bg_rgba = solid(w, BG_COLOR)
    write_png_rgba(os.path.join(images_dir, 'app_icon_background.png'), w, h, bg_rgba)

    # --- Adaptive foreground: glyph rescaled to fit the safe-zone circle. ---
    safe_r = ADAPTIVE_SAFE_RADIUS_RATIO * w
    margin = 0.92  # keep a small cushion inside the guaranteed-visible circle
    scale = (safe_r * margin) / r_flat
    offset = cx - cx * scale  # keep the glyph's own center pinned to canvas center
    fg_alpha = resample_alpha(w, h, alpha, w, scale, offset, offset)
    fxmin, fymin, fxmax, fymax = glyph_bounds(w, h, fg_alpha)
    fr = farthest_corner_radius(cx, cy, fxmin, fymin, fxmax, fymax)
    print(f'adaptive foreground: scale {scale:.3f}, resulting farthest-corner '
          f'radius {fr:.1f}px (safe circle {safe_r:.1f}px)')
    assert fr <= safe_r, 'adaptive foreground glyph escapes the safe zone'
    fg_rgba = alpha_to_rgba(fg_alpha, w, WHITE)
    write_png_rgba(os.path.join(images_dir, 'app_icon_foreground.png'), w, h, fg_rgba)
    write_png_rgba(MASTER, w, h, flat_rgba)  # re-save master (no-op if already flattened)

    # --- Android legacy mipmap + adaptive drawables, all densities. ---
    android_res = os.path.join(REPO_ROOT, 'android/app/src/main/res')
    for density, size in ANDROID_MIPMAP_SIZES.items():
        out = downsample_box(flat_rgba, w, size)
        write_png_rgba(os.path.join(android_res, f'mipmap-{density}', 'ic_launcher.png'), size, size, out)
    for density, size in ANDROID_ADAPTIVE_SIZES.items():
        bg_out = downsample_box(bg_rgba, w, size)
        fg_out = downsample_box(fg_rgba, w, size)
        write_png_rgba(os.path.join(android_res, f'drawable-{density}', 'ic_launcher_background.png'), size, size, bg_out)
        write_png_rgba(os.path.join(android_res, f'drawable-{density}', 'ic_launcher_foreground.png'), size, size, fg_out)

    # --- iOS AppIcon.appiconset. ---
    ios_dir = os.path.join(REPO_ROOT, 'ios/Runner/Assets.xcassets/AppIcon.appiconset')
    for filename, size in IOS_SIZES.items():
        out = downsample_box(flat_rgba, w, size)
        write_png_rgba(os.path.join(ios_dir, filename), size, size, out)

    # --- Web: plain icons match the flat glyph; maskable icons get their
    # own (looser) safe-zone treatment since they're a single composited
    # image rather than separate launcher layers. ---
    web_icons_dir = os.path.join(REPO_ROOT, 'web/icons')
    for size in (192, 512):
        out = downsample_box(flat_rgba, w, size)
        write_png_rgba(os.path.join(web_icons_dir, f'Icon-{size}.png'), size, size, out)

    mask_safe_r = MASKABLE_SAFE_RADIUS_RATIO * w
    mask_scale = (mask_safe_r * margin) / r_flat
    mask_offset = cx - cx * mask_scale
    mask_alpha = resample_alpha(w, h, alpha, w, mask_scale, mask_offset, mask_offset)
    mask_rgba = composite_on_bg(mask_alpha, w, WHITE, BG_COLOR)
    for size in (192, 512):
        out = downsample_box(mask_rgba, w, size)
        write_png_rgba(os.path.join(web_icons_dir, f'Icon-maskable-{size}.png'), size, size, out)

    favicon_out = downsample_box(flat_rgba, w, 16)
    write_png_rgba(os.path.join(REPO_ROOT, 'web/favicon.png'), 16, 16, favicon_out)

    print('done')


if __name__ == '__main__':
    main()
