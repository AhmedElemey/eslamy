import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/features/favorites/models/favorite_hadith.dart';
import 'package:eslamy/features/favorites/models/favorite_surah.dart';
import 'package:eslamy/features/favorites/service/favorites_database.dart';
import 'package:eslamy/features/hadith/models/hadith.dart';

import '../../support/sqflite_ffi_setup.dart';

FavoriteHadith _hadithFavorite({
  String id = 'fav-1',
  int hadithId = 402,
  String title = 'A hadith',
  DateTime? savedAt,
}) {
  return FavoriteHadith(
    id: id,
    hadith: HadithItem(
      id: hadithId,
      title: title,
      narrator: 'Narrator',
      body: 'Body text',
      book: 'bukhari',
      bookName: 'Sahih al-Bukhari',
      hadithNumber: hadithId,
    ),
    savedAt: savedAt ?? DateTime(2026, 1, 1),
  );
}

FavoriteSurah _surahFavorite({
  int chapterNumber = 1,
  String chapterName = 'الفاتحة',
  String chapterEnglishName = 'Al-Fatihah',
  DateTime? savedAt,
}) {
  return FavoriteSurah(
    chapterNumber: chapterNumber,
    chapterName: chapterName,
    chapterEnglishName: chapterEnglishName,
    savedAt: savedAt ?? DateTime(2026, 1, 1),
  );
}

void main() {
  setUpAll(() {
    initSqfliteFfiForTests();
  });

  final db = FavoritesDatabase();

  setUp(() async {
    await db.deleteAllFavorites();
    await db.deleteAllQuranFavorites();
  });

  group('FavoritesDatabase hadith favorites', () {
    test('insert then getFavoriteById returns the same favorite', () async {
      final favorite = _hadithFavorite();
      await db.insertFavorite(favorite);

      final fetched = await db.getFavoriteById(favorite.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, favorite.id);
      expect(fetched.hadith.id, favorite.hadith.id);
      expect(fetched.hadith.title, favorite.hadith.title);
      expect(fetched.hadith.narrator, favorite.hadith.narrator);
      expect(fetched.hadith.body, favorite.hadith.body);
      expect(fetched.hadith.book, favorite.hadith.book);
      expect(fetched.hadith.bookName, favorite.hadith.bookName);
      expect(fetched.savedAt, favorite.savedAt);
    });

    test('getFavoriteById returns null for an unknown id', () async {
      expect(await db.getFavoriteById('nonexistent'), isNull);
    });

    test('getFavoriteByHadithId finds a favorite by its hadith id', () async {
      final favorite = _hadithFavorite(id: 'fav-2', hadithId: 555);
      await db.insertFavorite(favorite);

      final fetched = await db.getFavoriteByHadithId(555);
      expect(fetched, isNotNull);
      expect(fetched!.id, 'fav-2');

      expect(await db.getFavoriteByHadithId(999), isNull);
    });

    test('isFavorite is true after insert and false after delete', () async {
      final favorite = _hadithFavorite(id: 'fav-3', hadithId: 777);
      expect(await db.isFavorite(777), isFalse);

      await db.insertFavorite(favorite);
      expect(await db.isFavorite(777), isTrue);

      await db.deleteFavorite('fav-3');
      expect(await db.isFavorite(777), isFalse);
    });

    test('deleteFavoriteByHadithId removes the matching row', () async {
      await db.insertFavorite(_hadithFavorite(id: 'fav-4', hadithId: 888));
      expect(await db.isFavorite(888), isTrue);

      final deletedCount = await db.deleteFavoriteByHadithId(888);
      expect(deletedCount, 1);
      expect(await db.isFavorite(888), isFalse);
    });

    test(
      'inserting with the same id replaces the row instead of duplicating',
      () async {
        await db.insertFavorite(
          _hadithFavorite(id: 'fav-5', hadithId: 1, title: 'Original'),
        );
        await db.insertFavorite(
          _hadithFavorite(id: 'fav-5', hadithId: 2, title: 'Updated'),
        );

        final all = await db.getAllFavorites();
        expect(all, hasLength(1));
        expect(all.single.hadith.title, 'Updated');
        expect(all.single.hadith.id, 2);
      },
    );

    test('getAllFavorites orders newest saved_at first', () async {
      await db.insertFavorite(
        _hadithFavorite(
          id: 'old',
          hadithId: 1,
          savedAt: DateTime(2020, 1, 1),
        ),
      );
      await db.insertFavorite(
        _hadithFavorite(
          id: 'new',
          hadithId: 2,
          savedAt: DateTime(2026, 1, 1),
        ),
      );

      final all = await db.getAllFavorites();
      expect(all.map((f) => f.id), ['new', 'old']);
    });

    test('getFavoritesCount reflects the number of hadith favorites', () async {
      expect(await db.getFavoritesCount(), 0);

      await db.insertFavorite(_hadithFavorite(id: 'a', hadithId: 1));
      await db.insertFavorite(_hadithFavorite(id: 'b', hadithId: 2));
      expect(await db.getFavoritesCount(), 2);

      await db.deleteFavorite('a');
      expect(await db.getFavoritesCount(), 1);
    });
  });

  group('FavoritesDatabase quran favorites', () {
    test('insert then getAllQuranFavorites returns the surah', () async {
      final favorite = _surahFavorite();
      await db.insertQuranFavorite(favorite);

      final all = await db.getAllQuranFavorites();
      expect(all, hasLength(1));
      expect(all.single.chapterNumber, favorite.chapterNumber);
      expect(all.single.chapterName, favorite.chapterName);
      expect(all.single.chapterEnglishName, favorite.chapterEnglishName);
    });

    test('isQuranFavorite true/false and delete removes it', () async {
      expect(await db.isQuranFavorite(2), isFalse);

      await db.insertQuranFavorite(_surahFavorite(chapterNumber: 2));
      expect(await db.isQuranFavorite(2), isTrue);

      await db.deleteQuranFavoriteByChapter(2);
      expect(await db.isQuranFavorite(2), isFalse);
    });

    test(
      'inserting the same chapter twice replaces rather than duplicates',
      () async {
        await db.insertQuranFavorite(
          _surahFavorite(chapterNumber: 3, chapterName: 'Old'),
        );
        await db.insertQuranFavorite(
          _surahFavorite(chapterNumber: 3, chapterName: 'New'),
        );

        final all = await db.getAllQuranFavorites();
        expect(all, hasLength(1));
        expect(all.single.chapterName, 'New');
      },
    );

    test(
      'quran favorites and hadith favorites live in separate tables',
      () async {
        await db.insertFavorite(_hadithFavorite(id: 'h1', hadithId: 1));
        await db.insertQuranFavorite(_surahFavorite(chapterNumber: 1));

        expect(await db.getFavoritesCount(), 1);
        final quranAll = await db.getAllQuranFavorites();
        expect(quranAll, hasLength(1));

        await db.deleteAllQuranFavorites();
        expect(await db.getFavoritesCount(), 1);
        expect(await db.getAllQuranFavorites(), isEmpty);

        await db.deleteAllFavorites();
        expect(await db.getFavoritesCount(), 0);
      },
    );
  });
}
