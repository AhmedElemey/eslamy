import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/hajj_umrah_content.dart';
import '../../data/models/ritual_models.dart';

/// Whether Pilgrim Mode's location watch is turned on. Off by default —
/// this only ever runs in the foreground while the guide screen is open
/// and the user has explicitly opted in; there is no background geofence.
final pilgrimModeEnabledProvider = StateProvider<bool>((ref) => false);

/// The nearest [HolySite] the device is currently within, or null.
/// autoDispose: the underlying position stream is only alive while this
/// provider is watched, and Riverpod cancels it automatically once the
/// last listener (Pilgrim Mode toggle + this screen) goes away.
final nearestHolySiteProvider = StreamProvider.autoDispose<HolySite?>((ref) {
  const settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 25,
  );
  return Geolocator.getPositionStream(locationSettings: settings).map((
    position,
  ) {
    for (final site in holySites) {
      final distanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        site.latitude,
        site.longitude,
      );
      if (distanceMeters <= site.radiusMeters) return site;
    }
    return null;
  });
});
