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

enum _PlayIntent { none, surah, range }

/// True when a finished pass through the current ayah range should start
/// over. A null [repeatTarget] repeats until the user stops; `1` plays once.
bool shouldReplayRange({
  required int? repeatTarget,
  required int completedPlays,
}) {
  return repeatTarget == null || completedPlays + 1 < repeatTarget;
}

/// Loop mode for an ayah range while [completedPlays] passes are done.
/// Looping natively (instead of seeking back once the range completes) lets
/// the player queue the next pass before this one ends, so a repeat doesn't
/// wait on a fresh network load of the ayah. The last pass runs with
/// [LoopMode.off] so the range completes and pauses.
LoopMode rangeLoopModeFor({
  required int ayahCount,
  required int? repeatTarget,
  required int completedPlays,
}) {
  if (ayahCount <= 0 ||
      !shouldReplayRange(
        repeatTarget: repeatTarget,
        completedPlays: completedPlays,
      )) {
    return LoopMode.off;
  }
  return ayahCount == 1 ? LoopMode.one : LoopMode.all;
}

/// Whether an auto-advance from [previousIndex] to [index] wrapped from the
/// last ayah of the range back to the first, i.e. one pass just finished.
bool isRangePassWrap({
  required int? previousIndex,
  required int? index,
  required int ayahCount,
}) {
  return ayahCount > 0 && previousIndex == ayahCount - 1 && index == 0;
}

/// Counts finished passes of a looping ayah range from two independent
/// signals — just_audio's auto-advance discontinuity and the sampled playback
/// position — so a loop that one of them misses still gets counted and a
/// finite repeat target can't over-repeat. A pass can be counted only after
/// playback has reached the second half of the range's last ayah, so the
/// same wrap reported by both signals counts once.
class RangePassTracker {
  bool _armed = false;
  Duration _lastPosition = Duration.zero;

  /// Forgets any progress through the current pass — after a new load, a
  /// seek, or the range finishing.
  void reset([Duration position = Duration.zero]) {
    _armed = false;
    _lastPosition = position;
  }

  /// Feeds a sampled playback position. Returns true when the position shows
  /// a single-ayah loop jumping back to its start that hasn't been counted.
  bool onPosition({
    required Duration position,
    required Duration? duration,
    required bool onLastAyah,
    required bool singleAyah,
  }) {
    final previous = _lastPosition;
    _lastPosition = position;
    if (duration == null || duration <= Duration.zero) return false;
    final half = duration * 0.5;
    if (singleAyah && previous >= half && position <= duration * 0.25) {
      return onWrap();
    }
    if (onLastAyah && position >= half) _armed = true;
    return false;
  }

  /// A loop back to the first ayah was reported. Returns true if it finishes
  /// a pass that hasn't been counted yet.
  bool onWrap() {
    if (!_armed) return false;
    _armed = false;
    return true;
  }
}

