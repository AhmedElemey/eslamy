import 'package:flutter/material.dart';

import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/quran_models.dart';
import '../../service/tajweed_text_parser.dart';
import 'mushaf_view.dart';

/// Paginates a surah's ayahs into real Mushaf pages (grouped by each verse's
/// `page` field, matching the standard printed Uthmani Mushaf) and lets the
/// user flip through them by swiping vertically — one page per swipe — or
/// by jumping straight to a page number.
///
/// Scoped to a single surah: a Mushaf page that spans two surahs will only
/// show this surah's share of it, since the chapter is fetched one surah at
/// a time.
class MushafPager extends StatefulWidget {
  const MushafPager({
    super.key,
    required this.surahArabicName,
    required this.ayahs,
    required this.showBasmala,
    required this.onVerseTap,
    this.tajweedByVerse = const {},
    this.highlightedAyahs = const {},
    this.scrollToAyah,
    this.onPositionChanged,
  });

  final String surahArabicName;
  final List<QuranVerse> ayahs;
  final bool showBasmala;
  final Map<int, String> tajweedByVerse;
  final void Function(int verseNumber, String verseText) onVerseTap;

  /// Fired whenever the visible page changes, with the mushaf page number
  /// and the `numberInSurah` of the first ayah on it — the single point
  /// where "what page is the user on" is known, used to persist the last
  /// read position for the home screen's "Continue Reading" card.
  final void Function(int pageNumber, int ayahNumber)? onPositionChanged;

  /// Verse numbers (numberInSurah) to shade — e.g. the ayah range currently
  /// selected for playback.
  final Set<int> highlightedAyahs;

  /// Bump this (with a fresh `nonce`, so repeat requests for the same ayah
  /// still fire) to make the pager jump to the page containing `ayah` —
  /// e.g. when the caller starts playing an ayah range.
  final ({int ayah, int nonce})? scrollToAyah;

  @override
  State<MushafPager> createState() => _MushafPagerState();
}

class _MushafPagerState extends State<MushafPager> {
  late PageController _controller;
  late List<MapEntry<int, List<QuranVerse>>> _pages;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = _groupByPage(widget.ayahs);
    _controller = PageController();
    // Deferred to after this frame: reporting synchronously here would mean
    // notifying lastReadPositionProvider's listeners while this widget's
    // own ancestor is still mid-build, which Riverpod/Flutter disallow.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reportPosition(_currentIndex);
    });
  }

  void _reportPosition(int index) {
    final callback = widget.onPositionChanged;
    if (callback == null || _pages.isEmpty) return;
    final entry = _pages[index];
    callback(entry.key, entry.value.first.numberInSurah);
  }

  @override
  void didUpdateWidget(covariant MushafPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ayahs != widget.ayahs) {
      _pages = _groupByPage(widget.ayahs);
      _currentIndex = _currentIndex.clamp(0, _pages.length - 1);
    }
    final request = widget.scrollToAyah;
    if (request != null && request != oldWidget.scrollToAyah) {
      final index = _pages.indexWhere(
        (entry) => entry.value.any((v) => v.numberInSurah == request.ayah),
      );
      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _goToIndex(index);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static List<MapEntry<int, List<QuranVerse>>> _groupByPage(
    List<QuranVerse> ayahs,
  ) {
    final byPage = <int, List<QuranVerse>>{};
    for (final verse in ayahs) {
      byPage.putIfAbsent(verse.page, () => []).add(verse);
    }
    return byPage.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  }

  static const double _minBodyFontSize = 13;
  static const double _maxBodyFontSize = 26;

  /// Largest verse-text font size that keeps this page's ayahs within
  /// [maxHeight] at [maxWidth], so the page always renders at full width
  /// (instead of the old approach of scaling the whole card down, which
  /// left empty side margins on denser pages).
  ///
  /// Measures whichever text [MushafView] will actually render — the
  /// tajweed edition's text (tags stripped) when tajweed coloring is on,
  /// since it's a separately-fetched edition whose character composition
  /// can differ slightly from the plain Uthmani text and previously threw
  /// the fit off by a line — via binary search over candidate sizes.
  double _fitBodyFontSize({
    required List<QuranVerse> verses,
    required double maxWidth,
    required double maxHeight,
  }) {
    final text = verses
        .map((v) {
          final tajweed = widget.tajweedByVerse[v.numberInSurah];
          if (tajweed == null) return v.text;
          return parseTajweedText(tajweed).map((s) => s.text).join();
        })
        .join(' ');
    // Leaves room for the inline ayah-marker badges, which the plain-text
    // measurement below doesn't account for.
    final effectiveWidth = maxWidth * 0.85;

    bool fits(double fontSize) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'ScheherazadeNew',
            fontSize: fontSize,
            height: 1.9,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
      )..layout(maxWidth: effectiveWidth);
      final fitsHeight = painter.size.height <= maxHeight;
      painter.dispose();
      return fitsHeight;
    }

    var low = _minBodyFontSize;
    var high = _maxBodyFontSize;
    if (fits(high)) return high;
    if (!fits(low)) return low;
    for (var i = 0; i < 8; i++) {
      final mid = (low + high) / 2;
      if (fits(mid)) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return low;
  }

  void _goToIndex(int index) {
    _controller.animateToPage(
      index.clamp(0, _pages.length - 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openJumpDialog() async {
    final l10n = context.l10n;
    final controller = TextEditingController(
      text: '${_pages[_currentIndex].key}',
    );
    final result = await showDialog<int>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(l10n.jumpToPageTitle),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(hintText: l10n.pageNumberHint),
              onSubmitted:
                  (value) =>
                      Navigator.of(dialogContext).pop(int.tryParse(value)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.of(
                      dialogContext,
                    ).pop(int.tryParse(controller.text)),
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
    if (result == null || !mounted) return;
    final index = _pages.indexWhere((entry) => entry.key == result);
    if (index != -1) {
      _goToIndex(index);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pageNotInThisSurah)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) return const SizedBox.shrink();
    final currentPageNumber = _pages[_currentIndex].key;

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              _reportPosition(index);
            },
            itemBuilder: (context, index) {
              final verses = _pages[index].value;
              final isFirstPageOfSurah = verses.any(
                (v) => v.numberInSurah == 1,
              );
              // No inner Scrollable here on purpose: a vertical scrollable
              // nested inside this vertical PageView would capture swipe
              // gestures for itself (even with nothing to scroll) and the
              // page-turn swipe would stop working. Instead, the verse text
              // size is shrunk just enough to fit the viewport, so the page
              // always renders at full width.
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const chromeOverhead = 120.0;
                    const bannerOverhead = 140.0;
                    final reserved =
                        chromeOverhead +
                        (isFirstPageOfSurah ? bannerOverhead : 0);
                    final fontSize = _fitBodyFontSize(
                      verses: verses,
                      maxWidth: constraints.maxWidth - 32,
                      maxHeight: (constraints.maxHeight - reserved) * 0.88,
                    );
                    final page = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PageContextRow(
                          surahName: widget.surahArabicName,
                          juz: verses.first.juz,
                        ),
                        MushafView(
                          surahArabicName: widget.surahArabicName,
                          ayahs: verses,
                          showSurahBanner: isFirstPageOfSurah,
                          showBasmala: isFirstPageOfSurah && widget.showBasmala,
                          tajweedByVerse: widget.tajweedByVerse,
                          onVerseTap: widget.onVerseTap,
                          bodyFontSize: fontSize,
                          highlightedAyahs: widget.highlightedAyahs,
                        ),
                      ],
                    );
                    // The font-size fit above is a heuristic (it measures a
                    // plain-text approximation), not an exact guarantee.
                    // Rather than let a rare miss overflow the fixed page
                    // slot — a RenderFlex overflow, which this app's error
                    // boundary turns into a full error page even for a few
                    // pixels — give the column truly unbounded height via
                    // OverflowBox (so it can never "overflow" a Flex) and
                    // only clip the paint to the page slot from the outside.
                    return ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        minHeight: 0,
                        maxHeight: double.infinity,
                        child: page,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        _PagerBar(
          pageNumber: currentPageNumber,
          onPrev:
              _currentIndex > 0 ? () => _goToIndex(_currentIndex - 1) : null,
          onNext:
              _currentIndex < _pages.length - 1
                  ? () => _goToIndex(_currentIndex + 1)
                  : null,
          onJump: _openJumpDialog,
        ),
      ],
    );
  }
}

