import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/last_read_position.dart';

/// Persists the last Mushaf reading position, mirroring
/// translation_preferences_service.dart's SharedPreferences-backed shape.
class LastReadPositionService {
  static const _key = 'last_read_position';

  Future<LastReadPosition?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return LastReadPosition.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(LastReadPosition position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(position.toJson()));
  }
}
