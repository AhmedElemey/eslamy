import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/quran_api_service.dart';
import '../../service/quran_audio_service.dart';
import '../../service/reciter_preferences_service.dart';
import '../../service/tajweed_preferences_service.dart';
import '../../service/translation_preferences_service.dart';
import '../../models/quran_models.dart';

// Service provider
final quranApiServiceProvider = Provider<QuranApiService>((ref) {
  return QuranApiService();
});

// Chapters provider
final chaptersProvider = FutureProvider<List<QuranChapter>>((ref) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getChapters();
});

// Juz (Para) ayahs provider — 1..30
final juzProvider = FutureProvider.family<List<AyahWithSurah>, int>((ref, juzNumber) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getJuz(juzNumber);
});

// Mushaf page ayahs provider — 1..604
final quranPageProvider = FutureProvider.family<List<AyahWithSurah>, int>((ref, pageNumber) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getPage(pageNumber);
});

// Hizb quarter ayahs provider — 1..240
final hizbQuarterProvider = FutureProvider.family<List<AyahWithSurah>, int>((ref, quarterNumber) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getHizbQuarter(quarterNumber);
});

// Chapter provider
final chapterProvider = FutureProvider.family<QuranChapterResponse, int>((
  ref,
  chapterNumber,
) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getChapter(chapterNumber);
});

// Verse provider
final verseProvider = FutureProvider.family<
  QuranVerseResponse,
  ({int chapterNumber, int verseNumber})
>((ref, params) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getVerse(params.chapterNumber, params.verseNumber);
});

// Tafseer provider
final tafseerProvider = FutureProvider.family<
  AyahTafsir,
  ({int chapterNumber, int verseNumber})
>((ref, params) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getTafseer(params.chapterNumber, params.verseNumber);
});

// Chapter Tajweed provider — same shape as chapterProvider, but verse text
// carries Tajweed bracket tags instead of plain Uthmani text.
final chapterTajweedProvider = FutureProvider.family<QuranChapterResponse, int>((
  ref,
  chapterNumber,
) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getChapterTajweed(chapterNumber);
});

final tajweedPreferencesServiceProvider = Provider(
  (ref) => TajweedPreferencesService(),
);

/// Whether verse text is rendered with Tajweed color-coding, defaulting to
/// on until any saved preference has loaded.
class TajweedColoringNotifier extends StateNotifier<bool> {
  TajweedColoringNotifier(this._prefs) : super(true) {
    _restore();
  }

  final TajweedPreferencesService _prefs;

  Future<void> _restore() async {
    final saved = await _prefs.loadEnabled();
    if (mounted) {
      state = saved;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _prefs.saveEnabled(enabled);
  }
}

final tajweedColoringEnabledProvider =
    StateNotifierProvider<TajweedColoringNotifier, bool>((ref) {
      return TajweedColoringNotifier(ref.watch(tajweedPreferencesServiceProvider));
    });

// Reciters provider
final recitersProvider = FutureProvider<List<Reciter>>((ref) async {
  // Use the audio service to get available reciters with enhanced data
  final allReciters = QuranAudioService.getAllReciters();
  return allReciters
      .map(
        (reciterData) => Reciter(
          id: int.parse(reciterData['id']!),
          name: reciterData['englishName']!,
          arabicName: reciterData['arabicName']!,
          relativePath: reciterData['key']!,
        ),
      )
      .toList();
});

// Chapter audio provider
final chapterAudioProvider = FutureProvider.family<String, int>((
  ref,
  chapterNumber,
) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getChapterAudio(chapterNumber);
});

// Verse audio URL provider
final verseAudioUrlProvider = FutureProvider.family<
  String,
  ({int chapterNumber, int verseNumber, String? reciterId})
>((ref, params) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getVerseAudio(
    params.chapterNumber,
    params.verseNumber,
    reciterId: params.reciterId,
  );
});

// Chapter audio URL provider with selected reciter
final chapterAudioUrlProvider = FutureProvider.family<String, int>((
  ref,
  chapterNumber,
) async {
  final selectedReciter = ref.watch(selectedReciterProvider);
  return await QuranAudioService.getChapterAudioUrl(
    chapterNumber,
    reciterId: selectedReciter?.relativePath,
  );
});

// Chapter translation provider
final chapterTranslationProvider = FutureProvider.family<
  QuranChapterResponse,
  ({int chapterNumber, String editionIdentifier})
>((ref, params) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getChapterTranslation(
    params.chapterNumber,
    editionIdentifier: params.editionIdentifier,
  );
});

// All selectable translation editions (100+ languages)
final translationEditionsProvider = FutureProvider<List<TranslationEdition>>((ref) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getTranslationEditions();
});

