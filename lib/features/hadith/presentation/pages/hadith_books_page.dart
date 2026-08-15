import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/hadith_book.dart';
import '../controllers/hadith_books_providers.dart';
import 'hadith_book_detail_page.dart';

class HadithBooksPage extends StatelessWidget {
  const HadithBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(context.l10n.hadithCollectionTitle)),
      body: AppBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: hadithBooks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _BookTile(book: hadithBooks[index]),
          ),
        ),
      ),
    );
  }
}

class _BookTile extends ConsumerWidget {
  const _BookTile({required this.book});

  final HadithBook book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cached = ref.watch(bookCachedStatusProvider(book));
    final textColor = Theme.of(context).textTheme.titleMedium?.color;

    return GlassCard(
      borderRadius: 16,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HadithBookDetailPage(book: book),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDeep, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              book.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          cached.when(
            data: (isCached) =>
                isCached
                    ? Icon(Icons.check_circle, color: Colors.green[500], size: 20)
                    : const Icon(Icons.cloud_download_outlined, color: AppColors.muted, size: 20),
            loading: () => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
