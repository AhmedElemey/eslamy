import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Elevated paper surface used for cards. Solid fill (no backdrop blur)
/// so contrast holds in both parchment light and ink-forest dark.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: radius,
        border: Border.all(color: AppColors.hairline(context)),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      ),
    );
  }
}
