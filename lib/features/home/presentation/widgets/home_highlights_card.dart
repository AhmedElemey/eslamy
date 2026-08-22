import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/display_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../duas/data/models/azkar_models.dart';
import '../../../duas/presentation/controllers/azkar_providers.dart';
import '../../../duas/presentation/pages/azkar_category_detail_page.dart';
import '../../../quran/presentation/controllers/quran_providers.dart';
import '../../../quran/presentation/pages/quran_chapter_detail_page.dart';

/// Swipeable highlight reel for the home screen: today's ayah, where the
/// user left off reading, and today's dua, sharing one card instead of
/// stacking three separate ones.
class HomeHighlightsCard extends StatefulWidget {
  const HomeHighlightsCard({super.key});

  @override
  State<HomeHighlightsCard> createState() => _HomeHighlightsCardState();
}

class _HomeHighlightsCardState extends State<HomeHighlightsCard> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      _AyahOfTheDayPage(),
      _ContinueReadingPage(),
      _DuaOfTheDayPage(),
    ];

    return Column(
      children: [
        SizedBox(
          height: 196,
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            children: pages,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < pages.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color:
                      i == _index
                          ? AppColors.primaryOnBg(context)
                          : AppColors.hairline(context),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Shared card chrome (surface, border, small caps title) for each swipe
/// page — keeps the three pages visually identical apart from their body.
class _HighlightShell extends StatelessWidget {
  const _HighlightShell({
    required this.icon,
    required this.title,
    required this.child,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.hairline(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryOnBg(context)),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.primaryOnBg(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _AyahOfTheDayPage extends ConsumerWidget {
  const _AyahOfTheDayPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ayahAsync = ref.watch(ayahOfTheDayProvider);

    return ayahAsync.when(
      data: (ayah) {
        final chapterName = localizedChapterName(
          context: context,
          arabicName: ayah.chapterArabicName,
          englishName: ayah.chapterEnglishName,
        );
        return _HighlightShell(
          icon: Icons.auto_stories_outlined,
          title: l10n.homeHighlightAyahOfDayTitle,
          onTap:
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (_) => QuranChapterDetailPage(
                        chapterNumber: ayah.chapterNumber,
                        chapterName: chapterName,
                        startingAyah: ayah.verseNumber,
                      ),
                ),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ayah.arabicText,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.ayah(context, size: 19),
                ),
              ),
              if (ayah.translationText.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  ayah.translationText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText(context),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                l10n.homeHighlightSurahAyahLabel(chapterName, ayah.verseNumber),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText(context),
                ),
              ),
            ],
          ),
        );
      },
      loading:
          () => _HighlightShell(
            icon: Icons.auto_stories_outlined,
            title: l10n.homeHighlightAyahOfDayTitle,
            child: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (_, _) => _HighlightShell(
            icon: Icons.auto_stories_outlined,
            title: l10n.homeHighlightAyahOfDayTitle,
            child: Center(
              child: Text(
                l10n.homeHighlightAyahOfDayError,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mutedText(context),
                  fontSize: 12,
                ),
              ),
            ),
          ),
    );
  }
}

class _ContinueReadingPage extends ConsumerWidget {
  const _ContinueReadingPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final position = ref.watch(lastReadPositionProvider);

    if (position == null) {
      return _HighlightShell(
        icon: Icons.bookmark_border_rounded,
        title: l10n.homeHighlightContinueReadingTitle,
        child: Center(
          child: Text(
            l10n.homeHighlightContinueReadingEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedText(context), fontSize: 13),
          ),
        ),
      );
    }

    final chapterName = localizedChapterName(
      context: context,
      arabicName: position.chapterArabicName,
      englishName: position.chapterEnglishName,
    );

    return _HighlightShell(
      icon: Icons.bookmark_border_rounded,
      title: l10n.homeHighlightContinueReadingTitle,
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => QuranChapterDetailPage(
                    chapterNumber: position.chapterNumber,
                    chapterName: chapterName,
                    startingAyah: position.ayahNumber,
                  ),
            ),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            chapterName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.heading(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.homeHighlightAyahPageLabel(
              position.ayahNumber,
              position.pageNumber,
            ),
            style: TextStyle(fontSize: 12, color: AppColors.mutedText(context)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                color: AppColors.primaryOnBg(context),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.homeHighlightContinueReadingCta,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primaryOnBg(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DuaOfTheDayPage extends ConsumerWidget {
  const _DuaOfTheDayPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final duaAsync = ref.watch(duaOfTheDayProvider);
    final categoriesAsync = ref.watch(azkarCategoriesProvider);

    return duaAsync.when(
      data: (dua) {
        AzkarCategory? category;
        for (final c
            in categoriesAsync.valueOrNull ?? const <AzkarCategory>[]) {
          if (c.id == dua.categoryId) {
            category = c;
            break;
          }
        }
        final matchedCategory = category;
        return _HighlightShell(
          icon: Icons.volunteer_activism_outlined,
          title: l10n.homeHighlightDuaOfDayTitle,
          onTap:
              matchedCategory == null
                  ? null
                  : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => AzkarCategoryDetailPage(
                            category: matchedCategory,
                          ),
                    ),
                  ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  dua.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.naskh(
                    size: 19,
                    weight: FontWeight.w600,
                    color: AppColors.ayahText(context),
                    height: 1.7,
                  ),
                ),
              ),
              if (dua.translation.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  dua.translation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText(context),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                localizedAzkarCategoryName(
                  l10n,
                  dua.categoryId,
                  dua.categoryId,
                ),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText(context),
                ),
              ),
            ],
          ),
        );
      },
      loading:
          () => _HighlightShell(
            icon: Icons.volunteer_activism_outlined,
            title: l10n.homeHighlightDuaOfDayTitle,
            child: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (_, _) => _HighlightShell(
            icon: Icons.volunteer_activism_outlined,
            title: l10n.homeHighlightDuaOfDayTitle,
            child: Center(
              child: Text(
                l10n.homeHighlightDuaOfDayError,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mutedText(context),
                  fontSize: 12,
                ),
              ),
            ),
          ),
    );
  }
}
