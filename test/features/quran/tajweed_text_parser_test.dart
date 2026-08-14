import 'package:eslamy/features/quran/service/tajweed_text_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseTajweedText', () {
    test('plain text with no tags returns a single untagged segment', () {
      final segments = parseTajweedText('بِسْمِ اللَّهِ');

      expect(segments, hasLength(1));
      expect(segments.single.text, 'بِسْمِ اللَّهِ');
      expect(segments.single.rule, isNull);
    });

    test('parses Al-Fatiha 1:1 (real API response) into the correct rule sequence', () {
      // GET https://api.alquran.cloud/v1/surah/1/quran-tajweed, ayah 1.
      const raw = 'بِسْمِ [h:1[ٱ]للَّهِ [h:2[ٱ][l[ل]رَّحْمَ[n[ـٰ]نِ [h:3[ٱ][l[ل]رَّح[p[ِي]مِ';

      final segments = parseTajweedText(raw);

      // Concatenating every segment's text must reconstruct the plain
      // (tag-free) verse text — no characters lost or duplicated.
      expect(
        segments.map((s) => s.text).join(),
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
      );

      final ruleCodes = segments.where((s) => s.rule != null).map((s) => s.rule!.code).toList();
      expect(ruleCodes, ['h', 'h', 'l', 'n', 'h', 'l', 'p']);

      // Two adjacent tags (no text between them), e.g. [h:2[ٱ][l[ل] — the
      // hamzat-wasl rule immediately followed by the lam-shamsiyyah rule.
      final hamzaSegment = segments.firstWhere((s) => s.rule?.code == 'h' && s.text == 'ٱ');
      expect(hamzaSegment.rule!.key, 'ham_wasl');
      final laamSegment = segments.firstWhere((s) => s.rule?.code == 'l');
      expect(laamSegment.rule!.key, 'laam_shamsiyah');
    });

    test('parses Al-Fatiha 1:3, which starts with a rule tag (no leading plain text)', () {
      const raw = 'ٱ[l[ل]رَّحْمَ[n[ـٰ]نِ [h:3[ٱ][l[ل]رَّح[p[ِي]مِ';

      final segments = parseTajweedText(raw);

      expect(segments.first.text, 'ٱ');
      expect(segments.first.rule, isNull);
      expect(
        segments.map((s) => s.text).join(),
        'ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
      );
    });

    test('unknown rule codes are still consumed without crashing', () {
      final segments = parseTajweedText('أ[z[ب]ت');

      expect(segments.map((s) => s.text).join(), 'أبت');
      expect(segments.firstWhere((s) => s.text == 'ب').rule, isNull);
    });
  });
}
