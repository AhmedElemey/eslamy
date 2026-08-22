import 'package:eslamy/features/hadith/models/hadith.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/favorite_hadith.dart';
import '../models/favorite_surah.dart';

class FavoritesDatabase {
  static final FavoritesDatabase _instance = FavoritesDatabase._internal();
  factory FavoritesDatabase() => _instance;
  FavoritesDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'favorites.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        hadith_id INTEGER NOT NULL,
        title TEXT,
        narrator TEXT,
        body TEXT,
        saved_at TEXT NOT NULL,
        book_slug TEXT,
        book_name TEXT,
        hadith_number INTEGER
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_hadith_id ON favorites(hadith_id)
    ''');

    await db.execute(_quranFavoritesTableSql);
  }

  Future<void> _upgradeTables(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE favorites ADD COLUMN book_slug TEXT');
      await db.execute('ALTER TABLE favorites ADD COLUMN book_name TEXT');
      await db.execute(
        'ALTER TABLE favorites ADD COLUMN hadith_number INTEGER',
      );
    }
    if (oldVersion < 3) {
      await db.execute(_quranFavoritesTableSql);
    }
  }

  static const String _quranFavoritesTableSql = '''
    CREATE TABLE IF NOT EXISTS quran_favorites (
      chapter_number INTEGER PRIMARY KEY,
      chapter_name TEXT,
      chapter_english_name TEXT,
      saved_at TEXT NOT NULL
    )
  ''';

  FavoriteHadith _favoriteFromMap(Map<String, dynamic> map) {
    return FavoriteHadith(
      id: map['id'],
      hadith: HadithItem(
        id: map['hadith_id'],
        title: map['title'] ?? '',
        narrator: map['narrator'],
        body: map['body'],
        book: map['book_slug'],
        bookName: map['book_name'],
        hadithNumber: map['hadith_number'] as num?,
      ),
      savedAt: DateTime.parse(map['saved_at']),
    );
  }

  Future<int> insertFavorite(FavoriteHadith favorite) async {
    final db = await database;
    return await db.insert('favorites', {
      'id': favorite.id,
      'hadith_id': favorite.hadith.id,
      'title': favorite.hadith.title,
      'narrator': favorite.hadith.narrator,
      'body': favorite.hadith.body,
      'saved_at': favorite.savedAt.toIso8601String(),
      'book_slug': favorite.hadith.book,
      'book_name': favorite.hadith.bookName,
      'hadith_number': favorite.hadith.hadithNumber,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FavoriteHadith>> getAllFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      orderBy: 'saved_at DESC',
    );

    return maps.map(_favoriteFromMap).toList();
  }

  Future<FavoriteHadith?> getFavoriteById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _favoriteFromMap(maps.first);
  }

  Future<FavoriteHadith?> getFavoriteByHadithId(int hadithId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'hadith_id = ?',
      whereArgs: [hadithId],
    );

    if (maps.isEmpty) return null;
    return _favoriteFromMap(maps.first);
  }

  Future<int> deleteFavorite(String id) async {
    final db = await database;
    return await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFavoriteByHadithId(int hadithId) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'hadith_id = ?',
      whereArgs: [hadithId],
    );
  }

  Future<int> deleteAllFavorites() async {
    final db = await database;
    return await db.delete('favorites');
  }

  Future<bool> isFavorite(int hadithId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'hadith_id = ?',
      whereArgs: [hadithId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<int> getFavoritesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM favorites');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  FavoriteSurah _quranFavoriteFromMap(Map<String, dynamic> map) {
    return FavoriteSurah(
      chapterNumber: map['chapter_number'] as int,
      chapterName: map['chapter_name'] as String? ?? '',
      chapterEnglishName: map['chapter_english_name'] as String? ?? '',
      savedAt: DateTime.parse(map['saved_at'] as String),
    );
  }

  Future<int> insertQuranFavorite(FavoriteSurah favorite) async {
    final db = await database;
    return await db.insert('quran_favorites', {
      'chapter_number': favorite.chapterNumber,
      'chapter_name': favorite.chapterName,
      'chapter_english_name': favorite.chapterEnglishName,
      'saved_at': favorite.savedAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FavoriteSurah>> getAllQuranFavorites() async {
    final db = await database;
    final maps = await db.query('quran_favorites', orderBy: 'saved_at DESC');
    return maps.map(_quranFavoriteFromMap).toList();
  }

  Future<int> deleteQuranFavoriteByChapter(int chapterNumber) async {
    final db = await database;
    return await db.delete(
      'quran_favorites',
      where: 'chapter_number = ?',
      whereArgs: [chapterNumber],
    );
  }

  Future<bool> isQuranFavorite(int chapterNumber) async {
    final db = await database;
    final maps = await db.query(
      'quran_favorites',
      where: 'chapter_number = ?',
      whereArgs: [chapterNumber],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<int> deleteAllQuranFavorites() async {
    final db = await database;
    return await db.delete('quran_favorites');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
