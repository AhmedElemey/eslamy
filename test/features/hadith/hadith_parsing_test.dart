import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/features/hadith/models/hadith.dart';
import 'package:eslamy/features/hadith/models/hadith_book.dart';
import 'package:eslamy/features/hadith/service/hadith_api_service.dart';

void main() {
  const bukhari = HadithBook(
    slug: 'bukhari',
    name: 'Sahih al-Bukhari',
    editionSlug: 'eng-bukhari',
  );

  test(
    'fractional hadith numbers get ids that do not collide with integers',
    () {
      expect(
        syntheticHadithId('bukhari', 402),
        isNot(syntheticHadithId('bukhari', 402.2)),
      );
      expect(syntheticHadithId('bukhari', 402), 1 * 1000000 + 402);
    },
  );

  test('parseHadithsDocument keeps 402.2 and skips empty/invalid rows', () {
    final items = parseHadithsDocument(
      {
        'hadiths': [
          {'hadithnumber': 402, 'text': 'First hadith'},
          {'hadithnumber': 402.2, 'text': 'Inserted hadith'},
          {'hadithnumber': 403, 'text': '   '},
          {'hadithnumber': 404, 'text': null},
          {'text': 'missing number'},
          'not a map',
        ],
      },
      bukhari,
      editionSlug: 'eng-bukhari',
    );

    expect(items, hasLength(2));
    expect(items[0].hadithNumber, 402);
    expect(items[1].hadithNumber, 402.2);
    expect(items[0].id, isNot(items[1].id));
    expect(formatHadithNumber(items[1].hadithNumber), '402.2');
  });
}
