import 'package:eslamy/features/quran/service/reciter_avatar_art.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('reciterAvatarColor', () {
    test('is deterministic for a given reciter id', () {
      expect(reciterAvatarColor(4), reciterAvatarColor(4));
    });

    test('cycles through the palette (wraps around by id)', () {
      // Palette has 8 entries — ids 8 apart must land on the same color.
      expect(reciterAvatarColor(1), reciterAvatarColor(9));
      expect(reciterAvatarColor(0), reciterAvatarColor(8));
    });

    test('different ids within one cycle get different colors', () {
      final colors = List.generate(8, reciterAvatarColor).toSet();
      expect(colors, hasLength(8));
    });
  });

  group('reciterInitials', () {
    test('two-word name takes the first letter of each word', () {
      expect(reciterInitials('Mishary Alafasy'), 'MA');
    });

    test('three-word name only uses the first two words', () {
      expect(reciterInitials('Mishary Rashid Alafasy'), 'MR');
    });

    test('single-word name falls back to one letter', () {
      expect(reciterInitials('Sudais'), 'S');
    });

    test('lowercase input is upper-cased', () {
      expect(reciterInitials('mishary alafasy'), 'MA');
    });

    test('collapses repeated whitespace between words', () {
      expect(reciterInitials('Mishary   Alafasy'), 'MA');
    });

    test('leading/trailing whitespace is ignored', () {
      expect(reciterInitials('  Mishary Alafasy  '), 'MA');
    });

    test('empty name falls back to "?"', () {
      expect(reciterInitials(''), '?');
    });

    test('whitespace-only name falls back to "?"', () {
      expect(reciterInitials('   '), '?');
    });
  });

  group('reciterPhotoAsset', () {
    test('returns the known asset path for a listed reciter', () {
      expect(reciterPhotoAsset(4), 'assets/images/reciters/4.jpg');
    });

    test('returns null for a reciter with no photo on file', () {
      expect(reciterPhotoAsset(999999), isNull);
    });
  });
}
