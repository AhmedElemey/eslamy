import 'package:eslamy/features/tasbih/models/dhikr_preset.dart';
import 'package:eslamy/features/tasbih/service/tasbih_preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late TasbihPreferencesService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = TasbihPreferencesService();
  });

  group('DhikrPreset JSON', () {
    test('toJson/fromJson round-trips all fields', () {
      const preset = DhikrPreset(
        id: 'custom-1',
        arabic: 'سُبْحَانَ اللَّهِ',
        englishName: 'SubhanAllah',
        target: 33,
      );

      final decoded = DhikrPreset.fromJson(preset.toJson());

      expect(decoded.id, preset.id);
      expect(decoded.arabic, preset.arabic);
      expect(decoded.englishName, preset.englishName);
      expect(decoded.target, preset.target);
    });
  });

  group('getCount / setCount', () {
    test('defaults to 0 for a preset with nothing stored', () async {
      expect(await service.getCount('subhanallah'), 0);
    });

    test('round-trips a stored count', () async {
      await service.setCount('subhanallah', 12);
      expect(await service.getCount('subhanallah'), 12);
    });

    test('counts for different presets are independent', () async {
      await service.setCount('subhanallah', 12);
      await service.setCount('alhamdulillah', 30);

      expect(await service.getCount('subhanallah'), 12);
      expect(await service.getCount('alhamdulillah'), 30);
      expect(await service.getCount('allahuakbar'), 0);
    });
  });

  group('getSelectedPresetId / setSelectedPresetId', () {
    test('returns null when nothing has been selected', () async {
      expect(await service.getSelectedPresetId(), isNull);
    });

    test('round-trips the selected preset id', () async {
      await service.setSelectedPresetId('allahuakbar');
      expect(await service.getSelectedPresetId(), 'allahuakbar');
    });
  });

  group('getCustomPresets / addCustomPreset', () {
    test('returns an empty list when nothing has been stored', () async {
      expect(await service.getCustomPresets(), isEmpty);
    });

    test('addCustomPreset persists a decodable preset', () async {
      const preset = DhikrPreset(
        id: 'custom-1',
        arabic: 'ذِكْر',
        englishName: 'My Dhikr',
        target: 50,
      );

      await service.addCustomPreset(preset);

      final loaded = await service.getCustomPresets();
      expect(loaded, hasLength(1));
      expect(loaded.single.id, 'custom-1');
      expect(loaded.single.arabic, 'ذِكْر');
      expect(loaded.single.englishName, 'My Dhikr');
      expect(loaded.single.target, 50);
    });

    test('addCustomPreset appends to, rather than overwrites, existing presets', () async {
      const first = DhikrPreset(
        id: 'custom-1',
        arabic: 'أ',
        englishName: 'First',
        target: 10,
      );
      const second = DhikrPreset(
        id: 'custom-2',
        arabic: 'ب',
        englishName: 'Second',
        target: 20,
      );

      await service.addCustomPreset(first);
      await service.addCustomPreset(second);

      final loaded = await service.getCustomPresets();
      expect(loaded, hasLength(2));
      expect(loaded.map((p) => p.id), ['custom-1', 'custom-2']);
    });
  });
}
