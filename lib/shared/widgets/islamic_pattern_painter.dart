import 'package:flutter/material.dart';

/// Subtle repeating 8-point-star geometric lattice — the classic Islamic
/// architectural motif (two overlapping squares, one rotated 45°) — drawn
/// as thin low-opacity strokes so it reads as texture, not decoration.
/// Used as a background layer behind gradient cards/headers.
class IslamicPatternOverlay extends StatelessWidget {
  const IslamicPatternOverlay({
    super.key,
    this.color = Colors.white,
    this.opacity = 0.08,
    this.tileSize = 44,
  });

  final Color color;
  final double opacity;
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _IslamicLatticePainter(
          color: color.withOpacity(opacity),
          tileSize: tileSize,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _IslamicLatticePainter extends CustomPainter {
  _IslamicLatticePainter({required this.color, required this.tileSize});

  final Color color;
  final double tileSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final half = tileSize / 2;
    for (double cy = 0; cy < size.height + tileSize; cy += tileSize) {
      for (double cx = 0; cx < size.width + tileSize; cx += tileSize) {
        canvas.save();
        canvas.translate(cx, cy);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: half, height: half), paint);
        canvas.rotate(0.7853981633974483); // 45°
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: half, height: half), paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicLatticePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.tileSize != tileSize;
}
