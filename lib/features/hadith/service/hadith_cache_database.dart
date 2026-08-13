import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/hadith.dart';

/// Local cache of downloaded hadith books, so a book only needs to be
/// fetched from the network once and search works fully offline afterwards.
class HadithCacheDatabase {
  static final HadithCacheDatabase _instance = HadithCacheDatabase._internal();
  factory HadithCacheDatabase() => _instance;
  HadithCacheDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'hadith_cache.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hadith_cache (
        id INTEGER PRIMARY KEY,
        book_slug TEXT NOT NULL,
        hadith_number INTEGER NOT NULL,
        narrator TEXT,
        body TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_book_slug ON hadith_cache(book_slug)');
  }

  Future<int> countForBook(String bookSlug) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM hadith_cache WHERE book_slug = ?',
      [bookSlug],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> cacheBook(String bookSlug, List<HadithItem> items) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('hadith_cache', where: 'book_slug = ?', whereArgs: [bookSlug]);
    for (final item in items) {
      batch.insert('hadith_cache', {
        'id': item.id,
        'book_slug': bookSlug,
        'hadith_number': item.hadithNumber,
        'narrator': item.narrator,
        'body': item.body ?? '',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<HadithItem>> getBookHadiths(String bookSlug, String bookName) async {
    final db = await database;
    final maps = await db.query(
      'hadith_cache',
      where: 'book_slug = ?',
      whereArgs: [bookSlug],
      orderBy: 'hadith_number ASC',
    );
    return maps
        .map(
          (m) => HadithItem(
            id: m['id'] as int,
            title: '$bookName #${m['hadith_number']}',
            narrator: m['narrator'] as String?,
            body: m['body'] as String?,
            book: bookSlug,
            bookName: bookName,
            hadithNumber: m['hadith_number'] as int,
          ),
        )
        .toList();
  }
}
