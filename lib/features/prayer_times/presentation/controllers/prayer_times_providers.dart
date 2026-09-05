import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/prayer_times.dart';
import '../../service/location_service.dart';
import '../../service/prayer_times_service.dart';
import '../../../settings/service/settings_database.dart';
import '../../../settings/presentation/controllers/language_providers.dart';
import '../../../../core/notifications/notification_service.dart';

final locationServiceProvider = Provider((ref) => LocationService());

/// Mirrors `MosqueLocationIssue` — a location problem the user can actually
/// fix (unlike a transient GPS timeout, which just falls back silently).
enum PrayerLocationIssue {
  permissionDenied,
  permissionDeniedForever,
  servicesDisabled,
}

class PrayerTimesState {
  final DailyPrayerTimes? timings;
  final double? qiblaDirection;
  final bool isLoading;
  final String? error;
  final bool usingFallbackLocation;
  final PrayerLocationIssue? locationIssue;

  const PrayerTimesState({
    this.timings,
    this.qiblaDirection,
    this.isLoading = false,
    this.error,
    this.usingFallbackLocation = false,
    this.locationIssue,
  });

  PrayerTimesState copyWith({
    DailyPrayerTimes? timings,
    double? qiblaDirection,
    bool? isLoading,
    String? error,
    bool? usingFallbackLocation,
    PrayerLocationIssue? locationIssue,
    bool clearLocationIssue = false,
  }) {
    return PrayerTimesState(
      timings: timings ?? this.timings,
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      usingFallbackLocation:
          usingFallbackLocation ?? this.usingFallbackLocation,
      locationIssue:
          clearLocationIssue ? null : (locationIssue ?? this.locationIssue),
    );
  }
}

/// Kept alive for the app lifetime (not autoDispose): both the home card and
/// the dedicated prayer times / qibla pages read from this one provider, and
/// re-fetching on every navigation would waste API calls for data that only
/// changes once a day.
class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  PrayerTimesNotifier(this._service, this._locationService)
    : super(const PrayerTimesState()) {
    load();
  }

  final PrayerTimesService _service;
  final LocationService _locationService;

  Future<void> load({bool requestFreshLocation = false}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      clearLocationIssue: true,
    );
    try {
      double lat;
      double lng;
      var fallback = false;

      final fix =
          requestFreshLocation || state.timings == null
              ? await _locationService.obtainFix(
                accuracy: LocationAccuracy.medium,
              )
              : null;

      if (fix != null && fix.hasCoordinates) {
        lat = fix.latitude!;
        lng = fix.longitude!;
      } else {
        final cached = await _locationService.getCachedPosition();
        if (cached != null) {
          (lat, lng) = cached;
        } else if (fix != null &&
            (fix.kind == LocationFixKind.permissionDenied ||
                fix.kind == LocationFixKind.permissionDeniedForever ||
                fix.kind == LocationFixKind.servicesDisabled)) {
          // A recoverable issue with nothing cached to fall back on — surface
          // it (with a way to fix it) instead of silently pinning the user to
          // Cairo forever, which also means every Adhan alert fires for the
          // wrong city.
          if (!mounted) return;
          state = state.copyWith(
            isLoading: false,
            locationIssue: switch (fix.kind) {
              LocationFixKind.permissionDenied =>
                PrayerLocationIssue.permissionDenied,
              LocationFixKind.permissionDeniedForever =>
                PrayerLocationIssue.permissionDeniedForever,
              LocationFixKind.servicesDisabled =>
                PrayerLocationIssue.servicesDisabled,
              _ => null,
            },
          );
          return;
        } else {
          // Transient failure (e.g. a GPS timeout) with nothing cached —
          // still recoverable via a normal retry, so fall back rather than
          // showing a dead-end permission screen.
          lat = fallbackLatitude;
          lng = fallbackLongitude;
          fallback = true;
        }
      }

      final results = await Future.wait([
        _service.fetchTimings(latitude: lat, longitude: lng),
        _service.fetchQiblaDirection(latitude: lat, longitude: lng),
      ]);

      if (!mounted) return;
      state = state.copyWith(
        timings: results[0] as DailyPrayerTimes,
        qiblaDirection: results[1] as double,
        isLoading: false,
        usingFallbackLocation: fallback,
        clearLocationIssue: true,
      );
      // Never schedule Adhan against the hardcoded Cairo fallback — a real
      // (even if stale/cached) location is required so alerts fire at the
      // user's own prayer times, not someone else's.
      if (!fallback) {
        unawaited(_scheduleAdhan(lat, lng, results[0] as DailyPrayerTimes));
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Opens the relevant system settings screen for the current
  /// [PrayerTimesState.locationIssue] — location services for a disabled
  /// service, the app's own permission page otherwise (denied/deniedForever
  /// both need the same screen; re-requesting in-app can't recover from
  /// "denied forever").
  Future<void> openSystemSettings() async {
    if (state.locationIssue == PrayerLocationIssue.servicesDisabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
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
    if (today == null) return;
    final cached = await _locationService.getCachedPosition();
    if (cached == null) return;
    final (lat, lng) = cached;
    await _scheduleAdhan(lat, lng, today);
  }

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
      final tomorrow = await _service.fetchTimings(
        latitude: lat,
        longitude: lng,
        date: DateTime.now().add(const Duration(days: 1)),
      );
      Map<String, DateTime> asMap(DailyPrayerTimes d) => {
        for (final p in d.prayers)
          if (p.name != 'Sunrise') p.name: p.time,
      };
      await NotificationService().scheduleAdhan(
        today: asMap(today),
        tomorrow: asMap(tomorrow),
        l10n: await loadStoredLocalizations(),
      );
    } catch (e, st) {
      // Adhan scheduling is a side effect — never block or fail the main
      // flow. Still surface it (Crashlytics is release-only, gated in
      // main.dart) — this used to be a bare silent catch, which made a
      // release-only scheduling failure completely undiagnosable.
      debugPrint('Adhan scheduling failed: $e\n$st');
      // Best-effort reporting only: if Firebase itself failed to initialize
      // (see main.dart), this call would throw too — swallow that rather
      // than letting a failed *report* about a swallowed error escalate
      // into the app's global error screen.
      unawaited(
        FirebaseCrashlytics.instance
            .recordError(e, st, reason: 'Adhan scheduling failed', fatal: false)
            .catchError((_) {}),
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
