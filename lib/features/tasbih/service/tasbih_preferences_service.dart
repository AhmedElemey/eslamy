import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-preset counts and the last-selected preset so the counter
/// survives app restarts. Mirrors reciter_preferences_service.dart's
/// SharedPreferences-backed shape.
class TasbihPreferencesService {
  static const _countKeyPrefix = 'tasbih_count_';
  static const _selectedKey = 'tasbih_selected_preset';

  Future<int> getCount(String presetId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_countKeyPrefix$presetId') ?? 0;
  }

  Future<void> setCount(String presetId, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_countKeyPrefix$presetId', count);
  }

  Future<String?> getSelectedPresetId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedKey);
  }

  Future<void> setSelectedPresetId(String presetId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedKey, presetId);
  }
}
