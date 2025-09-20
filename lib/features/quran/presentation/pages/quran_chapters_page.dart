import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../controllers/quran_providers.dart';
import 'quran_chapter_detail_page.dart';

class QuranChaptersPage extends ConsumerStatefulWidget {
  const QuranChaptersPage({super.key});

  @override
  ConsumerState<QuranChaptersPage> createState() => _QuranChaptersPageState();
}

class _QuranChaptersPageState extends ConsumerState<QuranChaptersPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentAudioUrl;
  int? _currentChapterNumber;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    debugPrint('Setting up audio player...');
    
    _audioPlayer.playerStateStream.listen((state) {
      debugPrint('Audio player state changed: playing=${state.playing}, processingState=${state.processingState}');
      
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });

        // Reset position to start when playback completes and auto-advance
        if (state.processingState == ProcessingState.completed) {
          debugPrint('Audio playback completed');
          _audioPlayer.seek(Duration.zero);
          setState(() {
            _position = Duration.zero;
            _isPlaying = false;
          });

          // Auto-advance to next chapter
          _autoAdvanceToNextChapter();
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

  Future<void> _playChapterAudio(int chapterNumber) async {
    try {
      if (_isPlaying && _currentChapterNumber == chapterNumber) {
        await _pauseAudio();
        return;
      }

      // Stop current audio if playing different chapter
      if (_isPlaying && _currentChapterNumber != chapterNumber) {
        await _stopAudio();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading audio...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Get the selected reciter from the provider
      final selectedReciter = ref.read(selectedReciterProvider);

      debugPrint(
        'Selected reciter for chapter audio: ${selectedReciter?.name} (${selectedReciter?.relativePath})',
      );
      
      // Show reciter info in snackbar for debugging
      if (mounted && selectedReciter != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playing chapter with reciter: ${selectedReciter.name}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      }

      final audioUrlAsync = ref.read(
        verseAudioUrlProvider((
          chapterNumber: chapterNumber,
          verseNumber: 1,
          reciterId: selectedReciter?.relativePath,
        )).future,
      );

      final audioUrl = await audioUrlAsync;
      debugPrint('Playing chapter audio from URL: $audioUrl');

      // Check if it's the test URL (indicates real URLs failed)
      if (audioUrl.contains('BabyElephantWalk60.wav')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Real audio not available, playing test audio. Reciter: ${selectedReciter?.name}'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      try {
        debugPrint('Setting audio URL: $audioUrl');
        await _audioPlayer.setUrl(audioUrl);
        debugPrint('Audio URL set successfully');
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        debugPrint('Starting audio playback...');
        await _audioPlayer.play();
        debugPrint('Audio playback started');
      } catch (e) {
        debugPrint('Error during audio playback: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Audio playback error: $e'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
        rethrow;
      }

      setState(() {
        _currentChapterNumber = chapterNumber;
        _currentAudioUrl = audioUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playing Chapter $chapterNumber audio'),
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
            content: Text('Failed to play audio. Please try again.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _playChapterAudio(chapterNumber),
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
      _currentChapterNumber = null;
      _currentAudioUrl = null;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _autoAdvanceToNextChapter() {
    if (_currentChapterNumber == null) return;

    // Get the chapters list from the provider
    final chaptersAsync = ref.read(chaptersProvider);
    chaptersAsync.whenData((chapters) {
      final currentIndex = chapters.indexWhere(
        (chapter) => chapter.number == _currentChapterNumber,
      );
      if (currentIndex != -1 && currentIndex < chapters.length - 1) {
        final nextChapter = chapters[currentIndex + 1];
        debugPrint(
          'Auto-advancing to next chapter: ${nextChapter.number} - ${nextChapter.englishName}',
        );

        // Show notification about auto-advance
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Auto-advancing to Chapter ${nextChapter.number}: ${nextChapter.englishName}',
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.blue,
            ),
          );
        }

        // Play next chapter after a short delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _playChapterAudio(nextChapter.number);
          }
        });
      } else {
        // No more chapters, show completion message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All chapters completed!'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Chapters'),
        centerTitle: true,
        actions: [
          if (_isPlaying) ...[
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: _pauseAudio,
              tooltip: 'Pause Audio',
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopAudio,
              tooltip: 'Stop Audio',
            ),
          ],
        ],
      ),
      body: chaptersAsync.when(
        data:
            (chapters) => Column(
              children: [
                // Audio Player UI
                if (_duration.inSeconds > 0 || _isPlaying)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
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
                              _currentChapterNumber != null
                                  ? 'Chapter $_currentChapterNumber Audio'
                                  : 'Audio Player',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed:
                                  _isPlaying
                                      ? _pauseAudio
                                      : () {
                                        if (_currentChapterNumber != null) {
                                          _playChapterAudio(
                                            _currentChapterNumber!,
                                          );
                                        }
                                      },
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
                // Chapters List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      final isCurrentChapter =
                          _currentChapterNumber == chapter.number;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isCurrentChapter ? 4 : 1,
                        color: isCurrentChapter ? Colors.green.shade50 : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              isCurrentChapter
                                  ? BorderSide(color: Colors.green, width: 2)
                                  : BorderSide.none,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isCurrentChapter
                                    ? Colors.green
                                    : Theme.of(context).primaryColor,
                            child: Text(
                              '${chapter.number}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            chapter.englishName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isCurrentChapter
                                      ? Colors.green.shade700
                                      : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter.englishNameTranslation,
                                style: TextStyle(
                                  color:
                                      isCurrentChapter
                                          ? Colors.green.shade600
                                          : Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${chapter.numberOfAyahs} verses • ${chapter.revelationType}',
                                style: TextStyle(
                                  color:
                                      isCurrentChapter
                                          ? Colors.green.shade500
                                          : Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isCurrentChapter && _isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color:
                                      isCurrentChapter
                                          ? Colors.green
                                          : Theme.of(context).primaryColor,
                                ),
                                onPressed:
                                    () => _playChapterAudio(chapter.number),
                                tooltip:
                                    isCurrentChapter && _isPlaying
                                        ? 'Pause Audio'
                                        : 'Play Audio',
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color:
                                    isCurrentChapter
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuranChapterDetailPage(
                                      chapterNumber: chapter.number,
                                      chapterName: chapter.englishName,
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
                    'Failed to load chapters',
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
                    onPressed: () => ref.refresh(chaptersProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
