import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/dhikr_preset.dart';

/// Persists per-preset counts, the last-selected preset, and any dhikrs the
/// user has added themselves (see TasbihPage's "Custom" dialog) so the
/// counter survives app restarts. Mirrors reciter_preferences_service.dart's
/// SharedPreferences-backed shape.
class TasbihPreferencesService {
  static const _countKeyPrefix = 'tasbih_count_';
  static const _selectedKey = 'tasbih_selected_preset';
  static const _customPresetsKey = 'tasbih_custom_presets';

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

  Future<List<DhikrPreset>> getCustomPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customPresetsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => DhikrPreset.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addCustomPreset(DhikrPreset preset) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getCustomPresets();
    final updated = [...existing, preset];
    await prefs.setString(
      _customPresetsKey,
      jsonEncode(updated.map((p) => p.toJson()).toList()),
    );
  }
}
