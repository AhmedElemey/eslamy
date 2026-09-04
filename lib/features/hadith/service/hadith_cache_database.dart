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
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        // v1 stored hadith_number as INTEGER and used a truncated id as the
        // PRIMARY KEY, so fractional numbers (402.2) overwrote 402. Drop and
        // recreate — the book re-downloads on next open.
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS hadith_cache');
          await _createTables(db, newVersion);
        }
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hadith_cache (
        id INTEGER PRIMARY KEY,
        book_slug TEXT NOT NULL,
        hadith_number REAL NOT NULL,
        narrator TEXT,
        body TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_book_slug ON hadith_cache(book_slug)');
  }

  // `cacheKey` is the edition slug (e.g. `eng-bukhari`/`ara-bukhari`), not
  // the bare book slug — different languages are different text and must
  // not collide in the cache, or switching app language could silently
  // show one language's hadith text while the picker/UI still says another.
  Future<int> countForBook(String cacheKey) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM hadith_cache WHERE book_slug = ?',
      [cacheKey],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> cacheBook(String cacheKey, List<HadithItem> items) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('hadith_cache', where: 'book_slug = ?', whereArgs: [cacheKey]);
    for (final item in items) {
      batch.insert('hadith_cache', {
        'id': item.id,
        'book_slug': cacheKey,
        'hadith_number': item.hadithNumber,
        'narrator': item.narrator,
        'body': item.body ?? '',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // `bookSlug`/`bookName` here are the real (bare) book identity, used only
  // to rebuild each HadithItem's display fields — kept edition-independent
  // so favorites/ids stay stable across a language switch.
  Future<List<HadithItem>> getBookHadiths(
    String cacheKey,
    String bookSlug,
    String bookName,
  ) async {
    final db = await database;
    final maps = await db.query(
      'hadith_cache',
      where: 'book_slug = ?',
      whereArgs: [cacheKey],
      orderBy: 'hadith_number ASC',
    );
    return maps
        .map(
          (m) => HadithItem(
            id: m['id'] as int,
            title:
                '$bookName #${formatHadithNumber(m['hadith_number'] as num?)}',
            narrator: m['narrator'] as String?,
            body: m['body'] as String?,
            book: bookSlug,
            bookName: bookName,
            hadithNumber: m['hadith_number'] as num?,
          ),
        )
        .toList();
  }
}
