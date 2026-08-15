import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String ui = 'SourceSans3';
  static const String arabic = 'ScheherazadeNew';

  static TextTheme textTheme(ColorScheme scheme) {
    final onSurface = scheme.onSurface;
    return TextTheme(
      displaySmall: TextStyle(
        fontFamily: ui,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: onSurface,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontFamily: ui,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: onSurface,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        fontFamily: ui,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: ui,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: ui,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: ui,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontFamily: ui,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurface,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontFamily: ui,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onSurface.withValues(alpha: 0.72),
        height: 1.35,
      ),
      labelLarge: TextStyle(
        fontFamily: ui,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
    );
  }

  static TextStyle naskh({
    double size = 24,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.9,
  }) {
    return TextStyle(
      fontFamily: arabic,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  static TextStyle ayah(BuildContext context, {double size = 26}) {
    return naskh(
      size: size,
      weight: FontWeight.w400,
      color: AppColors.ayahText(context),
      height: 1.9,
    );
  }
}
