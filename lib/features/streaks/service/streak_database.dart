import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

String formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// One row per calendar day the app was opened. Pruned to the last 90 days
/// on every write so it never grows unbounded.
class StreakDatabase {
  static final StreakDatabase _instance = StreakDatabase._internal();
  factory StreakDatabase() => _instance;
  StreakDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'streaks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE activity_log (date TEXT PRIMARY KEY)');
      },
    );
  }

  Future<void> recordToday() async {
    final db = await database;
    await db.insert('activity_log', {
      'date': formatDate(DateTime.now()),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    final cutoff = formatDate(
      DateTime.now().subtract(const Duration(days: 90)),
    );
    await db.delete('activity_log', where: 'date < ?', whereArgs: [cutoff]);
  }

  Future<Set<String>> getActiveDates({int lookbackDays = 30}) async {
    final db = await database;
    final cutoff = formatDate(
      DateTime.now().subtract(Duration(days: lookbackDays)),
    );
    final rows = await db.query(
      'activity_log',
      where: 'date >= ?',
      whereArgs: [cutoff],
    );
    return rows.map((r) => r['date'] as String).toSet();
  }
}
