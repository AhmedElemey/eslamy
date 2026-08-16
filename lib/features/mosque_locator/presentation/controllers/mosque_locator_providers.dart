import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_providers.dart'
    show locationServiceProvider;
import '../../../prayer_times/service/location_service.dart';
import '../../models/mosque.dart';
import '../../service/mosque_locator_service.dart';

class MosqueLocatorState {
  final List<Mosque> mosques;
  final bool isLoading;
  final String? error;
  final bool usingFallbackLocation;
  final DateTime? staleCacheAt;

  const MosqueLocatorState({
    this.mosques = const [],
    this.isLoading = false,
    this.error,
    this.usingFallbackLocation = false,
    this.staleCacheAt,
  });

  /// True when [mosques] came from the on-device cache because the live
  /// fetch just failed, rather than from a fresh successful fetch.
  bool get isShowingStaleCache => staleCacheAt != null;

  MosqueLocatorState copyWith({
    List<Mosque>? mosques,
    bool? isLoading,
    String? error,
    bool? usingFallbackLocation,
    DateTime? staleCacheAt,
    bool clearStaleCache = false,
  }) {
    return MosqueLocatorState(
      mosques: mosques ?? this.mosques,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      usingFallbackLocation:
          usingFallbackLocation ?? this.usingFallbackLocation,
      staleCacheAt: clearStaleCache ? null : (staleCacheAt ?? this.staleCacheAt),
    );
  }
}

class MosqueLocatorNotifier extends StateNotifier<MosqueLocatorState> {
  MosqueLocatorNotifier(this._service, this._locationService)
    : super(const MosqueLocatorState()) {
    load();
  }

  final MosqueLocatorService _service;
  final LocationService _locationService;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final position = await _locationService.getCurrentPosition();
      double lat;
      double lng;
      var fallback = false;

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

      final mosques = await _service.findNearby(
        latitude: lat,
        longitude: lng,
      );

      if (!mounted) return;
      state = state.copyWith(
        mosques: mosques,
        isLoading: false,
        usingFallbackLocation: fallback,
        clearStaleCache: true,
      );
    } catch (e) {
      if (!mounted) return;

      // The live fetch failed (e.g. the free Overpass instance is
      // overloaded) — fall back to the last successful result rather than
      // leaving the user with a bare error screen.
      final cached = await _service.getCachedNearby();
      if (!mounted) return;

      if (cached != null && cached.mosques.isNotEmpty) {
        state = state.copyWith(
          mosques: cached.mosques,
          isLoading: false,
          error: null,
          staleCacheAt: cached.cachedAt,
        );
      } else {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }
}

final mosqueLocatorProvider = StateNotifierProvider.autoDispose<
  MosqueLocatorNotifier,
  MosqueLocatorState
>((ref) {
  final service = ref.watch(mosqueLocatorServiceProvider);
  final locationService = ref.watch(locationServiceProvider);
  return MosqueLocatorNotifier(service, locationService);
});
