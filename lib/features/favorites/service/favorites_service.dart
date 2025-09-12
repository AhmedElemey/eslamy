import 'package:eslamy/features/hadith/models/hadith.dart';

import '../models/favorite_hadith.dart';
import 'favorites_database.dart';

class FavoritesService {
  final FavoritesDatabase _database = FavoritesDatabase();

  Future<List<FavoriteHadith>> getFavorites() async {
    try {
      return await _database.getAllFavorites();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addToFavorites(HadithItem hadith) async {
    try {
      // Check if already exists
      final exists = await _database.isFavorite(hadith.id);
      if (exists) return false;

      final favorite = FavoriteHadith(
        id: '${hadith.id}_${DateTime.now().millisecondsSinceEpoch}',
        hadith: hadith,
        savedAt: DateTime.now(),
      );

      await _database.insertFavorite(favorite);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromFavorites(String favoriteId) async {
    try {
      final result = await _database.deleteFavorite(favoriteId);
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromFavoritesByHadithId(int hadithId) async {
    try {
      final result = await _database.deleteFavoriteByHadithId(hadithId);
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isFavorite(int hadithId) async {
    try {
      return await _database.isFavorite(hadithId);
    } catch (e) {
      return false;
    }
  }

  Future<FavoriteHadith?> getFavoriteByHadithId(int hadithId) async {
    try {
      return await _database.getFavoriteByHadithId(hadithId);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      await _database.deleteAllFavorites();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<int> getFavoritesCount() async {
    try {
      return await _database.getFavoritesCount();
    } catch (e) {
      return 0;
    }
  }
}
