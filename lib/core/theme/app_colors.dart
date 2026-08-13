import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Warm emerald — the app's primary accent, replacing the old flat purple.
  static const Color primary = Color(0xFF1FAE85);
  static const Color primaryDeep = Color(0xFF0E7C60);
  static const Color gold = Color(0xFFE8C170);
  static const Color violet = Color(0xFF6C4DFF);

  static const Color muted = Color(0xFF8B96A5);
  static const Color white = Colors.white;

  // Dark-mode gradient background stops.
  static const Color bgDarkTop = Color(0xFF0A0F1C);
  static const Color bgDarkMid = Color(0xFF0F2027);
  static const Color bgDarkBottom = Color(0xFF1A1030);

  // Light-mode gradient background stops.
  static const Color bgLightTop = Color(0xFFFDFBF6);
  static const Color bgLightBottom = Color(0xFFEFF3EE);
}
