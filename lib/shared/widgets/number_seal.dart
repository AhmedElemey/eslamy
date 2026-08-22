import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Small emerald number seal used in lists instead of a two-hue gradient.
class NumberSeal extends StatelessWidget {
  const NumberSeal({super.key, required this.label, this.size = 36});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.33),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class IconSeal extends StatelessWidget {
  const IconSeal({
    super.key,
    required this.icon,
    this.size = 40,
    this.iconSize = 20,
  });

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: AppColors.primaryOnBg(context), size: iconSize),
    );
  }
}

/// Forward-disclosure chevron for list rows. `chevron_right_rounded` already
/// mirrors itself in RTL (it has `matchTextDirection: true`), so picking
/// `chevron_left_rounded` for RTL here would flip it a second time and point
/// the wrong way — always use the one icon and let Flutter mirror it.
IconData chevronFor(BuildContext context) => Icons.chevron_right_rounded;
