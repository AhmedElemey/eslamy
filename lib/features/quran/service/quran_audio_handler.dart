import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../data/surah_names.dart';
import '../models/quran_models.dart';
import 'quran_audio_service.dart';
import 'reciter_avatar_art.dart';

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
        final ayahs = _rangeAyahs;
        if (ayahs != null && _rangeIndex < ayahs.length - 1) {
          // Ayah-range mode: advance to the next verse in the selected range
          // instead of stopping.
          _rangeIndex++;
          _playCurrentRangeAyah();
          return;
        }
        if (ayahs == null && _currentSurah < kLastSurahNumber) {
          // Whole-surah playback finished — automatically continue with the
          // next surah rather than stopping.
          playSurah(_currentSurah + 1);
          return;
        }
        // End of an ayah range, or the last surah (114) finished: reset to
        // the start and pause rather than wrapping around.
        _player.pause();
        _player.seek(Duration.zero);
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();

  // Guards against the crash caused by rapid "next"/"previous" taps: each
  // call to `playSurah`/`_playCurrentRangeAyah` grabs a fresh token and an
  // exclusive slot on `_playerLock` before touching `_player`. A call whose
  // token has been superseded by a newer one (by the time its own awaits
  // resolve) aborts instead of racing a concurrent `setUrl`/`play` against
  // the same underlying `AudioPlayer`, which is what was crashing the app.
  int _playToken = 0;
  Future<void> _playerLock = Future.value();

  Future<void> _runExclusive(Future<void> Function() action) async {
    final previous = _playerLock;
    final completer = Completer<void>();
    _playerLock = completer.future;
    await previous;
    try {
      await action();
    } finally {
      completer.complete();
    }
  }

  int _currentSurah = kFirstSurahNumber;
  Reciter? _currentReciter;
  bool _arabicTitles = true;

  // Non-null while playing a specific ayah range (from `playAyahRange`);
  // null while playing a whole surah (from `playSurah`). Holds the ordered
  // list of ayah numbers in the selected range, with `_rangeIndex` pointing
  // at the one currently loaded.
  List<int>? _rangeAyahs;
  int _rangeIndex = 0;

  // Duration of each range ayah's clip, filled in as it loads (Duration.zero
  // until then) — lets the UI show one continuous position/duration for the
  // whole range instead of resetting to 0 every time playback moves to the
  // next ayah's separate audio file.
  List<Duration> _rangeDurations = [];

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

  /// Whether the current/last playback is an ayah range rather than a whole
  /// surah. Drives the Now Playing page and FAB's range-aware UI.
  bool get isRangeMode => _rangeAyahs != null;

  /// The ayah currently loaded, when in range mode.
  int? get currentRangeAyah => _rangeAyahs?[_rangeIndex];
  int? get rangeStart => _rangeAyahs?.first;
  int? get rangeEnd => _rangeAyahs?.last;
  bool get hasNextInRange =>
      _rangeAyahs != null && _rangeIndex < _rangeAyahs!.length - 1;
  bool get hasPreviousInRange => _rangeAyahs != null && _rangeIndex > 0;

  /// Sum of the durations of range ayahs already finished — the offset to
  /// add to the current clip's live position to get one continuous "elapsed
  /// time" across the whole selected range.
  Duration get rangeElapsedBeforeCurrent {
    var total = Duration.zero;
    for (var i = 0; i < _rangeIndex && i < _rangeDurations.length; i++) {
      total += _rangeDurations[i];
    }
    return total;
  }

  /// Best-effort total duration of the whole selected range: known clip
  /// durations summed, with any not-yet-loaded clips estimated using the
  /// average of the ones already known (refines as more of the range plays).
  /// The current clip falls back to the player's own live `duration` before
  /// the average estimate — its metadata is often available slightly before
  /// `_rangeDurations` is updated, and using it keeps the total from ever
  /// under-shooting the live elapsed position for an unusually long ayah.
  Duration get rangeTotalDuration {
    if (_rangeDurations.isEmpty) return Duration.zero;
    final avg = _averageKnownRangeDuration();
    var total = Duration.zero;
    for (var i = 0; i < _rangeDurations.length; i++) {
      final known = _rangeDurations[i];
      if (known > Duration.zero) {
        total += known;
      } else if (i == _rangeIndex &&
          (_player.duration ?? Duration.zero) > Duration.zero) {
        total += _player.duration!;
      } else {
        total += avg;
      }
    }
    return total;
  }

  Duration _averageKnownRangeDuration() {
    final known = _rangeDurations.where((d) => d > Duration.zero).toList();
    if (known.isEmpty) return Duration.zero;
    return known.reduce((a, b) => a + b) ~/ known.length;
  }

  /// Seeks to [target] on the whole range's continuous timeline (see
  /// [rangeElapsedBeforeCurrent]/[rangeTotalDuration]) — switching to
  /// whichever ayah clip that falls in and seeking within it, estimating
  /// clip length for any ayah not yet loaded.
  Future<void> seekInRange(Duration target) async {
    final ayahs = _rangeAyahs;
    if (ayahs == null || ayahs.isEmpty) return;
    final avg = _averageKnownRangeDuration();
    var remaining = target < Duration.zero ? Duration.zero : target;
    for (var i = 0; i < ayahs.length; i++) {
      final itemDuration =
          _rangeDurations[i] > Duration.zero ? _rangeDurations[i] : avg;
      final isLast = i == ayahs.length - 1;
      if (remaining <= itemDuration || isLast) {
        if (i != _rangeIndex) {
          _rangeIndex = i;
          await _playCurrentRangeAyah();
        }
        await _player.seek(remaining);
        return;
      }
      remaining -= itemDuration;
    }
  }

  /// Arabic vs English names on the OS notification / lock-screen.
  void setArabicTitles(bool arabic) {
    if (_arabicTitles == arabic) return;
    _arabicTitles = arabic;
    final current = mediaItem.value;
    if (current == null) return;
    mediaItem.add(current.copyWith(title: _titleFor(_currentSurah)));
  }

  String _titleFor(int number) =>
      surahDisplayName(number, arabic: _arabicTitles);

  /// Best-effort: never throws. A failure to generate/load the reciter's
  /// notification artwork must never block playback itself.
  Future<Uri?> _artUriFor(Reciter? reciter) async {
    if (reciter == null) return null;
    try {
      return await reciterAvatarArtUri(reciter.id, reciter.name);
    } catch (_) {
      return null;
    }
  }

  /// Plays [chapterNumber] (clamped 1..114) with [reciter] (falls back to the
  /// last-used reciter). Notification title is always the real surah name.
  Future<void> playSurah(
    int chapterNumber, {
    Reciter? reciter,
  }) async {
    final clamped = chapterNumber.clamp(kFirstSurahNumber, kLastSurahNumber);
    final token = ++_playToken;
    _currentSurah = clamped;
    _rangeAyahs = null;
    _rangeIndex = 0;
    _rangeDurations = [];
    if (reciter != null) _currentReciter = reciter;

    final currentReciter = _currentReciter;
    final urlFuture = QuranAudioService.getChapterAudioUrl(
      clamped,
      reciterId: currentReciter?.relativePath,
    );
    final artFuture = _artUriFor(currentReciter);
    final url = await urlFuture;
    final artUri = await artFuture;
    if (token != _playToken) return; // superseded by a newer request

    mediaItem.add(
      MediaItem(
        id: url,
        title: _titleFor(clamped),
        artist: currentReciter?.name,
        artUri: artUri,
        extras: {'chapterNumber': clamped},
      ),
    );

    await _runExclusive(() async {
      if (token != _playToken) return;
      try {
        await _player.setUrl(url);
        if (token != _playToken) return;
        await _player.play();
      } catch (_) {
        // Load/play was interrupted by a newer request superseding this
        // one — nothing to do, the newer request will take over the player.
      }
    });
  }

  /// Plays ayahs [fromAyah]..[toAyah] (inclusive, order-independent) of
  /// [chapterNumber] back-to-back with [reciter] (falls back to the
  /// last-used reciter). Reciters without true per-ayah recordings fall back
  /// to the whole-surah file for each step (same behavior as single-verse
  /// playback elsewhere in the app).
  Future<void> playAyahRange(
    int chapterNumber, {
    required int fromAyah,
    required int toAyah,
    Reciter? reciter,
  }) async {
    final clampedSurah = chapterNumber.clamp(kFirstSurahNumber, kLastSurahNumber);
    final start = fromAyah <= toAyah ? fromAyah : toAyah;
    final end = fromAyah <= toAyah ? toAyah : fromAyah;
    _currentSurah = clampedSurah;
    if (reciter != null) _currentReciter = reciter;
    _rangeAyahs = [for (var ayah = start; ayah <= end; ayah++) ayah];
    _rangeDurations = List<Duration>.filled(_rangeAyahs!.length, Duration.zero);
    _rangeIndex = 0;
    await _playCurrentRangeAyah();
  }

  Future<void> _playCurrentRangeAyah() async {
    final ayahs = _rangeAyahs;
    if (ayahs == null) return;
    final ayahNumber = ayahs[_rangeIndex];
    final rangeIndexAtRequest = _rangeIndex;
    final token = ++_playToken;
    final currentReciter = _currentReciter;

    final urlFuture = QuranAudioService.getVerseAudioUrl(
      _currentSurah,
      ayahNumber,
      reciterId: currentReciter?.relativePath,
    );
    final artFuture = _artUriFor(currentReciter);
    final url = await urlFuture;
    final artUri = await artFuture;
    if (token != _playToken) return; // superseded by a newer request

    mediaItem.add(
      MediaItem(
        id: url,
        title: _titleFor(_currentSurah),
        artist: currentReciter?.name,
        artUri: artUri,
        extras: {
          'chapterNumber': _currentSurah,
          'ayahNumber': ayahNumber,
          'rangeStart': ayahs.first,
          'rangeEnd': ayahs.last,
        },
      ),
    );

    await _runExclusive(() async {
      if (token != _playToken) return;
      try {
        final duration = await _player.setUrl(url);
        if (token != _playToken) return;
        if (duration != null && rangeIndexAtRequest < _rangeDurations.length) {
          _rangeDurations[rangeIndexAtRequest] = duration;
        }
        await _player.play();
      } catch (_) {
        // Superseded/interrupted — a newer request will take over the player.
      }
    });
  }

  /// Restarts the currently-playing surah (or ayah range) under a
  /// newly-selected reciter. No-op if nothing is playing — the new reciter
  /// simply applies next time playback starts.
  Future<void> setReciterAndRestartIfPlaying(Reciter reciter) async {
    _currentReciter = reciter;
    if (_player.playing) {
      if (_rangeAyahs != null) {
        await _playCurrentRangeAyah();
      } else {
        await playSurah(_currentSurah, reciter: reciter);
      }
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
    _rangeAyahs = null;
    _rangeIndex = 0;
    _rangeDurations = [];
    mediaItem.add(null);
    await super.stop();
  }

  @override
  Future<void> skipToNext() {
    if (_rangeAyahs != null) return _stepRange(1);
    return playSurah(_currentSurah + 1);
  }

  @override
  Future<void> skipToPrevious() {
    if (_rangeAyahs != null) return _stepRange(-1);
    return playSurah(_currentSurah - 1);
  }

  /// Moves within the current ayah range by [delta] (±1), clamped to its
  /// bounds. No-op at either end, same as the surah skip clamp above.
  Future<void> _stepRange(int delta) async {
    final ayahs = _rangeAyahs;
    if (ayahs == null) return;
    final next = (_rangeIndex + delta).clamp(0, ayahs.length - 1);
    if (next == _rangeIndex) return;
    _rangeIndex = next;
    await _playCurrentRangeAyah();
  }

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
