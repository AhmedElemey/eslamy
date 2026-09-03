import 'package:eslamy/features/quran/data/juz_starting_points.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('juzStartingPoints', () {
    test('has exactly 30 entries, one per Juz', () {
      expect(juzStartingPoints, hasLength(30));
    });

    test('Juz 1 starts at the very beginning of the Quran', () {
      expect(juzStartingPoints.first, (1, 1));
    });

    test('surah numbers are non-decreasing across Juz boundaries', () {
      for (var i = 1; i < juzStartingPoints.length; i++) {
        expect(
          juzStartingPoints[i].$1,
          greaterThanOrEqualTo(juzStartingPoints[i - 1].$1),
          reason: 'Juz ${i + 1} starts in an earlier surah than Juz $i',
        );
      }
    });

    test('every surah number is within the valid 1-114 range', () {
      for (final point in juzStartingPoints) {
        expect(point.$1, inInclusiveRange(1, 114));
      }
    });

    test('every ayah number is positive', () {
      for (final point in juzStartingPoints) {
        expect(point.$2, greaterThan(0));
      }
    });

    test('no two Juz start at the exact same (surah, ayah)', () {
      expect(juzStartingPoints.toSet(), hasLength(juzStartingPoints.length));
    });
  });
}
