import 'package:eslamy/features/quran/service/quran_audio_handler.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
