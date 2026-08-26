import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/core/localization/app_localizations.dart';
import 'package:eslamy/shared/widgets/list_error_view.dart';

void main() {
  Future<void> pumpView(WidgetTester tester, VoidCallback onRetry) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListErrorView(message: 'Could not load the list', onRetry: onRetry),
        ),
      ),
    );
  }

  testWidgets('shows the error message, an error icon, and a Retry button', (
    tester,
  ) async {
    await pumpView(tester, () {});

    expect(find.text('Could not load the list'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.widgetWithText(ElevatedButton, l10n.retry), findsOneWidget);
  });

  testWidgets('tapping Retry invokes onRetry exactly once', (tester) async {
    var retryCount = 0;
    await pumpView(tester, () => retryCount++);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(retryCount, 1);
  });
}
