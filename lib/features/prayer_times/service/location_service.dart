import 'dart:async';

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

/// Outcome of an explicit "enable location" tap, before a GPS read.
enum LocationAccess { granted, denied, needsAppSettings, needsLocationSettings }

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

  /// Asks for location access the way the prayer-times Enable button needs:
  /// prompt when the system will still show one, otherwise tell the caller
  /// to open Settings or Location Services. Does not read a GPS fix.
  Future<LocationAccess> requestAccess() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationAccess.needsLocationSettings;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.deniedForever:
        return LocationAccess.needsAppSettings;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationAccess.denied;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationAccess.granted;
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    final fix = await obtainFix(accuracy: accuracy, timeLimit: timeLimit);
    final usable =
        fix.hasCoordinates &&
        (fix.kind == LocationFixKind.gps || fix.kind == LocationFixKind.cached);
    if (!usable) return null;
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
        final position = await _readCurrentPosition(
          accuracy: accuracy,
          timeLimit: timeLimit,
        );
        await _cachePosition(position.latitude, position.longitude);
        return LocationFix.gps(position.latitude, position.longitude);
      } catch (e, st) {
        debugPrint('GPS reading failed: $e\n$st');
        // A fast failure is usually Play Services, not a slow GPS. Retry
        // once through the platform location manager. A timeout already
        // waited; don't make the user wait again before last-known.
        if (e is! TimeoutException &&
            defaultTargetPlatform == TargetPlatform.android) {
          try {
            final position = await _readCurrentPosition(
              accuracy: accuracy,
              timeLimit: const Duration(seconds: 8),
              forceLocationManager: true,
            );
            await _cachePosition(position.latitude, position.longitude);
            return LocationFix.gps(position.latitude, position.longitude);
          } catch (e2, st2) {
            debugPrint('LocationManager reading failed: $e2\n$st2');
          }
        }
        final fallbackFix = await _lastKnownOrCached();
        if (fallbackFix != null) return fallbackFix;
        return LocationFix.unavailable(e.toString());
      }
    } catch (e, st) {
      debugPrint('Location lookup failed: $e\n$st');
      return LocationFix.unavailable(e.toString());
    }
  }

  Future<Position> _readCurrentPosition({
    required LocationAccuracy accuracy,
    required Duration? timeLimit,
    bool forceLocationManager = false,
  }) {
    final limit = timeLimit ?? const Duration(seconds: 15);
    final LocationSettings settings =
        defaultTargetPlatform == TargetPlatform.android
            ? AndroidSettings(
              accuracy: accuracy,
              timeLimit: limit,
              forceLocationManager: forceLocationManager,
            )
            : LocationSettings(accuracy: accuracy, timeLimit: limit);
    return Geolocator.getCurrentPosition(locationSettings: settings);
  }

  /// A city-level last fix is enough for prayer times, and much closer to
  /// the user than the Cairo default when a fresh read times out.
  Future<LocationFix?> _lastKnownOrCached() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        await _cachePosition(last.latitude, last.longitude);
        return LocationFix.cached(last.latitude, last.longitude);
      }
    } catch (e, st) {
      debugPrint('Last known position failed: $e\n$st');
    }
    final cached = await getCachedPosition();
    if (cached == null) return null;
    return LocationFix.cached(cached.$1, cached.$2);
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
