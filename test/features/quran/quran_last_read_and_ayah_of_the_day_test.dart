import 'dart:convert';

import 'package:eslamy/features/quran/models/ayah_of_the_day.dart';
import 'package:eslamy/features/quran/models/last_read_position.dart';
import 'package:eslamy/features/quran/service/ayah_of_the_day_service.dart';
import 'package:eslamy/features/quran/service/last_read_position_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LastReadPositionService', () {
    late LastReadPositionService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = LastReadPositionService();
    });

    test('load returns null when nothing has been stored', () async {
      expect(await service.load(), isNull);
    });

    test('save then load round-trips every field', () async {
      final position = LastReadPosition(
        chapterNumber: 2,
        chapterArabicName: 'البقرة',
        chapterEnglishName: 'Al-Baqarah',
        ayahNumber: 255,
        pageNumber: 42,
        updatedAt: DateTime.utc(2026, 1, 15, 10, 30),
      );

      await service.save(position);
      final loaded = await service.load();

      expect(loaded, isNotNull);
      expect(loaded!.chapterNumber, 2);
      expect(loaded.chapterArabicName, 'البقرة');
      expect(loaded.chapterEnglishName, 'Al-Baqarah');
      expect(loaded.ayahNumber, 255);
      expect(loaded.pageNumber, 42);
      expect(loaded.updatedAt, DateTime.utc(2026, 1, 15, 10, 30));
    });

    test('save overwrites a previously stored position', () async {
      await service.save(
        LastReadPosition(
          chapterNumber: 1,
          chapterArabicName: 'الفاتحة',
          chapterEnglishName: 'Al-Fatihah',
          ayahNumber: 1,
          pageNumber: 1,
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );
      await service.save(
        LastReadPosition(
          chapterNumber: 3,
          chapterArabicName: 'آل عمران',
          chapterEnglishName: 'Aal-Imran',
          ayahNumber: 10,
          pageNumber: 60,
          updatedAt: DateTime.utc(2026, 1, 2),
        ),
      );

      final loaded = await service.load();
      expect(loaded!.chapterNumber, 3);
      expect(loaded.ayahNumber, 10);
    });

    test('load returns null when the stored value is corrupt JSON', () async {
      SharedPreferences.setMockInitialValues({
        'last_read_position': 'not valid json',
      });
      service = LastReadPositionService();

      expect(await service.load(), isNull);
    });

    test('load returns null when the stored JSON is missing a required field', () async {
      SharedPreferences.setMockInitialValues({
        'last_read_position': jsonEncode({'chapterNumber': 2}),
      });
      service = LastReadPositionService();

      expect(await service.load(), isNull);
    });
  });

  group('LastReadPosition JSON', () {
    test('toJson/fromJson round-trips including the ISO8601 date', () {
      final position = LastReadPosition(
        chapterNumber: 18,
        chapterArabicName: 'الكهف',
        chapterEnglishName: 'Al-Kahf',
        ayahNumber: 10,
        pageNumber: 293,
        updatedAt: DateTime.utc(2026, 3, 5, 8, 0),
      );

      final decoded = LastReadPosition.fromJson(
        jsonDecode(jsonEncode(position.toJson())) as Map<String, dynamic>,
      );

      expect(decoded.chapterNumber, position.chapterNumber);
      expect(decoded.chapterArabicName, position.chapterArabicName);
      expect(decoded.chapterEnglishName, position.chapterEnglishName);
      expect(decoded.ayahNumber, position.ayahNumber);
      expect(decoded.pageNumber, position.pageNumber);
      expect(decoded.updatedAt, position.updatedAt);
    });
  });

  group('AyahOfTheDayService', () {
    late AyahOfTheDayService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = AyahOfTheDayService();
    });

    test('loadCached returns null when nothing has been stored', () async {
      expect(await service.loadCached(), isNull);
    });

    test('save then loadCached round-trips every field', () async {
      const ayah = AyahOfTheDay(
        chapterNumber: 55,
        chapterArabicName: 'الرحمن',
        chapterEnglishName: 'Ar-Rahman',
        verseNumber: 13,
        arabicText: 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
        translationText: 'Then which of the favors of your Lord will you deny?',
        dateKey: '2026-03-05',
      );

      await service.save(ayah);
      final loaded = await service.loadCached();

      expect(loaded, isNotNull);
      expect(loaded!.chapterNumber, 55);
      expect(loaded.chapterArabicName, 'الرحمن');
      expect(loaded.chapterEnglishName, 'Ar-Rahman');
      expect(loaded.verseNumber, 13);
      expect(loaded.arabicText, 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ');
      expect(
        loaded.translationText,
        'Then which of the favors of your Lord will you deny?',
      );
      expect(loaded.dateKey, '2026-03-05');
    });

    test('save overwrites a previously cached ayah', () async {
      const yesterday = AyahOfTheDay(
        chapterNumber: 1,
        chapterArabicName: 'الفاتحة',
        chapterEnglishName: 'Al-Fatihah',
        verseNumber: 1,
        arabicText: 'بِسْمِ اللَّهِ',
        translationText: 'In the name of Allah',
        dateKey: '2026-03-04',
      );
      const today = AyahOfTheDay(
        chapterNumber: 2,
        chapterArabicName: 'البقرة',
        chapterEnglishName: 'Al-Baqarah',
        verseNumber: 1,
        arabicText: 'الم',
        translationText: 'Alif Lam Meem',
        dateKey: '2026-03-05',
      );

      await service.save(yesterday);
      await service.save(today);

      final loaded = await service.loadCached();
      expect(loaded!.dateKey, '2026-03-05');
      expect(loaded.chapterNumber, 2);
    });

    test('loadCached returns null when the stored value is corrupt JSON', () async {
      SharedPreferences.setMockInitialValues({
        'ayah_of_the_day': 'not valid json',
      });
      service = AyahOfTheDayService();

      expect(await service.loadCached(), isNull);
    });

    test('loadCached returns null when the stored JSON is missing a required field', () async {
      SharedPreferences.setMockInitialValues({
        'ayah_of_the_day': jsonEncode({'chapterNumber': 1}),
      });
      service = AyahOfTheDayService();

      expect(await service.loadCached(), isNull);
    });
  });

  group('AyahOfTheDay JSON', () {
    test('toJson/fromJson round-trips all fields', () {
      const ayah = AyahOfTheDay(
        chapterNumber: 112,
        chapterArabicName: 'الإخلاص',
        chapterEnglishName: 'Al-Ikhlas',
        verseNumber: 1,
        arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        translationText: 'Say, He is Allah, [who is] One',
        dateKey: '2026-03-05',
      );

      final decoded = AyahOfTheDay.fromJson(
        jsonDecode(jsonEncode(ayah.toJson())) as Map<String, dynamic>,
      );

      expect(decoded.chapterNumber, ayah.chapterNumber);
      expect(decoded.chapterArabicName, ayah.chapterArabicName);
      expect(decoded.chapterEnglishName, ayah.chapterEnglishName);
      expect(decoded.verseNumber, ayah.verseNumber);
      expect(decoded.arabicText, ayah.arabicText);
      expect(decoded.translationText, ayah.translationText);
      expect(decoded.dateKey, ayah.dateKey);
    });
  });

  group('todayDateKey', () {
    test('formats as yyyy-MM-dd matching DateTime.now()', () {
      final now = DateTime.now();
      final expected =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      expect(todayDateKey(), expected);
    });

    test('produces a stable, parseable date-only key', () {
      final key = todayDateKey();
      expect(key, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(DateTime.parse(key).day, DateTime.now().day);
    });
  });
}
