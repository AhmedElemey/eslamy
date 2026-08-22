import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

/// Small fixed palette so each reciter gets a consistent, distinct color
/// (by id), used as the fallback avatar for any reciter with no entry in
/// [_reciterPhotoAssets] below.
const List<int> _reciterAvatarPalette = [
  0xFF1A9B76, // primary green
  0xFFC49A3C, // gold
  0xFF2E6F95, // teal blue
  0xFF8B5E3C, // warm brown
  0xFF6B4C9A, // muted purple
  0xFF3E8E7E, // sea green
  0xFFB0553F, // terracotta
  0xFF4B6584, // slate blue
];

Color reciterAvatarColor(int reciterId) =>
    Color(_reciterAvatarPalette[reciterId % _reciterAvatarPalette.length]);

/// First letter of the first two words of [name] (e.g. "Mishary Rashid
/// Alafasy" -> "MR"), falling back to a single letter or "?" for edge cases.
String reciterInitials(String name) {
  final words =
      name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
  return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
}

/// Real photos, sourced from Wikimedia Commons under a permissive license
/// (see `assets/images/reciters/NOTICE.md` for attribution). Keyed by the
/// reciter id used throughout `QuranAudioService`. Reciters not listed here
/// have no clearly-licensed photo available and fall back to the generated
/// initials avatar.
const Map<int, String> _reciterPhotoAssets = {
  4: 'assets/images/reciters/4.jpg',
  5: 'assets/images/reciters/5.png',
  6: 'assets/images/reciters/6.jpg',
  8: 'assets/images/reciters/8.jpg',
  9: 'assets/images/reciters/9.png',
  11: 'assets/images/reciters/11.png',
  12: 'assets/images/reciters/12.jpg',
  13: 'assets/images/reciters/13.jpg',
  14: 'assets/images/reciters/14.png',
  16: 'assets/images/reciters/16.jpg',
  19: 'assets/images/reciters/19.png',
  22: 'assets/images/reciters/22.jpg',
  24: 'assets/images/reciters/24.jpg',
  25: 'assets/images/reciters/25.jpg',
  28: 'assets/images/reciters/28.jpg',
  29: 'assets/images/reciters/29.jpg',
};

/// The asset path for [reciterId]'s real photo, or null if none is
/// available (in which case callers should fall back to the initials
/// avatar via [reciterAvatarColor]/[reciterInitials]).
String? reciterPhotoAsset(int reciterId) => _reciterPhotoAssets[reciterId];

// Caches the in-flight *Future*, not just its eventual result. Rapid
// "next"/"previous" taps for a reciter whose art hasn't been generated yet
// (e.g. right after selecting them) each call this function before the
// first call finishes — without memoizing the Future itself, every one of
// those calls would independently decode the image and write to the same
// cache file at the same time, and the resulting write/read race threw an
// uncaught FileSystemException that aborted playback silently. Memoizing
// the Future means every concurrent caller awaits the exact same operation.
final Map<int, Future<Uri>> _reciterArtCache = {};

/// Renders the same avatar shown in the reciter picker (real photo if
/// [reciterPhotoAsset] has one, otherwise the color+initials avatar) to a
/// PNG file and returns its `file://` URI, for use as [MediaItem.artUri] —
/// the OS media notification needs an actual image resource, not a widget.
/// Cached per reciter both in-memory and on disk (persists across launches).
Future<Uri> reciterAvatarArtUri(int reciterId, String name) {
  final cached = _reciterArtCache[reciterId];
  if (cached != null) return cached;

  final future = _generateReciterAvatarArt(reciterId, name);
  _reciterArtCache[reciterId] = future;
  // Don't leave a failed attempt cached forever — let the next call retry.
  // (A separate listener, not the future itself: the caller below still
  // sees and can handle the original error.)
  future.then(
    (_) {},
    onError: (Object _) => _reciterArtCache.remove(reciterId),
  );
  return future;
}

Future<Uri> _generateReciterAvatarArt(int reciterId, String name) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/reciter_avatar_$reciterId.png');
  if (await file.exists()) {
    return file.uri;
  }

  const double size = 256;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final photoAsset = _reciterPhotoAssets[reciterId];
  if (photoAsset != null) {
    final data = await rootBundle.load(photoAsset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final photo = (await codec.getNextFrame()).image;

    // Cover-fit crop: the largest centered square from the source photo,
    // scaled to fill the circular canvas.
    final srcSize =
        photo.width < photo.height
            ? photo.width.toDouble()
            : photo.height.toDouble();
    final srcRect = Rect.fromCenter(
      center: Offset(photo.width / 2, photo.height / 2),
      width: srcSize,
      height: srcSize,
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(const Rect.fromLTWH(0, 0, size, size)));
    canvas.drawImageRect(
      photo,
      srcRect,
      const Rect.fromLTWH(0, 0, size, size),
      Paint(),
    );
    canvas.restore();
  } else {
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      Paint()..color = reciterAvatarColor(reciterId),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: reciterInitials(name),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );
  }

  final image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  await file.writeAsBytes(byteData!.buffer.asUint8List(), flush: true);

  return file.uri;
}
