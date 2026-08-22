import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/home/presentation/pages/main_shell.dart';
import 'features/error/presentation/pages/error_page.dart';
import 'features/network/presentation/pages/no_network_page.dart';
import 'core/network/connectivity_provider.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/presentation/controllers/settings_providers.dart';
import 'features/quran/presentation/pages/quran_index_page.dart';
import 'features/tafseer/presentation/pages/tafseer_index_page.dart';
import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/adhan_reschedule_task.dart';
import 'features/settings/presentation/controllers/language_providers.dart';
import 'features/settings/presentation/controllers/theme_mode_providers.dart';
import 'features/prayer_times/presentation/pages/prayer_times_page.dart';
import 'features/prayer_times/presentation/pages/qibla_page.dart';
import 'features/hadith/presentation/pages/hadith_books_page.dart';
import 'features/tasbih/presentation/pages/tasbih_page.dart';
import 'features/duas/presentation/pages/azkar_categories_page.dart';
import 'features/hijri_calendar/presentation/pages/hijri_calendar_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart';
import 'firebase_options.dart';
import 'features/quran/service/quran_audio_handler.dart';
import 'features/quran/presentation/controllers/quran_providers.dart';
import 'features/quran/presentation/widgets/quran_mini_player_bar.dart';
import 'features/quran/presentation/pages/quran_now_playing_page.dart';
import 'features/quran/models/quran_models.dart';
import 'features/quran/service/bubble_overlay_channel.dart';
import 'core/navigation/root_navigator.dart';
import 'core/navigation/now_playing_navigation.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

// The one shared audio session for surah playback — see
// quran_audio_handler.dart. Resolved before runApp so every widget reads the
// same instance via quranAudioHandlerProvider's override below.
late final QuranAudioHandler _audioHandler;

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final startupL10n = await loadStoredLocalizations();

      // Initialize audio session for proper audio playback
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      debugPrint('Audio session configured for music playback');

      _audioHandler = await AudioService.init(
        builder: () => QuranAudioHandler(),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.eslamy.eslamy.audio',
          androidNotificationChannelName:
              startupL10n.notificationChannelQuranPlayback,
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );

      // Bubble tap -> QuranAudioHandler.customAction('openNowPlaying') -> here.
      // Set up once at startup rather than in a widget so it isn't tied to
      // MyApp's build/rebuild lifecycle. Also listen for the native intent
      // extra MainActivity sends when MediaSession isn't connected yet.
      _audioHandler.openNowPlayingRequests.listen((_) {
        openNowPlayingPage();
      });
      BubbleOverlayChannel.setOpenNowPlayingHandler(openNowPlayingPage);

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Only report real crashes to Crashlytics — debug builds stay local
      // so day-to-day development noise doesn't pollute the dashboard.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );

      // Flutter framework errors and anything escaping the zone below (see
      // the runZonedGuarded error handler) both get forwarded to
      // Crashlytics, in addition to the existing local error screen.
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        _navigateToError(details.exception, details.stack);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      runApp(
        ProviderScope(
          overrides: [
            quranAudioHandlerProvider.overrideWithValue(_audioHandler),
          ],
          child: const MyApp(),
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await NotificationService().init(l10n: await loadStoredLocalizations());
        await _initFirebaseMessaging();
        await registerAdhanRescheduleTask();
      });
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      _navigateToError(error, stack);
    },
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate init
  await Firebase.initializeApp();
}

Future<void> _initFirebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final fcm = FirebaseMessaging.instance;
  await fcm.requestPermission(alert: true, badge: true, sound: true);
  // iOS: show foreground notifications
  await fcm.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // Fetch current FCM token on app start
  try {
    final token = await fcm.getToken();
    if (token != null) {
      // TODO: send to backend once one exists.
      debugPrint('FCM token acquired');
    }
  } catch (_) {
    // ignore
  }
  // Listen for token refreshes
  fcm.onTokenRefresh.listen((newToken) {
    // TODO: send to backend once one exists.
    debugPrint('FCM token refreshed');
  });
  // Handle foreground messages by displaying local notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await NotificationService().showNow(
        title:
            notification.title ??
            (await loadStoredLocalizations()).notificationFallbackTitle,
        body: notification.body ?? '',
      );
    }
  });
}

void _navigateToError(Object error, StackTrace? stack) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;
    // Clear the whole stack instead of stacking '/error' on top of the
    // current route: pushing additively can leave the splash screen (with
    // its still-armed navigation Timer) buried underneath, which later
    // fires against the wrong top-of-stack route and leaves a zombie
    // splash screen with no way to navigate forward after the user backs
    // out of the error screen.
    navigator.pushNamedAndRemoveUntil(
      '/error',
      (route) => false,
      arguments: {'error': error},
    );
  });
}

const String _kNoNetworkRoute = '/no-network';

/// Pushes/pops [_kNoNetworkRoute] app-wide in reaction to [connectivityProvider]
/// — mirrors `_navigateToError`'s use of [rootNavigatorKey], but keeps the
/// existing navigation stack (rather than wiping it) since connectivity, unlike
/// a crash, is expected to come back: popping this route on reconnect returns
/// the user to exactly where they were.
void _handleConnectivityChange(bool connected) {
  if (connected) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = rootNavigatorKey.currentState;
      if (navigator != null &&
          RootRouteTracker.instance.currentRouteName.value ==
              _kNoNetworkRoute) {
        navigator.pop();
      }
    });
    return;
  }
  _pushNoNetworkWhenReady();
}

