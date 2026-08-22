import 'package:flutter/material.dart';

/// Brand + semantic tokens. Emerald and gold only — no third hue.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1A9B76);
  static const Color primaryOnDark = Color(0xFF3EC9A0);
  static const Color primaryDeep = Color(0xFF0E7C60);
  static const Color primaryDeepest = Color(0xFF0B3D32);

  static const Color gold = Color(0xFFE8C170);
  static const Color goldDeep = Color(0xFFC49A3C);

  static const Color ink = Color(0xFF1C2A26);
  static const Color inkDark = Color(0xFFE8EEEB);
  static const Color ayahDark = Color(0xFFE4E0D4);

  static const Color mutedLight = Color(0xFF6B736F);
  static const Color mutedDark = Color(0xFF9AA8A3);

  /// Legacy alias used by older screens; prefer [mutedText].
  static const Color muted = mutedLight;

  static const Color bgLight = Color(0xFFF7F3EA);
  static const Color bgLightBottom = Color(0xFFF1EBE0);
  static const Color surfaceLight = Color(0xFFFFFCF6);
  static const Color hairlineLight = Color(0xFFE6DFD2);

  static const Color bgDark = Color(0xFF0C1614);
  static const Color bgDarkBottom = Color(0xFF12201C);
  static const Color surfaceDark = Color(0xFF16211E);
  static const Color hairlineDark = Color(0x14FFFFFF);

  static const Color success = Color(0xFF2E8B57);
  static const Color white = Colors.white;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color heading(BuildContext context) => isDark(context) ? inkDark : ink;

  static Color mutedText(BuildContext context) =>
      isDark(context) ? mutedDark : mutedLight;

  static Color mutedTextFrom(bool dark) => dark ? mutedDark : mutedLight;

  static Color surface(BuildContext context) =>
      isDark(context) ? surfaceDark : surfaceLight;

  static Color hairline(BuildContext context) =>
      isDark(context) ? hairlineDark : hairlineLight;

  static Color goldAccent(BuildContext context) =>
      isDark(context) ? gold : goldDeep;

  static Color primaryOnBg(BuildContext context) =>
      isDark(context) ? primaryOnDark : primary;

  static Color ayahText(BuildContext context) =>
      isDark(context) ? ayahDark : ink;

  static Color pageBackground(BuildContext context) =>
      isDark(context) ? bgDark : bgLight;

  static List<Color> pageGradient(BuildContext context) =>
      isDark(context)
          ? const [bgDark, bgDarkBottom]
          : const [bgLight, bgLightBottom];

  static List<Color> heroGradient(BuildContext context) =>
      isDark(context)
          ? const [primaryDeepest, primaryDeep, primary]
          : const [primaryDeep, primary];
}
