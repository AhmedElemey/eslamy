import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../models/quran_models.dart';
import '../controllers/quran_providers.dart';
import '../widgets/tajweed_legend_sheet.dart';
import '../widgets/tajweed_text.dart';
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
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentAudioUrl;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
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
    try {
      if (_isPlaying) {
        await _pauseAudio();
        return;
      }

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

      // Get chapter audio URL
      final audioUrlAsync = ref.read(
        chapterAudioProvider(widget.chapterNumber).future,
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
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterProvider(widget.chapterNumber));
    final l10n = context.l10n;
    final selectedEdition = ref.watch(selectedTranslationProvider);
    final translationAsync = ref.watch(
      chapterTranslationProvider((
        chapterNumber: widget.chapterNumber,
        editionIdentifier: selectedEdition.identifier,
      )),
    );
    final translationByVerse = translationAsync.maybeWhen(
      data: (r) => {for (final v in r.data.ayahs ?? <QuranVerse>[]) v.numberInSurah: v.text},
      orElse: () => const <int, String>{},
    );
    final tajweedEnabled = ref.watch(tajweedColoringEnabledProvider);
    final tajweedAsync =
        tajweedEnabled
            ? ref.watch(chapterTajweedProvider(widget.chapterNumber))
            : null;
    final tajweedByVerse =
        tajweedAsync?.maybeWhen(
          data: (r) => {for (final v in r.data.ayahs ?? <QuranVerse>[]) v.numberInSurah: v.text},
          orElse: () => const <int, String>{},
        ) ??
        const <int, String>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chapterWithNameTitle(widget.chapterNumber, widget.chapterName)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              tajweedEnabled ? Icons.format_color_text : Icons.format_color_reset,
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
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _playChapterAudio,
            tooltip: _isPlaying ? l10n.pauseChapterAudioTooltip : l10n.playChapterAudioTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _stopAudio,
            tooltip: l10n.stopAudioTooltip,
          ),
        ],
      ),
      body: chapterAsync.when(
        data:
            (chapterResponse) => Column(
              children: [
                // Chapter info header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        chapterResponse.data.englishName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chapterResponse.data.englishNameTranslation,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.versesCountRevelationType(
                          chapterResponse.data.numberOfAyahs,
                          chapterResponse.data.revelationType,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const TranslationSelectionWidget(),
                    ],
                  ),
                ),
                // Chapter Audio Player
                if (_duration.inSeconds > 0 || _isPlaying)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.volume_up,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.chapterAudioLabel,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed:
                                  _isPlaying ? _pauseAudio : _playChapterAudio,
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 32,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _stopAudio,
                              icon: const Icon(Icons.stop),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        if (_duration.inSeconds > 0) ...[
                          const SizedBox(height: 12),
                          Slider(
                            value: _position.inMilliseconds.toDouble().clamp(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(_position)),
                              Text(_formatDuration(_duration)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                // Verses list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: chapterResponse.data.ayahs?.length ?? 0,
                    itemBuilder: (context, index) {
                      final verse = chapterResponse.data.ayahs![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              '${verse.numberInSurah}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              tajweedByVerse[verse.numberInSurah] != null
                                  ? TajweedText(
                                    text: tajweedByVerse[verse.numberInSurah]!,
                                    style: const TextStyle(fontSize: 18, height: 1.5),
                                  )
                                  : Text(
                                    verse.text,
                                    style: const TextStyle(fontSize: 18, height: 1.5),
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                  ),
                              if (translationByVerse[verse.numberInSurah] != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  translationByVerse[verse.numberInSurah]!,
                                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.playAudioLabel,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.tafseerLabel,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    l10n.failedToLoadChapter,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () =>
                            ref.refresh(chapterProvider(widget.chapterNumber)),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
