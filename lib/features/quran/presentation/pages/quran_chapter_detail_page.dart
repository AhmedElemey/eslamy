import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../models/last_read_position.dart';
import '../../models/quran_models.dart';
import '../../service/quran_audio_handler.dart';
import '../../service/quran_audio_service.dart';
import '../controllers/quran_providers.dart';
import '../widgets/mushaf_pager.dart';
import '../widgets/reciter_selection_widget.dart';
import '../widgets/tajweed_legend_sheet.dart';
import 'quran_verse_detail_page.dart';

enum _ChapterAudioMode { full, range }

class QuranChapterDetailPage extends ConsumerStatefulWidget {
  final int chapterNumber;
  final String chapterName;

  /// Ayah (numberInSurah) to open the pager on, e.g. when navigating in
  /// from the home screen's "Continue Reading" card. Defaults to the start
  /// of the surah when null.
  final int? startingAyah;

  const QuranChapterDetailPage({
    super.key,
    required this.chapterNumber,
    required this.chapterName,
    this.startingAyah,
  });

  @override
  ConsumerState<QuranChapterDetailPage> createState() =>
      _QuranChapterDetailPageState();
}

class _QuranChapterDetailPageState
    extends ConsumerState<QuranChapterDetailPage> {
  _ChapterAudioMode _audioMode = _ChapterAudioMode.full;
  RangeValues? _ayahRange;
  ({int ayah, int nonce})? _scrollToAyah;
  int _scrollNonce = 0;

  @override
  void initState() {
    super.initState();
    final startingAyah = widget.startingAyah;
    if (startingAyah != null) {
      _scrollToAyah = (ayah: startingAyah, nonce: _scrollNonce++);
    }
  }

  void _saveLastReadPosition(
    QuranChapter chapter,
    int pageNumber,
    int ayahNumber,
  ) {
    ref
        .read(lastReadPositionProvider.notifier)
        .save(
          LastReadPosition(
            chapterNumber: chapter.number,
            chapterArabicName: chapter.name,
            chapterEnglishName: chapter.englishName,
            ayahNumber: ayahNumber,
            pageNumber: pageNumber,
            updatedAt: DateTime.now(),
          ),
        );
  }

  Set<int> get _highlightedAyahs {
    final range = _ayahRange;
    if (_audioMode != _ChapterAudioMode.range || range == null) {
      return const <int>{};
    }
    return {for (var i = range.start.round(); i <= range.end.round(); i++) i};
  }

  /// Plays the whole chapter on the shared handler (any other chapter or
  /// range already playing is replaced — matches the old page-local "stop
  /// current before starting new" behavior, now app-wide instead of
  /// per-screen).
  Future<void> _startChapterAudio(QuranAudioHandler handler) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.loadingChapterAudio),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      await handler.playSurah(
        widget.chapterNumber,
        reciter: ref.read(selectedReciterProvider),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.chapterAudioStartedPlaying),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error playing chapter audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToPlayChapterAudioRetry),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: context.l10n.retryAction,
              textColor: Colors.white,
              onPressed: () => _startChapterAudio(handler),
            ),
          ),
        );
      }
    }
  }

  /// Plays the selected ayah range on the shared handler — also scrolls the
  /// Mushaf pager to the page the range starts on, so the highlighted ayahs
  /// (see [_highlightedAyahs]) are actually in view when playback starts.
  Future<void> _startRangeAudio(
    QuranAudioHandler handler,
    RangeValues range,
  ) async {
    setState(() {
      _scrollToAyah = (ayah: range.start.round(), nonce: _scrollNonce++);
    });
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.loadingChapterAudio),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      await handler.playAyahRange(
        widget.chapterNumber,
        fromAyah: range.start.round(),
        toAyah: range.end.round(),
        reciter: ref.read(selectedReciterProvider),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.chapterAudioStartedPlaying),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error playing ayah range audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToPlayChapterAudioRetry),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: context.l10n.retryAction,
              textColor: Colors.white,
              onPressed: () => _startRangeAudio(handler, range),
            ),
          ),
        );
      }
    }
  }

  void _openReciterPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReciterSelectionDialog(),
    );
  }

  /// Lets the user pick between reading/playing the complete surah (the
  /// default view) or switching this same page into ayah-range mode.
  void _openPlaybackModeSheet(int totalAyahs) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.hairline(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_rounded),
                  title: Text(l10n.playFullSurahLabel),
                  trailing:
                      _audioMode == _ChapterAudioMode.full
                          ? Icon(
                            Icons.check_circle,
                            color: AppColors.primaryOnBg(context),
                          )
                          : null,
                  onTap: () {
                    setState(() => _audioMode = _ChapterAudioMode.full);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.format_list_numbered_rounded),
                  title: Text(l10n.playAyahRangeLabel),
                  trailing:
                      _audioMode == _ChapterAudioMode.range
                          ? Icon(
                            Icons.check_circle,
                            color: AppColors.primaryOnBg(context),
                          )
                          : null,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openRangePickerDialog(totalAyahs);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Popup for choosing the "from"/"to" ayah range — opened after closing
  /// the playback-mode sheet. Only switches the page into range mode (and
  /// updates the highlighted ayahs / audio bar) if the user confirms.
  Future<void> _openRangePickerDialog(int totalAyahs) async {
    final initialRange = _ayahRange ?? RangeValues(1, totalAyahs.toDouble());

    final result = await showDialog<RangeValues>(
      context: context,
      builder:
          (dialogContext) => _AyahRangeDialog(
            totalAyahs: totalAyahs,
            initialRange: initialRange,
          ),
    );

    if (result == null || !mounted) return;
    setState(() {
      _audioMode = _ChapterAudioMode.range;
      _ayahRange = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterProvider(widget.chapterNumber));
    final l10n = context.l10n;
    final selectedReciter = ref.watch(selectedReciterProvider);
    final handler = ref.watch(quranAudioHandlerProvider);
    final activeMediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final isThisChapterActive =
        activeMediaItem?.extras?['chapterNumber'] == widget.chapterNumber;
    final isPlaying =
        isThisChapterActive &&
        (ref.watch(playbackStateProvider).valueOrNull?.playing ?? false);
    final tajweedEnabled = ref.watch(tajweedColoringEnabledProvider);
    final tajweedAsync =
        tajweedEnabled
            ? ref.watch(chapterTajweedProvider(widget.chapterNumber))
            : null;
    final tajweedByVerse =
        tajweedAsync?.maybeWhen(
          data:
              (r) => {
                for (final v in r.data.ayahs ?? <QuranVerse>[])
                  v.numberInSurah: v.text,
              },
          orElse: () => const <int, String>{},
        ) ??
        const <int, String>{};

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.chapterWithNameTitle(widget.chapterNumber, widget.chapterName),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
            ),
            onPressed:
                isPlaying
                    ? handler.pause
                    : () =>
                        _audioMode == _ChapterAudioMode.range &&
                                _ayahRange != null
                            ? _startRangeAudio(handler, _ayahRange!)
                            : _startChapterAudio(handler),
            tooltip:
                isPlaying
                    ? l10n.pauseChapterAudioTooltip
                    : l10n.playChapterAudioTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.format_list_numbered_rounded),
            onPressed:
                chapterAsync.valueOrNull == null
                    ? null
                    : () => _openPlaybackModeSheet(
                      chapterAsync.valueOrNull!.data.numberOfAyahs,
                    ),
            tooltip: l10n.openAyahRangePlayerTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.record_voice_over),
            onPressed: _openReciterPicker,
            tooltip: selectedReciter?.name ?? l10n.quranReciterLabel,
          ),
          IconButton(
            icon: Icon(
              tajweedEnabled
                  ? Icons.format_color_text
                  : Icons.format_color_reset,
            ),
            onPressed:
                () => ref
                    .read(tajweedColoringEnabledProvider.notifier)
                    .setEnabled(!tajweedEnabled),
            tooltip: l10n.toggleTajweedColoringTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => showTajweedLegendSheet(context),
            tooltip: l10n.tajweedLegendTitle,
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: chapterAsync.when(
            data: (chapterResponse) {
              final ayahs = chapterResponse.data.ayahs ?? <QuranVerse>[];
              final totalAyahs = chapterResponse.data.numberOfAyahs;
              final showBasmala =
                  widget.chapterNumber != 1 && widget.chapterNumber != 9;
              if (_audioMode == _ChapterAudioMode.range) {
                _ayahRange ??= RangeValues(1, totalAyahs.toDouble());
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      children: [
                        Text(
                          chapterResponse.data.englishNameTranslation,
                          style: TextStyle(color: AppColors.mutedText(context)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.versesCountRevelationType(
                            chapterResponse.data.numberOfAyahs,
                            chapterResponse.data.revelationType == 'Meccan'
                                ? l10n.quranOriginMeccan
                                : l10n.quranOriginMedinian,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: MushafPager(
                      surahArabicName: chapterResponse.data.name,
                      ayahs: ayahs,
                      showBasmala: showBasmala,
                      tajweedByVerse: tajweedByVerse,
                      highlightedAyahs: _highlightedAyahs,
                      scrollToAyah: _scrollToAyah,
                      onPositionChanged:
                          (pageNumber, ayahNumber) => _saveLastReadPosition(
                            chapterResponse.data,
                            pageNumber,
                            ayahNumber,
                          ),
                      onVerseTap: (verseNumber, verseText) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => QuranVerseDetailPage(
                                  chapterNumber: widget.chapterNumber,
                                  verseNumber: verseNumber,
                                  verseText: verseText,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.failedToLoadChapter,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.mutedText(context)),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed:
                            () => ref.refresh(
                              chapterProvider(widget.chapterNumber),
                            ),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

/// Ayah-range picker popup: a "from"/"to" range slider kept in sync with two
/// typed number fields, either of which can drive the selection. If the
/// currently-selected reciter has no per-ayah recordings, the range controls
/// are hidden entirely (there's nothing to select) and a message asks the
/// user to pick a different reciter instead — reactively, so choosing one
/// from within this same dialog immediately reveals the controls.
class _AyahRangeDialog extends ConsumerStatefulWidget {
  const _AyahRangeDialog({
    required this.totalAyahs,
    required this.initialRange,
  });

  final int totalAyahs;
  final RangeValues initialRange;

  @override
  ConsumerState<_AyahRangeDialog> createState() => _AyahRangeDialogState();
}

class _AyahRangeDialogState extends ConsumerState<_AyahRangeDialog> {
  late RangeValues _range;
  late final TextEditingController _fromController;
  late final TextEditingController _toController;
  late final FocusNode _fromFocus;
  late final FocusNode _toFocus;

  @override
  void initState() {
    super.initState();
    _range = widget.initialRange;
    _fromController = TextEditingController(text: '${_range.start.round()}');
    _toController = TextEditingController(text: '${_range.end.round()}');
    // Typed values are only validated once the user finishes (Done, or
    // moving to another field) — validating on every keystroke would fight
    // a multi-digit entry the moment its first digit briefly crosses the
    // other bound (e.g. typing "100" passes through "1").
    _fromFocus = FocusNode()..addListener(_onFromFocusChange);
    _toFocus = FocusNode()..addListener(_onToFocusChange);
  }

  @override
  void dispose() {
    _fromFocus.dispose();
    _toFocus.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _onFromFocusChange() {
    if (!_fromFocus.hasFocus) _finalizeTyped();
  }

  void _onToFocusChange() {
    if (!_toFocus.hasFocus) _finalizeTyped();
  }

  void _applySlider(RangeValues value) {
    setState(() {
      _range = value;
      _fromController.text = '${value.start.round()}';
      _toController.text = '${value.end.round()}';
    });
  }

  /// Parses whatever is currently typed in both fields, clamps to
  /// 1..totalAyahs, reorders if "from" ended up past "to", and applies the
  /// result to the range + both fields' text.
  void _finalizeTyped() {
    final range = _clampedRangeFromText();
    setState(() {
      _range = range;
      _fromController.text = '${range.start.round()}';
      _toController.text = '${range.end.round()}';
    });
  }

  RangeValues _clampedRangeFromText() {
    final parsedFrom = int.tryParse(_fromController.text);
    final parsedTo = int.tryParse(_toController.text);
    var from = (parsedFrom ?? _range.start.round()).clamp(1, widget.totalAyahs);
    var to = (parsedTo ?? _range.end.round()).clamp(1, widget.totalAyahs);
    if (from > to) {
      final swap = from;
      from = to;
      to = swap;
    }
    return RangeValues(from.toDouble(), to.toDouble());
  }

  void _openReciterPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReciterSelectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reciter = ref.watch(selectedReciterProvider);
    final perAyahAvailable = QuranAudioService.hasPerAyahAudio(
      reciter?.relativePath,
    );
    final from = _range.start.round();
    final to = _range.end.round();
    final count = to - from + 1;

    return AlertDialog(
      title: Text(l10n.playAyahRangeLabel),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              perAyahAvailable
                  ? [
                    Text(
                      l10n.ayahRangeSummary(from, to, count),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: _fromController,
                        focusNode: _fromFocus,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: l10n.fromAyahFieldLabel,
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _finalizeTyped(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: _toController,
                        focusNode: _toFocus,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: l10n.toAyahFieldLabel,
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _finalizeTyped(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RangeSlider(
                      min: 1,
                      max: widget.totalAyahs.toDouble(),
                      divisions:
                          widget.totalAyahs > 1 ? widget.totalAyahs - 1 : null,
                      values: _range,
                      labels: RangeLabels('$from', '$to'),
                      onChanged: _applySlider,
                    ),
                  ]
                  : [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.primaryOnBg(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(l10n.reciterRangeUnavailableNotice),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _openReciterPicker,
                      icon: const Icon(Icons.record_voice_over),
                      label: Text(l10n.chooseReciterTitle),
                    ),
                  ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          // Finalizes from the text fields directly rather than relying on
          // _range, in case OK is tapped while a typed edit hasn't lost
          // focus yet (so onSubmitted/the focus-change listener never ran).
          onPressed:
              perAyahAvailable
                  ? () => Navigator.of(context).pop(_clampedRangeFromText())
                  : null,
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}
