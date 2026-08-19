import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/features/quran/models/quran_models.dart';
import 'package:eslamy/features/quran/service/quran_api_service.dart';

QuranVerse verseFrom({required Object sajda}) {
  return QuranVerse.fromJson({
    'number': 1,
    'text': 'test',
    'numberInSurah': 15,
    'juz': 21,
    'manzil': 5,
    'page': 1,
    'ruku': 1,
    'hizbQuarter': 1,
    'sajda': sajda,
  });
}

void main() {
  group('QuranVerse.sajda', () {
    test('false stays false', () {
      expect(verseFrom(sajda: false).sajda, isFalse);
    });

    test('true stays true', () {
      expect(verseFrom(sajda: true).sajda, isTrue);
    });

    test('Al Quran Cloud sajda object is treated as true', () {
      final verse = verseFrom(
        sajda: {'id': 10, 'recommended': false, 'obligatory': true},
      );
      expect(verse.sajda, isTrue);
    });
  });

  group('QuranApiService (Al Quran Cloud)', () {
    final service = QuranApiService();

    test('surah 32 (has a sajda ayah) loads every verse', () async {
      final chapter = await service.getChapter(32);
      expect(chapter.data.numberOfAyahs, 30);
      expect(chapter.data.ayahs, isNotNull);
      expect(chapter.data.ayahs, hasLength(30));
      expect(chapter.data.ayahs!.where((a) => a.sajda), hasLength(1));
      expect(chapter.data.ayahs![14].numberInSurah, 15);
      expect(chapter.data.ayahs![14].sajda, isTrue);
    });

    test('translation edition path returns English text, not Arabic', () async {
      final chapter = await service.getChapterTranslation(
        1,
        editionIdentifier: 'en.sahih',
      );
      final first = chapter.data.ayahs!.first.text.toLowerCase();
      expect(first, contains('allah'));
      expect(first, isNot(contains('بسم')));
    });
  });
}
