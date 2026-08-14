import '../../../../core/localization/app_localizations.dart';

/// Prayer names from [PrayerTimesService] are fixed English tokens also used
/// as lookup keys (e.g. into an icon map) — translate only for display.
String localizedPrayerName(AppLocalizations l10n, String prayerKey) {
  switch (prayerKey) {
    case 'Fajr':
      return l10n.prayerFajr;
    case 'Sunrise':
      return l10n.prayerSunrise;
    case 'Dhuhr':
      return l10n.prayerDhuhr;
    case 'Asr':
      return l10n.prayerAsr;
    case 'Maghrib':
      return l10n.prayerMaghrib;
    case 'Isha':
      return l10n.prayerIsha;
    default:
      return prayerKey;
  }
}
