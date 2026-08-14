import '../../../core/localization/app_localizations.dart';

/// Fixed Hijri-calendar occasions. Deliberately not sourced from AlAdhan's
/// per-day `holidays` field, which also lists minor/regional observances —
/// this is a small curated list of the major ones apps commonly surface.
class IslamicHoliday {
  final String nameEn;
  final String Function(AppLocalizations l10n) localizedName;
  final int hijriDay;
  final int hijriMonth;

  const IslamicHoliday({
    required this.nameEn,
    required this.localizedName,
    required this.hijriDay,
    required this.hijriMonth,
  });
}

const List<IslamicHoliday> islamicHolidays = [
  IslamicHoliday(
    nameEn: 'Islamic New Year',
    localizedName: _islamicNewYear,
    hijriDay: 1,
    hijriMonth: 1,
  ),
  IslamicHoliday(
    nameEn: 'Day of Ashura',
    localizedName: _dayOfAshura,
    hijriDay: 10,
    hijriMonth: 1,
  ),
  IslamicHoliday(
    nameEn: "Mawlid al-Nabi (Prophet's Birthday)",
    localizedName: _mawlidAlNabi,
    hijriDay: 12,
    hijriMonth: 3,
  ),
  IslamicHoliday(
    nameEn: 'Start of Ramadan',
    localizedName: _startOfRamadan,
    hijriDay: 1,
    hijriMonth: 9,
  ),
  IslamicHoliday(
    nameEn: 'Laylat al-Qadr (est.)',
    localizedName: _laylatAlQadr,
    hijriDay: 27,
    hijriMonth: 9,
  ),
  IslamicHoliday(
    nameEn: 'Eid al-Fitr',
    localizedName: _eidAlFitr,
    hijriDay: 1,
    hijriMonth: 10,
  ),
  IslamicHoliday(
    nameEn: 'Day of Arafah',
    localizedName: _dayOfArafah,
    hijriDay: 9,
    hijriMonth: 12,
  ),
  IslamicHoliday(
    nameEn: 'Eid al-Adha',
    localizedName: _eidAlAdha,
    hijriDay: 10,
    hijriMonth: 12,
  ),
];

String _islamicNewYear(AppLocalizations l10n) => l10n.holidayIslamicNewYear;
String _dayOfAshura(AppLocalizations l10n) => l10n.holidayDayOfAshura;
String _mawlidAlNabi(AppLocalizations l10n) => l10n.holidayMawlidAlNabi;
String _startOfRamadan(AppLocalizations l10n) => l10n.holidayStartOfRamadan;
String _laylatAlQadr(AppLocalizations l10n) => l10n.holidayLaylatAlQadr;
String _eidAlFitr(AppLocalizations l10n) => l10n.holidayEidAlFitr;
String _dayOfArafah(AppLocalizations l10n) => l10n.holidayDayOfArafah;
String _eidAlAdha(AppLocalizations l10n) => l10n.holidayEidAlAdha;
