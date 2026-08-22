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

  /// Primary line is the current/next prayer (name, time); secondary is
  /// today's full schedule, so both the "what's next" and "what's the whole
  /// day" views the user asked for fit in the same kicker/primary/secondary
  /// shape every widget surface already renders. No countdown here — it
  /// made the line too long to fit on the narrower widget surfaces (the
  /// exact time is right there, and the Android Prayer card's schedule row
  /// already shows every prayer's time for the day).
  static WidgetContent? prayer(PrayerTimesState state, AppLocalizations l10n) {
    final timings = state.timings;
    final prayer = timings?.nextPrayer;
    if (timings == null || prayer == null) return null;
    return WidgetContent(
      kind: WidgetContentKind.prayer,
      kicker: l10n.widgetNextPrayerTitle,
      primary:
          '${localizedPrayerName(l10n, prayer.name)} · ${_formatTime(prayer.time, l10n)}',
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

  /// The 5 canonical daily prayers (Sunrise excluded) for the Android
  /// home-screen widget's dedicated schedule-row layout — see
  /// eslamy_widget_prayer_layout.xml. Returns null once no timings are
  /// loaded yet, same as [prayer].
  static List<PrayerScheduleEntry>? prayerSchedule(
    PrayerTimesState state,
    AppLocalizations l10n,
  ) {
    final timings = state.timings;
    if (timings == null) return null;
    final nextName = timings.nextPrayer?.name;
    return timings.prayers
        .where((p) => p.name != 'Sunrise')
        .map(
          (p) => PrayerScheduleEntry(
            name: localizedPrayerName(l10n, p.name),
            // No AM/PM suffix here (unlike _formatTime): 5 equal-width
            // columns don't have room for it, and the next-prayer line
            // right above already gives the day-half context.
            time: _formatTimeCompact(p.time),
            isNext: p.name == nextName,
          ),
        )
        .toList();
  }

  /// Today's real Gregorian date, compact enough for the Prayer card's
  /// header row (e.g. "Sat 22 Aug") — same weekday/month names already
  /// used for the full date in AppDrawer, just shortened to 3 characters
  /// so it fits next to the kicker without pushing the row's width budget
  /// over what a narrow widget can render without truncating.
  static String prayerDateCompact(AppLocalizations l10n) {
    final now = DateTime.now();
    final weekdays = [
      l10n.weekdayMonday,
      l10n.weekdayTuesday,
      l10n.weekdayWednesday,
      l10n.weekdayThursday,
      l10n.weekdayFriday,
      l10n.weekdaySaturday,
      l10n.weekdaySunday,
    ];
    final months = [
      l10n.monthJanuary,
      l10n.monthFebruary,
      l10n.monthMarch,
      l10n.monthApril,
      l10n.monthMay,
      l10n.monthJune,
      l10n.monthJuly,
      l10n.monthAugust,
      l10n.monthSeptember,
      l10n.monthOctober,
      l10n.monthNovember,
      l10n.monthDecember,
    ];
    return '${_short(weekdays[now.weekday - 1])} ${now.day} ${_short(months[now.month - 1])}';
  }

  static String _short(String s) => s.length <= 3 ? s : s.substring(0, 3);

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

  static String _formatTimeCompact(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
