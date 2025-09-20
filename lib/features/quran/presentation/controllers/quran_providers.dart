import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/quran_api_service.dart';
import '../../service/quran_audio_service.dart';
import '../../service/reciter_preferences_service.dart';
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
  QuranChapterResponse,
  ({int chapterNumber, int verseNumber})
>((ref, params) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getTafseer(params.chapterNumber, params.verseNumber);
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
  ({int chapterNumber, String language})
>((ref, params) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getChapterTranslation(
    params.chapterNumber,
    language: params.language,
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
