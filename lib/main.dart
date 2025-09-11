import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/error/presentation/pages/error_page.dart';
import 'dart:async';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eslamy',
      debugShowCheckedModeBanner: false,
      navigatorKey: _rootNavigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C3BFF)),
      ),
      routes: {
        '/': (_) => const SplashPage(),
        '/home': (_) => const HomePage(),
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
 
