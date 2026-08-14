import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's chosen translation edition identifier, mirroring
/// reciter_preferences_service.dart's SharedPreferences-backed shape.
class TranslationPreferencesService {
  static const _key = 'selected_translation_edition';

  Future<String?> loadSelectedEdition() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> saveSelectedEdition(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, identifier);
  }
}
