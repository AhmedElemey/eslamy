import 'package:flutter/material.dart';
import 'package:eslamy/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/favorites_providers.dart';
import '../../models/favorite_hadith.dart';
import '../../models/favorite_surah.dart';
import '../../../hadith/presentation/widgets/hadith_share_sheet.dart';
import '../../../quran/presentation/pages/quran_chapter_detail_page.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/display_names.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Rebuild for every index change (not just committed swipes) so the
      // header/delete-all button track the tab as it's being dragged.
      setState(() {});
    });
    Future.microtask(() {
      ref.read(favoritesProvider.notifier).loadFavorites();
      ref.read(quranFavoritesProvider.notifier).loadFavorites();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.primary;
    final l10n = context.l10n;
    final hadithState = ref.watch(favoritesProvider);
    final hadithNotifier = ref.read(favoritesProvider.notifier);
    final quranState = ref.watch(quranFavoritesProvider);
    final quranNotifier = ref.read(quranFavoritesProvider.notifier);
    final isQuranTab = _tabController.index == 1;

    final textColor = Theme.of(context).textTheme.titleMedium?.color;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.favoritesTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (isQuranTab
              ? quranState.favorites.isNotEmpty
              : hadithState.favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed:
                  () =>
                      isQuranTab
                          ? _showClearAllQuranDialog(
                            context,
                            quranNotifier,
                            quranState.favorites,
                          )
                          : _showClearAllDialog(context, hadithNotifier),
            ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isQuranTab ? Icons.menu_book_rounded : Icons.favorite,
                        color: primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isQuranTab
                                ? l10n.bookmarkedQuran
                                : l10n.bookmarkedHadiths,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isQuranTab
                                ? l10n.surahsSavedCount(
                                  quranState.favorites.length,
                                )
                                : l10n.hadithsSavedCount(
                                  hadithState.favorites.length,
                                ),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.heading(context),
                unselectedLabelColor: AppColors.mutedText(context),
                tabs: [
                  Tab(text: l10n.hadithLabel),
                  Tab(text: l10n.navQuranLabel),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHadithContent(hadithState, hadithNotifier),
                    _buildQuranContent(quranState, quranNotifier),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Hadith tab ----

  Widget _buildHadithContent(FavoritesState state, FavoritesNotifier notifier) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return _buildErrorState(() => notifier.loadFavorites());
    }

    if (state.favorites.isEmpty) {
      return _buildEmptyState(context.l10n.noFavoritesYetBody);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadFavorites(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: state.favorites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildHadithCard(state.favorites[index], notifier);
        },
      ),
    );
  }

  Widget _buildHadithCard(FavoriteHadith favorite, FavoritesNotifier notifier) {
    const primary = AppColors.primary;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color;
    final bodyColor = Theme.of(context).textTheme.bodyLarge?.color;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDeep, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${favorite.hadith.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => showHadithShareSheet(context, favorite.hadith),
                icon: const Icon(
                  Icons.share_outlined,
                  color: primary,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => _removeFavorite(favorite.id, notifier),
                icon: const Icon(Icons.bookmark, color: primary, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (favorite.hadith.title.isNotEmpty) ...[
            Text(
              favorite.hadith.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
          ],

          if (favorite.hadith.narrator != null &&
              favorite.hadith.narrator!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                favorite.hadith.narrator!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFB8863C),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (favorite.hadith.body != null &&
              favorite.hadith.body!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline(context)),
              ),
              child: Text(
                favorite.hadith.body!,
                style: TextStyle(fontSize: 14, color: bodyColor, height: 1.6),
              ),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.mutedText(context),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(favorite.savedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedText(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Quran tab ----

  Widget _buildQuranContent(
    QuranFavoritesState state,
    QuranFavoritesNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return _buildErrorState(() => notifier.loadFavorites());
    }

    if (state.favorites.isEmpty) {
      return _buildEmptyState(context.l10n.noQuranFavoritesYetBody);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadFavorites(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: state.favorites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildQuranCard(state.favorites[index], notifier);
        },
      ),
    );
  }

  Widget _buildQuranCard(
    FavoriteSurah favorite,
    QuranFavoritesNotifier notifier,
  ) {
    const primary = AppColors.primary;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color;
    final name = localizedChapterName(
      context: context,
      arabicName: favorite.chapterName,
      englishName: favorite.chapterEnglishName,
    );

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => QuranChapterDetailPage(
                      chapterNumber: favorite.chapterNumber,
                      chapterName: name,
                    ),
              ),
            ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDeep, AppColors.primary],
                ),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${favorite.chapterNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 13,
                        color: AppColors.mutedText(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(favorite.savedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed:
                  () => _removeQuranFavorite(favorite.chapterNumber, notifier),
              icon: const Icon(Icons.favorite_rounded, color: primary),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Shared states ----

  Widget _buildErrorState(VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.somethingWentWrongGeneric,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.failedToLoadFavorites,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mutedText(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String body) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.bookmark_border,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.noFavoritesYetTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mutedText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final l10n = context.l10n;

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.hoursAgo(difference.inHours);
    } else {
      return l10n.justNow;
    }
  }

  Future<void> _removeFavorite(
    String favoriteId,
    FavoritesNotifier notifier,
  ) async {
    final success = await notifier.removeFromFavorites(favoriteId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.removedFromFavorites),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _removeQuranFavorite(
    int chapterNumber,
    QuranFavoritesNotifier notifier,
  ) async {
    final success = await notifier.removeFromFavorites(chapterNumber);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.removedFromFavorites),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _showClearAllDialog(
    BuildContext context,
    FavoritesNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.clearAllFavoritesTitle),
            content: Text(l10n.clearAllFavoritesBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.clearAllButton),
              ),
            ],
          ),
    );

    if (result == true && mounted) {
      await notifier.clearAllFavorites();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.allFavoritesCleared),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _showClearAllQuranDialog(
    BuildContext context,
    QuranFavoritesNotifier notifier,
    List<FavoriteSurah> favorites,
  ) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.clearAllFavoritesTitle),
            content: Text(l10n.clearAllFavoritesBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.clearAllButton),
              ),
            ],
          ),
    );

    if (result != true || !mounted) return;
    for (final favorite in favorites) {
      await notifier.removeFromFavorites(favorite.chapterNumber);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.allFavoritesCleared),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
