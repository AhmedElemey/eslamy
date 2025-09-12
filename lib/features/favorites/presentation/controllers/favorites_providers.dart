import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/favorites_service.dart';
import '../../models/favorite_hadith.dart';
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
