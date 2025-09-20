import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioPlayerService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (!_isInitialized) {
      _isInitialized = true;

      // Listen to player state changes
      _audioPlayer.playerStateStream.listen((playerState) {
        // Handle player state changes if needed
      });

      // Listen to position changes
      _audioPlayer.positionStream.listen((position) {
        // Handle position changes if needed
      });

      // Listen to duration changes
      _audioPlayer.durationStream.listen((duration) {
        // Handle duration changes if needed
      });
    }
  }

  static Future<void> playAudio(
    String audioUrl, {
    int? chapterNumber,
    int? verseNumber,
  }) async {
    try {
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      throw Exception('Failed to play audio: $e');
    }
  }

  static Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  static Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  static Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  static Stream<PlayerState> get playerStateStream =>
      _audioPlayer.playerStateStream;
  static Stream<Duration> get positionStream => _audioPlayer.positionStream;
  static Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  static Duration get position => _audioPlayer.position;
  static Duration? get duration => _audioPlayer.duration;
  static bool get isPlaying => _audioPlayer.playing;
  static bool get isPaused =>
      _audioPlayer.playerState.playing == false &&
      _audioPlayer.playerState.processingState == ProcessingState.ready;
  static bool get isStopped =>
      _audioPlayer.playerState.processingState == ProcessingState.idle;

  static Future<void> dispose() async {
    await _audioPlayer.dispose();
    _isInitialized = false;
  }
}

// Audio player service provider
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService();
});
