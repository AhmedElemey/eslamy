/// A single ayah picked for "today", cached locally so it stays the same
/// across app opens on the same day instead of changing on every rebuild.
/// Not codegen-backed since it's a small, self-contained shape (matches
/// [AyahWithSurah]/[TranslationEdition] in quran_models.dart).
class AyahOfTheDay {
  final int chapterNumber;
  final String chapterArabicName;
  final String chapterEnglishName;
  final int verseNumber;
  final String arabicText;
  final String translationText;

  /// Local date this ayah was picked for, as `yyyy-MM-dd` — a fresh pick
  /// only happens once the current date no longer matches this key.
  final String dateKey;

  const AyahOfTheDay({
    required this.chapterNumber,
    required this.chapterArabicName,
    required this.chapterEnglishName,
    required this.verseNumber,
    required this.arabicText,
    required this.translationText,
    required this.dateKey,
  });

  factory AyahOfTheDay.fromJson(Map<String, dynamic> json) => AyahOfTheDay(
    chapterNumber: json['chapterNumber'] as int,
    chapterArabicName: json['chapterArabicName'] as String,
    chapterEnglishName: json['chapterEnglishName'] as String,
    verseNumber: json['verseNumber'] as int,
    arabicText: json['arabicText'] as String,
    translationText: json['translationText'] as String,
    dateKey: json['dateKey'] as String,
  );

  Map<String, dynamic> toJson() => {
    'chapterNumber': chapterNumber,
    'chapterArabicName': chapterArabicName,
    'chapterEnglishName': chapterEnglishName,
    'verseNumber': verseNumber,
    'arabicText': arabicText,
    'translationText': translationText,
    'dateKey': dateKey,
  };
}
