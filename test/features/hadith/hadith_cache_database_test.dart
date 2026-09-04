import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/features/hadith/models/hadith.dart';
import 'package:eslamy/features/hadith/service/hadith_cache_database.dart';

import '../../support/sqflite_ffi_setup.dart';

void main() {
  setUpAll(initSqfliteFfiForTests);

  final db = HadithCacheDatabase();

  const bookSlug = 'bukhari';
  const bookName = 'Sahih al-Bukhari';
  const cacheKey = 'eng-bukhari';

  List<HadithItem> sampleItems() => const [
    HadithItem(
      id: 1001,
      narrator: 'Umar ibn al-Khattab',
      body: 'Actions are judged by intentions.',
      book: bookSlug,
      bookName: bookName,
      hadithNumber: 1,
    ),
    HadithItem(
      id: 1002,
      narrator: 'Aisha',
      body: 'The second hadith body.',
      book: bookSlug,
      bookName: bookName,
      hadithNumber: 2,
    ),
  ];

  setUp(() async {
    await db.cacheBook(cacheKey, []);
    await db.cacheBook('ara-bukhari', []);
  });

  group('cacheBook/getBookHadiths', () {
    test('round-trips id/narrator/body/hadithNumber', () async {
      await db.cacheBook(cacheKey, sampleItems());

      final results = await db.getBookHadiths(cacheKey, bookSlug, bookName);

      expect(results, hasLength(2));
      expect(results[0].id, 1001);
      expect(results[0].narrator, 'Umar ibn al-Khattab');
      expect(results[0].body, 'Actions are judged by intentions.');
      expect(results[0].hadithNumber, 1);
      expect(results[1].id, 1002);
      expect(results[1].narrator, 'Aisha');
      expect(results[1].body, 'The second hadith body.');
      expect(results[1].hadithNumber, 2);
    });

    test(
      'title is rebuilt from bookName/hadith_number, not stored verbatim',
      () async {
        await db.cacheBook(cacheKey, [
          const HadithItem(
            id: 2001,
            title: 'Some title that should be ignored',
            body: 'body text',
            hadithNumber: 7,
          ),
        ]);

        final results = await db.getBookHadiths(
          cacheKey,
          bookSlug,
          'A Different Book Name',
        );

        expect(results.single.title, 'A Different Book Name #7');
      },
    );

    test('caches book/hadith with a fractional hadith number', () async {
      await db.cacheBook(cacheKey, [
        const HadithItem(
          id: 3001,
          body: 'Fractional numbered hadith.',
          hadithNumber: 402.2,
        ),
      ]);

      final results = await db.getBookHadiths(cacheKey, bookSlug, bookName);

      expect(results.single.hadithNumber, 402.2);
      expect(results.single.title, '$bookName #402.2');
    });
  });

  group('countForBook', () {
    test('reflects the number of cached hadiths for that book', () async {
      expect(await db.countForBook(cacheKey), 0);

      await db.cacheBook(cacheKey, sampleItems());

      expect(await db.countForBook(cacheKey), 2);
    });
  });

  group('re-caching the same cacheKey', () {
    test('fully replaces the old rows', () async {
      await db.cacheBook(cacheKey, sampleItems());
      expect(await db.countForBook(cacheKey), 2);

      final replacement = [
        const HadithItem(
          id: 5001,
          body: 'Only one hadith now.',
          hadithNumber: 1,
        ),
      ];
      await db.cacheBook(cacheKey, replacement);

      expect(await db.countForBook(cacheKey), 1);
      final results = await db.getBookHadiths(cacheKey, bookSlug, bookName);
      expect(results, hasLength(1));
      expect(results.single.id, 5001);
      expect(results.single.body, 'Only one hadith now.');
      expect(results.any((h) => h.id == 1001), isFalse);
      expect(results.any((h) => h.id == 1002), isFalse);
    });
  });

  group('different cacheKeys for the same underlying book', () {
    test('do not collide', () async {
      await db.cacheBook(cacheKey, sampleItems());
      await db.cacheBook('ara-bukhari', [
        const HadithItem(id: 9001, body: 'Arabic text here', hadithNumber: 1),
      ]);

      expect(await db.countForBook(cacheKey), 2);
      expect(await db.countForBook('ara-bukhari'), 1);

      final english = await db.getBookHadiths(cacheKey, bookSlug, bookName);
      final arabic = await db.getBookHadiths('ara-bukhari', bookSlug, bookName);
      expect(english, hasLength(2));
      expect(arabic, hasLength(1));
      expect(arabic.single.id, 9001);
    });
  });
}
