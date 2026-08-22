import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Renders the widget wrapped by [boundaryKey] to a PNG and opens the
  /// native share sheet with it.
  static Future<void> shareWidgetAsImage(
    GlobalKey boundaryKey, {
    String? text,
  }) async {
    final boundary =
        boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final pngBytes = byteData.buffer.asUint8List();
    final file = await _writeTempPng(pngBytes);

    await Share.shareXFiles([XFile(file.path)], text: text);
  }

  static Future<File> _writeTempPng(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/eslamy_share_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    return file.writeAsBytes(bytes);
  }
}
