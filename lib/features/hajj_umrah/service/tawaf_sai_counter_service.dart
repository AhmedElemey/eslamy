import 'package:shared_preferences/shared_preferences.dart';

/// Persists the Tawaf and Sa'i circuit counts separately, mirroring
/// tasbih_preferences_service.dart's SharedPreferences-backed shape.
class TawafSaiCounterService {
  static const _tawafKey = 'tawaf_counter_count';
  static const _saiKey = 'sai_counter_count';

  Future<int> getTawafCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tawafKey) ?? 0;
  }

  Future<void> setTawafCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tawafKey, count);
  }

  Future<int> getSaiCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_saiKey) ?? 0;
  }

  Future<void> setSaiCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_saiKey, count);
  }
}
