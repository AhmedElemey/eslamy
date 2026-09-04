import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_numerals.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../models/quran_models.dart';
import '../../service/quran_audio_handler.dart';
import '../controllers/quran_providers.dart';
import '../widgets/reciter_selection_widget.dart';
import '../widgets/tajweed_legend_sheet.dart';
import '../widgets/tajweed_text.dart';

class QuranVerseDetailPage extends ConsumerStatefulWidget {
  final int chapterNumber;
  final int verseNumber;
  final String verseText;

  const QuranVerseDetailPage({
    super.key,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
  });

  @override
  ConsumerState<QuranVerseDetailPage> createState() =>
      _QuranVerseDetailPageState();
}

class _QuranVerseDetailPageState extends ConsumerState<QuranVerseDetailPage> {
  // Practice-loop repeat counts offered next to the player; null means loop
  // indefinitely until the user stops it.
  static const List<int?> _repeatOptions = [1, 3, 5, 10, null];

  late final ProviderSubscription<Reciter?> _reciterSubscription;
  int? _repeatTarget = 1;
  int _repeatCount = 0;

  bool _isThisVerse(MediaItem? mediaItem) =>
      mediaItem?.extras?['chapterNumber'] == widget.chapterNumber &&
      mediaItem?.extras?['ayahNumber'] == widget.verseNumber;

  @override
  void initState() {
    super.initState();
    // Restart with the new reciter's audio if this verse is playing when the
    // user switches reciters (from this page's own picker, or any other
    // screen) — mirrors the app-wide handler, scoped to only this verse.
    _reciterSubscription = ref.listenManual<Reciter?>(selectedReciterProvider, (
      previous,
      next,
    ) {
      if (!mounted || previous == next) return;
      final handler = ref.read(quranAudioHandlerProvider);
      final mediaItem = ref.read(currentMediaItemProvider).valueOrNull;
      final playing =
          ref.read(playbackStateProvider).valueOrNull?.playing ?? false;
      if (_isThisVerse(mediaItem) && playing) {
        handler.setReciterAndRestartIfPlaying(next!);
      }
    });
  }

  Future<void> _playAudio(
    QuranAudioHandler handler,
    bool isThisVerseActive,
    bool isPlaying,
  ) async {
    if (isThisVerseActive && isPlaying) {
      await handler.pause();
      return;
    }
    await _startAudio(handler);
  }

