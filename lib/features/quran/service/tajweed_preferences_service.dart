import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether Tajweed color-coding is on, mirroring
/// translation_preferences_service.dart's SharedPreferences-backed shape.
class TajweedPreferencesService {
  static const _key = 'tajweed_coloring_enabled';

  Future<bool> loadEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  Future<void> saveEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}
