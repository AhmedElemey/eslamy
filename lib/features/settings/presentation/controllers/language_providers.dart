import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/settings_database.dart';

enum AppLanguage { english, arabic, italian }

extension AppLanguageLocale on AppLanguage {
  Locale get locale => switch (this) {
    AppLanguage.english => const Locale('en'),
    AppLanguage.arabic => const Locale('ar'),
    AppLanguage.italian => const Locale('it'),
  };
}

class LanguageController extends AsyncNotifier<AppLanguage> {
  static const String _key = 'app_language';

  @override
  Future<AppLanguage> build() async {
    final db = SettingsDatabase();
    final stored = await db.getValue(_key);
    return _fromString(stored);
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = AsyncData(language);
    final db = SettingsDatabase();
    await db.setValue(_key, language.name);
  }

  AppLanguage _fromString(String? value) {
    switch (value) {
      case 'english':
        return AppLanguage.english;
      case 'italian':
        return AppLanguage.italian;
      default:
        return AppLanguage.arabic;
    }
  }
}

final languageProvider = AsyncNotifierProvider<LanguageController, AppLanguage>(
  () => LanguageController(),
);
