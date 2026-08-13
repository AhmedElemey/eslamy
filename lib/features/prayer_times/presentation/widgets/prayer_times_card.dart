import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/prayer_times_providers.dart';
import '../pages/prayer_times_page.dart';

class PrayerTimesCard extends ConsumerStatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  ConsumerState<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends ConsumerState<PrayerTimesCard> {
  // Ticks every 30s so the countdown text stays roughly live. The empty
  // setState triggers build() -> _buildContent(), which recomputes
  // _countdown() from DateTime.now() on every rebuild — no separate stream
  // or listener is needed for the text itself to refresh.
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerTimesProvider);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PrayerTimesPage()),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDeep, AppColors.primary, AppColors.violet],
                    stops: [0, 0.55, 1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Ambient glow accents — purely decorative depth, clipped by
            // the parent ClipRRect so they never bleed outside the card.
            Positioned(
              top: -40,
              right: -30,
              child: _glowCircle(120, AppColors.gold.withOpacity(0.35)),
            ),
            Positioned(
              bottom: -50,
              left: -20,
              child: _glowCircle(110, Colors.white.withOpacity(0.12)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: _buildContent(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }

  Widget _buildContent(PrayerTimesState state) {
    if (state.isLoading && state.timings == null) {
      return const SizedBox(
        height: 88,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (state.error != null && state.timings == null) {
      return Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Couldn\'t load prayer times',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(prayerTimesProvider.notifier).load(),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    final timings = state.timings;
    if (timings == null) return const SizedBox.shrink();

    final next = timings.nextPrayer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: const Icon(Icons.mosque, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              next == null ? 'ALL PRAYERS DONE' : 'NEXT PRAYER',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
        const SizedBox(height: 14),
        if (next == null)
          const Text(
            'Fajr resumes after midnight',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      next.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatTime(next.time),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _countdown(next.time),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _formatTime(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _countdown(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return 'now';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h > 0) return 'in ${h}h ${m}m';
    return 'in ${m}m';
  }
}
