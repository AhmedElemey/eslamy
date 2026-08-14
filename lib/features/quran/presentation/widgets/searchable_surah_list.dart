import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/quran_providers.dart';
import '../pages/quran_chapter_detail_page.dart';

/// The 114-chapter Surah list, filterable by [query] (English name, Arabic
/// name, or chapter number) — used inside QuranIndexPage's search.
class SearchableSurahList extends ConsumerWidget {
  const SearchableSurahList({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = context.l10n;
    final chaptersAsync = ref.watch(chaptersProvider);

    return chaptersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load surahs\n$e', textAlign: TextAlign.center),
        ),
      ),
      data: (chapters) {
        final q = query.trim().toLowerCase();
        final filtered = q.isEmpty
            ? chapters
            : chapters
                .where((c) =>
                    c.englishName.toLowerCase().contains(q) ||
                    c.name.contains(query.trim()) ||
                    '${c.number}' == q)
                .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No surahs match "$query"', textAlign: TextAlign.center),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final chapter = filtered[i];
            final origin = chapter.revelationType == 'Meccan'
                ? l10n.quranOriginMeccan
                : l10n.quranOriginMedinian;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.violet],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${chapter.number}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                title: Text(chapter.englishName, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '$origin • ${l10n.versesCountCaps(chapter.numberOfAyahs)}',
                  style: TextStyle(color: textMuted),
                ),
                trailing: Text(
                  chapter.name,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuranChapterDetailPage(
                        chapterNumber: chapter.number,
                        chapterName: chapter.englishName,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
