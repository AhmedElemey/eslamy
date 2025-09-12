import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/error/presentation/pages/error_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/presentation/controllers/settings_providers.dart';
import 'dart:async';
import 'core/theme/app_colors.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _navigateToError(details.exception, details.stack);
  };

  runZonedGuarded(() {
    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    _navigateToError(error, stack);
  });
}

void _navigateToError(Object error, StackTrace? stack) {
  final navigator = _rootNavigatorKey.currentState;
  if (navigator == null) return;
  navigator.pushNamed('/error', arguments: {
    'message': 'Unexpected error occurred',
    'error': error,
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textDeltaAsync = ref.watch(textSizeProvider);

    double scaleForDelta(int delta) {
      switch (delta) {
        case 0:
          return 1.0;
        case 4:
          return 1.1;
        case 8:
          return 1.2;
        case 10:
          return 1.25;
        default:
          return 1.0;
      }
    }

    return MaterialApp(
      title: 'Eslamy',
      debugShowCheckedModeBanner: false,
      navigatorKey: _rootNavigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
        ),
      ),
      builder: (context, child) {
        final scale = textDeltaAsync.maybeWhen(
          data: (delta) => scaleForDelta(delta),
          orElse: () => 1.0,
        );
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(scale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routes: {
        '/': (_) => const SplashPage(),
        '/home': (_) => const HomePage(),
        '/settings': (_) => const SettingsPage(),
        '/error': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map) {
            return ErrorPage(
              message: args['message'] as String?,
              error: args['error'] as Object?,
            );
          }
          return const ErrorPage();
        },
      },
    );
  }
}
