import 'package:eslamy/features/hadith/models/hadith.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/favorite_hadith.dart';

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
      version: 1,
      onCreate: _createTables,
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
        saved_at TEXT NOT NULL
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_hadith_id ON favorites(hadith_id)
    ''');
  }

  Future<int> insertFavorite(FavoriteHadith favorite) async {
    final db = await database;
    return await db.insert(
      'favorites',
      {
        'id': favorite.id,
        'hadith_id': favorite.hadith.id,
        'title': favorite.hadith.title,
        'narrator': favorite.hadith.narrator,
        'body': favorite.hadith.body,
        'saved_at': favorite.savedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FavoriteHadith>> getAllFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      orderBy: 'saved_at DESC',
    );

    return maps.map((map) => FavoriteHadith(
      id: map['id'],
      hadith: HadithItem(
        id: map['hadith_id'],
        title: map['title'] ?? '',
        narrator: map['narrator'],
        body: map['body'],
      ),
      savedAt: DateTime.parse(map['saved_at']),
    )).toList();
  }

  Future<FavoriteHadith?> getFavoriteById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return FavoriteHadith(
      id: map['id'],
      hadith: HadithItem(
        id: map['hadith_id'],
        title: map['title'] ?? '',
        narrator: map['narrator'],
        body: map['body'],
      ),
      savedAt: DateTime.parse(map['saved_at']),
    );
  }

  Future<FavoriteHadith?> getFavoriteByHadithId(int hadithId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'hadith_id = ?',
      whereArgs: [hadithId],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return FavoriteHadith(
      id: map['id'],
      hadith: HadithItem(
        id: map['hadith_id'],
        title: map['title'] ?? '',
        narrator: map['narrator'],
        body: map['body'],
      ),
      savedAt: DateTime.parse(map['saved_at']),
    );
  }

  Future<int> deleteFavorite(String id) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
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

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
