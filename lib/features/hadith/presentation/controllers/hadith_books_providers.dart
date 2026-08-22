import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/hadith.dart';
import '../../models/hadith_book.dart';
import '../../service/hadith_api_service.dart';
import '../../service/hadith_cache_database.dart';
import '../../../settings/presentation/controllers/language_providers.dart';

final hadithCacheDbProvider = Provider((ref) => HadithCacheDatabase());

class BookHadithsState {
  final List<HadithItem> allCached;
  final List<HadithItem> visible;
  final bool isDownloading;
  final double downloadProgress;
  final bool isCached;
  final String? error;
  final String query;

  const BookHadithsState({
    this.allCached = const [],
    this.visible = const [],
    this.isDownloading = false,
    this.downloadProgress = 0,
    this.isCached = false,
    this.error,
    this.query = '',
  });

  BookHadithsState copyWith({
    List<HadithItem>? allCached,
    List<HadithItem>? visible,
    bool? isDownloading,
    double? downloadProgress,
    bool? isCached,
    String? error,
    String? query,
  }) {
    return BookHadithsState(
      allCached: allCached ?? this.allCached,
      visible: visible ?? this.visible,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isCached: isCached ?? this.isCached,
      error: error,
      query: query ?? this.query,
    );
  }
}

/// autoDispose: a downloaded book's ~4-8k hadiths are only worth holding in
/// memory while the user is actually browsing it.
class BookHadithsNotifier extends StateNotifier<BookHadithsState> {
  BookHadithsNotifier(this._api, this._db, this.book, this.editionSlug)
    : super(const BookHadithsState()) {
    _init();
  }

  final HadithApiService _api;
  final HadithCacheDatabase _db;
  final HadithBook book;
  final String editionSlug;

  Future<void> _init() async {
    final count = await _db.countForBook(editionSlug);
    if (count > 0) {
      final items = await _db.getBookHadiths(editionSlug, book.slug, book.name);
      if (!mounted) return;
      state = state.copyWith(allCached: items, visible: items, isCached: true);
    } else {
      await download();
    }
  }

  Future<void> download() async {
    state = state.copyWith(
      isDownloading: true,
      downloadProgress: 0,
      error: null,
    );
    try {
      final items = await _api.fetchBook(
        book,
        editionSlug: editionSlug,
        onProgress: (received, total) {
          if (!mounted || total <= 0) return;
          state = state.copyWith(downloadProgress: received / total);
        },
      );
      await _db.cacheBook(editionSlug, items);
      if (!mounted) return;
      state = state.copyWith(
        allCached: items,
        visible: _filter(items, state.query),
        isDownloading: false,
        isCached: true,
        downloadProgress: 1,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isDownloading: false, error: e.toString());
    }
  }

  void search(String query) {
    state = state.copyWith(
      query: query,
      visible: _filter(state.allCached, query),
    );
  }

  List<HadithItem> _filter(List<HadithItem> items, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((h) {
      final body = h.body?.toLowerCase() ?? '';
      final narrator = h.narrator?.toLowerCase() ?? '';
      return body.contains(q) ||
          narrator.contains(q) ||
          '${h.hadithNumber}' == q ||
          (h.hadithNumber != null && h.hadithNumber!.toInt().toString() == q);
    }).toList();
  }
}

final bookHadithsProvider = StateNotifierProvider.autoDispose
    .family<BookHadithsNotifier, BookHadithsState, HadithBook>((ref, book) {
      final api = ref.watch(hadithApiServiceProvider);
      final db = ref.watch(hadithCacheDbProvider);
      // Watched so switching app language rebuilds this with the matching
      // edition slug (a fresh notifier — the family key is still just
      // `book`, so this doesn't fragment the family).
      final appLanguage =
          ref.watch(languageProvider).valueOrNull ?? AppLanguage.arabic;
      return BookHadithsNotifier(
        api,
        db,
        book,
        editionSlugFor(book, appLanguage),
      );
    });

/// Per-book cached status for the books browse page (name shown, downloaded
/// badge or not). autoDispose + family so each book's tiny query is cheap
/// and doesn't linger once the browse page is left.
final bookCachedStatusProvider = FutureProvider.autoDispose
    .family<bool, HadithBook>((ref, book) async {
      final db = ref.watch(hadithCacheDbProvider);
      final appLanguage =
          ref.watch(languageProvider).valueOrNull ?? AppLanguage.arabic;
      final count = await db.countForBook(editionSlugFor(book, appLanguage));
      return count > 0;
    });
