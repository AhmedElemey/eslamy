import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../settings/service/settings_database.dart';

/// Cairo, Egypt — used only by prayer times when the device has no location
/// permission and no previously cached position. The mosque locator does
/// **not** use this; a denied GPS fix must not pretend the user is in Cairo.
const fallbackLatitude = 30.0444;
const fallbackLongitude = 31.2357;

enum LocationFixKind {
  gps,
  cached,
  servicesDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class LocationFix {
  final LocationFixKind kind;
  final double? latitude;
  final double? longitude;
  final String? error;

  const LocationFix._(this.kind, {this.latitude, this.longitude, this.error});

  const LocationFix.gps(double latitude, double longitude)
    : this._(LocationFixKind.gps, latitude: latitude, longitude: longitude);

  const LocationFix.cached(double latitude, double longitude)
    : this._(LocationFixKind.cached, latitude: latitude, longitude: longitude);

  const LocationFix.servicesDisabled()
    : this._(LocationFixKind.servicesDisabled);

  const LocationFix.permissionDenied()
    : this._(LocationFixKind.permissionDenied);

  const LocationFix.permissionDeniedForever()
    : this._(LocationFixKind.permissionDeniedForever);

  const LocationFix.unavailable([String? error])
    : this._(LocationFixKind.unavailable, error: error);

  bool get hasCoordinates => latitude != null && longitude != null;
}

class LocationService {
  static const _latKey = 'prayer_location_lat';
  static const _lngKey = 'prayer_location_lng';

  final SettingsDatabase _settingsDb = SettingsDatabase();

  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.medium,
    Duration? timeLimit,
  }) async {
    final fix = await obtainFix(accuracy: accuracy, timeLimit: timeLimit);
    if (!fix.hasCoordinates || fix.kind != LocationFixKind.gps) return null;
    return Position(
      longitude: fix.longitude!,
      latitude: fix.latitude!,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  /// Resolves the best available device location without falling back to a
  /// hardcoded city. Used by the mosque locator so "nearest" means nearest
  /// to the user, not nearest to Cairo.
  Future<LocationFix> obtainFix({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return const LocationFix.servicesDisabled();

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const LocationFix.permissionDenied();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationFix.permissionDeniedForever();
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: accuracy,
            timeLimit: timeLimit ?? const Duration(seconds: 15),
          ),
        );
        await _cachePosition(position.latitude, position.longitude);
        return LocationFix.gps(position.latitude, position.longitude);
      } catch (e, st) {
        debugPrint('GPS reading failed: $e\n$st');
        final cached = await getCachedPosition();
        if (cached != null) {
          return LocationFix.cached(cached.$1, cached.$2);
        }
        return LocationFix.unavailable(e.toString());
      }
    } catch (e, st) {
      debugPrint('Location lookup failed: $e\n$st');
      return LocationFix.unavailable(e.toString());
    }
  }

  Future<void> _cachePosition(double lat, double lng) async {
    await _settingsDb.setValue(_latKey, lat.toString());
    await _settingsDb.setValue(_lngKey, lng.toString());
  }

  Future<(double lat, double lng)?> getCachedPosition() async {
    final lat = double.tryParse(await _settingsDb.getValue(_latKey) ?? '');
    final lng = double.tryParse(await _settingsDb.getValue(_lngKey) ?? '');
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }
}
