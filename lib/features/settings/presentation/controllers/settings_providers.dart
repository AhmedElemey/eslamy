import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/service/settings_database.dart';

class TextSizeController extends AsyncNotifier<int> {
  static const String _key = 'text_size_delta';

  @override
  Future<int> build() async {
    final db = SettingsDatabase();
    final stored = await db.getValue(_key);
    final value = int.tryParse(stored ?? '') ?? 0;
    return value;
  }

  Future<void> setTextSize(int delta) async {
    state = const AsyncLoading();
    final db = SettingsDatabase();
    await db.setValue(_key, delta.toString());
    state = AsyncData(delta);
  }
}

final textSizeProvider = AsyncNotifierProvider<TextSizeController, int>(() {
  return TextSizeController();
});
