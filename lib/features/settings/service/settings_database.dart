import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../../core/widget/widget_content_kind.dart';

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

  Future<TimeOfDay?> getTimeValue(String key) async {
    final val = await getValue(key);
    if (val == null || val.isEmpty) return null;
    final parts = val.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> setTimeValue(String key, TimeOfDay time) async {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    await setValue(key, '$hh:$mm');
  }

  Future<TimeOfDay?> getWerdTime() => getTimeValue('werd_time');

  Future<void> setWerdTime(TimeOfDay time) => setTimeValue('werd_time', time);

  Future<bool> getAdhanEnabled() async {
    final val = await getValue('adhan_enabled');
    return val != '0'; // enabled by default until explicitly turned off
  }

  Future<void> setAdhanEnabled(bool enabled) =>
      setValue('adhan_enabled', enabled ? '1' : '0');

  /// The content kinds rotating through the home-screen widget, and their
  /// order. Defaults to every kind enabled — matches the widget's behavior
  /// before this preference existed.
  Future<List<WidgetContentKind>> getWidgetEnabledKinds() async {
    final val = await getValue('widget_enabled_kinds');
    if (val == null || val.isEmpty) return WidgetContentKind.values;
    final kinds =
        val
            .split(',')
            .map(WidgetContentKindX.fromStorageKey)
            .whereType<WidgetContentKind>()
            .toList();
    return kinds.isEmpty ? WidgetContentKind.values : kinds;
  }

  Future<void> setWidgetEnabledKinds(List<WidgetContentKind> kinds) => setValue(
    'widget_enabled_kinds',
    kinds.map((k) => k.storageKey).join(','),
  );
}
