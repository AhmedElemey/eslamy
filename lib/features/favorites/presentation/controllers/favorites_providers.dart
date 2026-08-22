import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/favorites_service.dart';
import '../../models/favorite_hadith.dart';
import '../../models/favorite_surah.dart';
import '../../../hadith/models/hadith.dart';

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService();
});

class FavoritesState {
  final List<FavoriteHadith> favorites;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<FavoriteHadith>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier(this._service) : super(const FavoritesState());

  final FavoritesService _service;

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final favorites = await _service.getFavorites();
      state = state.copyWith(favorites: favorites, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<bool> addToFavorites(HadithItem hadith) async {
    try {
      final success = await _service.addToFavorites(hadith);
      if (success) {
        await loadFavorites(); // Refresh the list
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> removeFromFavorites(String favoriteId) async {
    try {
      final success = await _service.removeFromFavorites(favoriteId);
      if (success) {
        await loadFavorites(); // Refresh the list
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> removeFromFavoritesByHadithId(int hadithId) async {
    try {
      final success = await _service.removeFromFavoritesByHadithId(hadithId);
      if (success) {
        await loadFavorites(); // Refresh the list
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> isFavorite(int hadithId) async {
    try {
      return await _service.isFavorite(hadithId);
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      await _service.clearAllFavorites();
      await loadFavorites();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<List<FavoriteHadith>> getFavorites() async {
    return await _service.getFavorites();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
      final service = ref.watch(favoritesServiceProvider);
      return FavoritesNotifier(service);
    });

class QuranFavoritesState {
  final List<FavoriteSurah> favorites;
  final bool isLoading;
  final String? error;

  const QuranFavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  QuranFavoritesState copyWith({
    List<FavoriteSurah>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return QuranFavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Mirrors [FavoritesNotifier] but for bookmarked Quran chapters — a single
/// heart toggle per surah rather than a per-item list like hadith, since
/// there's only ever one row per chapter number.
class QuranFavoritesNotifier extends StateNotifier<QuranFavoritesState> {
  QuranFavoritesNotifier(this._service) : super(const QuranFavoritesState());

  final FavoritesService _service;

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final favorites = await _service.getQuranFavorites();
      state = state.copyWith(favorites: favorites, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  bool isFavorite(int chapterNumber) =>
      state.favorites.any((f) => f.chapterNumber == chapterNumber);

  /// Adds [chapterNumber] if not already saved, removes it if it is —
  /// mirrors the mini player's heart icon toggle behavior.
  Future<void> toggle({
    required int chapterNumber,
    required String chapterName,
    required String chapterEnglishName,
  }) async {
    if (isFavorite(chapterNumber)) {
      await _service.removeChapterFromFavorites(chapterNumber);
    } else {
      await _service.addChapterToFavorites(
        chapterNumber: chapterNumber,
        chapterName: chapterName,
        chapterEnglishName: chapterEnglishName,
      );
    }
    await loadFavorites();
  }

  Future<bool> removeFromFavorites(int chapterNumber) async {
    try {
      final success = await _service.removeChapterFromFavorites(chapterNumber);
      if (success) await loadFavorites();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final quranFavoritesProvider =
    StateNotifierProvider<QuranFavoritesNotifier, QuranFavoritesState>((ref) {
      final service = ref.watch(favoritesServiceProvider);
      return QuranFavoritesNotifier(service);
    });
