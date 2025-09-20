import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/quran_providers.dart';

class QuranTestPage extends ConsumerWidget {
  const QuranTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quran API Test'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Chapters
            _buildTestSection(
              context,
              'Test 1: Get All Chapters',
              'Testing /surah endpoint',
              () async {
                try {
                  final chapters = await ref.read(chaptersProvider.future);
                  _showResult(
                    context,
                    'Success!',
                    'Found ${chapters.length} chapters',
                  );
                } catch (e) {
                  _showResult(context, 'Error!', e.toString());
                }
              },
            ),

            const SizedBox(height: 16),

            // Test Single Chapter
            _buildTestSection(
              context,
              'Test 2: Get Chapter 1 (Al-Fatiha)',
              'Testing /surah/1 endpoint',
              () async {
                try {
                  final chapter = await ref.read(chapterProvider(1).future);
                  _showResult(
                    context,
                    'Success!',
                    'Chapter: ${chapter.data.name} (${chapter.data.englishName})',
                  );
                } catch (e) {
                  _showResult(context, 'Error!', e.toString());
                }
              },
            ),

            const SizedBox(height: 16),

            // Test Verse
            _buildTestSection(
              context,
              'Test 3: Get Verse 1:1',
              'Testing verse endpoint',
              () async {
                try {
                  final verse = await ref.read(
                    verseProvider((chapterNumber: 1, verseNumber: 1)).future,
                  );
                  _showResult(
                    context,
                    'Success!',
                    'Verse: ${verse.verse.text}',
                  );
                } catch (e) {
                  _showResult(context, 'Error!', e.toString());
                }
              },
            ),

            const SizedBox(height: 16),

            // Test Tafseer
            _buildTestSection(
              context,
              'Test 4: Get Tafseer for 1:1',
              'Testing tafseer endpoint',
              () async {
                try {
                  final tafseer = await ref.read(
                    tafseerProvider((chapterNumber: 1, verseNumber: 1)).future,
                  );
                  _showResult(
                    context,
                    'Success!',
                    'Tafseer loaded: ${tafseer.data.ayahs?.length ?? 0} verses',
                  );
                } catch (e) {
                  _showResult(context, 'Error!', e.toString());
                }
              },
            ),

            const SizedBox(height: 16),

            // Test Reciters
            _buildTestSection(
              context,
              'Test 5: Get Reciters',
              'Testing /edition endpoint for audio',
              () async {
                try {
                  final reciters = await ref.read(recitersProvider.future);
                  _showResult(
                    context,
                    'Success!',
                    'Found ${reciters.length} reciters',
                  );
                } catch (e) {
                  _showResult(context, 'Error!', e.toString());
                }
              },
            ),

            const SizedBox(height: 16),

            // Test Audio URL
            _buildTestSection(
              context,
              'Test 6: Get Audio URL for 1:1',
              'Testing audio URL generation',
              () async {
                try {
                  final audioUrl = await ref.read(
                    verseAudioUrlProvider((
                      chapterNumber: 1,
                      verseNumber: 1,
                      reciterId: 'Abdul_Basit_Murattal',
                    )).future,
                  );
                  _showResult(context, 'Success!', 'Audio URL: $audioUrl');
                } catch (e) {
                  _showResult(context, 'Error!', e.toString());
                }
              },
            ),

            const SizedBox(height: 16),

            // Test Translation
            _buildTestSection(
              context,
              'Test 7: Get English Translation',
              'Testing translation endpoint',
              () async {
                try {
                  final translation = await ref.read(
                    chapterTranslationProvider((
                      chapterNumber: 1,
                      language: 'en',
                    )).future,
                  );
                  _showResult(
                    context,
                    'Success!',
                    'Translation loaded: ${translation.data.ayahs?.length ?? 0} verses',
                  );
                } catch (e) {
                  _showResult(context, 'Error!', e.toString());
                }
              },
            ),

            const SizedBox(height: 32),

            // Run All Tests Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _runAllTests(context, ref),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run All Tests'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(
    BuildContext context,
    String title,
    String description,
    VoidCallback onTest,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onTest, child: const Text('Test')),
          ],
        ),
      ),
    );
  }

  void _showResult(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(child: Text(message)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _runAllTests(BuildContext context, WidgetRef ref) async {
    final results = <String>[];

    // Test 1: Chapters
    try {
      final chapters = await ref.read(chaptersProvider.future);
      results.add('✅ Chapters: ${chapters.length} found');
    } catch (e) {
      results.add('❌ Chapters: $e');
    }

    // Test 2: Single Chapter
    try {
      final chapter = await ref.read(chapterProvider(1).future);
      results.add('✅ Chapter 1: ${chapter.data.name}');
    } catch (e) {
      results.add('❌ Chapter 1: $e');
    }

    // Test 3: Verse
    try {
      final verse = await ref.read(
        verseProvider((chapterNumber: 1, verseNumber: 1)).future,
      );
      results.add('✅ Verse 1:1: ${verse.verse.text.substring(0, 50)}...');
    } catch (e) {
      results.add('❌ Verse 1:1: $e');
    }

    // Test 4: Tafseer
    try {
      final tafseer = await ref.read(
        tafseerProvider((chapterNumber: 1, verseNumber: 1)).future,
      );
      results.add('✅ Tafseer: ${tafseer.data.ayahs?.length ?? 0} verses');
    } catch (e) {
      results.add('❌ Tafseer: $e');
    }

    // Test 5: Reciters
    try {
      final reciters = await ref.read(recitersProvider.future);
      results.add('✅ Reciters: ${reciters.length} found');
    } catch (e) {
      results.add('❌ Reciters: $e');
    }

    // Test 6: Audio URL
    try {
      final audioUrl = await ref.read(
        verseAudioUrlProvider((
          chapterNumber: 1,
          verseNumber: 1,
          reciterId: 'Abdul_Basit_Murattal',
        )).future,
      );
      results.add('✅ Audio URL: $audioUrl');
    } catch (e) {
      results.add('❌ Audio URL: $e');
    }

    // Test 7: Translation
    try {
      final translation = await ref.read(
        chapterTranslationProvider((chapterNumber: 1, language: 'en')).future,
      );
      results.add(
        '✅ Translation: ${translation.data.ayahs?.length ?? 0} verses',
      );
    } catch (e) {
      results.add('❌ Translation: $e');
    }

    _showResult(context, 'All Tests Results', results.join('\n\n'));
  }
}
