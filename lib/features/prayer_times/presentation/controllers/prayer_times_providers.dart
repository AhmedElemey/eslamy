import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/prayer_times.dart';
import '../../service/location_service.dart';
import '../../service/prayer_times_service.dart';

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
      usingFallbackLocation: usingFallbackLocation ?? this.usingFallbackLocation,
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
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
      final service = ref.watch(prayerTimesServiceProvider);
      final locationService = ref.watch(locationServiceProvider);
      return PrayerTimesNotifier(service, locationService);
    });
