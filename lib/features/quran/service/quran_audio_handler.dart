import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../models/quran_models.dart';
import 'quran_audio_service.dart';

const int kFirstSurahNumber = 1;
const int kLastSurahNumber = 114;

/// Single app-wide audio session for surah playback. Replaces the old
/// per-screen `AudioPlayer` instances so play state (and the audio itself)
/// survives navigation, and so the OS notification/lock-screen/Control
/// Center controls and the in-app FAB all reflect the same source of truth.
class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  QuranAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        // Mirrors the old per-screen behavior: reset to the start and pause
        // rather than auto-advancing to the next surah.
        _player.pause();
        _player.seek(Duration.zero);
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();

  int _currentSurah = kFirstSurahNumber;
  Reciter? _currentReciter;

  // Not closed: this handler lives for the app's process lifetime, same as
  // `_player` above — there's no point in the app's life where it should stop
  // being listenable.
  final StreamController<void> _openNowPlayingController =
      StreamController<void>.broadcast();

  /// Fires when the Android floating bubble is tapped — see
  /// BubbleOverlayService.kt, which reaches this through the app's existing
  /// MediaSession via `MediaControllerCompat.sendCustomAction('openNowPlaying')`.
  Stream<void> get openNowPlayingRequests => _openNowPlayingController.stream;

  /// Exposed for UI convenience (seek bar position stream) — the handler
  /// remains the only thing that calls play/pause/seek on it directly.
  AudioPlayer get player => _player;

  int get currentSurah => _currentSurah;
  Reciter? get currentReciter => _currentReciter;

  /// Plays [chapterNumber] (clamped 1..114) with [reciter] (falls back to the
  /// last-used reciter). [chapterName] is best-effort display text for the OS
  /// notification/lock-screen — in-app UI should prefer resolving a richer
  /// name from `chaptersProvider` using `mediaItem.extras['chapterNumber']`.
  Future<void> playSurah(
    int chapterNumber, {
    Reciter? reciter,
    String? chapterName,
  }) async {
    final clamped = chapterNumber.clamp(kFirstSurahNumber, kLastSurahNumber);
    _currentSurah = clamped;
    if (reciter != null) _currentReciter = reciter;

    final url = await QuranAudioService.getChapterAudioUrl(
      clamped,
      reciterId: _currentReciter?.relativePath,
    );

    mediaItem.add(
      MediaItem(
        id: url,
        title: chapterName ?? 'Surah $clamped',
        artist: _currentReciter?.name,
        extras: {'chapterNumber': clamped},
      ),
    );

    await _player.setUrl(url);
    await _player.play();
  }

  /// Restarts the currently-playing surah under a newly-selected reciter.
  /// No-op if nothing is playing — the new reciter simply applies next time
  /// `playSurah` is called.
  Future<void> setReciterAndRestartIfPlaying(Reciter reciter) async {
    _currentReciter = reciter;
    if (_player.playing) {
      await playSurah(_currentSurah, reciter: reciter, chapterName: mediaItem.value?.title);
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    mediaItem.add(null);
    await super.stop();
  }

  @override
  Future<void> skipToNext() => playSurah(_currentSurah + 1);

  @override
  Future<void> skipToPrevious() => playSurah(_currentSurah - 1);

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'openNowPlaying') {
      _openNowPlayingController.add(null);
    }
    return super.customAction(name, extras);
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState:
            const {
              ProcessingState.idle: AudioProcessingState.idle,
              ProcessingState.loading: AudioProcessingState.loading,
              ProcessingState.buffering: AudioProcessingState.buffering,
              ProcessingState.ready: AudioProcessingState.ready,
              ProcessingState.completed: AudioProcessingState.completed,
            }[_player.processingState] ??
            AudioProcessingState.idle,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }
}
