import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/features/hifz/service/hifz_database.dart';

import '../../support/sqflite_ffi_setup.dart';

void main() {
  setUpAll(() {
    initSqfliteFfiForTests();
  });

  final db = HifzDatabase();

  setUp(() async {
    final memorized = await db.getMemorizedSurahs();
    for (final surah in memorized) {
      await db.unmarkMemorized(surah);
    }
  });

  group('HifzDatabase', () {
    test('getMemorizedSurahs starts empty', () async {
      expect(await db.getMemorizedSurahs(), isEmpty);
    });

    test('markMemorized then getMemorizedSurahs includes the surah', () async {
      await db.markMemorized(1);
      expect(await db.getMemorizedSurahs(), {1});

      await db.markMemorized(114);
      expect(await db.getMemorizedSurahs(), {1, 114});
    });

    test('unmarkMemorized removes exactly that surah', () async {
      await db.markMemorized(2);
      await db.markMemorized(3);

      await db.unmarkMemorized(2);
      expect(await db.getMemorizedSurahs(), {3});
    });

    test(
      'marking the same surah twice does not create a duplicate entry',
      () async {
        await db.markMemorized(5);
        await db.markMemorized(5);

        final memorized = await db.getMemorizedSurahs();
        expect(memorized.where((s) => s == 5), hasLength(1));
        expect(memorized, {5});
      },
    );

    test('unmarking a surah that was never marked is a no-op', () async {
      await db.markMemorized(7);

      await db.unmarkMemorized(999);
      expect(await db.getMemorizedSurahs(), {7});
    });
  });
}
