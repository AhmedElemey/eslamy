import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/prayer_times.dart';
import '../../service/location_service.dart';
import '../../service/prayer_times_service.dart';
import '../../../settings/service/settings_database.dart';
import '../../../settings/presentation/controllers/language_providers.dart';
import '../../../../core/notifications/notification_service.dart';

final locationServiceProvider = Provider((ref) => LocationService());

class PrayerTimesState {
  final DailyPrayerTimes? timings;
  final double? qiblaDirection;
  final bool isLoading;
  final String? error;
  final bool usingFallbackLocation;

  const PrayerTimesState({
    this.timings,
    this.qiblaDirection,
    this.isLoading = false,
    this.error,
    this.usingFallbackLocation = false,
  });

  PrayerTimesState copyWith({
    DailyPrayerTimes? timings,
    double? qiblaDirection,
    bool? isLoading,
    String? error,
    bool? usingFallbackLocation,
  }) {
    return PrayerTimesState(
      timings: timings ?? this.timings,
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      usingFallbackLocation:
          usingFallbackLocation ?? this.usingFallbackLocation,
    );
  }
}

/// Kept alive for the app lifetime (not autoDispose): both the home card and
/// the dedicated prayer times / qibla pages read from this one provider, and
/// re-fetching on every navigation would waste API calls for data that only
/// changes once a day.
class PrayerTimesNotifier extends StateNotifier<PrayerTimesState>
    with WidgetsBindingObserver {
  PrayerTimesNotifier(this._service, this._locationService)
    : super(const PrayerTimesState()) {
    WidgetsBinding.instance.addObserver(this);
    // 20s is well inside a prayer's clock minute, so a boundary is not
    // skipped just because the tick landed a few seconds after HH:MM:00.
    _adhanTick = Timer.periodic(const Duration(seconds: 20), (_) {
      unawaited(_onAdhanTick());
    });
    load();
  }

  final PrayerTimesService _service;
  final LocationService _locationService;
  Timer? _adhanTick;
  double? _lastLat;
  double? _lastLng;

  @override
  void dispose() {
    _adhanTick?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed) {
      unawaited(_onAdhanTick());
    }
  }

  Future<void> load({bool requestFreshLocation = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      double lat;
      double lng;
      var fallback = false;

      final position =
          requestFreshLocation || state.timings == null
              ? await _locationService.getCurrentPosition()
              : null;

      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
      } else {
        final cached = await _locationService.getCachedPosition();
        if (cached != null) {
          (lat, lng) = cached;
        } else {
          lat = fallbackLatitude;
          lng = fallbackLongitude;
          fallback = true;
        }
      }

      final results = await Future.wait([
        _service.fetchTimings(latitude: lat, longitude: lng),
        _service.fetchQiblaDirection(latitude: lat, longitude: lng),
      ]);

      _lastLat = lat;
      _lastLng = lng;
      if (!mounted) return;
      state = state.copyWith(
        timings: results[0] as DailyPrayerTimes,
        qiblaDirection: results[1] as double,
        isLoading: false,
        usingFallbackLocation: fallback,
      );
      unawaited(_scheduleAdhan(lat, lng, results[0] as DailyPrayerTimes));
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Applies an Adhan Alerts on/off change immediately — called when the
  /// user flips the toggle in Settings, so alerts start or stop firing
  /// right away instead of waiting for the next cold-start prayer-times
  /// load. Schedules using already-known timings/location when available;
  /// if timings haven't loaded yet, the next [load] call will schedule
  /// them (it already checks the saved enabled flag).
  Future<void> applyAdhanEnabledChange(bool enabled) async {
    if (!enabled) {
      await NotificationService().cancelAdhan();
      return;
    }
    final today = state.timings;
    if (today == null) {
      await load();
      return;
    }
    final cached = await _locationService.getCachedPosition();
    final lat = _lastLat ?? cached?.$1 ?? fallbackLatitude;
    final lng = _lastLng ?? cached?.$2 ?? fallbackLongitude;
    await _scheduleAdhan(lat, lng, today);
  }

  /// Fires an Adhan if a prayer's HH:MM is the current clock minute, and
  /// reloads/reschedules when the calendar day has rolled over (the
  /// provider is kept alive, so [load] would otherwise never run again).
  Future<void> _onAdhanTick() async {
    try {
      final enabled = await SettingsDatabase().getAdhanEnabled();
      if (!enabled) return;
      final timings = state.timings;
      if (timings == null) return;

      final now = DateTime.now();
      final loadedDay = DateTime(
        timings.date.year,
        timings.date.month,
        timings.date.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      if (loadedDay != today) {
        await load();
        return;
      }

      await NotificationService().notifyIfPrayerTimeNow(
        today: _asAdhanMap(timings),
        l10n: await loadStoredLocalizations(),
      );
    } catch (e, st) {
      debugPrint('Adhan tick failed: $e\n$st');
    }
  }

  Map<String, DateTime> _asAdhanMap(DailyPrayerTimes d) => {
    for (final p in d.prayers)
      if (p.name != 'Sunrise') p.name: p.time,
  };

  /// Schedules today + tomorrow's Adhan alerts once timings are known.
  /// Best-effort: failures here must never surface as a prayer-times error.
  Future<void> _scheduleAdhan(
    double lat,
    double lng,
    DailyPrayerTimes today,
  ) async {
    try {
      final enabled = await SettingsDatabase().getAdhanEnabled();
      if (!enabled) return;
      // Adhan is enabled by default, so this may be the first time we ever
      // touch notification permissions for a given user — without this,
      // Android 13+ silently drops every scheduled alert because
      // POST_NOTIFICATIONS was never granted (iOS prompts happen earlier,
      // inside NotificationService.init()). Safe to call on every load:
      // once the OS has recorded a decision, requesting again is a no-op
      // that doesn't re-show any dialog.
      await NotificationService().requestPermissions();
      // Fetched separately from `today` (already known) so a rate-limited
      // or otherwise failed fetch for tomorrow doesn't also throw away the
      // Adhan alerts we can already schedule for today.
      DailyPrayerTimes? tomorrow;
      try {
        tomorrow = await _service.fetchTimings(
          latitude: lat,
          longitude: lng,
          date: DateTime.now().add(const Duration(days: 1)),
        );
      } catch (e, st) {
        debugPrint('Adhan: failed to fetch tomorrow\'s timings: $e\n$st');
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            st,
            reason: 'Adhan: failed to fetch tomorrow\'s timings',
            fatal: false,
          ),
        );
      }
      await NotificationService().scheduleAdhan(
        today: _asAdhanMap(today),
        tomorrow: tomorrow == null ? {} : _asAdhanMap(tomorrow),
        l10n: await loadStoredLocalizations(),
      );
    } catch (e, st) {
      // Adhan scheduling is a side effect — never block or fail the main
      // flow. Still surface it (Crashlytics is release-only, gated in
      // main.dart) — this used to be a bare silent catch, which made a
      // release-only scheduling failure completely undiagnosable.
      debugPrint('Adhan scheduling failed: $e\n$st');
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          st,
          reason: 'Adhan scheduling failed',
          fatal: false,
        ),
      );
    }
  }
}

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
      final service = ref.watch(prayerTimesServiceProvider);
      final locationService = ref.watch(locationServiceProvider);
      return PrayerTimesNotifier(service, locationService);
    });
