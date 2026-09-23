import 'package:eslamy/features/quran/service/quran_audio_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  group('shouldReplayRange', () {
    test('plays a range once when the target is 1', () {
      expect(shouldReplayRange(repeatTarget: 1, completedPlays: 0), isFalse);
    });

    test('repeats until the target number of passes is reached', () {
      expect(shouldReplayRange(repeatTarget: 3, completedPlays: 0), isTrue);
      expect(shouldReplayRange(repeatTarget: 3, completedPlays: 1), isTrue);
      expect(shouldReplayRange(repeatTarget: 3, completedPlays: 2), isFalse);
    });

    test('a null target repeats indefinitely', () {
      expect(shouldReplayRange(repeatTarget: null, completedPlays: 4), isTrue);
    });
  });

  group('rangeLoopModeFor', () {
    test('a single ayah loops itself while more passes remain', () {
      expect(
        rangeLoopModeFor(ayahCount: 1, repeatTarget: 3, completedPlays: 0),
        LoopMode.one,
      );
      expect(
        rangeLoopModeFor(ayahCount: 1, repeatTarget: 3, completedPlays: 1),
        LoopMode.one,
      );
    });

    test('the last pass does not loop, so the range completes', () {
      expect(
        rangeLoopModeFor(ayahCount: 1, repeatTarget: 3, completedPlays: 2),
        LoopMode.off,
      );
      expect(
        rangeLoopModeFor(ayahCount: 1, repeatTarget: 1, completedPlays: 0),
        LoopMode.off,
      );
    });

    test('a multi-ayah range loops the whole playlist', () {
      expect(
        rangeLoopModeFor(ayahCount: 4, repeatTarget: 2, completedPlays: 0),
        LoopMode.all,
      );
    });

    test('an infinite target always loops', () {
      expect(
        rangeLoopModeFor(ayahCount: 1, repeatTarget: null, completedPlays: 9),
        LoopMode.one,
      );
    });

    test('an empty range never loops', () {
      expect(
        rangeLoopModeFor(ayahCount: 0, repeatTarget: null, completedPlays: 0),
        LoopMode.off,
      );
    });
  });

  group('isRangePassWrap', () {
    test('a single ayah looping onto itself is a finished pass', () {
      expect(isRangePassWrap(previousIndex: 0, index: 0, ayahCount: 1), isTrue);
    });

    test('wrapping from the last ayah to the first is a finished pass', () {
      expect(isRangePassWrap(previousIndex: 2, index: 0, ayahCount: 3), isTrue);
    });

    test('advancing within the range is not a finished pass', () {
      expect(
        isRangePassWrap(previousIndex: 0, index: 1, ayahCount: 3),
        isFalse,
      );
      expect(
        isRangePassWrap(previousIndex: null, index: 0, ayahCount: 1),
        isFalse,
      );
    });
  });
}
