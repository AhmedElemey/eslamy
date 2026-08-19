import 'package:flutter/widgets.dart';

import 'root_navigator.dart';

const String kNowPlayingRoute = '/now-playing';
const String kSplashRoute = '/';

/// Tracks the root navigator's current route so overlays sitting *outside*
/// the navigator (the in-app audio FAB) can tell whether `/now-playing` is
/// already on top — `ModalRoute.of(fabContext)` is null for those widgets.
class RootRouteTracker extends NavigatorObserver {
  RootRouteTracker._();
  static final RootRouteTracker instance = RootRouteTracker._();

  final ValueNotifier<String?> currentRouteName = ValueNotifier<String?>(null);

  bool _hasObservedRoute = false;

  bool get hasObservedRoute => _hasObservedRoute;

  bool get isNowPlaying => currentRouteName.value == kNowPlayingRoute;

  bool get isSplash =>
      _hasObservedRoute && currentRouteName.value == kSplashRoute;

  void _set(Route<dynamic>? route) {
    _hasObservedRoute = true;
    currentRouteName.value = route?.settings.name;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _set(newRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(previousRoute);

  @visibleForTesting
  void resetForTest() {
    _hasObservedRoute = false;
    currentRouteName.value = null;
  }
}

bool _openInFlight = false;

/// Opens the Now Playing page via [rootNavigatorKey].
///
/// Safe to call from the in-app FAB (outside the navigator subtree), from
/// the Android overlay's MediaSession custom action, and from a native
/// intent extra that arrives before the first frame:
/// - retries until the navigator exists and splash has been replaced
/// - no-ops when `/now-playing` is already the current route (avoids a
///   stack of identical pages whose back button appears "broken")
Future<void> openNowPlayingPage() async {
  if (RootRouteTracker.instance.isNowPlaying) return;
  if (_openInFlight) return;
  _openInFlight = true;
  try {
    await _pushNowPlayingWhenReady();
  } finally {
    _openInFlight = false;
  }
}

Future<void> _pushNowPlayingWhenReady() async {
  const maxAttempts = 100;
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    if (RootRouteTracker.instance.isNowPlaying) return;

    final nav = rootNavigatorKey.currentState;
    final tracker = RootRouteTracker.instance;
    final offSplash =
        nav != null &&
        nav.mounted &&
        tracker.hasObservedRoute &&
        !tracker.isSplash;

    if (offSplash) {
      // Do not await: pushNamed completes when the route is popped.
      nav.pushNamed(kNowPlayingRoute);
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  final nav = rootNavigatorKey.currentState;
  if (nav != null &&
      nav.mounted &&
      !RootRouteTracker.instance.isNowPlaying) {
    nav.pushNamed(kNowPlayingRoute);
  }
}

@visibleForTesting
void resetNowPlayingNavigationForTest() {
  _openInFlight = false;
  RootRouteTracker.instance.resetForTest();
}
