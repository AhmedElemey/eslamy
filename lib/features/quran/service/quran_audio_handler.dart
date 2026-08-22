import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/surah_names.dart';
import '../models/quran_models.dart';
import 'quran_audio_service.dart';
import 'reciter_avatar_art.dart';

const int kFirstSurahNumber = 1;
const int kLastSurahNumber = 114;

// `_player.setUrl()` is a real network fetch with no built-in timeout of its
// own — if it stalls (e.g. a momentary connectivity drop), it can hang
// indefinitely. Since it runs inside `_runExclusive`'s critical section, a
// stall that never resolves or throws would hold that lock forever and
// permanently block every future play/skip request, not just the current
// one. Capping it here guarantees the lock is always eventually released.
const Duration _kAudioLoadTimeout = Duration(seconds: 15);

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
  Future<void> playSurah(int chapterNumber, {Reciter? reciter}) async {
    final clamped = chapterNumber.clamp(kFirstSurahNumber, kLastSurahNumber);
    final token = ++_playToken;
    _currentSurah = clamped;
    _rangeAyahs = null;
    _rangeIndex = 0;
    _rangeDurations = [];
    if (reciter != null) _currentReciter = reciter;

    final currentReciter = _currentReciter;

    // Publish the new title immediately, before the URL/art even start
    // resolving. Without this, the displayed title lags behind
    // `_currentSurah` while those awaits are in flight — long enough that a
    // manual skip tap landing in that window reads the already-updated
    // `_currentSurah` and computes one surah further than what's on screen,
    // looking like it skipped two surahs at once (most visible when this
    // races the auto-advance-on-completion below).
    final previousItem = mediaItem.value;
    mediaItem.add(
      MediaItem(
        id: previousItem?.id ?? '',
        title: _titleFor(clamped),
        artist: currentReciter?.name,
        artUri: previousItem?.artUri,
        extras: {'chapterNumber': clamped},
      ),
    );

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

    // `_player.setUrl()` below is a real network fetch of the audio file —
    // it can take seconds, and once started it can't be cancelled. Without
    // this settle window, a burst of rapid skip taps each grab the
    // exclusive lock in turn and each fully load their (soon-to-be-discarded)
    // audio before the next one gets a turn, so the real, audible track can
    // lag the displayed title by however many wasted loads came before it —
    // or, if one of those loads stalls, never catch up at all. Waiting here
    // lets a newer tap supersede this one (via the token check just below)
    // before any network request is made, so a fast burst costs one real
    // load — for the final target — instead of one per tap.
    await Future.delayed(const Duration(milliseconds: 250));
    if (token != _playToken) return; // superseded during the settle window

    await _runExclusive(() async {
      // Loops instead of returning on staleness: if a burst of taps is
      // spread out wider than the settle window above, more than one of
      // them can independently reach this point and queue up behind each
      // other on `_runExclusive`, each about to load real (uncancellable)
      // audio that's already known to be discarded by the time its turn
      // comes. Rather than let a stale call queue its own doomed load, only
      // ever act on whichever target is *current* right now, and if that
      // changes again mid-load, re-fetch and retry in place — so no matter
      // how the taps are spaced, only ever one real load is in flight, and
      // it's always chasing the latest tap rather than an abandoned one.
      var loopToken = token;
      var loopClamped = clamped;
      var loopUrl = url;
      while (true) {
        if (loopToken != _playToken) {
          loopToken = _playToken;
          loopClamped = _currentSurah;
          final loopReciter = _currentReciter;
          loopUrl = await QuranAudioService.getChapterAudioUrl(
            loopClamped,
            reciterId: loopReciter?.relativePath,
          );
          if (loopToken != _playToken) continue; // moved on again already
          final loopArtUri = await _artUriFor(loopReciter);
          if (loopToken != _playToken) continue;
          mediaItem.add(
            MediaItem(
              id: loopUrl,
              title: _titleFor(loopClamped),
              artist: loopReciter?.name,
              artUri: loopArtUri,
              extras: {'chapterNumber': loopClamped},
            ),
          );
        }
        try {
          await _player.setUrl(loopUrl).timeout(_kAudioLoadTimeout);
          if (loopToken != _playToken) continue; // resync to the latest tap
          // `play()`'s Future does not complete until playback pauses or
          // ends (documented just_audio behavior) — awaiting it here would
          // hold this critical section for the rest of the track's runtime,
          // blocking every future skip/play request behind it. We only need
          // playback to *start*, so fire-and-forget it.
          unawaited(_player.play());
          if (loopToken == _playToken) return; // stable — done
        } catch (e) {
          // A genuine load/play failure (bad connection, dead URL) must
          // surface to the caller so the UI can show an error and offer a
          // retry — only a request superseded by a newer one is silently
          // retried against the newer target instead.
          if (loopToken == _playToken) rethrow;
        }
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
    final clampedSurah = chapterNumber.clamp(
      kFirstSurahNumber,
      kLastSurahNumber,
    );
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

    // See the matching comment in playSurah: publish immediately so a
    // rapid follow-up step (or the completion listener's auto-advance)
    // never computes its target against a UI that's still showing the
    // previous ayah/surah.
    final previousItem = mediaItem.value;
    mediaItem.add(
      MediaItem(
        id: previousItem?.id ?? '',
        title: _titleFor(_currentSurah),
        artist: currentReciter?.name,
        artUri: previousItem?.artUri,
        extras: {
          'chapterNumber': _currentSurah,
          'ayahNumber': ayahNumber,
          'rangeStart': ayahs.first,
          'rangeEnd': ayahs.last,
        },
      ),
    );

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

    // See the matching comment/fix in playSurah: settle briefly so a rapid
    // burst of range-step taps only pays for one real network load — the
    // final target — instead of one wasted load per step.
    await Future.delayed(const Duration(milliseconds: 250));
    if (token != _playToken) return; // superseded during the settle window

    await _runExclusive(() async {
      // See the matching comment/fix in playSurah: keep chasing whatever
      // step is current instead of returning and leaving a stale queued
      // call to redo (and likely also lose) the same real network load.
      var loopToken = token;
      var loopUrl = url;
      var loopRangeIndex = rangeIndexAtRequest;
      while (true) {
        if (loopToken != _playToken) {
          final loopAyahs = _rangeAyahs;
          if (loopAyahs == null) return; // switched out of range mode
          loopToken = _playToken;
          loopRangeIndex = _rangeIndex;
          final loopAyahNumber = loopAyahs[loopRangeIndex];
          final loopReciter = _currentReciter;
          loopUrl = await QuranAudioService.getVerseAudioUrl(
            _currentSurah,
            loopAyahNumber,
            reciterId: loopReciter?.relativePath,
          );
          if (loopToken != _playToken) continue; // moved on again already
          final loopArtUri = await _artUriFor(loopReciter);
          if (loopToken != _playToken) continue;
          mediaItem.add(
            MediaItem(
              id: loopUrl,
              title: _titleFor(_currentSurah),
              artist: loopReciter?.name,
              artUri: loopArtUri,
              extras: {
                'chapterNumber': _currentSurah,
                'ayahNumber': loopAyahNumber,
                'rangeStart': loopAyahs.first,
                'rangeEnd': loopAyahs.last,
              },
            ),
          );
        }
        try {
          final duration = await _player
              .setUrl(loopUrl)
              .timeout(_kAudioLoadTimeout);
          if (loopToken != _playToken) continue; // resync to the latest step
          if (duration != null && loopRangeIndex < _rangeDurations.length) {
            _rangeDurations[loopRangeIndex] = duration;
          }
          // See the matching comment/fix in playSurah: don't await — its
          // Future doesn't resolve until playback pauses or ends, which
          // would hold this lock for the rest of the track and block every
          // future skip/play request behind it.
          unawaited(_player.play());
          if (loopToken == _playToken) return; // stable — done
        } catch (e) {
          // See the matching comment in playSurah: only swallow when this
          // request was superseded, otherwise let the caller see the failure.
          if (loopToken == _playToken) rethrow;
        }
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
  Future<void> play() async {
    // See the comment in playSurah: `_player.play()`'s Future doesn't
    // complete until playback pauses or ends, so returning it directly here
    // would leave any awaiting caller (including audio_service's own OS
    // media-control handling) hanging for the entire remaining playback.
    unawaited(_player.play());
  }

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
  Future<void> skipToNext() => _skipSafely(
    () => _rangeAyahs != null ? _stepRange(1) : playSurah(_currentSurah + 1),
  );

  @override
  Future<void> skipToPrevious() => _skipSafely(
    () => _rangeAyahs != null ? _stepRange(-1) : playSurah(_currentSurah - 1),
  );

  /// Runs a skip action without letting a failure (e.g. a network timeout
  /// loading the next track) become an unhandled exception. The mini player
  /// and OS media controls call `skipToNext`/`skipToPrevious` without
  /// awaiting or catching, so unlike a page's own "play this chapter"
  /// action — which does await `playSurah` directly and shows its own error
  /// snackbar — there's no local error UI for a skip failure to reach.
  /// Letting it propagate instead trips the app's global error handler and
  /// replaces the whole screen for what's usually just a transient hiccup
  /// the next tap (or the loop's own self-healing) would recover from.
  Future<void> _skipSafely(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('Quran skip failed: $e');
    }
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
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
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
