import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/ayah_block.dart';
import '../../models/quran_models.dart';
import '../controllers/quran_providers.dart';
import '../widgets/reciter_selection_widget.dart';
import '../widgets/tajweed_legend_sheet.dart';
import '../widgets/translation_selection_widget.dart';
import 'quran_verse_detail_page.dart';

class QuranChapterDetailPage extends ConsumerStatefulWidget {
  final int chapterNumber;
  final String chapterName;

  const QuranChapterDetailPage({
    super.key,
    required this.chapterNumber,
    required this.chapterName,
  });

  @override
  ConsumerState<QuranChapterDetailPage> createState() =>
      _QuranChapterDetailPageState();
}

class _QuranChapterDetailPageState
    extends ConsumerState<QuranChapterDetailPage> {
  late AudioPlayer _audioPlayer;
  late final ProviderSubscription<Reciter?> _reciterSubscription;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentAudioUrl;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    // Restart with the new reciter's audio if the chapter is playing when
    // the user switches reciters (from this page's own picker, or any
    // other screen).
    _reciterSubscription = ref.listenManual<Reciter?>(selectedReciterProvider, (
      previous,
      next,
    ) {
      if (mounted && previous != next && _isPlaying) {
        _startChapterAudio();
      }
    });
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });

        // Reset position to start when playback completes
        if (state.processingState == ProcessingState.completed) {
          _audioPlayer.seek(Duration.zero);
          setState(() {
            _position = Duration.zero;
            _isPlaying = false;
          });
        }
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  Future<void> _playChapterAudio() async {
    if (_isPlaying) {
      await _pauseAudio();
      return;
    }
    await _startChapterAudio();
  }

  /// Fetches the chapter audio URL for the currently selected reciter and
  /// plays it. Used both by the play button and to restart with a new
  /// reciter while the chapter is already playing.
  Future<void> _startChapterAudio() async {
    try {
      // Stop any current audio before starting new
      if (_currentAudioUrl != null) {
        await _stopAudio();
      }

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.loadingChapterAudio),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Get chapter audio URL for the selected reciter
      final audioUrlAsync = ref.read(
        chapterAudioUrlProvider(widget.chapterNumber).future,
      );
      _currentAudioUrl = await audioUrlAsync;

      debugPrint('Playing chapter audio from URL: $_currentAudioUrl');

      await _audioPlayer.setUrl(_currentAudioUrl!);
      await _audioPlayer.play();

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
              onPressed: _playChapterAudio,
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

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _reciterSubscription.close();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterProvider(widget.chapterNumber));
    final l10n = context.l10n;
    final selectedReciter = ref.watch(selectedReciterProvider);
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
                            chapterResponse.data.revelationType,
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
                  _ChapterAudioBar(
                    label: l10n.chapterAudioLabel,
                    isPlaying: _isPlaying,
                    position: _position,
                    duration: _duration,
                    onPlayPause: _isPlaying ? _pauseAudio : _playChapterAudio,
                    onStop: _stopAudio,
                    formatDuration: _formatDuration,
                    onSeek: (value) {
                      _audioPlayer.seek(Duration(milliseconds: value.toInt()));
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
