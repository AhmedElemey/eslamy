import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/azkar_models.dart';

/// Local cache of the Duas & Azkar dataset. Seeded once from the bundled
/// asset (offline-first) and silently overwritten whenever a live refresh
/// from UmmahAPI succeeds, mirroring hadith_cache_database.dart.
class AzkarCacheDatabase {
  static final AzkarCacheDatabase _instance = AzkarCacheDatabase._internal();
  factory AzkarCacheDatabase() => _instance;
  AzkarCacheDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'azkar_cache.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE azkar_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE azkar_items (
        id INTEGER PRIMARY KEY,
        category_id TEXT NOT NULL,
        title TEXT,
        arabic TEXT NOT NULL,
        transliteration TEXT,
        translation TEXT,
        source TEXT,
        repeat_count INTEGER
      )
    ''');
    await db.execute('CREATE INDEX idx_azkar_category ON azkar_items(category_id)');
  }

  Future<bool> isEmpty() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM azkar_items');
    return (Sqflite.firstIntValue(result) ?? 0) == 0;
  }

  Future<void> replaceAll(AzkarDataset dataset) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('azkar_categories');
    batch.delete('azkar_items');
    for (final c in dataset.categories) {
      batch.insert('azkar_categories', {
        'id': c.id,
        'name': c.name,
        'description': c.description,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final i in dataset.items) {
      batch.insert('azkar_items', {
        'id': i.id,
        'category_id': i.categoryId,
        'title': i.title,
        'arabic': i.arabic,
        'transliteration': i.transliteration,
        'translation': i.translation,
        'source': i.source,
        'repeat_count': i.repeat,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<AzkarCategory>> getCategories() async {
    final db = await database;
    final maps = await db.query('azkar_categories', orderBy: 'name ASC');
    return maps
        .map((m) => AzkarCategory(
              id: m['id'] as String,
              name: m['name'] as String,
              description: m['description'] as String? ?? '',
            ))
        .toList();
  }

  Future<List<AzkarItem>> getItemsForCategory(String categoryId) async {
    final db = await database;
    final maps = await db.query(
      'azkar_items',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'id ASC',
    );
    return maps
        .map((m) => AzkarItem(
              id: m['id'] as int,
              categoryId: m['category_id'] as String,
              title: m['title'] as String? ?? '',
              arabic: m['arabic'] as String,
              transliteration: m['transliteration'] as String? ?? '',
              translation: m['translation'] as String? ?? '',
              source: m['source'] as String? ?? '',
              repeat: m['repeat_count'] as int? ?? 1,
            ))
        .toList();
  }
}
