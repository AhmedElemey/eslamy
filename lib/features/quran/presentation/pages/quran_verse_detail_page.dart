import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../controllers/quran_providers.dart';

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
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

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

    // Listen for player errors
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.idle &&
          state.playing == false) {
        debugPrint('Audio player is idle');
      }
    });
  }

  Future<void> _playAudio() async {
    try {
      if (_isPlaying) {
        await _pauseAudio();
        return;
      }

      // Stop any current audio before starting new
      await _stopAudio();

      // Show loading indicator
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
        'Selected reciter for audio: ${selectedReciter?.name} (${selectedReciter?.relativePath})',
      );
      
      // Show reciter info in snackbar for debugging
      if (mounted && selectedReciter != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playing with reciter: ${selectedReciter.name}'),
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
              content: Text('Real audio not available, playing test audio. Reciter: ${selectedReciter?.name}'),
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
              content: Text('Audio playback error: $e'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
        rethrow;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio started playing'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio. Please try again.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
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
  }

  @override
  void dispose() {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chapter ${widget.chapterNumber}, Verse ${widget.verseNumber}',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                            'Chapter ${widget.chapterNumber}, Verse ${widget.verseNumber}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
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
                      'Audio Recitation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.grey[700],
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
                                  'Tap play to load audio',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                            ],
                          ),
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
                      'Tafseer (Interpretation)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    tafseerAsync.when(
                      data: (tafseerResponse) {
                        if (tafseerResponse.data.ayahs == null ||
                            tafseerResponse.data.ayahs!.isEmpty) {
                          return Text(
                            'No tafseer available for this verse.',
                            style: TextStyle(color: Colors.grey[600]),
                          );
                        }

                        // Find the specific verse
                        final verse = tafseerResponse.data.ayahs!.firstWhere(
                          (ayah) => ayah.numberInSurah == widget.verseNumber,
                          orElse: () => tafseerResponse.data.ayahs!.first,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tafseer (Muyassar)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                verse.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
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
                      error:
                          (error, stack) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[600],
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load tafseer',
                                  style: TextStyle(
                                    color: Colors.red[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  error.toString(),
                                  style: TextStyle(
                                    color: Colors.red[600],
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
                                    backgroundColor: Colors.red[600],
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
