import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: const Text('Qibla Direction')),
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
                            'Qibla direction unavailable\n${state.error ?? ''}',
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
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Waiting for compass sensor…\n(not available on all simulators)',
              textAlign: TextAlign.center,
            ),
          );
        }

        final heading = snapshot.data!.heading;
        if (heading == null) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This device has no compass sensor.',
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
              aligned ? 'Facing Qibla ✓' : 'Rotate to align',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: aligned ? Colors.green : AppColors.primary,
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
                    child: _CompassDial(qiblaDirection: qiblaDirection),
                  ),
                  Icon(
                    Icons.arrow_drop_up,
                    size: 40,
                    color: aligned ? Colors.green : Colors.grey[400],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Qibla bearing: ${qiblaDirection.round()}°  ·  Heading: ${heading.round()}°',
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        );
      },
    );
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({required this.qiblaDirection});

  final double qiblaDirection;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final label in const ['N', 'E', 'S', 'W'])
            _directionLabel(label),
          Transform.rotate(
            angle: qiblaDirection * (math.pi / 180),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Icon(Icons.mosque, color: AppColors.gold, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _directionLabel(String label) {
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
                color: label == 'N' ? AppColors.primary : AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
