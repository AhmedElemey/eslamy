#!/usr/bin/env python3
"""Generates the app icon assets as flat PNGs, matching the app's own brand
gradient (AppColors.primaryDeep -> primary -> violet) with a bold, simplified
mosque silhouette (dome + two minarets + base — no fine architectural detail,
which would turn to mush at actual icon sizes). Pure stdlib (zlib + struct)
since no PIL/ImageMagick is available in this environment, and Flutter's
headless test renderer produced blank frames here (`toImage()` returned fully
transparent pixels even via the blessed `matchesGoldenFile` path) — safer/
faster to compute pixels directly.

Outputs (consumed by flutter_launcher_icons via pubspec.yaml):
  assets/images/app_icon.png             flattened icon (iOS + legacy Android)
  assets/images/app_icon_background.png  Android adaptive icon background
  assets/images/app_icon_foreground.png  Android adaptive icon foreground
"""
import math
import struct
import zlib

CANVAS = 1024

# AppColors (lib/core/theme/app_colors.dart)
PRIMARY_DEEP = (14, 124, 96)
PRIMARY = (31, 174, 133)
VIOLET = (108, 77, 255)


def lerp_channel(a, b, t):
    return round(a + (b - a) * t)


def lerp_color(c1, c2, t):
    return tuple(lerp_channel(c1[i], c2[i], t) for i in range(3))


def gradient_color(x, y, w, h):
    """Diagonal 3-stop gradient, top-left -> bottom-right, matching Flutter's
    LinearGradient(colors: [primaryDeep, primary, violet]) with default even
    stops (0, 0.5, 1)."""
    t = (x * w + y * h) / (w * w + h * h)
    t = max(0.0, min(1.0, t))
    if t <= 0.5:
        return lerp_color(PRIMARY_DEEP, PRIMARY, t / 0.5)
    return lerp_color(PRIMARY, VIOLET, (t - 0.5) / 0.5)


def dist(x, y, cx, cy):
    return math.hypot(x - cx, y - cy)


def in_rect(x, y, x0, y0, x1, y1):
    return x0 <= x <= x1 and y0 <= y <= y1


def in_taper(x, y, cx, y_bottom, y_top, half_w_bottom, half_w_top):
    """Trapezoid (or triangle, when half_w_top=0) between y_bottom (wider)
    and y_top (narrower), linearly interpolating half-width by height."""
    if not (y_top <= y <= y_bottom):
        return False
    t = (y_bottom - y) / (y_bottom - y_top)
    half_w = half_w_bottom + (half_w_top - half_w_bottom) * t
    return abs(x - cx) <= half_w


def make_glyph(cx, cy, r):
    """Precomputes a simplified mosque silhouette (base with an arched
    doorway cutout, an onion-domed drum, and two tapered minarets with
    conical caps) once per render, returning a predicate for whether a pixel
    is inside the glyph. Deliberately no window/brick detail beyond the
    single doorway — at real icon sizes (down to ~20px) fine ornament
    disappears or reads as noise; a few bold shapes stay legible at every
    size while still reading distinctly as a mosque, not a generic building."""
    # Base building.
    base_x0, base_x1 = cx - 0.62 * r, cx + 0.62 * r
    base_y0, base_y1 = cy + 0.05 * r, cy + 0.45 * r

    # Arched doorway, cut out of the base.
    arch_half_w = 0.09 * r
    arch_rect_y1 = base_y1 - 0.20 * r
    arch_circle_cy = arch_rect_y1

    def in_doorway(x, y):
        if in_rect(x, y, cx - arch_half_w, arch_rect_y1, cx + arch_half_w, base_y1):
            return True
        return y <= arch_circle_cy and dist(x, y, cx, arch_circle_cy) <= arch_half_w

    # Central drum + onion dome (circle capped with a tapered point).
    drum_x0, drum_x1 = cx - 0.16 * r, cx + 0.16 * r
    drum_y0, drum_y1 = base_y0 - 0.12 * r, base_y0
    dome_r = 0.22 * r
    dome_cx, dome_cy = cx, drum_y0 - dome_r * 0.65
    tip_base_y = dome_cy - dome_r * 0.7
    tip_apex_y = dome_cy - dome_r * 1.6
    tip_half_w = dome_r * 0.5

    # Two minarets flanking the base: tapered shaft + conical cap.
    minaret_shaft_bottom = base_y0
    minaret_shaft_top = base_y0 - 0.36 * r
    minaret_cap_apex = minaret_shaft_top - 0.14 * r
    shaft_hw_bottom, shaft_hw_top = 0.055 * r, 0.032 * r
    cap_hw_bottom = 0.048 * r
    left_cx = base_x0 + 0.11 * r
    right_cx = base_x1 - 0.11 * r

    def in_minaret(x, y, mcx):
        if in_taper(x, y, mcx, minaret_shaft_bottom, minaret_shaft_top, shaft_hw_bottom, shaft_hw_top):
            return True
        return in_taper(x, y, mcx, minaret_shaft_top, minaret_cap_apex, cap_hw_bottom, 0.0)

    def covers(x, y):
        if in_rect(x, y, base_x0, base_y0, base_x1, base_y1) and not in_doorway(x, y):
            return True
        if in_rect(x, y, drum_x0, drum_y0, drum_x1, drum_y1):
            return True
        if dist(x, y, dome_cx, dome_cy) <= dome_r:
            return True
        if in_taper(x, y, dome_cx, tip_base_y, tip_apex_y, tip_half_w, 0.0):
            return True
        if in_minaret(x, y, left_cx) or in_minaret(x, y, right_cx):
            return True
        return False

    return covers


