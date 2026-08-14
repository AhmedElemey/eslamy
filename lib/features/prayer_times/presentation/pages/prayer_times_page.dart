import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../controllers/prayer_times_providers.dart';
import '../widgets/prayer_name_localizer.dart';
import 'qibla_page.dart';

const _prayerIcons = {
  'Fajr': Icons.wb_twilight,
  'Sunrise': Icons.wb_sunny_outlined,
  'Dhuhr': Icons.light_mode,
  'Asr': Icons.sunny_snowing,
  'Maghrib': Icons.wb_twilight,
  'Isha': Icons.nights_stay,
};

class PrayerTimesPage extends ConsumerWidget {
  const PrayerTimesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimesProvider);
    final notifier = ref.read(prayerTimesProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.prayerTimesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore_outlined),
            tooltip: l10n.qiblaDirectionTooltip,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QiblaPage()),
              );
            },
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => notifier.load(requestFreshLocation: true),
            child: _buildBody(context, state, notifier),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PrayerTimesState state,
    PrayerTimesNotifier notifier,
  ) {
    if (state.isLoading && state.timings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.timings == null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Center(
            child: Text(
              context.l10n.failedToLoadPrayerTimesWithError(state.error.toString()),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () => notifier.load(requestFreshLocation: true),
              child: Text(context.l10n.retry),
            ),
          ),
        ],
      );
    }

    final timings = state.timings;
    if (timings == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF16231F);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        if (state.usingFallbackLocation)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_off, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.showingCairoFallback,
                    style: TextStyle(fontSize: 12, color: textColor),
                  ),
                ),
                TextButton(
                  onPressed: () => notifier.load(requestFreshLocation: true),
                  child: Text(context.l10n.enableButton),
                ),
              ],
            ),
          ),
        Center(
          child: Text(
            timings.hijriDate,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...timings.prayers.map((p) {
          final isNext = timings.nextPrayer?.name == p.name;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: isNext
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.violet],
                    )
                  : null,
              color: isNext
                  ? null
                  : (isDark ? Colors.white.withOpacity(0.04) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isNext
                    ? Colors.transparent
                    : (isDark ? Colors.white12 : Colors.black.withOpacity(0.06)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _prayerIcons[p.name] ?? Icons.access_time,
                  color: isNext ? Colors.white : AppColors.muted,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    localizedPrayerName(context.l10n, p.name),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                      color: isNext ? Colors.white : textColor,
                    ),
                  ),
                ),
                Text(
                  _formatTime(context, p.time),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                    color: isNext ? Colors.white : textColor,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const QiblaPage()),
            );
          },
          icon: const Icon(Icons.explore_outlined),
          label: Text(context.l10n.findQiblaDirection),
        ),
      ],
    );
  }

  String _formatTime(BuildContext context, DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? context.l10n.pmLabel : context.l10n.amLabel;
    return '$hour:$minute $period';
  }
}
