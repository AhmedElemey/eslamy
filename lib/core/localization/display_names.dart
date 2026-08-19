import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

bool isArabicLocale(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

String localizedChapterName({
  required BuildContext context,
  required String arabicName,
  required String englishName,
}) {
  return isArabicLocale(context) ? arabicName : englishName;
}

String localizedReciterName({
  required BuildContext context,
  required String arabicName,
  required String englishName,
}) {
  return isArabicLocale(context) ? arabicName : englishName;
}

String localizedReciterStyle(AppLocalizations l10n, String style) {
  return switch (style) {
    'Mujawwad (Melodic)' => l10n.reciterStyleMujawwadMelodic,
    'Murattal (Slow)' => l10n.reciterStyleMurattalSlow,
    'Modern' => l10n.reciterStyleModern,
    'Traditional' => l10n.reciterStyleTraditional,
    'Murattal' => l10n.reciterStyleMurattal,
    _ => style,
  };
}

String localizedDhikrName(AppLocalizations l10n, String id, String fallback) {
  return switch (id) {
    'subhanallah' => l10n.dhikrSubhanAllah,
    'alhamdulillah' => l10n.dhikrAlhamdulillah,
    'allahuakbar' => l10n.dhikrAllahuAkbar,
    'lailahaillallah' => l10n.dhikrLaIlahaIllaAllah,
    'astaghfirullah' => l10n.dhikrAstaghfirullah,
    'custom' => l10n.dhikrCustom,
    _ => fallback,
  };
}

String localizedTajweedRuleName(
  AppLocalizations l10n,
  String code,
  String fallback,
) {
  return switch (code) {
    'h' => l10n.tajweedHamzatUlWasl,
    's' => l10n.tajweedSilent,
    'l' => l10n.tajweedLamShamsiyyah,
    'n' => l10n.tajweedMaddaNormal,
    'p' => l10n.tajweedMaddaPermissible,
    'm' => l10n.tajweedMaddaNecessary,
    'q' => l10n.tajweedQalqalah,
    'o' => l10n.tajweedMaddaObligatory,
    'c' => l10n.tajweedIkhfaShafawi,
    'f' => l10n.tajweedIkhfa,
    'w' => l10n.tajweedIdghamShafawi,
    'i' => l10n.tajweedIqlab,
    'a' => l10n.tajweedIdghamGhunnah,
    'u' => l10n.tajweedIdghamNoGhunnah,
    'd' => l10n.tajweedIdghamMutajanisayn,
    'b' => l10n.tajweedIdghamMutaqaribayn,
    'g' => l10n.tajweedGhunnah,
    _ => fallback,
  };
}

String localizedHadithBookName(
  AppLocalizations l10n,
  String slug,
  String fallback,
) {
  return switch (slug) {
    'bukhari' => l10n.hadithBookBukhari,
    'muslim' => l10n.hadithBookMuslim,
    'abudawud' => l10n.hadithBookAbuDawud,
    'tirmidhi' => l10n.hadithBookTirmidhi,
    'nasai' => l10n.hadithBookNasai,
    'ibnmajah' => l10n.hadithBookIbnMajah,
    'malik' => l10n.hadithBookMalik,
    'nawawi' => l10n.hadithBookNawawi,
    'qudsi' => l10n.hadithBookQudsi,
    'dehlawi' => l10n.hadithBookDehlawi,
    _ => fallback,
  };
}

String localizedAzkarCategoryName(AppLocalizations l10n, String id, String fallback) {
  return switch (id) {
    'morning' => l10n.azkarCategoryMorning,
    'evening' => l10n.azkarCategoryEvening,
    'wudu' => l10n.azkarCategoryWudu,
    'prayer' => l10n.azkarCategoryPrayer,
    'after_prayer' => l10n.azkarCategoryAfterPrayer,
    'sleep' => l10n.azkarCategorySleep,
    'food' => l10n.azkarCategoryFood,
    'travel' => l10n.azkarCategoryTravel,
    'home' => l10n.azkarCategoryHome,
    'masjid' => l10n.azkarCategoryMasjid,
    'distress' => l10n.azkarCategoryDistress,
    'forgiveness' => l10n.azkarCategoryForgiveness,
    'illness' => l10n.azkarCategoryIllness,
    'weather' => l10n.azkarCategoryWeather,
    'knowledge' => l10n.azkarCategoryKnowledge,
    'parents' => l10n.azkarCategoryParents,
    'guidance' => l10n.azkarCategoryGuidance,
    'gratitude' => l10n.azkarCategoryGratitude,
    'protection' => l10n.azkarCategoryProtection,
    'dhikr' => l10n.azkarCategoryDhikr,
    'marriage' => l10n.azkarCategoryMarriage,
    'hajj' => l10n.azkarCategoryHajj,
    'grief' => l10n.azkarCategoryGrief,
    'children' => l10n.azkarCategoryChildren,
    'business' => l10n.azkarCategoryBusiness,
    'night_prayer' => l10n.azkarCategoryNightPrayer,
    'quran_recitation' => l10n.azkarCategoryQuranRecitation,
    _ => fallback,
  };
}

String localizedAzkarCategoryDescription(
  AppLocalizations l10n,
  String id,
  String fallback,
) {
  return switch (id) {
    'morning' => l10n.azkarCategoryMorningDescription,
    'evening' => l10n.azkarCategoryEveningDescription,
    'wudu' => l10n.azkarCategoryWuduDescription,
    'prayer' => l10n.azkarCategoryPrayerDescription,
    'after_prayer' => l10n.azkarCategoryAfterPrayerDescription,
    'sleep' => l10n.azkarCategorySleepDescription,
    'food' => l10n.azkarCategoryFoodDescription,
    'travel' => l10n.azkarCategoryTravelDescription,
    'home' => l10n.azkarCategoryHomeDescription,
    'masjid' => l10n.azkarCategoryMasjidDescription,
    'distress' => l10n.azkarCategoryDistressDescription,
    'forgiveness' => l10n.azkarCategoryForgivenessDescription,
    'illness' => l10n.azkarCategoryIllnessDescription,
    'weather' => l10n.azkarCategoryWeatherDescription,
    'knowledge' => l10n.azkarCategoryKnowledgeDescription,
    'parents' => l10n.azkarCategoryParentsDescription,
    'guidance' => l10n.azkarCategoryGuidanceDescription,
    'gratitude' => l10n.azkarCategoryGratitudeDescription,
    'protection' => l10n.azkarCategoryProtectionDescription,
    'dhikr' => l10n.azkarCategoryDhikrDescription,
    'marriage' => l10n.azkarCategoryMarriageDescription,
    'hajj' => l10n.azkarCategoryHajjDescription,
    'grief' => l10n.azkarCategoryGriefDescription,
    'children' => l10n.azkarCategoryChildrenDescription,
    'business' => l10n.azkarCategoryBusinessDescription,
    'night_prayer' => l10n.azkarCategoryNightPrayerDescription,
    'quran_recitation' => l10n.azkarCategoryQuranRecitationDescription,
    _ => fallback,
  };
}
