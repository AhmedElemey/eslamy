import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/settings_database.dart';

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  static const String _key = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    final db = SettingsDatabase();
    final stored = await db.getValue(_key);
    return _fromString(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(mode);
    final db = SettingsDatabase();
    await db.setValue(_key, mode.name);
  }

  ThemeMode _fromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  () => ThemeModeController(),
);
