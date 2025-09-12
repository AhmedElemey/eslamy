import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class SettingsDatabase {
  static final SettingsDatabase _instance = SettingsDatabase._internal();
  factory SettingsDatabase() => _instance;
  SettingsDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'settings.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE app_settings (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
        await db.insert('app_settings', {'key': 'werd_time', 'value': ''});
      },
    );
  }

  Future<void> setValue(String key, String value) async {
    final db = await database;
    await db.insert('app_settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getValue(String key) async {
    final db = await database;
    final res = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return res.first['value'] as String?;
  }

  Future<TimeOfDay?> getWerdTime() async {
    final val = await getValue('werd_time');
    if (val == null || val.isEmpty) return null;
    final parts = val.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> setWerdTime(TimeOfDay time) async {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    await setValue('werd_time', '$hh:$mm');
  }
}
