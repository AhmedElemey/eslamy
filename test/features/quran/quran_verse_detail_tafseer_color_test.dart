import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eslamy/core/localization/app_localizations.dart';
import 'package:eslamy/core/theme/app_colors.dart';
import 'package:eslamy/core/theme/app_theme.dart';
import 'package:eslamy/features/quran/models/quran_models.dart';
import 'package:eslamy/features/quran/presentation/controllers/quran_providers.dart';
import 'package:eslamy/features/quran/presentation/pages/quran_verse_detail_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'tajweed_coloring_enabled': false,
    });
  });

  testWidgets('tafseer body uses themed text color in dark mode', (
    tester,
  ) async {
    const tafsirText = 'تفسير تجريبي للنص';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tafseerProvider.overrideWith((ref, params) async {
            return const AyahTafsir(
              text: tafsirText,
              editionName: 'Al-Jalalayn',
            );
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const QuranVerseDetailPage(
            chapterNumber: 1,
            verseNumber: 1,
            verseText: 'بِسْمِ ٱللَّهِ',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.text(tafsirText));
    expect(text.style?.color, AppColors.ayahDark);
    expect(text.style?.color, isNot(Colors.white));
  });
}
