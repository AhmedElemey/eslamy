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

  group('RangePassTracker', () {
    const duration = Duration(seconds: 10);

    bool sample(
      RangePassTracker tracker,
      int millis, {
      bool onLastAyah = true,
      bool singleAyah = true,
    }) {
      return tracker.onPosition(
        position: Duration(milliseconds: millis),
        duration: duration,
        onLastAyah: onLastAyah,
        singleAyah: singleAyah,
      );
    }

    test('counts a single-ayah loop the discontinuity signal missed', () {
      final tracker = RangePassTracker();
      expect(sample(tracker, 2000), isFalse);
      expect(sample(tracker, 9800), isFalse);
      expect(sample(tracker, 100), isTrue);
    });

    test('counts a wrap reported by both signals only once', () {
      final tracker = RangePassTracker();
      sample(tracker, 9800);
      expect(tracker.onWrap(), isTrue);
      expect(sample(tracker, 100), isFalse);

      sample(tracker, 9800);
      expect(sample(tracker, 100), isTrue);
      expect(tracker.onWrap(), isFalse);
    });

    test('does not count a wrap before the last ayah\'s second half', () {
      final tracker = RangePassTracker();
      sample(tracker, 3000);
      expect(tracker.onWrap(), isFalse);
    });

    test('a seek back to the start is not a pass', () {
      final tracker = RangePassTracker();
      sample(tracker, 9000);
      tracker.reset(Duration.zero);
      expect(sample(tracker, 50), isFalse);
      expect(tracker.onWrap(), isFalse);
    });

    test('multi-ayah ranges count wraps only from the last ayah', () {
      final tracker = RangePassTracker();
      sample(tracker, 9000, onLastAyah: false, singleAyah: false);
      expect(tracker.onWrap(), isFalse);
      sample(tracker, 9000, singleAyah: false);
      // A position drop alone is an ayah change, not a pass, in a range.
      expect(sample(tracker, 100, singleAyah: false), isFalse);
      expect(tracker.onWrap(), isTrue);
    });

    test('ignores samples before the clip duration is known', () {
      final tracker = RangePassTracker();
      expect(
        tracker.onPosition(
          position: const Duration(seconds: 9),
          duration: null,
          onLastAyah: true,
          singleAyah: true,
        ),
        isFalse,
      );
      expect(tracker.onWrap(), isFalse);
    });
  });
}