def render(glyph_radius_ratio, with_background, out_path):
    """glyph_radius_ratio: glyph circle radius as a fraction of CANVAS/2.
    with_background: draw the brand gradient behind the glyph; when False the
    canvas is transparent (adaptive-icon foreground layer)."""
    w = h = CANVAS
    cx = cy = CANVAS / 2
    r = (CANVAS / 2) * glyph_radius_ratio
    covers = make_glyph(cx, cy, r)

    rows = []
    for y in range(h):
        row = bytearray(w * 4)
        for x in range(w):
            if with_background:
                col = gradient_color(x, y, w, h)
                a = 255
            else:
                col = (255, 255, 255)
                a = 0
            if covers(x, y):
                col = (255, 255, 255)
                a = 255
            i = x * 4
            row[i] = col[0]
            row[i + 1] = col[1]
            row[i + 2] = col[2]
            row[i + 3] = a
        rows.append(bytes(row))
    write_png(out_path, w, h, rows)


def render_background_only(out_path):
    w = h = CANVAS
    rows = []
    for y in range(h):
        row = bytearray(w * 4)
        for x in range(w):
            col = gradient_color(x, y, w, h)
            i = x * 4
            row[i], row[i + 1], row[i + 2], row[i + 3] = col[0], col[1], col[2], 255
        rows.append(bytes(row))
    write_png(out_path, w, h, rows)


def _chunk(tag, data):
    return (
        struct.pack('>I', len(data))
        + tag
        + data
        + struct.pack('>I', zlib.crc32(tag + data) & 0xFFFFFFFF)
    )


def write_png(path, w, h, rows):
    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)  # 6 = RGBA
    raw = bytearray()
    for row in rows:
        raw.append(0)  # filter type 0 (none) per scanline
        raw.extend(row)
    idat = zlib.compress(bytes(raw), 9)
    with open(path, 'wb') as f:
        f.write(sig)
        f.write(_chunk(b'IHDR', ihdr))
        f.write(_chunk(b'IDAT', idat))
        f.write(_chunk(b'IEND', b''))


if __name__ == '__main__':
    # Flattened icon: gradient + glyph, opaque. Glyph fills most of the
    # canvas since iOS/older-Android apply no extra safe-zone cropping.
    # (Mosque bounding box is ~1.24r wide x ~0.88r tall, unlike the old
    # crescent's simple 2r-diameter circle, so this ratio is tuned separately
    # to land at a similar ~62%-of-canvas visual weight.)
    render(1.0, with_background=True, out_path='assets/images/app_icon.png')

    # Adaptive icon background: gradient only, full bleed.
    render_background_only('assets/images/app_icon_background.png')

    # Adaptive icon foreground: glyph only, transparent. Android's safe zone
    # is a centered circle at 66% of canvas diameter (radius 0.33*CANVAS);
    # the mosque's farthest point (a base corner) sits at ~0.766r from
    # center, so ratio 0.75 keeps every corner comfortably inside it.
    render(0.75, with_background=False, out_path='assets/images/app_icon_foreground.png')

    print('done')
