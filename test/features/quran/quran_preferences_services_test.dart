import 'package:eslamy/features/quran/models/quran_models.dart';
import 'package:eslamy/features/quran/service/memory_preferences_service.dart';
import 'package:eslamy/features/quran/service/reciter_preferences_service.dart';
import 'package:eslamy/features/quran/service/tajweed_preferences_service.dart';
import 'package:eslamy/features/quran/service/translation_preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _testReciter = Reciter(
  id: 42,
  name: 'Test Reciter',
  arabicName: 'قارئ الاختبار',
  relativePath: 'Test_Reciter',
);

void main() {
  // ReciterPreferencesService caches its SharedPreferences instance in a
  // static field the first time any test touches it, so a later
  // SharedPreferences.setMockInitialValues() call in setUp does not reset
  // its view of storage. Clearing through the service's own API instead
  // keeps every test isolated regardless of that caching.
  Future<void> resetReciterState() async {
    await ReciterPreferencesService.clearSelectedReciter();
  }

  group('ReciterPreferencesService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await resetReciterState();
    });

    test('loadSelectedReciter returns null when nothing has been saved', () async {
      expect(await ReciterPreferencesService.loadSelectedReciter(), isNull);
    });

    test('saveSelectedReciter then loadSelectedReciter round-trips', () async {
      await ReciterPreferencesService.saveSelectedReciter(_testReciter);

      final loaded = await ReciterPreferencesService.loadSelectedReciter();
      expect(loaded, isNotNull);
      expect(loaded!.id, _testReciter.id);
      expect(loaded.name, _testReciter.name);
      expect(loaded.arabicName, _testReciter.arabicName);
      expect(loaded.relativePath, _testReciter.relativePath);
    });

    test('clearSelectedReciter removes a previously saved reciter', () async {
      await ReciterPreferencesService.saveSelectedReciter(_testReciter);
      await ReciterPreferencesService.clearSelectedReciter();

      expect(await ReciterPreferencesService.loadSelectedReciter(), isNull);
    });

    test('saveSelectedReciter also mirrors into MemoryPreferencesService', () async {
      await ReciterPreferencesService.saveSelectedReciter(_testReciter);

      final memoryReciter = MemoryPreferencesService.loadSelectedReciter();
      expect(memoryReciter, isNotNull);
      expect(memoryReciter!.id, _testReciter.id);
    });

    test('clearSelectedReciter also clears MemoryPreferencesService', () async {
      await ReciterPreferencesService.saveSelectedReciter(_testReciter);
      await ReciterPreferencesService.clearSelectedReciter();

      expect(MemoryPreferencesService.loadSelectedReciter(), isNull);
      expect(MemoryPreferencesService.hasData(), isFalse);
    });

    test('getDefaultReciter returns the fixed fallback reciter', () {
      final defaultReciter = ReciterPreferencesService.getDefaultReciter();

      expect(defaultReciter.id, 1);
      expect(defaultReciter.name, 'Abdul Basit Mujawwad');
      expect(defaultReciter.arabicName, 'عبد الباسط عبد الصمد');
      expect(defaultReciter.relativePath, 'Abdul_Basit_Mujawwad');
    });
  });

  group('MemoryPreferencesService', () {
    setUp(() {
      MemoryPreferencesService.clearSelectedReciter();
    });

    test('loadSelectedReciter returns null when nothing has been saved', () {
      expect(MemoryPreferencesService.loadSelectedReciter(), isNull);
    });

    test('hasData is false when nothing has been saved', () {
      expect(MemoryPreferencesService.hasData(), isFalse);
    });

    test('saveSelectedReciter then loadSelectedReciter round-trips', () {
      MemoryPreferencesService.saveSelectedReciter(_testReciter);

      final loaded = MemoryPreferencesService.loadSelectedReciter();
      expect(loaded, isNotNull);
      expect(loaded!.id, _testReciter.id);
      expect(loaded.name, _testReciter.name);
      expect(loaded.arabicName, _testReciter.arabicName);
      expect(loaded.relativePath, _testReciter.relativePath);
      expect(MemoryPreferencesService.hasData(), isTrue);
    });

    test('clearSelectedReciter removes the saved reciter', () {
      MemoryPreferencesService.saveSelectedReciter(_testReciter);
      MemoryPreferencesService.clearSelectedReciter();

      expect(MemoryPreferencesService.loadSelectedReciter(), isNull);
      expect(MemoryPreferencesService.hasData(), isFalse);
    });
  });

  group('TajweedPreferencesService', () {
    late TajweedPreferencesService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = TajweedPreferencesService();
    });

    test('loadEnabled defaults to true when nothing is stored', () async {
      expect(await service.loadEnabled(), isTrue);
    });

    test('saveEnabled(false) then loadEnabled round-trips', () async {
      await service.saveEnabled(false);
      expect(await service.loadEnabled(), isFalse);
    });

    test('saveEnabled(true) then loadEnabled round-trips', () async {
      await service.saveEnabled(false);
      await service.saveEnabled(true);
      expect(await service.loadEnabled(), isTrue);
    });
  });

  group('TranslationPreferencesService', () {
    late TranslationPreferencesService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = TranslationPreferencesService();
    });

    test('loadSelectedEdition returns null when nothing is stored', () async {
      expect(await service.loadSelectedEdition(), isNull);
    });

    test('saveSelectedEdition then loadSelectedEdition round-trips', () async {
      await service.saveSelectedEdition('en.sahih');
      expect(await service.loadSelectedEdition(), 'en.sahih');
    });

    test('saveSelectedEdition overwrites a previous edition', () async {
      await service.saveSelectedEdition('en.sahih');
      await service.saveSelectedEdition('ar.muyassar');
      expect(await service.loadSelectedEdition(), 'ar.muyassar');
    });
  });
}
