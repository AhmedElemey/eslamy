import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../favorites/presentation/controllers/favorites_providers.dart';
import '../../models/hadith.dart';
import '../../models/hadith_book.dart';
import '../controllers/hadith_books_providers.dart';
import '../widgets/hadith_share_sheet.dart';

class HadithBookDetailPage extends ConsumerStatefulWidget {
  const HadithBookDetailPage({super.key, required this.book});

  final HadithBook book;

  @override
  ConsumerState<HadithBookDetailPage> createState() =>
      _HadithBookDetailPageState();
}

class _HadithBookDetailPageState extends ConsumerState<HadithBookDetailPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(favoritesProvider.notifier).loadFavorites());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookHadithsProvider(widget.book));
    final notifier = ref.read(bookHadithsProvider(widget.book).notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(widget.book.name)),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              if (state.isCached)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    onChanged: notifier.search,
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.book.name}…',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              Expanded(child: _buildBody(state, notifier)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BookHadithsState state, BookHadithsNotifier notifier) {
    if (state.isDownloading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: state.downloadProgress > 0 ? state.downloadProgress : null,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Downloading ${widget.book.name} for offline use…',
                textAlign: TextAlign.center,
              ),
              if (state.downloadProgress > 0) ...[
                const SizedBox(height: 4),
                Text('${(state.downloadProgress * 100).round()}%'),
              ],
            ],
          ),
        ),
      );
    }

    if (state.error != null && state.allCached.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Failed to download\n${state.error}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: notifier.download,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.visible.isEmpty) {
      return const Center(child: Text('No hadiths match your search'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.visible.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _HadithCard(hadith: state.visible[index]),
    );
  }
}

class _HadithCard extends ConsumerWidget {
  const _HadithCard({required this.hadith});

  final HadithItem hadith;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (s) => s.favorites.any((f) => f.hadith.id == hadith.id),
      ),
    );

    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return GlassCard(
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${hadith.hadithNumber}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => showHadithShareSheet(context, hadith),
                icon: const Icon(Icons.share_outlined, color: AppColors.muted),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                onPressed: () => _toggleFavorite(context, ref, isFavorite),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.primary : Colors.grey[500],
                ),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          if (hadith.narrator != null && hadith.narrator!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Narrated ${hadith.narrator}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.muted,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            hadith.body ?? '',
            style: TextStyle(fontSize: 14, height: 1.6, color: textColor),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    bool isCurrentlyFavorite,
  ) async {
    final notifier = ref.read(favoritesProvider.notifier);
    if (isCurrentlyFavorite) {
      await notifier.removeFromFavoritesByHadithId(hadith.id);
    } else {
      await notifier.addToFavorites(hadith);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCurrentlyFavorite ? 'Removed from favorites' : 'Added to favorites'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
