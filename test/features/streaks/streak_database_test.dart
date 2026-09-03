import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/features/streaks/service/streak_database.dart';

import '../../support/sqflite_ffi_setup.dart';

Future<void> _clearActivityLog(StreakDatabase db) async {
  final dates = await db.getActiveDates(lookbackDays: 100000);
  for (final date in dates) {
    final db2 = await db.database;
    await db2.delete('activity_log', where: 'date = ?', whereArgs: [date]);
  }
}

void main() {
  setUpAll(() {
    initSqfliteFfiForTests();
  });

  final db = StreakDatabase();

  setUp(() async {
    await _clearActivityLog(db);
  });

  group('formatDate', () {
    test('zero-pads month and day, four-digit year', () {
      expect(formatDate(DateTime(2026, 1, 5)), '2026-01-05');
      expect(formatDate(DateTime(2026, 9, 3)), '2026-09-03');
      expect(formatDate(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });

  group('StreakDatabase', () {
    test('recordToday makes today show up in getActiveDates', () async {
      expect(await db.getActiveDates(), isEmpty);

      await db.recordToday();

      final today = formatDate(DateTime.now());
      expect(await db.getActiveDates(), contains(today));
    });

    test('calling recordToday twice the same day does not error', () async {
      await db.recordToday();
      await db.recordToday();

      final today = formatDate(DateTime.now());
      expect(await db.getActiveDates(), {today});
    });

    test(
      'getActiveDates(lookbackDays: N) excludes dates older than the cutoff',
      () async {
        await db.recordToday();

        // StreakDatabase has no public method to insert a backdated row and
        // recordToday only ever writes today's date, but `database` is a
        // public getter, so we go through it (not the private `_database`
        // field) to insert an old row the same way the app's own writes do.
        final rawDb = await db.database;
        final oldDate = formatDate(
          DateTime.now().subtract(const Duration(days: 50)),
        );
        await rawDb.insert('activity_log', {'date': oldDate});

        final today = formatDate(DateTime.now());
        final wideLookback = await db.getActiveDates(lookbackDays: 60);
        expect(wideLookback, containsAll([today, oldDate]));

        final narrowLookback = await db.getActiveDates(lookbackDays: 30);
        expect(narrowLookback, contains(today));
        expect(narrowLookback, isNot(contains(oldDate)));
      },
    );
  });
}
