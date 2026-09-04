import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/features/duas/data/azkar_cache_database.dart';
import 'package:eslamy/features/duas/data/models/azkar_models.dart';

import '../../support/sqflite_ffi_setup.dart';

void main() {
  setUpAll(initSqfliteFfiForTests);

  final db = AzkarCacheDatabase();

  const morningCategory = AzkarCategory(
    id: 'morning',
    name: 'Morning Azkar',
    description: 'Duas to say in the morning',
  );
  const eveningCategory = AzkarCategory(
    id: 'evening',
    name: 'Evening Azkar',
    description: 'Duas to say in the evening',
  );

  const firstItem = AzkarItem(
    id: 1,
    categoryId: 'morning',
    title: 'Ayat al-Kursi',
    arabic: 'arabic text 1',
    transliteration: 'transliteration 1',
    translation: 'translation 1',
    source: 'Quran 2:255',
    repeat: 1,
  );
  const secondItem = AzkarItem(
    id: 2,
    categoryId: 'morning',
    title: 'Three Quls',
    arabic: 'arabic text 2',
    transliteration: 'transliteration 2',
    translation: 'translation 2',
    source: 'Various',
    repeat: 3,
  );
  const thirdItem = AzkarItem(
    id: 3,
    categoryId: 'evening',
    title: 'Evening dua',
    arabic: 'arabic text 3',
    transliteration: 'transliteration 3',
    translation: 'translation 3',
    source: 'Sunnah',
    repeat: 1,
  );

  final sampleDataset = AzkarDataset(
    categories: [morningCategory, eveningCategory],
    items: [firstItem, secondItem, thirdItem],
  );

  setUp(() async {
    await db.replaceAll(const AzkarDataset(categories: [], items: []));
  });

  group('isEmpty', () {
    test('is true before any data has been stored', () async {
      expect(await db.isEmpty(), isTrue);
    });

    test('is false after replaceAll stores items', () async {
      await db.replaceAll(sampleDataset);
      expect(await db.isEmpty(), isFalse);
    });
  });

  group('getCategories', () {
    test('returns categories sorted by name', () async {
      await db.replaceAll(sampleDataset);

      final categories = await db.getCategories();

      expect(categories, hasLength(2));
      expect(categories.map((c) => c.name), ['Evening Azkar', 'Morning Azkar']);
      expect(categories[0].id, 'evening');
      expect(categories[0].description, 'Duas to say in the evening');
      expect(categories[1].id, 'morning');
      expect(categories[1].description, 'Duas to say in the morning');
    });
  });

  group('getAllItems', () {
    test('returns every item across categories with fields intact', () async {
      await db.replaceAll(sampleDataset);

      final items = await db.getAllItems();

      expect(items, hasLength(3));
      expect(items.map((i) => i.id), [1, 2, 3]);

      final first = items.firstWhere((i) => i.id == 1);
      expect(first.categoryId, 'morning');
      expect(first.title, 'Ayat al-Kursi');
      expect(first.arabic, 'arabic text 1');
      expect(first.transliteration, 'transliteration 1');
      expect(first.translation, 'translation 1');
      expect(first.source, 'Quran 2:255');
      expect(first.repeat, 1);

      final third = items.firstWhere((i) => i.id == 3);
      expect(third.categoryId, 'evening');
      expect(third.repeat, 1);
    });
  });

  group('getItemsForCategory', () {
    test('returns only items belonging to that category', () async {
      await db.replaceAll(sampleDataset);

      final morningItems = await db.getItemsForCategory('morning');
      final eveningItems = await db.getItemsForCategory('evening');

      expect(morningItems.map((i) => i.id), [1, 2]);
      expect(eveningItems.map((i) => i.id), [3]);
      expect(morningItems[1].title, 'Three Quls');
      expect(morningItems[1].repeat, 3);
    });

    test('returns an empty list for a category with no items', () async {
      await db.replaceAll(sampleDataset);
      expect(await db.getItemsForCategory('nonexistent'), isEmpty);
    });
  });

  group('replaceAll called again', () {
    test('fully replaces both tables with the new dataset', () async {
      await db.replaceAll(sampleDataset);
      expect(await db.getCategories(), hasLength(2));
      expect(await db.getAllItems(), hasLength(3));

      const replacementDataset = AzkarDataset(
        categories: [
          AzkarCategory(id: 'night', name: 'Night Azkar', description: ''),
        ],
        items: [
          AzkarItem(
            id: 99,
            categoryId: 'night',
            title: 'Night dua',
            arabic: 'arabic night',
            transliteration: '',
            translation: '',
            source: '',
            repeat: 1,
          ),
        ],
      );
      await db.replaceAll(replacementDataset);

      final categories = await db.getCategories();
      expect(categories, hasLength(1));
      expect(categories.single.id, 'night');

      final items = await db.getAllItems();
      expect(items, hasLength(1));
      expect(items.single.id, 99);

      expect(await db.getItemsForCategory('morning'), isEmpty);
      expect(await db.getItemsForCategory('evening'), isEmpty);
    });
  });
}
