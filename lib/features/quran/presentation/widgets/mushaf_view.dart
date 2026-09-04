import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/arabic_numerals.dart';
import '../../data/tajweed_rules.dart';
import '../../models/quran_models.dart';
import '../../service/tajweed_text_parser.dart';

/// Continuous "Mushaf" reading layout: verses flow line-by-line and wrap
/// like a printed Quran page, with small ring-shaped ayah-end markers
/// inline in the text — instead of one card per verse. This is the
/// "complete surah" reading experience: pure Arabic text, no per-verse
/// translation, closer to reading from an actual Mushaf.
class MushafView extends StatefulWidget {
  const MushafView({
    super.key,
    required this.surahArabicName,
    required this.ayahs,
    required this.showBasmala,
    required this.onVerseTap,
    this.tajweedByVerse = const {},
    this.showSurahBanner = true,
    this.bodyFontSize = 24,
    this.highlightedAyahs = const {},
  });

  final String surahArabicName;
  final List<QuranVerse> ayahs;
  final bool showBasmala;
  final Map<int, String> tajweedByVerse;
  final void Function(int verseNumber, String verseText) onVerseTap;

  /// Verse numbers (numberInSurah) to shade with a highlight background —
  /// e.g. the ayah range currently selected for playback.
  final Set<int> highlightedAyahs;

  /// Whether to render the decorative surah-name banner — off for pages
  /// (in [MushafPager]) that don't start the surah.
  final bool showSurahBanner;

  /// Verse text size — [MushafPager] shrinks this per page so a page's
  /// worth of ayahs fits the screen at full width instead of the whole
  /// card being scaled down (which would leave empty side margins).
  final double bodyFontSize;

  @override
  State<MushafView> createState() => _MushafViewState();
}

class _MushafViewState extends State<MushafView> {
  final List<TapGestureRecognizer> _recognizers = [];

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _showRuleInfo(TajweedRule rule) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final muted = Theme.of(context).textTheme.bodyMedium?.color;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rule.colorFor(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.arabicName,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(rule.englishName, style: TextStyle(color: muted)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InlineSpan _buildVerseSpan(QuranVerse verse, TextStyle baseStyle) {
    final tajweed = widget.tajweedByVerse[verse.numberInSurah];
    final spans = <InlineSpan>[];

    if (tajweed != null) {
      for (final segment in parseTajweedText(tajweed)) {
        if (segment.rule == null) {
          spans.add(TextSpan(text: segment.text, style: baseStyle));
        } else {
          final recognizer =
              TapGestureRecognizer()
                ..onTap = () => _showRuleInfo(segment.rule!);
          _recognizers.add(recognizer);
          spans.add(
            TextSpan(
              text: segment.text,
              style: baseStyle.copyWith(
                color: segment.rule!.colorFor(context),
                fontWeight: FontWeight.w600,
              ),
              recognizer: recognizer,
            ),
          );
        }
      }
    } else {
      spans.add(TextSpan(text: verse.text, style: baseStyle));
    }

    final gold = AppColors.goldAccent(context);
    final markerSize = widget.bodyFontSize;
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
          onTap: () => widget.onVerseTap(verse.numberInSurah, verse.text),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: markerSize,
              height: markerSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold, width: 1.1),
              ),
              // Arabic-Indic digit glyphs can be wider than the Western
              // digits this badge size was tuned for, so a 2-3 digit ayah
              // number can overflow the circle (and bleed into a
              // neighboring marker on the same line) without this — shrink
              // to fit instead of overflowing.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    toArabicIndicDigits(verse.numberInSurah),
                    // Unlike Western digits (bidi type EN), Arabic-Indic
                    // digits are bidi type AN and already read in the
                    // correct order inside this RTL paragraph — forcing
                    // LTR here scrambles their digit order instead.
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: markerSize * 0.42,
                      fontWeight: FontWeight.w700,
                      color: gold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    spans.add(const TextSpan(text: ' '));

    final isHighlighted = widget.highlightedAyahs.contains(verse.numberInSurah);
    return TextSpan(
      style:
          isHighlighted
              ? TextStyle(
                backgroundColor: AppColors.goldAccent(
                  context,
                ).withValues(alpha: 0.22),
              )
              : null,
      children: spans,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Spans embed fresh TapGestureRecognizers each build; drop the previous
    // batch first so they don't leak.
    _disposeRecognizers();
    final gold = AppColors.goldAccent(context);
    final baseStyle = AppTypography.ayah(context, size: widget.bodyFontSize);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.hairline(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showSurahBanner)
            _SurahBanner(name: widget.surahArabicName, color: gold),
          if (widget.showBasmala) ...[
            const SizedBox(height: 18),
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: AppTypography.naskh(
                size: 24,
                color: AppColors.primaryOnBg(context),
                height: 1.6,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Text.rich(
            TextSpan(
              children: [
                for (final verse in widget.ayahs)
                  _buildVerseSpan(verse, baseStyle),
              ],
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

/// Decorative bordered surah-name banner, echoing the ornamented title
/// boxes used at the head of each surah in a printed Mushaf.
class _SurahBanner extends StatelessWidget {
  const _SurahBanner({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          _ornament(color),
          Expanded(
            child: Text(
              name,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: AppTypography.naskh(
                size: 24,
                weight: FontWeight.w700,
                color: color,
                height: 1.2,
              ),
            ),
          ),
          _ornament(color),
        ],
      ),
    );
  }

  Widget _ornament(Color color) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.2),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
