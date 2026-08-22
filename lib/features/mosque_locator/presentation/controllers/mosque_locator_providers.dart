import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_providers.dart'
    show locationServiceProvider;
import '../../../prayer_times/service/location_service.dart';
import '../../models/mosque.dart';
import '../../service/mosque_locator_service.dart';

enum MosqueLocationIssue {
  permissionDenied,
  permissionDeniedForever,
  servicesDisabled,
}

class MosqueLocatorState {
  final List<Mosque> mosques;
  final bool isLoading;
  final String? error;
  final bool usingCachedGps;
  final MosqueLocationIssue? locationIssue;
  final DateTime? staleCacheAt;

  const MosqueLocatorState({
    this.mosques = const [],
    this.isLoading = false,
    this.error,
    this.usingCachedGps = false,
    this.locationIssue,
    this.staleCacheAt,
  });

  /// True when [mosques] came from the on-device cache because the live
  /// fetch just failed, rather than from a fresh successful fetch.
  bool get isShowingStaleCache => staleCacheAt != null;

  MosqueLocatorState copyWith({
    List<Mosque>? mosques,
    bool? isLoading,
    String? error,
    bool? usingCachedGps,
    MosqueLocationIssue? locationIssue,
    DateTime? staleCacheAt,
    bool clearStaleCache = false,
    bool clearLocationIssue = false,
  }) {
    return MosqueLocatorState(
      mosques: mosques ?? this.mosques,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      usingCachedGps: usingCachedGps ?? this.usingCachedGps,
      locationIssue:
          clearLocationIssue ? null : (locationIssue ?? this.locationIssue),
      staleCacheAt:
          clearStaleCache ? null : (staleCacheAt ?? this.staleCacheAt),
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
    state = state.copyWith(
      isLoading: true,
      error: null,
      clearLocationIssue: true,
    );
    try {
      final fix = await _locationService.obtainFix(
        accuracy: LocationAccuracy.high,
      );

      if (!fix.hasCoordinates) {
        if (fix.kind == LocationFixKind.servicesDisabled) {
          final cached = await _locationService.getCachedPosition();
          if (cached != null) {
            final mosques = await _service.findNearby(
              latitude: cached.$1,
              longitude: cached.$2,
            );
            if (!mounted) return;
            state = state.copyWith(
              mosques: mosques,
              isLoading: false,
              usingCachedGps: true,
              clearStaleCache: true,
              clearLocationIssue: true,
            );
            return;
          }
        }
        if (!mounted) return;
        state = state.copyWith(
          isLoading: false,
          mosques: const [],
          locationIssue: switch (fix.kind) {
            LocationFixKind.permissionDenied =>
              MosqueLocationIssue.permissionDenied,
            LocationFixKind.permissionDeniedForever =>
              MosqueLocationIssue.permissionDeniedForever,
            LocationFixKind.servicesDisabled =>
              MosqueLocationIssue.servicesDisabled,
            _ => MosqueLocationIssue.permissionDenied,
          },
          error: fix.error,
        );
        return;
      }

      final lat = fix.latitude!;
      final lng = fix.longitude!;
      final usingCachedGps = fix.kind == LocationFixKind.cached;

      final mosques = await _service.findNearby(latitude: lat, longitude: lng);

      if (!mounted) return;
      state = state.copyWith(
        mosques: mosques,
        isLoading: false,
        usingCachedGps: usingCachedGps,
        clearStaleCache: true,
        clearLocationIssue: true,
      );
    } catch (e) {
      if (!mounted) return;

      final cachedFix = await _locationService.getCachedPosition();
      final cached = await _service.getCachedNearby(
        latitude: cachedFix?.$1,
        longitude: cachedFix?.$2,
      );
      if (!mounted) return;

      if (cached != null && cached.mosques.isNotEmpty) {
        state = state.copyWith(
          mosques: cached.mosques,
          isLoading: false,
          error: null,
          staleCacheAt: cached.cachedAt,
          usingCachedGps: true,
        );
      } else {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> openSystemSettings() async {
    if (state.locationIssue == MosqueLocationIssue.servicesDisabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
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
