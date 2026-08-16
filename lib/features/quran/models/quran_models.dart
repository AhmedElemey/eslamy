import 'package:json_annotation/json_annotation.dart';

part 'quran_models.g.dart';

@JsonSerializable()
class QuranChapter {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  final List<QuranVerse>? ayahs;

  const QuranChapter({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    this.ayahs,
  });

  factory QuranChapter.fromJson(Map<String, dynamic> json) =>
      _$QuranChapterFromJson(json);

  Map<String, dynamic> toJson() => _$QuranChapterToJson(this);
}

@JsonSerializable()
class QuranVerse {
  final int number;
  final String text;
  final int numberInSurah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;

  const QuranVerse({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) =>
      _$QuranVerseFromJson(json);

  Map<String, dynamic> toJson() => _$QuranVerseToJson(this);
}

@JsonSerializable()
class QuranChapterResponse {
  final QuranChapter data;

  const QuranChapterResponse({required this.data});

  factory QuranChapterResponse.fromJson(Map<String, dynamic> json) =>
      _$QuranChapterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuranChapterResponseToJson(this);
}

@JsonSerializable()
class QuranVerseResponse {
  final QuranChapter chapter;
  final QuranVerse verse;

  const QuranVerseResponse({required this.chapter, required this.verse});

  factory QuranVerseResponse.fromJson(Map<String, dynamic> json) =>
      _$QuranVerseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuranVerseResponseToJson(this);
}

@JsonSerializable()
class Tafseer {
  final int id;
  final String language;
  final String text;
  final String resourceName;
  final String resourceId;

  const Tafseer({
    required this.id,
    required this.language,
    required this.text,
    required this.resourceName,
    required this.resourceId,
  });

  factory Tafseer.fromJson(Map<String, dynamic> json) =>
      _$TafseerFromJson(json);

  Map<String, dynamic> toJson() => _$TafseerToJson(this);
}

@JsonSerializable()
class TafseerResponse {
  final QuranChapter chapter;
  final QuranVerse verse;
  final List<Tafseer> tafseer;

  const TafseerResponse({
    required this.chapter,
    required this.verse,
    required this.tafseer,
  });

  factory TafseerResponse.fromJson(Map<String, dynamic> json) =>
      _$TafseerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TafseerResponseToJson(this);
}

@JsonSerializable()
class Reciter {
  final int id;
  final String name;
  final String arabicName;
  final String relativePath;

  const Reciter({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.relativePath,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) =>
      _$ReciterFromJson(json);

  Map<String, dynamic> toJson() => _$ReciterToJson(this);
}

@JsonSerializable()
class RecitersResponse {
  final List<Reciter> reciters;

  const RecitersResponse({required this.reciters});

  factory RecitersResponse.fromJson(Map<String, dynamic> json) =>
      _$RecitersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RecitersResponseToJson(this);
}

@JsonSerializable()
class AudioFile {
  final int id;
  final String chapterNumber;
  final String fileSize;
  final String format;
  final String audioUrl;

  const AudioFile({
    required this.id,
    required this.chapterNumber,
    required this.fileSize,
    required this.format,
    required this.audioUrl,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) =>
      _$AudioFileFromJson(json);

  Map<String, dynamic> toJson() => _$AudioFileToJson(this);
}

@JsonSerializable()
class AudioResponse {
  final List<AudioFile> audioFiles;

  const AudioResponse({required this.audioFiles});

  factory AudioResponse.fromJson(Map<String, dynamic> json) =>
      _$AudioResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AudioResponseToJson(this);
}

/// A single ayah as returned by the /juz, /page and /hizbQuarter endpoints —
/// these spans cross surah boundaries, so each ayah carries its own surah
/// info (unlike QuranVerse, which is always read within one already-known
/// surah). Not codegen-backed since it's a small, self-contained shape.
class AyahWithSurah {
  final int numberInSurah;
  final String text;
  final int surahNumber;
  final String surahEnglishName;
  final String surahArabicName;

  const AyahWithSurah({
    required this.numberInSurah,
    required this.text,
    required this.surahNumber,
    required this.surahEnglishName,
    required this.surahArabicName,
  });

  factory AyahWithSurah.fromJson(Map<String, dynamic> json) {
    final surah = json['surah'] as Map<String, dynamic>;
    return AyahWithSurah(
      numberInSurah: json['numberInSurah'] as int,
      text: json['text'] as String,
      surahNumber: surah['number'] as int,
      surahEnglishName: surah['englishName'] as String,
      surahArabicName: surah['name'] as String,
    );
  }
}

/// One selectable Quran translation edition (language + identifier), from
/// Al Quran Cloud's /edition?format=text&type=translation — not codegen-
/// backed since it's a small, self-contained shape.
class TranslationEdition {
  final String identifier;
  final String language;
  final String name;
  final String englishName;

  const TranslationEdition({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
  });

  factory TranslationEdition.fromJson(Map<String, dynamic> json) =>
      TranslationEdition(
        identifier: json['identifier'] as String,
        language: json['language'] as String,
        name: json['name'] as String,
        englishName: json['englishName'] as String,
      );
}

/// A single ayah's tafsir (per-verse exegesis), from Al Quran Cloud's
/// /ayah/{surah}:{ayah}/{edition} endpoint — not codegen-backed since it's
/// a small, self-contained shape.
class AyahTafsir {
  final String text;
  final String editionName;

  const AyahTafsir({required this.text, required this.editionName});

  factory AyahTafsir.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AyahTafsir(
      text: data['text'] as String,
      editionName: data['edition']['englishName'] as String,
    );
  }
}
