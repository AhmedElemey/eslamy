import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/display_names.dart';
import '../../../../core/localization/error_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/ayah_block.dart';
import '../../models/quran_models.dart';
import 'quran_verse_detail_page.dart';

/// Displays the ayahs of a Juz, mushaf page, or Hizb quarter — the three
/// share an identical shape (a flat ayah list that spans surah boundaries),
/// so this one page serves all three rather than tripling near-identical
/// screens. [rangeProvider] is whichever family provider already resolves
/// to that range's ayahs (juzProvider(n), quranPageProvider(n), etc).
class QuranRangeDetailPage extends ConsumerWidget {
  const QuranRangeDetailPage({
    super.key,
    required this.title,
    required this.rangeProvider,
  });

  final String title;
  final ProviderListenable<AsyncValue<List<AyahWithSurah>>> rangeProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(rangeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(title)),
      body: AppBackground(
        child: SafeArea(
          child: ayahsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      context.l10n.couldNotLoadSectionWithError(
                        localizedError(context.l10n, e),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            data:
                (ayahs) => ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: ayahs.length,
                  itemBuilder: (context, i) {
                    final ayah = ayahs[i];
                    final isNewSurah =
                        i == 0 || ayahs[i - 1].surahNumber != ayah.surahNumber;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isNewSurah) _SurahHeader(ayah: ayah),
                        AyahBlock(
                          number: ayah.numberInSurah,
                          arabic: ayah.text,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => QuranVerseDetailPage(
                                      chapterNumber: ayah.surahNumber,
                                      verseNumber: ayah.numberInSurah,
                                      verseText: ayah.text,
                                    ),
                              ),
                            );
                          },
                        ),
                        Divider(height: 1, color: AppColors.hairline(context)),
                      ],
                    );
                  },
                ),
          ),
        ),
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.ayah});

  final AyahWithSurah ayah;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${ayah.surahNumber}. ${localizedChapterName(context: context, arabicName: ayah.surahArabicName, englishName: ayah.surahEnglishName)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryOnBg(context),
              ),
            ),
          ),
          if (!isArabicLocale(context))
            Text(
              ayah.surahArabicName,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryOnBg(context),
              ),
            ),
        ],
      ),
    );
  }
}