/// Single app-wide audio session for surah playback. Replaces the old
/// per-screen `AudioPlayer` instances so play state (and the audio itself)
/// survives navigation, and so the OS notification/lock-screen/Control
/// Center controls and the in-app FAB all reflect the same source of truth.
class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  QuranAudioHandler() {
    _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object error, StackTrace _) {
        // A source error (bad URL, a load cancelled by the next request)
        // is delivered on this stream. With no onError, Dart treats it as
        // uncaught and the zone handler takes down the whole app — which
        // showed up after a few ayah-to-ayah loads.
        debugPrint('Quran playback event error: $error');
      },
    );
    _player.currentIndexStream.listen(
      _onRangeIndexChanged,
      onError: (Object error, StackTrace _) {
        debugPrint('Quran index stream error: $error');
      },
    );
    _player.durationStream.listen(
      _rememberRangeClipDuration,
      onError: (Object error, StackTrace _) {
        debugPrint('Quran duration stream error: $error');
      },
    );
    _player.positionStream.listen(
      _trackRangePosition,
      onError: (Object error, StackTrace _) {
        debugPrint('Quran position stream error: $error');
      },
    );
    _player.positionDiscontinuityStream.listen(
      _onPositionDiscontinuity,
      onError: (Object error, StackTrace _) {
        debugPrint('Quran discontinuity stream error: $error');
      },
    );
    _player.processingStateStream.listen(
      (state) {
        if (state == ProcessingState.ready ||
            state == ProcessingState.buffering) {
          // Re-arm only after the player has actually left `completed`,
          // so a seek-to-start that briefly echoes completion can't
          // immediately start another pass.
          _rangeEndArmed = true;
        }
        if (state != ProcessingState.completed) return;
        if (_intent == _PlayIntent.range && _rangeAyahs != null) {
          if (!_rangeEndArmed) return;
          _rangeEndArmed = false;
          unawaited(_handleRangeFinished());
          return;
        }
        if (_intent == _PlayIntent.surah && _currentSurah < kLastSurahNumber) {
          // Whole-surah playback finished — automatically continue with the
          // next surah rather than stopping.
          unawaited(_skipSafely(() => playSurah(_currentSurah + 1)));
          return;
        }
        // The last surah (114) finished: reset to the start and pause
        // rather than wrapping around.
        unawaited(_pauseAndRewind());
      },
      onError: (Object error, StackTrace _) {
        debugPrint('Quran processing state error: $error');
      },
    );
  }

  final AudioPlayer _player = AudioPlayer();

  // Guards against the crash caused by rapid "next"/"previous" taps: each
  // call to `playSurah`/`playAyahRange` grabs a fresh token and an
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
  _PlayIntent _intent = _PlayIntent.none;
  Uri? _currentArtUri;

  // Practice-loop for the current range. Null repeats until the user stops;
  // 1 (the default) plays the range through once. Owned here, not by the
  // page that started playback, so a repeat seek can't race the player's
  // own completion handling.
  int? _repeatTarget = 1;
  int _completedPlays = 0;
  bool _rangeEndArmed = true;
  final RangePassTracker _passTracker = RangePassTracker();
  bool _finishingRange = false;

  // Non-null while playing a specific ayah range (from `playAyahRange`);
  // null while playing a whole surah (from `playSurah`). Holds the ordered
  // list of ayah numbers in the selected range, with `_rangeIndex` pointing
  // at the one currently loaded.
  List<int>? _rangeAyahs;
  int _rangeIndex = 0;
  List<String> _rangeUrls = [];

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

  /// The loaded source is paused mid-playback (or rewound to the start after
  /// finishing) and [play] can continue it. False while idle, completed, or
  /// still loading — those need a fresh [playSurah]/[playAyahRange].
  bool get canResume {
    if (_intent == _PlayIntent.none) return false;
    switch (_player.processingState) {
      case ProcessingState.ready:
      case ProcessingState.buffering:
        return true;
      case ProcessingState.loading:
      case ProcessingState.idle:
      case ProcessingState.completed:
        return false;
    }
  }

  /// Whether the loaded range is exactly [fromAyah]..[toAyah] of
  /// [chapterNumber]. Used so a pause/play on the same selection resumes
  /// instead of building a new player source — reloading on every tap is
  /// what crashed playback after a few repeats.
  bool matchesRange(int chapterNumber, int fromAyah, int toAyah) {
    final ayahs = _rangeAyahs;
    if (_intent != _PlayIntent.range ||
        _currentSurah != chapterNumber ||
        ayahs == null ||
        ayahs.isEmpty) {
      return false;
    }
    final start = fromAyah <= toAyah ? fromAyah : toAyah;
    final end = fromAyah <= toAyah ? toAyah : fromAyah;
    return ayahs.first == start && ayahs.last == end;
  }

  /// Updates how many times the current range plays through. Null repeats
  /// until the user stops. Takes effect on the next time the range ends,
  /// including a range that's already playing.
  void setRepeatTarget(int? target) {
    _repeatTarget = target;
    unawaited(_syncRangeLoopMode());
  }

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
        try {
          await _player.seek(remaining, index: i);
        } catch (e) {
          debugPrint('Quran range seek failed: $e');
        }
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
    _intent = _PlayIntent.surah;
    _currentSurah = clamped;
    _rangeAyahs = null;
    _rangeIndex = 0;
    _rangeDurations = [];
    _rangeUrls = [];
    _repeatTarget = 1;
    _completedPlays = 0;
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
        if (_intent != _PlayIntent.surah) return;
        if (loopToken != _playToken) {
          // A range request (or a stop) took the token. Don't adopt it and
          // load a surah over that — the range loader owns the player now.
          if (_intent != _PlayIntent.surah) return;
          loopToken = _playToken;
          loopClamped = _currentSurah;
          final loopReciter = _currentReciter;
          loopUrl = await QuranAudioService.getChapterAudioUrl(
            loopClamped,
            reciterId: loopReciter?.relativePath,
          );
          if (loopToken != _playToken || _intent != _PlayIntent.surah) {
            continue;
          }
          final loopArtUri = await _artUriFor(loopReciter);
          if (loopToken != _playToken || _intent != _PlayIntent.surah) {
            continue;
          }
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
          // A range practice loop may have left the player looping; a
          // surah must complete so playback can continue to the next one.
          await _player.setLoopMode(LoopMode.off);
          await _player.setUrl(loopUrl).timeout(_kAudioLoadTimeout);
          if (loopToken != _playToken) continue; // resync to the latest tap
          // `play()`'s Future does not complete until playback pauses or
          // ends (documented just_audio behavior) — awaiting it here would
          // hold this critical section for the rest of the track's runtime,
          // blocking every future skip/play request behind it. We only need
          // playback to *start*, so fire-and-forget it. Errors are swallowed
          // inside `_startPlayback`: an interrupted play used to escape as
          // an uncaught async error and crash the app.
          _startPlayback();
          if (loopToken == _playToken) return; // stable — done
        } catch (e) {
          // A genuine load/play failure (bad connection, dead URL) must
          // surface to the caller so the UI can show an error and offer a
          // retry — only a request superseded by a newer one is silently
          // retried against the newer target instead.
          if (loopToken == _playToken && _intent == _PlayIntent.surah) {
            rethrow;
          }
        }
      }
    });
  }

  /// Plays ayahs [fromAyah]..[toAyah] (inclusive, order-independent) of
  /// [chapterNumber] back-to-back with [reciter] (falls back to the
  /// last-used reciter). Reciters without true per-ayah recordings fall back
  /// to the whole-surah file for each step (same behavior as single-verse
  /// playback elsewhere in the app).
  ///
  /// The whole selection is one playlist. Stepping to the next ayah used to
  /// call `setUrl` from the completion listener; after a few verses that
  /// overlapping load threw an uncaught player error and crashed the app.
  /// [repeatTarget] null repeats until the user stops; the default plays once.
  /// [initialIndex] starts partway through the range (reciter changes).
  Future<void> playAyahRange(
    int chapterNumber, {
    required int fromAyah,
    required int toAyah,
    Reciter? reciter,
    int initialIndex = 0,
    int? repeatTarget = 1,
  }) async {
    final clampedSurah = chapterNumber.clamp(
      kFirstSurahNumber,
      kLastSurahNumber,
    );
    final start = fromAyah <= toAyah ? fromAyah : toAyah;
    final end = fromAyah <= toAyah ? toAyah : fromAyah;
    final ayahs = [for (var ayah = start; ayah <= end; ayah++) ayah];
    final index = initialIndex.clamp(0, ayahs.length - 1);
    final token = ++_playToken;
    _intent = _PlayIntent.range;
    _repeatTarget = repeatTarget;
    _completedPlays = 0;
    _rangeEndArmed = true;
    _passTracker.reset();
    _currentSurah = clampedSurah;
    if (reciter != null) _currentReciter = reciter;
    _rangeAyahs = ayahs;
    _rangeIndex = index;
    _rangeDurations = List<Duration>.filled(ayahs.length, Duration.zero);
    // Cleared until this request's URLs arrive, so a stale load still
    // inside `_runExclusive` bails instead of playing the previous range.
    _rangeUrls = [];

    final currentReciter = _currentReciter;
    _publishRangeMediaItem(artUri: _currentArtUri);

    final urlsFuture = Future.wait([
      for (final ayah in ayahs)
        QuranAudioService.getVerseAudioUrl(
          clampedSurah,
          ayah,
          reciterId: currentReciter?.relativePath,
        ),
    ]);
    final artFuture = _artUriFor(currentReciter);
    final urls = await urlsFuture;
    final artUri = await artFuture;
    if (token != _playToken) return;

    _rangeUrls = urls;
    _currentArtUri = artUri;
    _publishRangeMediaItem(artUri: artUri);

    // See the matching comment in playSurah: settle briefly so a rapid
    // burst of play taps only pays for one real network load.
    await Future.delayed(const Duration(milliseconds: 250));
    if (token != _playToken) return;

    await _runExclusive(() async {
      var loopToken = token;
      while (true) {
        if (_intent != _PlayIntent.range) return;
        final loopAyahs = _rangeAyahs;
        final loopUrls = _rangeUrls;
        if (loopAyahs == null ||
            loopUrls.isEmpty ||
            loopUrls.length != loopAyahs.length) {
          return;
        }
        if (loopToken != _playToken) {
          loopToken = _playToken;
          continue;
        }
        try {
          final playlist = ConcatenatingAudioSource(
            children: [
              for (final url in loopUrls) AudioSource.uri(Uri.parse(url)),
            ],
          );
          final startIndex = _rangeIndex.clamp(0, loopUrls.length - 1);
          await _player.setLoopMode(
            rangeLoopModeFor(
              ayahCount: loopAyahs.length,
              repeatTarget: _repeatTarget,
              completedPlays: _completedPlays,
            ),
          );
          final duration = await _player
              .setAudioSource(
                playlist,
                initialIndex: startIndex,
                initialPosition: Duration.zero,
              )
              .timeout(_kAudioLoadTimeout);
          if (loopToken != _playToken || _intent != _PlayIntent.range) {
            continue;
          }
          if (duration != null && startIndex < _rangeDurations.length) {
            _rangeDurations[startIndex] = duration;
          }
          _startPlayback();
          if (loopToken == _playToken) return;
        } catch (e) {
          if (loopToken == _playToken && _intent == _PlayIntent.range) {
            rethrow;
          }
        }
      }
    });
  }

  void _publishRangeMediaItem({Uri? artUri}) {
    final ayahs = _rangeAyahs;
    if (ayahs == null || ayahs.isEmpty) return;
    final index = _rangeIndex.clamp(0, ayahs.length - 1);
    final url =
        index < _rangeUrls.length
            ? _rangeUrls[index]
            : (mediaItem.value?.id ?? '');
    mediaItem.add(
      MediaItem(
        id: url,
        title: _titleFor(_currentSurah),
        artist: _currentReciter?.name,
        artUri: artUri ?? _currentArtUri,
        extras: {
          'chapterNumber': _currentSurah,
          'ayahNumber': ayahs[index],
          'rangeStart': ayahs.first,
          'rangeEnd': ayahs.last,
        },
      ),
    );
  }

  void _onRangeIndexChanged(int? index) {
    final ayahs = _rangeAyahs;
    if (_intent != _PlayIntent.range || ayahs == null || index == null) {
      return;
    }
    if (index < 0 || index >= ayahs.length || index == _rangeIndex) return;
    // Backup for the discontinuity signal: the looping playlist moved from
    // the last ayah back to the first. A seek there already reset the
    // tracker, so only a real loop counts.
    if (isRangePassWrap(
      previousIndex: _rangeIndex,
      index: index,
      ayahCount: ayahs.length,
    )) {
      _countRangePass();
    }
    _rangeIndex = index;
    _publishRangeMediaItem();
  }

  void _rememberRangeClipDuration(Duration? duration) {
    if (_intent != _PlayIntent.range ||
        duration == null ||
        duration <= Duration.zero) {
      return;
    }
    final index = _player.currentIndex;
    if (index == null || index < 0 || index >= _rangeDurations.length) return;
    _rangeDurations[index] = duration;
  }

  /// Counts a finished pass each time the looping player wraps from the last
  /// ayah back to the first, and turns looping off once the pass that just
  /// started is the last one wanted.
  void _onPositionDiscontinuity(PositionDiscontinuity discontinuity) {
    if (discontinuity.reason == PositionDiscontinuityReason.seek) {
      // A seek (user drag, skip, or our own rewind) is never a finished
      // pass; start tracking again from where it landed.
      _passTracker.reset(discontinuity.event.updatePosition);
      return;
    }
    if (discontinuity.reason != PositionDiscontinuityReason.autoAdvance) {
      return;
    }
    final ayahs = _rangeAyahs;
    if (_intent != _PlayIntent.range || ayahs == null) return;
    if (!isRangePassWrap(
      previousIndex: discontinuity.previousEvent.currentIndex,
      index: discontinuity.event.currentIndex,
      ayahCount: ayahs.length,
    )) {
      return;
    }
    _countRangePass();
  }

  void _trackRangePosition(Duration position) {
    final ayahs = _rangeAyahs;
    if (_intent != _PlayIntent.range || ayahs == null || ayahs.isEmpty) {
      return;
    }
    final index = _player.currentIndex;
    final restarted = _passTracker.onPosition(
      position: position,
      duration: _player.duration,
      onLastAyah: index == ayahs.length - 1,
      singleAyah: ayahs.length == 1,
    );
    if (restarted) _bumpCompletedPlays();
  }

  /// One pass of the range finished while looping, reported by any of the
  /// signals above. Counted at most once per pass.
  void _countRangePass() {
    if (_passTracker.onWrap()) _bumpCompletedPlays();
  }

  void _bumpCompletedPlays() {
    _completedPlays++;
    unawaited(_syncRangeLoopMode());
  }

  Future<void> _syncRangeLoopMode() async {
    final ayahs = _rangeAyahs;
    if (_intent != _PlayIntent.range || ayahs == null) return;
    final mode = rangeLoopModeFor(
      ayahCount: ayahs.length,
      repeatTarget: _repeatTarget,
      completedPlays: _completedPlays,
    );
    if (_player.loopMode == mode) return;
    try {
      await _player.setLoopMode(mode);
    } catch (e) {
      debugPrint('Quran loop mode update failed: $e');
    }
  }

  /// The playlist reached its end — normally only on the last pass, since
  /// earlier passes loop natively. Rewinds and pauses; if looping was turned
  /// off too late to catch a pass that should repeat, starts it again by
  /// seeking instead. Runs outside the completion callback so a seek can't
  /// re-enter it.
  Future<void> _handleRangeFinished() async {
    if (_finishingRange) return;
    if (_intent != _PlayIntent.range || _rangeAyahs == null) return;
    _finishingRange = true;
    final token = _playToken;
    try {
      final repeat = shouldReplayRange(
        repeatTarget: _repeatTarget,
        completedPlays: _completedPlays,
      );
      _passTracker.reset();
      if (repeat) {
        _completedPlays++;
        await _syncRangeLoopMode();
        await _player.seek(Duration.zero, index: 0);
        if (token != _playToken || _intent != _PlayIntent.range) return;
        _startPlayback();
        return;
      }
      _completedPlays = 0;
      await _player.pause();
      if (token != _playToken || _intent != _PlayIntent.range) return;
      await _player.seek(Duration.zero, index: 0);
      // Re-arm looping so resuming the rewound range repeats again.
      await _syncRangeLoopMode();
    } catch (e) {
      debugPrint('Quran range finished with error: $e');
    } finally {
      _finishingRange = false;
    }
  }

  Future<void> _pauseAndRewind() async {
    try {
      await _player.pause();
      await _player.seek(Duration.zero);
    } catch (e) {
      debugPrint('Quran rewind failed: $e');
    }
  }

  /// Starts playback without awaiting [AudioPlayer.play]. That future only
  /// completes when playback pauses or ends, and if a newer load interrupts
  /// it the error would otherwise be uncaught.
  void _startPlayback() {
    unawaited(
      _player.play().then(
        (_) {},
        onError: (Object error, StackTrace _) {
          debugPrint('Quran playback error: $error');
        },
      ),
    );
  }

  /// Restarts the currently-playing surah (or ayah range) under a
  /// newly-selected reciter. No-op if nothing is playing — the new reciter
  /// simply applies next time playback starts.
  Future<void> setReciterAndRestartIfPlaying(Reciter reciter) async {
    _currentReciter = reciter;
    if (_player.playing) {
      final ayahs = _rangeAyahs;
      if (_intent == _PlayIntent.range && ayahs != null && ayahs.isNotEmpty) {
        await playAyahRange(
          _currentSurah,
          fromAyah: ayahs.first,
          toAyah: ayahs.last,
          reciter: reciter,
          initialIndex: _rangeIndex,
          repeatTarget: _repeatTarget,
        );
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
    _startPlayback();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    _playToken++;
    _intent = _PlayIntent.none;
    _repeatTarget = 1;
    _completedPlays = 0;
    _rangeAyahs = null;
    _rangeIndex = 0;
    _rangeDurations = [];
    _rangeUrls = [];
    await _player.stop();
    await _player.setLoopMode(LoopMode.off);
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
  /// Seeks inside the already-loaded playlist — loading a new URL per step
  /// is what crashed after a few ayahs.
  Future<void> _stepRange(int delta) async {
    final ayahs = _rangeAyahs;
    if (ayahs == null) return;
    final next = (_rangeIndex + delta).clamp(0, ayahs.length - 1);
    if (next == _rangeIndex) return;
    try {
      await _player.seek(Duration.zero, index: next);
    } catch (e) {
      debugPrint('Quran range skip failed: $e');
    }
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