class _PageContextRow extends StatelessWidget {
  const _PageContextRow({required this.surahName, required this.juz});

  final String surahName;
  final int juz;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = AppColors.mutedText(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(surahName, style: TextStyle(fontSize: 12, color: muted)),
          Text(
            l10n.mushafJuzLabel(juz),
            style: TextStyle(fontSize: 12, color: muted),
          ),
        ],
      ),
    );
  }
}

/// Floating pill-shaped page selector: ‹ prev / "Page" / page-number chip /
/// next › grouped together, plus a separate search (jump-to-page) button.
/// Kept left-to-right regardless of app locale, like a numeric control.
class _PagerBar extends StatelessWidget {
  const _PagerBar({
    required this.pageNumber,
    required this.onPrev,
    required this.onNext,
    required this.onJump,
  });

  final int pageNumber;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onJump;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final heading = AppColors.heading(context);
    final accent = AppColors.primaryOnBg(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        top: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.hairline(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              textDirection: TextDirection.ltr,
              mainAxisSize: MainAxisSize.min,
              children: [
                _PillIconButton(
                  icon: Icons.chevron_left_rounded,
                  color: accent,
                  onTap: onPrev,
                  tooltip: l10n.mushafPreviousPageTooltip,
                ),
                const SizedBox(width: 2),
                Text(
                  l10n.tabPage,
                  style: TextStyle(fontWeight: FontWeight.w600, color: heading),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onJump,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 46),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pageBackground(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '$pageNumber',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: heading,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                _PillIconButton(
                  icon: Icons.chevron_right_rounded,
                  color: accent,
                  onTap: onNext,
                  tooltip: l10n.mushafNextPageTooltip,
                ),
                const SizedBox(width: 8),
                // _PillIconButton(
                //   icon: Icons.search_rounded,
                //   color: accent,
                //   onTap: onJump,
                //   tooltip: l10n.jumpToPageTitle,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillIconButton extends StatelessWidget {
  const _PillIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      // This bar is always laid out LTR (prev on the left, next on the
      // right). Force LTR on the icon too so Arabic RTL doesn't mirror
      // chevrons that already have matchTextDirection on the IconData.
      icon: Icon(icon, textDirection: TextDirection.ltr),
      color: color,
      disabledColor: color.withValues(alpha: 0.3),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
    );
  }
}
