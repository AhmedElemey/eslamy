import '../../hadith/models/hadith.dart';

class FavoriteHadith {
  final String id;
  final HadithItem hadith;
  final DateTime savedAt;

  const FavoriteHadith({
    required this.id,
    required this.hadith,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hadith': {
        'id': hadith.id,
        'title': hadith.title,
        'narrator': hadith.narrator,
        'body': hadith.body,
      },
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory FavoriteHadith.fromJson(Map<String, dynamic> json) {
    final hadithData = json['hadith'] as Map<String, dynamic>;
    return FavoriteHadith(
      id: json['id'] as String,
      hadith: HadithItem(
        id: hadithData['id'] as int,
        title: hadithData['title'] as String? ?? '',
        narrator: hadithData['narrator'] as String?,
        body: hadithData['body'] as String?,
      ),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  FavoriteHadith copyWith({
    String? id,
    HadithItem? hadith,
    DateTime? savedAt,
  }) {
    return FavoriteHadith(
      id: id ?? this.id,
      hadith: hadith ?? this.hadith,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
