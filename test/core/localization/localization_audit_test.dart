import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/core/localization/app_localizations.dart';
import 'package:eslamy/core/localization/display_names.dart';
import 'package:eslamy/core/localization/error_localizer.dart';
import 'package:eslamy/features/hajj_umrah/l10n/hajj_umrah_strings.dart';
import 'package:eslamy/features/hadith/models/hadith_book.dart';

void main() {
  test('Arabic localizations cover newly added UI chrome', () {
    final l10n = lookupAppLocalizations(const Locale('ar'));
    expect(l10n.azkarCategoryMorning, 'أذكار الصباح');
    expect(l10n.dhikrCustom, 'مخصص');
    expect(l10n.hadithBookBukhari, 'صحيح البخاري');
    expect(l10n.notificationChannelAdhan, 'الأذان');
    expect(l10n.surahNumberLabel(2), contains('2'));
  });

  test('display-name helpers resolve by locale, not English fallbacks', () {
    final ar = lookupAppLocalizations(const Locale('ar'));
    final it = lookupAppLocalizations(const Locale('it'));
    expect(localizedHadithBookName(ar, 'nawawi', hadithBooks[7].name), ar.hadithBookNawawi);
    expect(localizedHadithBookName(it, 'nawawi', hadithBooks[7].name), it.hadithBookNawawi);
    expect(localizedAzkarCategoryName(ar, 'sleep', 'Sleep'), ar.azkarCategorySleep);
    expect(localizedDhikrName(ar, 'custom', 'Custom'), ar.dhikrCustom);
  });

  test('network errors are mapped instead of shown in English', () {
    final l10n = lookupAppLocalizations(const Locale('ar'));
    expect(
      localizedError(l10n, 'Connection timeout, try again later'),
      l10n.errorConnectionTimeout,
    );
    expect(
      localizedError(l10n, Exception('No internet connection. Please check your network.')),
      l10n.errorNoInternet,
    );
  });

  test('Hajj content tables cover both non-English locales', () {
    expect(hajjUmrahAr['day-0.title'], isNotNull);
    expect(hajjUmrahIt['day-0.title'], isNotNull);
    expect(hajjUmrahAr['talbiyah.name'], isNotEmpty);
    expect(hajjUmrahIt.length, hajjUmrahAr.length);
  });
}
