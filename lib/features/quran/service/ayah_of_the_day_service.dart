import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ayah_of_the_day.dart';

/// Persists the currently-picked "ayah of the day", mirroring
/// translation_preferences_service.dart's SharedPreferences-backed shape.
class AyahOfTheDayService {
  static const _key = 'ayah_of_the_day';

  Future<AyahOfTheDay?> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return AyahOfTheDay.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(AyahOfTheDay ayah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(ayah.toJson()));
  }
}

/// `yyyy-MM-dd` key for "today", local time.
String todayDateKey() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}
