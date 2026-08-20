import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/ayah_block.dart';
import '../../../quran/models/quran_models.dart';
import '../../../quran/presentation/controllers/quran_providers.dart';
import '../../../quran/presentation/pages/quran_verse_detail_page.dart';
import '../../../quran/presentation/widgets/reciter_selection_widget.dart';
import '../../../quran/presentation/widgets/tajweed_legend_sheet.dart';
import '../../../quran/presentation/widgets/translation_selection_widget.dart';
import '../../../quran/service/quran_audio_handler.dart';

class TafseerChapterPage extends ConsumerStatefulWidget {
  final int chapterNumber;
  final String chapterName;

  const TafseerChapterPage({
    super.key,
    required this.chapterNumber,
    required this.chapterName,
  });

  @override
  ConsumerState<TafseerChapterPage> createState() => _TafseerChapterPageState();
}

class _TafseerChapterPageState extends ConsumerState<TafseerChapterPage> {
  /// Plays this chapter on the shared handler (any other chapter already
  /// playing is replaced — matches the old page-local "stop current before
  /// starting new" behavior, now app-wide instead of per-screen).
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

  void _openReciterPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReciterSelectionDialog(),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
    final selectedEdition = ref.watch(selectedTranslationProvider);
    final translationAsync = ref.watch(
      chapterTranslationProvider((
        chapterNumber: widget.chapterNumber,
        editionIdentifier: selectedEdition.identifier,
      )),
    );
    final translationByVerse = translationAsync.maybeWhen(
      data:
          (r) => {
            for (final v in r.data.ayahs ?? <QuranVerse>[])
              v.numberInSurah: v.text,
          },
      orElse: () => const <int, String>{},
    );
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
              final showBasmala =
                  widget.chapterNumber != 1 && widget.chapterNumber != 9;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      children: [
                        Text(
                          chapterResponse.data.name,
                          textDirection: TextDirection.rtl,
                          style: AppTypography.naskh(
                            size: 28,
                            weight: FontWeight.w700,
                            color: AppColors.heading(context),
                          ),
                        ),
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
                        const SizedBox(height: 10),
                        const TranslationSelectionWidget(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: ayahs.length + (showBasmala ? 1 : 0),
                      separatorBuilder:
                          (_, __) => Divider(
                            height: 1,
                            color: AppColors.hairline(context),
                          ),
                      itemBuilder: (context, index) {
                        if (showBasmala && index == 0) {
                          return const BasmalaHeader();
                        }
                        final verse = ayahs[showBasmala ? index - 1 : index];
                        return AyahBlock(
                          number: verse.numberInSurah,
                          arabic: verse.text,
                          tajweedText: tajweedByVerse[verse.numberInSurah],
                          translation: translationByVerse[verse.numberInSurah],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuranVerseDetailPage(
                                      chapterNumber: widget.chapterNumber,
                                      verseNumber: verse.numberInSurah,
                                      verseText: verse.text,
                                    ),
                              ),
                            );
                          },
                          footer: Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 18,
                                color: AppColors.primaryOnBg(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.playAudioLabel,
                                style: TextStyle(
                                  color: AppColors.primaryOnBg(context),
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: AppColors.mutedText(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.tafseerLabel,
                                style: TextStyle(
                                  color: AppColors.mutedText(context),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  StreamBuilder<Duration>(
                    stream: handler.player.positionStream,
                    builder: (context, snapshot) {
                      final position =
                          isThisChapterActive
                              ? (snapshot.data ?? Duration.zero)
                              : Duration.zero;
                      final duration =
                          isThisChapterActive
                              ? (handler.player.duration ?? Duration.zero)
                              : Duration.zero;
                      return _ChapterAudioBar(
                        label: l10n.chapterAudioLabel,
                        isPlaying: isPlaying,
                        position: position,
                        duration: duration,
                        onPlayPause:
                            isPlaying
                                ? handler.pause
                                : () => _startChapterAudio(handler),
                        onStop: handler.stop,
                        formatDuration: _formatDuration,
                        onSeek: (value) {
                          handler.seek(Duration(milliseconds: value.toInt()));
                        },
                      );
                    },
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

class _ChapterAudioBar extends StatelessWidget {
  const _ChapterAudioBar({
    required this.label,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onStop,
    required this.formatDuration,
    required this.onSeek,
  });

  final String label;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final String Function(Duration) formatDuration;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds.toDouble();
    return Material(
      color: AppColors.surface(context),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading(context),
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: onPlayPause,
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: onStop,
                    icon: const Icon(Icons.stop),
                  ),
                ],
              ),
              if (maxMs > 0) ...[
                Slider(
                  value: position.inMilliseconds.toDouble().clamp(0.0, maxMs),
                  max: maxMs,
                  onChanged: onSeek,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(position),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      formatDuration(duration),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
