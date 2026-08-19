import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Full-bleed parchment / ink-forest background behind every scaffold.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.pageGradient(context),
          ),
        ),
        child: child,
      ),
    );
  }
}
