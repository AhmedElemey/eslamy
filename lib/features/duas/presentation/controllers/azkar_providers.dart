import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/azkar_cache_database.dart';
import '../../data/azkar_local_datasource.dart';
import '../../data/azkar_remote_datasource.dart';
import '../../data/models/azkar_models.dart';

final azkarCacheDatabaseProvider = Provider((ref) => AzkarCacheDatabase());
final azkarLocalDataSourceProvider = Provider((ref) => AzkarLocalDataSource());

Future<void> _ensureSeeded(AzkarCacheDatabase cache, AzkarLocalDataSource local) async {
  if (await cache.isEmpty()) {
    final seed = await local.load();
    await cache.replaceAll(seed);
  }
}

/// Categories list: cache-first, seeded from the bundled asset on first
/// run, then opportunistically refreshed from UmmahAPI in the background.
/// The UI never blocks on and never surfaces a network error for the
/// refresh — offline users simply keep the bundled snapshot.
class AzkarCategoriesNotifier extends StateNotifier<AsyncValue<List<AzkarCategory>>> {
  AzkarCategoriesNotifier(this._cache, this._local, this._remote)
    : super(const AsyncValue.loading()) {
    _load();
  }

  final AzkarCacheDatabase _cache;
  final AzkarLocalDataSource _local;
  final AzkarRemoteDataSource _remote;

  Future<void> _load() async {
    try {
      await _ensureSeeded(_cache, _local);
      if (!mounted) return;
      state = AsyncValue.data(await _cache.getCategories());
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
    unawaited(_refreshInBackground());
  }

  Future<void> _refreshInBackground() async {
    try {
      final fresh = await _remote.fetch();
      await _cache.replaceAll(fresh);
      if (!mounted) return;
      state = AsyncValue.data(await _cache.getCategories());
    } catch (_) {
      // No internet or the API is unreachable — bundled/cached data stands.
    }
  }
}

final azkarCategoriesProvider =
    StateNotifierProvider<AzkarCategoriesNotifier, AsyncValue<List<AzkarCategory>>>((ref) {
      return AzkarCategoriesNotifier(
        ref.watch(azkarCacheDatabaseProvider),
        ref.watch(azkarLocalDataSourceProvider),
        ref.watch(azkarRemoteDataSourceProvider),
      );
    });

final azkarItemsProvider = FutureProvider.family<List<AzkarItem>, String>((ref, categoryId) async {
  final cache = ref.watch(azkarCacheDatabaseProvider);
  await _ensureSeeded(cache, ref.watch(azkarLocalDataSourceProvider));
  return cache.getItemsForCategory(categoryId);
});
