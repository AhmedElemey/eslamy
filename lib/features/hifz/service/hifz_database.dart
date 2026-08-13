import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Which surahs (1-114) the user has marked as memorized.
class HifzDatabase {
  static final HifzDatabase _instance = HifzDatabase._internal();
  factory HifzDatabase() => _instance;
  HifzDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'hifz.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE hifz_progress (
            surah_number INTEGER PRIMARY KEY,
            memorized_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<Set<int>> getMemorizedSurahs() async {
    final db = await database;
    final rows = await db.query('hifz_progress');
    return rows.map((r) => r['surah_number'] as int).toSet();
  }

  Future<void> markMemorized(int surahNumber) async {
    final db = await database;
    await db.insert('hifz_progress', {
      'surah_number': surahNumber,
      'memorized_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> unmarkMemorized(int surahNumber) async {
    final db = await database;
    await db.delete(
      'hifz_progress',
      where: 'surah_number = ?',
      whereArgs: [surahNumber],
    );
  }
}