  Future<void> _startAudio(QuranAudioHandler handler) async {
    _repeatCount = 0;
    final l10n = context.l10n;
    try {
      final reciter = ref.read(selectedReciterProvider);
      await handler.playAyahRange(
        widget.chapterNumber,
        fromAyah: widget.verseNumber,
        toAyah: widget.verseNumber,
        reciter: reciter,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToPlayAudioRetry),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: l10n.retryAction,
              textColor: Colors.white,
              onPressed: () => _startAudio(handler),
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

  @override
  void dispose() {
    _reciterSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tafseerAsync = ref.watch(
      tafseerProvider((
        chapterNumber: widget.chapterNumber,
        verseNumber: widget.verseNumber,
      )),
    );
    final l10n = context.l10n;
    final handler = ref.watch(quranAudioHandlerProvider);
    final selectedReciter = ref.watch(selectedReciterProvider);
    final tajweedEnabled = ref.watch(tajweedColoringEnabledProvider);
    final tajweedAsync =
        tajweedEnabled
            ? ref.watch(chapterTajweedProvider(widget.chapterNumber))
            : null;
    final tajweedVerseText = tajweedAsync?.maybeWhen(
      data: (r) {
        for (final v in r.data.ayahs ?? const <QuranVerse>[]) {
          if (v.numberInSurah == widget.verseNumber) return v.text;
        }
        return null;
      },
      orElse: () => null,
    );

    final activeMediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final isThisVerseActive = _isThisVerse(activeMediaItem);
    final isPlaying =
        isThisVerseActive &&
        (ref.watch(playbackStateProvider).valueOrNull?.playing ?? false);
    // Reserve room at the bottom of the scroll content for the global mini
    // player when something is loaded, so it can never permanently cover the
    // Tafseer card below — without this, a short page has nothing to scroll
    // and the floating bar just sits on top of the last card with no way to
    // see what's underneath it.
    final reserveForMiniPlayer = activeMediaItem != null;

    ref.listen<AsyncValue<PlaybackState>>(playbackStateProvider, (
      previous,
      next,
    ) {
      final state = next.valueOrNull;
      if (state == null) return;
      if (!_isThisVerse(ref.read(currentMediaItemProvider).valueOrNull)) {
        return;
      }
      if (state.processingState != AudioProcessingState.completed) return;
      final target = _repeatTarget;
      final shouldRepeatAgain = target == null || _repeatCount + 1 < target;
      if (shouldRepeatAgain) {
        _repeatCount++;
        handler.seek(Duration.zero);
        handler.play();
      } else {
        _repeatCount = 0;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.chapterVerseTitle(widget.chapterNumber, widget.verseNumber),
        ),
        centerTitle: true,
        actions: [
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
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 +
                  MediaQuery.paddingOf(context).bottom +
                  (reserveForMiniPlayer ? 190 : 0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verse text card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              // Arabic-Indic digit glyphs can be wider than
                              // the Western digits this avatar was tuned
                              // for, so a 2-3 digit ayah number can overflow
                              // — shrink to fit instead of getting clipped.
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    toArabicIndicDigits(widget.verseNumber),
                                    // Unlike Western digits (bidi type EN),
                                    // Arabic-Indic digits are bidi type AN
                                    // and already read in the correct order
                                    // here — forcing LTR scrambles their
                                    // digit order instead.
                                    textDirection: TextDirection.rtl,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.chapterVerseTitle(
                                  widget.chapterNumber,
                                  widget.verseNumber,
                                ),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        tajweedVerseText != null
                            ? TajweedText(
                              text: tajweedVerseText,
                              style: const TextStyle(fontSize: 20, height: 1.8),
                            )
                            : Text(
                              widget.verseText,
                              style: const TextStyle(fontSize: 20, height: 1.8),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                            ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Audio player card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.audioRecitationLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              onPressed:
                                  () => _playAudio(
                                    handler,
                                    isThisVerseActive,
                                    isPlaying,
                                  ),
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 32,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                handler.stop();
                                _repeatCount = 0;
                              },
                              icon: const Icon(Icons.stop),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.pageBackground(
                                  context,
                                ),
                                foregroundColor: AppColors.heading(context),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child:
                                  isThisVerseActive
                                      ? _VersePlaybackProgress(handler: handler)
                                      : Text(
                                        l10n.tapPlayToLoadAudio,
                                        style: TextStyle(
                                          color: AppColors.mutedText(context),
                                        ),
                                      ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.repeatPracticeLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedText(context)),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final option in _repeatOptions)
                              ChoiceChip(
                                label: Text(option == null ? '∞' : '$option×'),
                                selected: _repeatTarget == option,
                                onSelected:
                                    (_) =>
                                        setState(() => _repeatTarget = option),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tafseer section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tafseerInterpretationLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        tafseerAsync.when(
                          data: (tafsir) {
                            if (tafsir.text.isEmpty) {
                              return Text(
                                l10n.noTafseerAvailable,
                                style: TextStyle(
                                  color: AppColors.mutedText(context),
                                ),
                              );
                            }

                            final scheme = Theme.of(context).colorScheme;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.hairline(context),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tafsir.editionName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.heading(context),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tafsir.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: AppColors.ayahText(context),
                                    ),
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            );
                          },
                          loading:
                              () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          error: (error, stack) {
                            final scheme = Theme.of(context).colorScheme;
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: scheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: scheme.error.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: scheme.onErrorContainer,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.failedToLoadTafseer,
                                    style: TextStyle(
                                      color: scheme.onErrorContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    error.toString(),
                                    style: TextStyle(
                                      color: scheme.onErrorContainer,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed:
                                        () => ref.refresh(
                                          tafseerProvider((
                                            chapterNumber: widget.chapterNumber,
                                            verseNumber: widget.verseNumber,
                                          )),
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: scheme.error,
                                      foregroundColor: scheme.onError,
                                    ),
                                    child: Text(l10n.retry),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Live position/duration slider for a verse currently playing on the shared
/// handler — same range-aware math the global mini player and Now Playing
/// page use, so a single verse (a range of length one) reports correctly.
class _VersePlaybackProgress extends StatelessWidget {
  const _VersePlaybackProgress({required this.handler});

  final QuranAudioHandler handler;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '${duration.inHours}:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: handler.player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = handler.player.duration ?? Duration.zero;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (duration.inSeconds > 0) ...[
              Slider(
                value: position.inMilliseconds.toDouble().clamp(
                  0.0,
                  duration.inMilliseconds.toDouble(),
                ),
                max: duration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  handler.seek(Duration(milliseconds: value.toInt()));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position)),
                  Text(_formatDuration(duration)),
                ],
              ),
            ] else
              Text(
                context.l10n.loadingAudio,
                style: TextStyle(color: AppColors.mutedText(context)),
              ),
          ],
        );
      },
    );
  }
}
