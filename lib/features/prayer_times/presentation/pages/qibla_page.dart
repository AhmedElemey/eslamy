import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../controllers/prayer_times_providers.dart';

class QiblaPage extends ConsumerWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimesProvider);
    final qibla = state.qiblaDirection;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(context.l10n.qiblaDirectionTitle)),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child:
                qibla == null
                    ? state.isLoading
                        ? const CircularProgressIndicator()
                        : Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            context.l10n.qiblaUnavailableWithError(
                              state.error ?? '',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                    : _CompassView(qiblaDirection: qibla),
          ),
        ),
      ),
    );
  }
}

class _CompassView extends StatelessWidget {
  const _CompassView({required this.qiblaDirection});

  final double qiblaDirection;

  @override
  Widget build(BuildContext context) {
    // StreamBuilder owns the subscription to FlutterCompass.events and
    // cancels it automatically when this widget is disposed.
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              context.l10n.waitingForCompassSensor,
              textAlign: TextAlign.center,
            ),
          );
        }

        final heading = snapshot.data!.heading;
        if (heading == null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              context.l10n.noCompassSensor,
              textAlign: TextAlign.center,
            ),
          );
        }

        final relativeQibla = (qiblaDirection - heading) % 360;
        final aligned = relativeQibla < 6 || relativeQibla > 354;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              aligned ? context.l10n.facingQibla : context.l10n.rotateToAlign,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color:
                    aligned
                        ? AppColors.goldAccent(context)
                        : AppColors.primaryOnBg(context),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -heading * (math.pi / 180),
                    child: _CompassDial(
                      qiblaDirection: qiblaDirection,
                      aligned: aligned,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_up,
                    size: 48,
                    color:
                        aligned
                            ? AppColors.goldAccent(context)
                            : AppColors.primaryOnBg(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.qiblaBearingHeading(
                qiblaDirection.round().toString(),
                heading.round().toString(),
              ),
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        );
      },
    );
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({required this.qiblaDirection, required this.aligned});

  final double qiblaDirection;
  final bool aligned;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DialPainter(
        tickColor: AppColors.mutedText(context),
        rimColor:
            aligned
                ? AppColors.goldAccent(context)
                : AppColors.gold.withValues(alpha: 0.5),
        fillColor: AppColors.surface(context),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final label in const ['N', 'E', 'S', 'W'])
            _directionLabel(context, label),
          Transform.rotate(
            angle: qiblaDirection * (math.pi / 180),
            child: const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 24),
                child: Icon(Icons.mosque, color: AppColors.gold, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _directionLabel(BuildContext context, String label) {
    const angles = {'N': 0.0, 'E': 90.0, 'S': 180.0, 'W': 270.0};
    final angle = angles[label]! * (math.pi / 180);
    return Transform.rotate(
      angle: angle,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Transform.rotate(
            angle: -angle,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color:
                    label == 'N'
                        ? AppColors.primaryOnBg(context)
                        : AppColors.mutedText(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.tickColor,
    required this.rimColor,
    required this.fillColor,
  });

  final Color tickColor;
  final Color rimColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    canvas.drawCircle(center, radius, Paint()..color = fillColor);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = rimColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = alignedWidth,
    );
    for (var i = 0; i < 36; i++) {
      final major = i % 9 == 0;
      final angle = i * 10 * math.pi / 180;
      final inner = radius - (major ? 14 : 8);
      final p =
          Paint()
            ..color = tickColor.withValues(alpha: major ? 0.8 : 0.35)
            ..strokeWidth = major ? 2 : 1;
      canvas.drawLine(
        Offset(
          center.dx + inner * math.cos(angle),
          center.dy + inner * math.sin(angle),
        ),
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        p,
      );
    }
  }

  static const alignedWidth = 3.0;

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.rimColor != rimColor || oldDelegate.fillColor != fillColor;
}
