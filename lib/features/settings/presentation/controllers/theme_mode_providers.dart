import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/settings_database.dart';

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  static const String _key = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    final db = SettingsDatabase();
    final stored = await db.getValue(_key);
    if (stored == null || stored.isEmpty) {
      await db.setValue(_key, ThemeMode.light.name);
      return ThemeMode.light;
    }
    return _fromString(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(mode);
    final db = SettingsDatabase();
    await db.setValue(_key, mode.name);
  }

  ThemeMode _fromString(String? value) {
    switch (value) {
      case 'system':
        return ThemeMode.system;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  () => ThemeModeController(),
);
