import '../../features/duas/data/models/azkar_models.dart';
import '../../features/hijri_calendar/presentation/controllers/hijri_calendar_providers.dart';
import '../../features/prayer_times/models/prayer_times.dart';
import '../../features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import '../../features/prayer_times/presentation/widgets/prayer_name_localizer.dart';
import '../../features/quran/models/ayah_of_the_day.dart';
import '../localization/app_localizations.dart';
import '../localization/display_names.dart';
import 'widget_content.dart';
import 'widget_content_kind.dart';

/// Turns the app's live feature state into the exact text the home/lock
/// screen widgets show. Kept separate from WidgetSyncBootstrapper (which
/// pushes this to the native widgets) so WidgetCustomizationPage can render
/// an in-app preview using the same formatting, without duplicating it.
class WidgetContentBuilder {
  WidgetContentBuilder._();

  /// Primary line is the current/next prayer (name, time, countdown);
  /// secondary is today's full schedule, so both the "what's next" and
  /// "what's the whole day" views the user asked for fit in the same
  /// kicker/primary/secondary shape every widget surface already renders.
  static WidgetContent? prayer(PrayerTimesState state, AppLocalizations l10n) {
    final timings = state.timings;
    final prayer = timings?.nextPrayer;
    if (timings == null || prayer == null) return null;
    return WidgetContent(
      kind: WidgetContentKind.prayer,
      kicker: l10n.widgetNextPrayerTitle,
      primary:
          '${localizedPrayerName(l10n, prayer.name)} · ${_formatTime(prayer.time, l10n)} · ${_countdown(prayer.time, l10n)}',
      secondary: _scheduleLine(timings.prayers, l10n),
    );
  }

  static String _scheduleLine(List<PrayerTime> prayers, AppLocalizations l10n) {
    return prayers
        .map(
          (p) =>
              '${localizedPrayerName(l10n, p.name)} ${_formatTime(p.time, l10n)}',
        )
        .join(' · ');
  }

  static WidgetContent ayah(AyahOfTheDay ayah, AppLocalizations l10n) =>
      WidgetContent(
        kind: WidgetContentKind.ayah,
        kicker: l10n.homeHighlightAyahOfDayTitle,
        primary: ayah.arabicText,
        secondary: ayah.translationText,
      );

  static WidgetContent dua(AzkarItem dua, AppLocalizations l10n) =>
      WidgetContent(
        kind: WidgetContentKind.dua,
        kicker: l10n.homeHighlightDuaOfDayTitle,
        primary: dua.arabic,
        secondary: dua.translation,
      );

  static WidgetContent? hijri(HijriCalendarState state, AppLocalizations l10n) {
    final today = state.todayHijri;
    if (today == null) return null;
    // The Lock Screen already shows the Gregorian date natively, so the
    // second line is more useful as the nearest upcoming occasion than a
    // repeat of information the OS already surfaces.
    final nextHoliday = state.upcoming.isEmpty ? null : state.upcoming.first;
    return WidgetContent(
      kind: WidgetContentKind.hijri,
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