/// Same "wait until off splash" retry loop as `_pushNowPlayingWhenReady` in
/// now_playing_navigation.dart — needed because the app can start already
/// offline, before the splash screen's own timer-driven navigation has run;
/// pushing on top of splash then would leave it as a zombie route
/// underneath once its timer later fires a `pushReplacementNamed` against
/// what's now the wrong top-of-stack route.
Future<void> _pushNoNetworkWhenReady() async {
  const maxAttempts = 100;
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    final tracker = RootRouteTracker.instance;
    if (tracker.currentRouteName.value == _kNoNetworkRoute) return;

    final nav = rootNavigatorKey.currentState;
    final offSplash =
        nav != null &&
        nav.mounted &&
        tracker.hasObservedRoute &&
        !tracker.isSplash;
    if (offSplash) {
      // Re-check fresh rather than trusting the `connected` value captured
      // when this loop started — connectivity may have flipped back during
      // the wait.
      if (!await checkHasConnection()) {
        nav.pushNamed(_kNoNetworkRoute);
      }
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

const _kOverlayPermissionAskedKey = 'quran_overlay_permission_asked';

/// Android only: shows the floating bubble immediately if permission is
/// already granted; otherwise asks once (via a rationale dialog tied to the
/// moment the user actually started audio) and never nags again after a
/// decline — `_kOverlayPermissionAskedKey` persists that choice.
Future<void> _ensureOverlayPermissionAndShowBubble(
  AppLocalizations l10n,
) async {
  if (!Platform.isAndroid) return;
  if (await BubbleOverlayChannel.hasOverlayPermission()) {
    await BubbleOverlayChannel.show();
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_kOverlayPermissionAskedKey) == true) return;

  // Freshly re-read from the persistent root navigator key (not a widget's
  // own disposable context), so there's no "stale after await" risk here —
  // ignored rather than guarded with a `mounted` check that doesn't apply to
  // a non-State context.
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;

  final allow = await showDialog<bool>(
    // ignore: use_build_context_synchronously
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(l10n.overlayPermissionTitle),
          content: Text(l10n.overlayPermissionBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.overlayPermissionNotNow),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.overlayPermissionAllow),
            ),
          ],
        ),
  );
  await prefs.setBool(_kOverlayPermissionAskedKey, true);

  if (allow == true) {
    await BubbleOverlayChannel.requestOverlayPermission();
    // The user resolves the system permission screen outside the app; the
    // bubble shows next time playback starts and this function re-runs.
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textDeltaAsync = ref.watch(textSizeProvider);
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.light;
    final language =
        ref.watch(languageProvider).valueOrNull ?? AppLanguage.arabic;

    // Single app-wide reciter-switch reaction — replaces the old duplicated
    // per-screen restart subscriptions now that there's one shared player.
    ref.listen<Reciter?>(selectedReciterProvider, (previous, next) {
      if (next != null && next != previous) {
        ref.read(quranAudioHandlerProvider).setReciterAndRestartIfPlaying(next);
      }
    });

    // App-wide "no network" redirect — pushes/pops '/no-network' as
    // connectivity drops/returns, wherever the user currently is.
    ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
      final connected = next.valueOrNull;
      if (connected == null) return;
      _handleConnectivityChange(connected);
    });

    if (Platform.isAndroid) {
      // First play (or resume after a full stop) -> show the bubble,
      // prompting for the overlay permission the first time this happens.
      ref.listen(playbackStateProvider, (previous, next) {
        final playing = next.valueOrNull?.playing ?? false;
        final wasPlaying = previous?.valueOrNull?.playing ?? false;
        if (playing && !wasPlaying) {
          // Resolved fresh here (not captured from build-time `language`)
          // since this listener can fire long after MyApp last rebuilt.
          final locale =
              ref.read(languageProvider).valueOrNull?.locale ??
              const Locale('ar');
          _ensureOverlayPermissionAndShowBubble(lookupAppLocalizations(locale));
        }
      });
      // A full stop (not just pause) clears the media item — hide the
      // bubble along with it rather than leaving a stale, inert overlay.
      ref.listen(currentMediaItemProvider, (previous, next) {
        if (next.valueOrNull == null && previous?.valueOrNull != null) {
          BubbleOverlayChannel.hide();
        }
      });
    }

    ref
        .read(quranAudioHandlerProvider)
        .setArabicTitles(language == AppLanguage.arabic);

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
      title: lookupAppLocalizations(language.locale).appTitle,
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      navigatorObservers: [RootRouteTracker.instance],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: language.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final scale = textDeltaAsync.maybeWhen(
          data: (delta) => scaleForDelta(delta),
          orElse: () => 1.0,
        );
        final media = MediaQuery.of(context);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.overlayFor(Theme.of(context).brightness),
          child: ColoredBox(
            color: AppColors.pageBackground(context),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MediaQuery(
                  data: media.copyWith(textScaler: TextScaler.linear(scale)),
                  child: child ?? const SizedBox.shrink(),
                ),
                // Sits above every pushed route (not just MainShell's tabs) so
                // the mini player follows the user into chapter/verse detail
                // pages and back out again — see quran_mini_player_bar.dart.
                const QuranMiniPlayerBar(),
              ],
            ),
          ),
        );
      },
      routes: {
        '/': (_) => const SplashPage(),
        '/home': (_) => const MainShell(),
        '/settings': (_) => const SettingsPage(),
        '/quran': (_) => const QuranIndexPage(),
        '/tafseer': (_) => const TafseerIndexPage(),
        '/now-playing': (_) => const QuranNowPlayingPage(),
        '/prayer-times': (_) => const PrayerTimesPage(),
        '/qibla': (_) => const QiblaPage(),
        '/hadith': (_) => const HadithBooksPage(),
        '/tasbih': (_) => const TasbihPage(),
        '/duas': (_) => const AzkarCategoriesPage(),
        '/hijri-calendar': (_) => const HijriCalendarPage(),
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
        _kNoNetworkRoute: (_) => const NoNetworkPage(),
      },
    );
  }
}
