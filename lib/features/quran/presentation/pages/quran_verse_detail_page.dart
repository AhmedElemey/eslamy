import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../models/quran_models.dart';
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

  late AudioPlayer _audioPlayer;
  late final ProviderSubscription<Reciter?> _reciterSubscription;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int? _repeatTarget = 1;
  int _repeatCount = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    // Restart with the new reciter's audio if the verse is playing when
    // the user switches reciters (from this page's own picker, or any
    // other screen).
    _reciterSubscription = ref.listenManual<Reciter?>(selectedReciterProvider, (
      previous,
      next,
    ) {
      if (mounted && previous != next && _isPlaying) {
        _startAudio();
      }
    });
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });

        // On completion, either loop back for the practice repeat count or
        // reset to the start like before.
        if (state.processingState == ProcessingState.completed) {
          final target = _repeatTarget;
          final shouldRepeatAgain = target == null || _repeatCount + 1 < target;
          if (shouldRepeatAgain) {
            _repeatCount++;
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.play();
          } else {
            _audioPlayer.seek(Duration.zero);
            setState(() {
              _position = Duration.zero;
              _isPlaying = false;
              _repeatCount = 0;
            });
          }
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

    // Listen for player errors
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.idle &&
          state.playing == false) {
        debugPrint('Audio player is idle');
      }
    });
  }

  Future<void> _playAudio() async {
    if (_isPlaying) {
      await _pauseAudio();
      return;
    }
    await _startAudio();
  }

  /// Fetches the verse audio URL for the currently selected reciter and
  /// plays it. Used both by the play button and to restart with a new
  /// reciter while the verse is already playing.
  Future<void> _startAudio() async {
    try {
      // Stop any current audio before starting new
      await _stopAudio();
      _repeatCount = 0;

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.loadingAudio),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Get the selected reciter from the provider
      final selectedReciter = ref.read(selectedReciterProvider);

      debugPrint(
        'Selected reciter for audio: ${selectedReciter?.name} (${selectedReciter?.relativePath})',
      );

      // Show reciter info in snackbar for debugging
      if (mounted && selectedReciter != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.playingWithReciter(selectedReciter.name),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      }

      final audioUrlAsync = ref.read(
        verseAudioUrlProvider((
          chapterNumber: widget.chapterNumber,
          verseNumber: widget.verseNumber,
          reciterId: selectedReciter?.relativePath,
        )).future,
      );

      final audioUrl = await audioUrlAsync;
      debugPrint('Playing audio from URL: $audioUrl');

      // Check if it's the test URL (indicates real URLs failed)
      if (audioUrl.contains('BabyElephantWalk60.wav')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.realAudioNotAvailableReciter(
                  selectedReciter?.name ?? '',
                ),
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Set audio source with error handling
      try {
        debugPrint('Setting audio URL: $audioUrl');
        await _audioPlayer.setUrl(audioUrl);
        debugPrint('Audio URL set successfully');

        // Wait a moment for the audio to load
        await Future.delayed(const Duration(milliseconds: 500));

        // Play the audio
        debugPrint('Starting audio playback...');
        await _audioPlayer.play();
        debugPrint('Audio playback started');
      } catch (e) {
        debugPrint('Error during audio playback: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.audioPlaybackErrorWithError(e.toString()),
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
        rethrow;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.audioStartedPlaying),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToPlayAudioRetry),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: context.l10n.retryAction,
              textColor: Colors.white,
              onPressed: _playAudio,
            ),
          ),
        );
      }
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    _repeatCount = 0;
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
    _audioPlayer.dispose();
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
              16 + MediaQuery.paddingOf(context).bottom,
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
                              child: Text(
                                '${widget.verseNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
                              onPressed: _isPlaying ? _pauseAudio : _playAudio,
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 32,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: _stopAudio,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_duration.inSeconds > 0) ...[
                                    Slider(
                                      value: _position.inMilliseconds
                                          .toDouble()
                                          .clamp(
                                            0.0,
                                            _duration.inMilliseconds.toDouble(),
                                          ),
                                      max: _duration.inMilliseconds.toDouble(),
                                      onChanged: (value) {
                                        _audioPlayer.seek(
                                          Duration(milliseconds: value.toInt()),
                                        );
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_formatDuration(_position)),
                                        Text(_formatDuration(_duration)),
                                      ],
                                    ),
                                  ] else
                                    Text(
                                      l10n.tapPlayToLoadAudio,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.repeatPracticeLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
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
                                            chapterNumber:
                                                widget.chapterNumber,
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
