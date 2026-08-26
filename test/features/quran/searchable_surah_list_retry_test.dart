import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/core/localization/app_localizations.dart';
import 'package:eslamy/features/quran/models/quran_models.dart';
import 'package:eslamy/features/quran/presentation/controllers/quran_providers.dart';
import 'package:eslamy/features/quran/presentation/widgets/searchable_surah_list.dart';
import 'package:eslamy/shared/widgets/list_error_view.dart';

void main() {
  testWidgets(
    'SearchableSurahList shows a Retry button on error, and retry reloads the list',
    (tester) async {
      var attempts = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chaptersProvider.overrideWith((ref) async {
              attempts++;
              if (attempts == 1) {
                throw Exception('network down');
              }
              return const [
                QuranChapter(
                  number: 1,
                  name: 'الفاتحة',
                  englishName: 'Al-Fatihah',
                  englishNameTranslation: 'The Opening',
                  numberOfAyahs: 7,
                  revelationType: 'Meccan',
                ),
              ];
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: SearchableSurahList(query: '')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First load failed: a ListErrorView with a Retry button is shown,
      // and no surah data is rendered.
      expect(attempts, 1);
      expect(find.byType(ListErrorView), findsOneWidget);
      expect(find.text('Al-Fatihah'), findsNothing);

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final retryButton = find.widgetWithText(ElevatedButton, l10n.retry);
      expect(retryButton, findsOneWidget);

      // Tapping Retry invalidates chaptersProvider, which re-runs the
      // (now succeeding) fetch and swaps the error view for the list.
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.byType(ListErrorView), findsNothing);
      expect(find.text('Al-Fatihah'), findsOneWidget);
    },
  );
}