final translationPreferencesServiceProvider = Provider(
  (ref) => TranslationPreferencesService(),
);

/// Selected translation edition, defaulting to Sahih International (English)
/// until the editions list has loaded and any saved choice can be resolved.
class SelectedTranslationNotifier extends StateNotifier<TranslationEdition> {
  SelectedTranslationNotifier(this._prefs, this._service)
    : super(
        const TranslationEdition(
          identifier: 'en.sahih',
          language: 'en',
          name: 'Sahih International',
          englishName: 'Sahih International',
        ),
      ) {
    _restore();
  }

  final TranslationPreferencesService _prefs;
  final QuranApiService _service;

  Future<void> _restore() async {
    final savedId = await _prefs.loadSelectedEdition();
    if (savedId == null || savedId == state.identifier) return;
    try {
      final editions = await _service.getTranslationEditions();
      TranslationEdition? match;
      for (final e in editions) {
        if (e.identifier == savedId) {
          match = e;
          break;
        }
      }
      if (match != null && mounted) {
        state = match;
      }
    } catch (_) {
      // Keep the default if the editions list can't be fetched yet.
    }
  }

  Future<void> select(TranslationEdition edition) async {
    state = edition;
    await _prefs.saveSelectedEdition(edition.identifier);
  }
}

final selectedTranslationProvider =
    StateNotifierProvider<SelectedTranslationNotifier, TranslationEdition>((ref) {
      return SelectedTranslationNotifier(
        ref.watch(translationPreferencesServiceProvider),
        ref.watch(quranApiServiceProvider),
      );
    });

// Current playing audio state
class AudioPlayerState {
  final bool isPlaying;
  final String? currentAudioUrl;
  final int? currentChapterNumber;
  final int? currentVerseNumber;
  final Duration position;
  final Duration duration;

  const AudioPlayerState({
    this.isPlaying = false,
    this.currentAudioUrl,
    this.currentChapterNumber,
    this.currentVerseNumber,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    String? currentAudioUrl,
    int? currentChapterNumber,
    int? currentVerseNumber,
    Duration? position,
    Duration? duration,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentAudioUrl: currentAudioUrl ?? this.currentAudioUrl,
      currentChapterNumber: currentChapterNumber ?? this.currentChapterNumber,
      currentVerseNumber: currentVerseNumber ?? this.currentVerseNumber,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

// Audio player state notifier
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  AudioPlayerNotifier() : super(const AudioPlayerState());

  void playAudio(String audioUrl, {int? chapterNumber, int? verseNumber}) {
    state = state.copyWith(
      isPlaying: true,
      currentAudioUrl: audioUrl,
      currentChapterNumber: chapterNumber,
      currentVerseNumber: verseNumber,
    );
  }

  void pauseAudio() {
    state = state.copyWith(isPlaying: false);
  }

  void stopAudio() {
    state = const AudioPlayerState();
  }

  void updatePosition(Duration position) {
    state = state.copyWith(position: position);
  }

  void updateDuration(Duration duration) {
    state = state.copyWith(duration: duration);
  }
}

// Audio player provider
final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
      return AudioPlayerNotifier();
    });

// Selected reciter state with persistence
final selectedReciterProvider =
    StateNotifierProvider<SelectedReciterNotifier, Reciter?>((ref) {
      return SelectedReciterNotifier();
    });

class SelectedReciterNotifier extends StateNotifier<Reciter?> {
  SelectedReciterNotifier() : super(null) {
    _loadSelectedReciter();
  }

  Future<void> _loadSelectedReciter() async {
    try {
      final savedReciter =
          await ReciterPreferencesService.loadSelectedReciter();
      if (savedReciter != null) {
        state = savedReciter;
      } else {
        // Set default reciter if none is saved or if loading failed
        state = ReciterPreferencesService.getDefaultReciter();
      }
    } catch (e) {
      // If there's any error, just set the default reciter
      state = ReciterPreferencesService.getDefaultReciter();
    }
  }

  Future<void> setSelectedReciter(Reciter reciter) async {
    // Always update the state immediately for better UX
    state = reciter;

    // Try to save to preferences, but don't fail if it doesn't work
    try {
      await ReciterPreferencesService.saveSelectedReciter(reciter);
    } catch (e) {
      // Log the error but don't throw it
      // The state is already updated, so the UI will work
    }
  }

  Future<void> clearSelectedReciter() async {
    state = null;

    try {
      await ReciterPreferencesService.clearSelectedReciter();
    } catch (e) {
      // Log the error but don't throw it
    }
  }
}

// Selected language state
final selectedLanguageProvider = StateProvider<String>((ref) => 'en');
