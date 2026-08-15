import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Filled circle with a progress ring traced around its edge — the visual
/// used by the Tasbih counter and the Tawaf/Sa'i counter.
class RingProgressPainter extends CustomPainter {
  RingProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius - 10, Paint()..color = fillColor);

    final rect = Rect.fromCircle(center: center, radius: radius - 4);
    final track =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    final sweep =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, sweep);
  }

  @override
  bool shouldRepaint(covariant RingProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}
