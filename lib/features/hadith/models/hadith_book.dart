import '../../settings/presentation/controllers/language_providers.dart';

class HadithBook {
  final String slug;
  final String name;
  final String editionSlug;

  const HadithBook({
    required this.slug,
    required this.name,
    required this.editionSlug,
  });
}

/// The six canonical books plus the well-known 40-hadith compilations,
/// as published by the fawazahmed0/hadith-api open dataset.
/// Index in this list (1-based) is used to build a stable synthetic id
/// for each hadith so favorites stay unique across books.
const hadithBooks = <HadithBook>[
  HadithBook(slug: 'bukhari', name: 'Sahih al-Bukhari', editionSlug: 'eng-bukhari'),
  HadithBook(slug: 'muslim', name: 'Sahih Muslim', editionSlug: 'eng-muslim'),
  HadithBook(slug: 'abudawud', name: 'Sunan Abu Dawud', editionSlug: 'eng-abudawud'),
  HadithBook(slug: 'tirmidhi', name: 'Jami At-Tirmidhi', editionSlug: 'eng-tirmidhi'),
  HadithBook(slug: 'nasai', name: 'Sunan an-Nasai', editionSlug: 'eng-nasai'),
  HadithBook(slug: 'ibnmajah', name: 'Sunan Ibn Majah', editionSlug: 'eng-ibnmajah'),
  HadithBook(slug: 'malik', name: 'Muwatta Malik', editionSlug: 'eng-malik'),
  HadithBook(slug: 'nawawi', name: "An-Nawawi's 40 Hadith", editionSlug: 'eng-nawawi'),
  HadithBook(slug: 'qudsi', name: '40 Hadith Qudsi', editionSlug: 'eng-qudsi'),
  HadithBook(slug: 'dehlawi', name: "Shah Waliullah's 40 Hadith", editionSlug: 'eng-dehlawi'),
];

int syntheticHadithId(String bookSlug, int hadithNumber) {
  final index = hadithBooks.indexWhere((b) => b.slug == bookSlug) + 1;
  return index * 1000000 + hadithNumber;
}

/// Every book has a full `ara-<slug>` Arabic edition on the dataset, so
/// Arabic gets real translated text. Italian has no edition for any book on
/// this dataset — it silently falls back to English (`book.editionSlug`)
/// rather than showing an error, matching how the rest of the app degrades
/// when a language just isn't available for a given content source.
String editionSlugFor(HadithBook book, AppLanguage language) {
  if (language == AppLanguage.arabic) return 'ara-${book.slug}';
  return book.editionSlug;
}
