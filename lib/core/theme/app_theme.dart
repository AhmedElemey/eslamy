import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        scheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.goldDeep,
          onSecondary: AppColors.ink,
          tertiary: AppColors.primaryDeep,
          onTertiary: Colors.white,
          error: Color(0xFFB3261E),
          onError: Colors.white,
          surface: AppColors.surfaceLight,
          onSurface: AppColors.ink,
          outline: AppColors.hairlineLight,
          surfaceContainerHighest: AppColors.bgLightBottom,
        ),
        scaffold: AppColors.bgLight,
        divider: AppColors.hairlineLight,
        card: AppColors.surfaceLight,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primaryOnDark,
          onPrimary: AppColors.primaryDeepest,
          secondary: AppColors.gold,
          onSecondary: AppColors.primaryDeepest,
          tertiary: AppColors.primary,
          onTertiary: AppColors.inkDark,
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          surface: AppColors.surfaceDark,
          onSurface: AppColors.inkDark,
          outline: AppColors.hairlineDark,
          surfaceContainerHighest: Color(0xFF1C2A26),
        ),
        scaffold: AppColors.bgDark,
        divider: AppColors.hairlineDark,
        card: AppColors.surfaceDark,
      );

  /// Transparent system bars so the page background fills the Android
  /// gesture-nav inset instead of showing a black window behind it
  /// (edge-to-edge default on recent Flutter/Android).
  static SystemUiOverlayStyle overlayFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffold,
    required Color divider,
    required Color card,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.ui,
      fontFamilyFallback: const [AppTypography.arabic],
      textTheme: AppTypography.textTheme(scheme),
      scaffoldBackgroundColor: scaffold,
      cardColor: card,
      dividerColor: divider,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: overlayFor(brightness),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.ui,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        elevation: 0,
        height: 68,
        indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.18 : 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: AppTypography.ui,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? scheme.primary : AppColors.mutedTextFrom(isDark),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? scheme.primary : AppColors.mutedTextFrom(isDark),
          );
        }),
      ),
      chipTheme: ChipThemeData(
        selectedColor: scheme.primary,
        backgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.bgLightBottom,
        labelStyle: TextStyle(
          fontFamily: AppTypography.ui,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: AppTypography.ui,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        side: BorderSide(color: divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.surfaceLight,
        hintStyle: TextStyle(color: AppColors.mutedTextFrom(isDark)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontFamily: AppTypography.ui,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.ink,
        contentTextStyle: const TextStyle(
          fontFamily: AppTypography.ui,
          color: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: isDark ? AppColors.primaryDeepest : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      dividerTheme: DividerThemeData(color: divider, space: 1, thickness: 1),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.ui,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}
