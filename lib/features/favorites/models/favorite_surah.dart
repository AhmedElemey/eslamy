/// A bookmarked Quran chapter — one entry per surah (favoriting again just
/// replaces the row, there's no concept of favoriting the same surah twice).
class FavoriteSurah {
  final int chapterNumber;
  final String chapterName;
  final String chapterEnglishName;
  final DateTime savedAt;

  const FavoriteSurah({
    required this.chapterNumber,
    required this.chapterName,
    required this.chapterEnglishName,
    required this.savedAt,
  });
}
