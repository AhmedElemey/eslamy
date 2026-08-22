import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/ayah_of_the_day_service.dart';
import '../../service/last_read_position_service.dart';
import '../../service/quran_api_service.dart';
import '../../service/quran_audio_handler.dart';
import '../../service/quran_audio_service.dart';
import '../../service/reciter_preferences_service.dart';
import '../../service/tajweed_preferences_service.dart';
import '../../service/translation_preferences_service.dart';
import '../../models/ayah_of_the_day.dart';
import '../../models/last_read_position.dart';
import '../../models/quran_models.dart';
import '../../../settings/presentation/controllers/language_providers.dart';

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
final juzProvider = FutureProvider.family<List<AyahWithSurah>, int>((
  ref,
  juzNumber,
) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getJuz(juzNumber);
});

// Mushaf page ayahs provider — 1..604
final quranPageProvider = FutureProvider.family<List<AyahWithSurah>, int>((
  ref,
  pageNumber,
) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getPage(pageNumber);
});

// Hizb quarter ayahs provider — 1..240
final hizbQuarterProvider = FutureProvider.family<List<AyahWithSurah>, int>((
  ref,
  quarterNumber,
) async {
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
final tafseerProvider =
    FutureProvider.family<AyahTafsir, ({int chapterNumber, int verseNumber})>((
      ref,
      params,
    ) async {
      final service = ref.read(quranApiServiceProvider);
      return await service.getTafseer(params.chapterNumber, params.verseNumber);
    });

// Chapter Tajweed provider — same shape as chapterProvider, but verse text
// carries Tajweed bracket tags instead of plain Uthmani text.
final chapterTajweedProvider = FutureProvider.family<QuranChapterResponse, int>(
  (ref, chapterNumber) async {
    final service = ref.read(quranApiServiceProvider);
    return await service.getChapterTajweed(chapterNumber);
  },
);

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
      return TajweedColoringNotifier(
        ref.watch(tajweedPreferencesServiceProvider),
      );
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
final translationEditionsProvider = FutureProvider<List<TranslationEdition>>((
  ref,
) async {
  final service = ref.read(quranApiServiceProvider);
  return await service.getTranslationEditions();
});

final translationPreferencesServiceProvider = Provider(
  (ref) => TranslationPreferencesService(),
);

/// Selected translation edition, defaulting to Sahih International (English)
/// until the editions list has loaded and any saved choice can be resolved.
/// The Quran text is already Arabic, so the API has no true Arabic
/// "translation" edition — `ar.muyassar` (a well-known plain-language
/// tafsir) fills that role here by deliberate choice, not a literal
/// translation. Italian has exactly one clean edition; English keeps the
/// long-standing default.
TranslationEdition defaultTranslationForLanguage(AppLanguage language) {
  return switch (language) {
    AppLanguage.arabic => const TranslationEdition(
      identifier: 'ar.muyassar',
      language: 'ar',
      name: 'التفسير الميسر',
      englishName: 'Al-Muyassar (Tafsir)',
    ),
    AppLanguage.italian => const TranslationEdition(
      identifier: 'it.piccardo',
      language: 'it',
      name: 'Hamza Roberto Piccardo',
      englishName: 'Hamza Roberto Piccardo',
    ),
    AppLanguage.english => const TranslationEdition(
      identifier: 'en.sahih',
      language: 'en',
      name: 'Sahih International',
      englishName: 'Sahih International',
    ),
  };
}

class SelectedTranslationNotifier extends StateNotifier<TranslationEdition> {
  SelectedTranslationNotifier(
    this._prefs,
    this._service,
    AppLanguage appLanguage,
  ) : super(defaultTranslationForLanguage(appLanguage)) {
    _restore();
  }

  final TranslationPreferencesService _prefs;
  final QuranApiService _service;

  Future<void> _restore() async {
    // No explicit save yet — the language-based default from the
    // constructor already stands, and should keep tracking app-language
    // changes until the user actually picks an edition themselves.
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
    StateNotifierProvider<SelectedTranslationNotifier, TranslationEdition>((
      ref,
    ) {
      // Watched (not read) so a fresh notifier — and thus a fresh
      // language-based default — is created whenever app language changes,
      // same pattern relied on for the reciter/translation restore flow.
      final appLanguage =
          ref.watch(languageProvider).valueOrNull ?? AppLanguage.arabic;
      return SelectedTranslationNotifier(
        ref.watch(translationPreferencesServiceProvider),
        ref.watch(quranApiServiceProvider),
        appLanguage,
      );
    });

// The single app-wide audio session, overridden with a real instance once
// `AudioService.init` resolves in `main.dart`. Reading this before that
// override is a programming error (there's no sensible "no handler yet"
// fallback), hence the throw.
final quranAudioHandlerProvider = Provider<QuranAudioHandler>((ref) {
  throw UnimplementedError(
    'quranAudioHandlerProvider must be overridden in main.dart after '
    'AudioService.init() resolves.',
  );
});

// Currently loaded surah, or null when nothing is playing/paused. Drives the
// persistent FAB's visibility and the Now Playing page's title/reciter.
final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  return ref.watch(quranAudioHandlerProvider).mediaItem;
});

// Play/pause/processing state, used for the FAB icon, the Now Playing page's
// controls, and per-chapter "is this the surah currently playing" checks.
final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  return ref.watch(quranAudioHandlerProvider).playbackState;
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

final ayahOfTheDayServiceProvider = Provider((ref) => AyahOfTheDayService());

/// A random ayah picked once per calendar day, cached so it stays the same
/// across app opens on the same day. Falls back to the last cached pick
/// (even if stale) when a fresh fetch fails, so the home widget still shows
/// something offline instead of an error.
final ayahOfTheDayProvider = FutureProvider<AyahOfTheDay>((ref) async {
  final cacheService = ref.watch(ayahOfTheDayServiceProvider);
  final apiService = ref.watch(quranApiServiceProvider);
  final editionIdentifier = ref.watch(selectedTranslationProvider).identifier;
  final todayKey = todayDateKey();

  final cached = await cacheService.loadCached();
  if (cached != null && cached.dateKey == todayKey) {
    return cached;
  }

  try {
    final chapters = await apiService.getChapters();
    final random = Random(int.parse(todayKey.replaceAll('-', '')));
    final chapter = chapters[random.nextInt(chapters.length)];
    final verseNumber = 1 + random.nextInt(chapter.numberOfAyahs);

    final verse = await apiService.getVerse(chapter.number, verseNumber);
    final translation = await apiService.getAyahInEdition(
      chapter.number,
      verseNumber,
      editionIdentifier,
    );

    final ayah = AyahOfTheDay(
      chapterNumber: chapter.number,
      chapterArabicName: chapter.name,
      chapterEnglishName: chapter.englishName,
      verseNumber: verseNumber,
      arabicText: verse.verse.text,
      translationText: translation.text,
      dateKey: todayKey,
    );
    await cacheService.save(ayah);
    return ayah;
  } catch (e) {
    if (cached != null) return cached;
    rethrow;
  }
});

final lastReadPositionServiceProvider = Provider(
  (ref) => LastReadPositionService(),
);

class LastReadPositionNotifier extends StateNotifier<LastReadPosition?> {
  LastReadPositionNotifier(this._service) : super(null) {
    _restore();
  }

  final LastReadPositionService _service;

  Future<void> _restore() async {
    final saved = await _service.load();
    if (mounted) state = saved;
  }

  Future<void> save(LastReadPosition position) async {
    state = position;
    await _service.save(position);
  }
}

/// Where the user last left off in the Mushaf reader, or null if they
/// haven't read anything yet — drives the home screen's "Continue Reading"
/// card.
final lastReadPositionProvider =
    StateNotifierProvider<LastReadPositionNotifier, LastReadPosition?>((ref) {
      return LastReadPositionNotifier(
        ref.watch(lastReadPositionServiceProvider),
      );
    });
