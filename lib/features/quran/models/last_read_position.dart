/// Where the user last left off in the Mushaf reader, so a home-screen
/// "Continue Reading" card can jump straight back there. Not codegen-backed
/// since it's a small, self-contained shape.
class LastReadPosition {
  final int chapterNumber;
  final String chapterArabicName;
  final String chapterEnglishName;
  final int ayahNumber;
  final int pageNumber;
  final DateTime updatedAt;

  const LastReadPosition({
    required this.chapterNumber,
    required this.chapterArabicName,
    required this.chapterEnglishName,
    required this.ayahNumber,
    required this.pageNumber,
    required this.updatedAt,
  });

  factory LastReadPosition.fromJson(Map<String, dynamic> json) =>
      LastReadPosition(
        chapterNumber: json['chapterNumber'] as int,
        chapterArabicName: json['chapterArabicName'] as String,
        chapterEnglishName: json['chapterEnglishName'] as String,
        ayahNumber: json['ayahNumber'] as int,
        pageNumber: json['pageNumber'] as int,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'chapterNumber': chapterNumber,
    'chapterArabicName': chapterArabicName,
    'chapterEnglishName': chapterEnglishName,
    'ayahNumber': ayahNumber,
    'pageNumber': pageNumber,
    'updatedAt': updatedAt.toIso8601String(),
  };
}
