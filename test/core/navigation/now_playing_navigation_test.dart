import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/core/localization/app_localizations.dart';
import 'package:eslamy/core/navigation/now_playing_navigation.dart';
import 'package:eslamy/core/navigation/root_navigator.dart';
import 'package:eslamy/features/splash/presentation/pages/splash_page.dart';

void main() {
  tearDown(() {
    resetNowPlayingNavigationForTest();
  });

  Widget app({String initialRoute = '/home'}) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      navigatorObservers: [RootRouteTracker.instance],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: initialRoute,
      routes: {
        '/': (_) => const Scaffold(body: Text('SPLASH')),
        '/home': (_) => const Scaffold(body: Text('HOME')),
        '/now-playing': (_) => const Scaffold(body: Text('NOW')),
      },
    );
  }

  testWidgets('openNowPlayingPage pushes a single Now Playing route', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await openNowPlayingPage();
    await tester.pumpAndSettle();
    expect(find.text('NOW'), findsOneWidget);

    await openNowPlayingPage();
    await tester.pumpAndSettle();
    expect(find.text('NOW'), findsOneWidget);

    rootNavigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('NOW'), findsNothing);
  });

  testWidgets('openNowPlayingPage waits for splash before pushing', (
    tester,
  ) async {
    await tester.pumpWidget(app(initialRoute: '/'));
    await tester.pumpAndSettle();
    expect(find.text('SPLASH'), findsOneWidget);

    final pending = openNowPlayingPage();
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('NOW'), findsNothing);
    expect(find.text('SPLASH'), findsOneWidget);

    rootNavigatorKey.currentState!.pushReplacementNamed('/home');
    await tester.pumpAndSettle();

    // The helper polls every 50ms (fake-async); advance time so it sees /home.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    await pending;

    expect(find.text('NOW'), findsOneWidget);
    expect(find.text('SPLASH'), findsNothing);
  });

  testWidgets(
    'splash timer does not replace Now Playing pushed on top of splash',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: {
            '/': (_) => const SplashPage(),
            '/home': (_) => const Scaffold(body: Text('HOME')),
            '/now-playing': (_) => const Scaffold(body: Text('NOW')),
          },
        ),
      );
      await tester.pump();

      Navigator.of(
        tester.element(find.byType(SplashPage)),
      ).pushNamed('/now-playing');
      await tester.pumpAndSettle();
      expect(find.text('NOW'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1900));
      await tester.pumpAndSettle();

      expect(find.text('NOW'), findsOneWidget);
      expect(find.text('HOME'), findsNothing);
    },
  );
}
