import 'package:geolocator/geolocator.dart';
import '../../settings/service/settings_database.dart';

/// Cairo, Egypt — used only when the device has no location permission
/// and no previously cached position.
const fallbackLatitude = 30.0444;
const fallbackLongitude = 31.2357;

class LocationService {
  static const _latKey = 'prayer_location_lat';
  static const _lngKey = 'prayer_location_lng';

  final SettingsDatabase _settingsDb = SettingsDatabase();

  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      await _cachePosition(position.latitude, position.longitude);
      return position;
    } catch (_) {
      return null;
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
