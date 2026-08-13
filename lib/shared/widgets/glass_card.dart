import 'dart:ui';
import 'package:flutter/material.dart';

/// Frosted-glass surface: blurred backdrop + translucent gradient fill +
/// a thin light border. Used for the app's cards instead of flat
/// Colors.white/#1E1E1E containers so content reads as floating above the
/// gradient background rather than sitting in an opaque box.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);

    final content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.white.withOpacity(0.09), Colors.white.withOpacity(0.03)]
                  : [Colors.white.withOpacity(0.85), Colors.white.withOpacity(0.6)],
            ),
            borderRadius: radius,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.14) : Colors.white.withOpacity(0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return content;
    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}
