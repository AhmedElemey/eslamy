import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Full-bleed gradient background used behind every scaffold — the
/// deep navy-to-violet gradient in dark mode, a soft warm off-white in
/// light mode. Wrap a Scaffold's body (with the Scaffold itself set to
/// transparent) so the gradient shows through the app bar area too.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  AppColors.bgDarkTop,
                  AppColors.bgDarkMid,
                  AppColors.bgDarkBottom,
                ]
              : const [AppColors.bgLightTop, AppColors.bgLightBottom],
        ),
      ),
      child: child,
    );
  }
}
