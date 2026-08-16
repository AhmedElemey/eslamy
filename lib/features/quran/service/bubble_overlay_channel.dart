import 'package:flutter/services.dart';

/// Bridge to BubbleOverlayService.kt — the Android-only floating playback
/// bubble. A native `WindowManager` overlay, not a second Flutter engine, so
/// it doesn't hit the Flutter engine bug that made `flutter_overlay_window`'s
/// secondary-isolate content permanently blank. Interaction (tap to open the
/// app, drag-to-bottom to stop) is handled entirely in Kotlin; this channel
/// only starts/stops the overlay and checks/requests the one permission it
/// needs.
class BubbleOverlayChannel {
  BubbleOverlayChannel._();

  static const MethodChannel _channel = MethodChannel('com.eslamy.eslamy/bubble');

  static Future<bool> hasOverlayPermission() async =>
      (await _channel.invokeMethod<bool>('hasOverlayPermission')) ?? false;

  static Future<void> requestOverlayPermission() =>
      _channel.invokeMethod('requestOverlayPermission');

  static Future<void> show() => _channel.invokeMethod('showBubble');

  static Future<void> hide() => _channel.invokeMethod('hideBubble');
}
