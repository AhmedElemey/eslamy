// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuranChapter _$QuranChapterFromJson(Map<String, dynamic> json) => QuranChapter(
  number: (json['number'] as num).toInt(),
  name: json['name'] as String,
  englishName: json['englishName'] as String,
  englishNameTranslation: json['englishNameTranslation'] as String,
  numberOfAyahs: (json['numberOfAyahs'] as num).toInt(),
  revelationType: json['revelationType'] as String,
  ayahs:
      (json['ayahs'] as List<dynamic>?)
          ?.map((e) => QuranVerse.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$QuranChapterToJson(QuranChapter instance) =>
    <String, dynamic>{
      'number': instance.number,
      'name': instance.name,
      'englishName': instance.englishName,
      'englishNameTranslation': instance.englishNameTranslation,
      'numberOfAyahs': instance.numberOfAyahs,
      'revelationType': instance.revelationType,
      'ayahs': instance.ayahs,
    };

QuranVerse _$QuranVerseFromJson(Map<String, dynamic> json) => QuranVerse(
  number: (json['number'] as num).toInt(),
  text: json['text'] as String,
  numberInSurah: (json['numberInSurah'] as num).toInt(),
  juz: (json['juz'] as num).toInt(),
  manzil: (json['manzil'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  ruku: (json['ruku'] as num).toInt(),
  hizbQuarter: (json['hizbQuarter'] as num).toInt(),
  sajda: json['sajda'] as bool,
);

Map<String, dynamic> _$QuranVerseToJson(QuranVerse instance) =>
    <String, dynamic>{
      'number': instance.number,
      'text': instance.text,
      'numberInSurah': instance.numberInSurah,
      'juz': instance.juz,
      'manzil': instance.manzil,
      'page': instance.page,
      'ruku': instance.ruku,
      'hizbQuarter': instance.hizbQuarter,
      'sajda': instance.sajda,
    };

QuranChapterResponse _$QuranChapterResponseFromJson(
  Map<String, dynamic> json,
) => QuranChapterResponse(
  data: QuranChapter.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$QuranChapterResponseToJson(
  QuranChapterResponse instance,
) => <String, dynamic>{'data': instance.data};

QuranVerseResponse _$QuranVerseResponseFromJson(Map<String, dynamic> json) =>
    QuranVerseResponse(
      chapter: QuranChapter.fromJson(json['chapter'] as Map<String, dynamic>),
      verse: QuranVerse.fromJson(json['verse'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuranVerseResponseToJson(QuranVerseResponse instance) =>
    <String, dynamic>{'chapter': instance.chapter, 'verse': instance.verse};

Tafseer _$TafseerFromJson(Map<String, dynamic> json) => Tafseer(
  id: (json['id'] as num).toInt(),
  language: json['language'] as String,
  text: json['text'] as String,
  resourceName: json['resourceName'] as String,
  resourceId: json['resourceId'] as String,
);

Map<String, dynamic> _$TafseerToJson(Tafseer instance) => <String, dynamic>{
  'id': instance.id,
  'language': instance.language,
  'text': instance.text,
  'resourceName': instance.resourceName,
  'resourceId': instance.resourceId,
};

TafseerResponse _$TafseerResponseFromJson(Map<String, dynamic> json) =>
    TafseerResponse(
      chapter: QuranChapter.fromJson(json['chapter'] as Map<String, dynamic>),
      verse: QuranVerse.fromJson(json['verse'] as Map<String, dynamic>),
      tafseer:
          (json['tafseer'] as List<dynamic>)
              .map((e) => Tafseer.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$TafseerResponseToJson(TafseerResponse instance) =>
    <String, dynamic>{
      'chapter': instance.chapter,
      'verse': instance.verse,
      'tafseer': instance.tafseer,
    };

Reciter _$ReciterFromJson(Map<String, dynamic> json) => Reciter(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  arabicName: json['arabicName'] as String,
  relativePath: json['relativePath'] as String,
);

Map<String, dynamic> _$ReciterToJson(Reciter instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'arabicName': instance.arabicName,
  'relativePath': instance.relativePath,
};

RecitersResponse _$RecitersResponseFromJson(Map<String, dynamic> json) =>
    RecitersResponse(
      reciters:
          (json['reciters'] as List<dynamic>)
              .map((e) => Reciter.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$RecitersResponseToJson(RecitersResponse instance) =>
    <String, dynamic>{'reciters': instance.reciters};

AudioFile _$AudioFileFromJson(Map<String, dynamic> json) => AudioFile(
  id: (json['id'] as num).toInt(),
  chapterNumber: json['chapterNumber'] as String,
  fileSize: json['fileSize'] as String,
  format: json['format'] as String,
  audioUrl: json['audioUrl'] as String,
);

Map<String, dynamic> _$AudioFileToJson(AudioFile instance) => <String, dynamic>{
  'id': instance.id,
  'chapterNumber': instance.chapterNumber,
  'fileSize': instance.fileSize,
  'format': instance.format,
  'audioUrl': instance.audioUrl,
};

AudioResponse _$AudioResponseFromJson(Map<String, dynamic> json) =>
    AudioResponse(
      audioFiles:
          (json['audioFiles'] as List<dynamic>)
              .map((e) => AudioFile.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$AudioResponseToJson(AudioResponse instance) =>
    <String, dynamic>{'audioFiles': instance.audioFiles};
