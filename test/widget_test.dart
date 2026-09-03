// Smoke test for a self-contained screen that needs no Firebase/audio
// bootstrapping. The previous version of this file was the unmodified
// Flutter template counter-app test, left over from `flutter create` and
// exercising nothing in this app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/core/localization/app_localizations.dart';
import 'package:eslamy/features/error/presentation/pages/error_page.dart';

void main() {
  testWidgets('ErrorPage renders the provided message and error details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ErrorPage(
          message: 'Something specific broke',
          error: 'network unreachable',
        ),
      ),
    );

    expect(find.text('Something specific broke'), findsOneWidget);
    expect(find.text('network unreachable'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('ErrorPage falls back to a generic message when none is given', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ErrorPage(),
      ),
    );

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.somethingWentWrongGeneric), findsOneWidget);
  });
}
