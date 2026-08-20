import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/display_names.dart';
import '../../../../core/localization/error_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/number_seal.dart';
import '../controllers/quran_providers.dart';
import '../pages/quran_chapter_detail_page.dart';

/// The 114-chapter Surah list, filterable by [query] (English name, Arabic
/// name, or chapter number) — used inside QuranIndexPage's search.
class SearchableSurahList extends ConsumerWidget {
  const SearchableSurahList({
    super.key,
    required this.query,
    this.chapterPageBuilder,
  });

  final String query;

  /// Opens a custom chapter page (e.g. Tafseer). Defaults to the mushaf
  /// [QuranChapterDetailPage].
  final Widget Function(int chapterNumber, String chapterName)?
      chapterPageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textMuted = AppColors.mutedText(context);
    final l10n = context.l10n;
    final chaptersAsync = ref.watch(chaptersProvider);

    return chaptersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.failedToLoadSurahsWithError(localizedError(l10n, e)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      data: (chapters) {
        final q = query.trim().toLowerCase();
        final filtered =
            q.isEmpty
                ? chapters
                : chapters
                    .where(
                      (c) =>
                          c.englishName.toLowerCase().contains(q) ||
                          c.name.contains(query.trim()) ||
                          '${c.number}' == q,
                    )
                    .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.noSurahsMatchQuery(query),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final chapter = filtered[i];
            final origin =
                chapter.revelationType == 'Meccan'
                    ? l10n.quranOriginMeccan
                    : l10n.quranOriginMedinian;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.hairline(context)),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: NumberSeal(label: '${chapter.number}'),
                title: Text(
                  localizedChapterName(
                    context: context,
                    arabicName: chapter.name,
                    englishName: chapter.englishName,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '$origin • ${l10n.versesCountCaps(chapter.numberOfAyahs)}',
                  style: TextStyle(color: textMuted),
                ),
                trailing: isArabicLocale(context)
                    ? Text(
                        chapter.englishName,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : Text(
                  chapter.name,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  final chapterName = localizedChapterName(
                    context: context,
                    arabicName: chapter.name,
                    englishName: chapter.englishName,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              chapterPageBuilder?.call(
                                chapter.number,
                                chapterName,
                              ) ??
                              QuranChapterDetailPage(
                                chapterNumber: chapter.number,
                                chapterName: chapterName,
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
