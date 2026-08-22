import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/duas/data/models/azkar_models.dart';
import '../../features/duas/presentation/controllers/azkar_providers.dart';
import '../../features/hijri_calendar/presentation/controllers/hijri_calendar_providers.dart';
import '../../features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import '../../features/quran/models/ayah_of_the_day.dart';
import '../../features/quran/presentation/controllers/quran_providers.dart';
import '../../features/settings/presentation/controllers/widget_preferences_providers.dart';
import '../localization/app_localizations.dart';
import '../localization/context_l10n_extension.dart';
import 'widget_content_builder.dart';
import 'widget_data_service.dart';

/// Invisible widget that keeps the OS home-screen widget's data fresh
/// whenever the underlying prayer/ayah/dua/hijri providers resolve or
/// change, and mirrors the user's on/off choice (WidgetCustomizationPage)
/// into the native-readable store. Mount once near the app root (MainShell)
/// so it stays active app-wide.
class WidgetSyncBootstrapper extends ConsumerStatefulWidget {
  const WidgetSyncBootstrapper({super.key});

  @override
  ConsumerState<WidgetSyncBootstrapper> createState() =>
      _WidgetSyncBootstrapperState();
}

class _WidgetSyncBootstrapperState
    extends ConsumerState<WidgetSyncBootstrapper> {
  Timer? _minuteTimer;

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
      ref
          .read(widgetPreferencesProvider)
          .whenData(WidgetDataService.pushEnabledKinds);
    });
    // prayerTimesProvider's state only changes when a fetch happens, but
    // "next prayer" and its countdown are true continuously — without this,
    // the widget would only catch up to a prayer boundary crossing (or a
    // ticking countdown) the next time the app happens to refetch. Only
    // covers the app-open window; Android/iOS both cap background widget
    // refresh well above one minute regardless of what any app requests.
    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      _pushPrayer(ref.read(prayerTimesProvider), context.l10n);
    });
  }

  @override
  void dispose() {
    _minuteTimer?.cancel();
    super.dispose();
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
    ref.listen(widgetPreferencesProvider, (previous, next) {
      next.whenData(WidgetDataService.pushEnabledKinds);
    });

    return const SizedBox.shrink();
  }

  void _pushPrayer(PrayerTimesState state, AppLocalizations l10n) {
    final content = WidgetContentBuilder.prayer(state, l10n);
    if (content == null) return;
    WidgetDataService.pushPrayer(
      kicker: content.kicker,
      primary: content.primary,
      secondary: content.secondary,
    );
    final schedule = WidgetContentBuilder.prayerSchedule(state, l10n);
    if (schedule != null) WidgetDataService.pushPrayerSchedule(schedule);
  }

  void _pushAyah(AyahOfTheDay ayah, AppLocalizations l10n) {
    final content = WidgetContentBuilder.ayah(ayah, l10n);
    WidgetDataService.pushAyah(
      kicker: content.kicker,
      primary: content.primary,
      secondary: content.secondary,
    );
  }

  void _pushDua(AzkarItem dua, AppLocalizations l10n) {
    final content = WidgetContentBuilder.dua(dua, l10n);
    WidgetDataService.pushDua(
      kicker: content.kicker,
      primary: content.primary,
      secondary: content.secondary,
    );
  }

  void _pushHijri(HijriCalendarState state, AppLocalizations l10n) {
    final content = WidgetContentBuilder.hijri(state, l10n);
    if (content == null) return;
    WidgetDataService.pushHijri(
      kicker: content.kicker,
      primary: content.primary,
      secondary: content.secondary,
    );
  }
}
