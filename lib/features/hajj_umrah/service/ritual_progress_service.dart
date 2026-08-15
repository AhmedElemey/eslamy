import 'package:shared_preferences/shared_preferences.dart';

/// Persists which ritual step ids the user has marked complete, mirroring
/// tajweed_preferences_service.dart's SharedPreferences-backed shape.
class RitualProgressService {
  static const _key = 'hajj_umrah_completed_steps';

  Future<Set<String>> loadCompletedSteps() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).toSet();
  }

  Future<void> saveCompletedSteps(Set<String> stepIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, stepIds.toList());
  }
}
