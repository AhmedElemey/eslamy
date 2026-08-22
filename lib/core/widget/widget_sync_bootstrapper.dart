import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/duas/data/models/azkar_models.dart';
import '../../features/duas/presentation/controllers/azkar_providers.dart';
import '../../features/hijri_calendar/presentation/controllers/hijri_calendar_providers.dart';
import '../../features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import '../../features/prayer_times/presentation/widgets/prayer_name_localizer.dart';
import '../../features/quran/models/ayah_of_the_day.dart';
import '../../features/quran/presentation/controllers/quran_providers.dart';
import '../localization/app_localizations.dart';
import '../localization/context_l10n_extension.dart';
import '../localization/display_names.dart';
import 'widget_data_service.dart';

/// Invisible widget that keeps the OS home-screen widget's data fresh
/// whenever the underlying prayer/ayah/dua providers resolve or change.
/// Mount once near the app root (MainShell) so it stays active app-wide.
class WidgetSyncBootstrapper extends ConsumerStatefulWidget {
  const WidgetSyncBootstrapper({super.key});

  @override
  ConsumerState<WidgetSyncBootstrapper> createState() =>
      _WidgetSyncBootstrapperState();
}

class _WidgetSyncBootstrapperState
    extends ConsumerState<WidgetSyncBootstrapper> {
  @override
  void initState() {
    super.initState();
    // ref.listen only fires on future changes, so anything already resolved
    // before this widget mounts (e.g. prayerTimesProvider, loaded elsewhere
    // earlier) would otherwise never reach the widget — push whatever's
    // already available once, after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = context.l10n;
      _pushPrayer(ref.read(prayerTimesProvider), l10n);
      ref.read(ayahOfTheDayProvider).whenData((a) => _pushAyah(a, l10n));
      ref.read(duaOfTheDayProvider).whenData((d) => _pushDua(d, l10n));
      _pushHijri(ref.read(hijriCalendarProvider), l10n);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(prayerTimesProvider, (previous, next) {
      _pushPrayer(next, l10n);
    });
    ref.listen(ayahOfTheDayProvider, (previous, next) {
      next.whenData((ayah) => _pushAyah(ayah, l10n));
    });
    ref.listen(duaOfTheDayProvider, (previous, next) {
      next.whenData((dua) => _pushDua(dua, l10n));
    });
    ref.listen(hijriCalendarProvider, (previous, next) {
      _pushHijri(next, l10n);
    });

    return const SizedBox.shrink();
  }

  void _pushPrayer(PrayerTimesState state, AppLocalizations l10n) {
    final prayer = state.timings?.nextPrayer;
    if (prayer == null) return;
    WidgetDataService.pushPrayer(
      kicker: l10n.widgetNextPrayerTitle,
      primary:
          '${localizedPrayerName(l10n, prayer.name)} · ${_formatTime(prayer.time, l10n)}',
      secondary: _countdown(prayer.time, l10n),
    );
  }

  void _pushAyah(AyahOfTheDay ayah, AppLocalizations l10n) {
    WidgetDataService.pushAyah(
      kicker: l10n.homeHighlightAyahOfDayTitle,
      primary: ayah.arabicText,
      secondary: ayah.translationText,
    );
  }

  void _pushDua(AzkarItem dua, AppLocalizations l10n) {
    WidgetDataService.pushDua(
      kicker: l10n.homeHighlightDuaOfDayTitle,
      primary: dua.arabic,
      secondary: dua.translation,
    );
  }

  void _pushHijri(HijriCalendarState state, AppLocalizations l10n) {
    final today = state.todayHijri;
    if (today == null) return;
    // The Lock Screen already shows the Gregorian date natively, so the
    // second line is more useful as the nearest upcoming occasion than a
    // repeat of information the OS already surfaces.
    final nextHoliday = state.upcoming.isEmpty ? null : state.upcoming.first;
    WidgetDataService.pushHijri(
      kicker: l10n.widgetHijriDateTitle,
      primary: localizedHijriDateAh(
        l10n,
        day: today.day,
        month: today.month,
        year: today.year,
      ),
      secondary:
          nextHoliday == null
              ? ''
              : '${nextHoliday.holiday.localizedName(l10n)} · ${_holidayCountdown(nextHoliday.daysRemaining, l10n)}',
    );
  }

  static String _holidayCountdown(int days, AppLocalizations l10n) {
    if (days == 0) return l10n.todayCountdown;
    if (days == 1) return l10n.tomorrowCountdown;
    return l10n.inDaysCountdown(days);
  }

  static String _formatTime(DateTime t, AppLocalizations l10n) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? l10n.pmLabel : l10n.amLabel;
    return '$hour:$minute $period';
  }

  static String _countdown(DateTime target, AppLocalizations l10n) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return l10n.countdownNow;
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h > 0) return l10n.countdownHoursMinutes(h, m);
    return l10n.countdownMinutes(m);
  }
}
