import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/quran_models.dart';
import 'quran_audio_service.dart';

class QuranApiService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  late final Dio _dio;

  QuranApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Get list of all Quran chapters
  Future<List<QuranChapter>> getChapters() async {
    try {
      final response = await _dio.get('/surah');
      final Map<String, dynamic> data = response.data;
      final List<dynamic> chaptersJson = data['data'];
      return chaptersJson.map((json) => QuranChapter.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint(e.toString());
      throw _handleError(e);
    }
  }

  /// Get a specific chapter with all its verses
  Future<QuranChapterResponse> getChapter(int chapterNumber) async {
    try {
      final response = await _dio.get('/surah/$chapterNumber');
      final Map<String, dynamic> data = response.data;
      return QuranChapterResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioException in getChapter: ${e.toString()}');
      throw _handleError(e);
    }
  }

  /// Get a specific verse
  Future<QuranVerseResponse> getVerse(
    int chapterNumber,
    int verseNumber,
  ) async {
    try {
      final response = await _dio.get(
        '/chapters/$chapterNumber/verses/$verseNumber',
      );
      return QuranVerseResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('DioException in getVerse: ${e.toString()}');
      throw _handleError(e);
    }
  }

  /// Get a chapter with Tajweed-tagged text (bracket format — see
  /// tajweed_text_parser.dart) instead of plain Uthmani text.
  Future<QuranChapterResponse> getChapterTajweed(int chapterNumber) async {
    try {
      final response = await _dio.get('/surah/$chapterNumber/quran-tajweed');
      final Map<String, dynamic> data = response.data;
      return QuranChapterResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioException in getChapterTajweed: ${e.toString()}');
      throw _handleError(e);
    }
  }

  /// Get the tafsir (exegesis) for one specific ayah — ar.jalalayn (Tafsir
  /// Al-Jalalayn) is a real per-ayah tafsir edition, unlike ar.muyassar
  /// (a translation) which this used to call by mistake.
  Future<AyahTafsir> getTafseer(int chapterNumber, int verseNumber) async {
    try {
      final response = await _dio.get(
        '/ayah/$chapterNumber:$verseNumber/ar.jalalayn',
      );
      final Map<String, dynamic> data = response.data;
      return AyahTafsir.fromJson(data);
    } on DioException catch (e) {
      debugPrint(e.toString());
      throw _handleError(e);
    }
  }

  /// Get available reciters
  Future<List<Reciter>> getReciters() async {
    try {
      final response = await _dio.get('/edition');
      final List<dynamic> editions = response.data['data'];
      final audioEditions =
          editions.where((edition) => edition['format'] == 'audio').toList();
      return audioEditions.map((edition) => Reciter.fromJson(edition)).toList();
    } on DioException catch (e) {
      debugPrint('DioException in getReciters: ${e.toString()}');
      throw _handleError(e);
    }
  }

  /// Get audio file for a specific verse
  Future<String> getVerseAudio(
    int chapterNumber,
    int verseNumber, {
    String? reciterId,
  }) async {
    try {
      // Use the audio service to get verse audio
      return await QuranAudioService.getVerseAudioUrl(
        chapterNumber,
        verseNumber,
        reciterId: reciterId,
      );
    } on DioException catch (e) {
      debugPrint('DioException in getVerseAudio: ${e.toString()}');
      throw _handleError(e);
    }
  }

  /// Get the list of selectable translation editions (100+ languages).
  Future<List<TranslationEdition>> getTranslationEditions() async {
    try {
      final response = await _dio.get('/edition?format=text&type=translation');
      final List<dynamic> editions = response.data['data'];
      return editions
          .map((e) => TranslationEdition.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('DioException in getTranslationEditions: ${e.toString()}');
      throw _handleError(e);
    }
  }

  /// Get a full chapter in the given translation edition (any identifier
  /// from getTranslationEditions, e.g. 'en.sahih', 'fr.hamidullah').
  Future<QuranChapterResponse> getChapterTranslation(
    int chapterNumber, {
    String editionIdentifier = 'en.sahih',
  }) async {
    try {
      final response = await _dio.get(
        '/surah/$chapterNumber?edition=$editionIdentifier',
      );
      final Map<String, dynamic> data = response.data;
      return QuranChapterResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioException in getChapterTranslation: ${e.toString()}');
      throw _handleError(e);
    }
  }

  /// Get all ayahs in a Juz (Para), 1-30 — spans surah boundaries.
  Future<List<AyahWithSurah>> getJuz(int juzNumber) async {
    try {
      final response = await _dio.get('/juz/$juzNumber/quran-uthmani');
      final List<dynamic> ayahs = response.data['data']['ayahs'];
      return ayahs
          .map((a) => AyahWithSurah.fromJson(a as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('DioException in getJuz: ${e.toString()}');
      throw _handleError(e);
    }
  }

  /// Get all ayahs on a mushaf page, 1-604 — spans surah boundaries.
  Future<List<AyahWithSurah>> getPage(int pageNumber) async {
    try {
      final response = await _dio.get('/page/$pageNumber/quran-uthmani');
      final List<dynamic> ayahs = response.data['data']['ayahs'];
      return ayahs
          .map((a) => AyahWithSurah.fromJson(a as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('DioException in getPage: ${e.toString()}');
      throw _handleError(e);
    }
  }

  /// Get all ayahs in a Hizb quarter, 1-240 (the API numbers quarters
  /// directly rather than Hizb-then-quarter).
  Future<List<AyahWithSurah>> getHizbQuarter(int quarterNumber) async {
    try {
      final response = await _dio.get(
        '/hizbQuarter/$quarterNumber/quran-uthmani',
      );
      final List<dynamic> ayahs = response.data['data']['ayahs'];
      return ayahs
          .map((a) => AyahWithSurah.fromJson(a as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('DioException in getHizbQuarter: ${e.toString()}');
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    debugPrint('Error details: ${e.toString()}');
    debugPrint('Error type: ${e.type}');
    debugPrint('Error message: ${e.message}');
    debugPrint('Response status: ${e.response?.statusCode}');
    debugPrint('Response data: ${e.response?.data}');
    debugPrint('Request URL: ${e.requestOptions.uri}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return Exception('Requested resource not found.');
        } else if (statusCode == 500) {
          return Exception('Server error. Please try again later.');
        }
        return Exception('Request failed with status: $statusCode');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      default:
        return Exception('An unexpected error occurred: ${e.message}');
    }
  }
}
