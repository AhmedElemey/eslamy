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

  /// Get tafseer for a specific verse
  Future<QuranChapterResponse> getTafseer(
    int chapterNumber,
    int verseNumber,
  ) async {
    try {
      final response = await _dio.get(
        '/surah/$chapterNumber?edition=ar.muyassar',
      );
      final Map<String, dynamic> data = response.data;
      return QuranChapterResponse.fromJson(data);
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

  /// Get audio files for a specific chapter
  Future<String> getChapterAudio(int chapterNumber) async {
    try {
      // Use the audio service to get chapter audio
      return await QuranAudioService.getChapterAudioUrl(chapterNumber);
    } on DioException catch (e) {
      debugPrint('DioException in getChapterAudio: ${e.toString()}');
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

  /// Get full translation of a chapter
  Future<QuranChapterResponse> getChapterTranslation(
    int chapterNumber, {
    String language = 'en',
  }) async {
    try {
      final edition = language == 'en' ? 'en.sahih' : 'ar.muyassar';
      final response = await _dio.get('/surah/$chapterNumber?edition=$edition');
      final Map<String, dynamic> data = response.data;
      return QuranChapterResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioException in getChapterTranslation: ${e.toString()}');
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
