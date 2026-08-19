import 'dart:async';
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
class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  PrayerTimesNotifier(this._service, this._locationService)
    : super(const PrayerTimesState()) {
    load();
  }

  final PrayerTimesService _service;
  final LocationService _locationService;

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
    } catch (_) {
      // Adhan scheduling is a side effect — never block or fail the main flow.
    }
  }
}

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
      final service = ref.watch(prayerTimesServiceProvider);
      final locationService = ref.watch(locationServiceProvider);
      return PrayerTimesNotifier(service, locationService);
    });
