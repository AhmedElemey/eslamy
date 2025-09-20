import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AudioUrlValidator {
  static final Dio _dio = Dio();

  /// Test if an audio URL is accessible
  static Future<bool> isUrlAccessible(String url) async {
    try {
      debugPrint('Testing URL accessibility: $url');
      final response = await _dio.head(url);
      final isAccessible = response.statusCode == 200;
      debugPrint('URL $url is ${isAccessible ? 'accessible' : 'not accessible'}');
      return isAccessible;
    } catch (e) {
      debugPrint('URL $url failed: $e');
      return false;
    }
  }

  /// Test multiple URLs and return the first accessible one
  static Future<String?> findFirstAccessibleUrl(List<String> urls) async {
    for (final url in urls) {
      if (await isUrlAccessible(url)) {
        return url;
      }
    }
    return null;
  }

  /// Test all reciter URLs for a specific chapter
  static Future<Map<String, String?>> testAllReciterUrls(int chapterNumber) async {
    final formattedChapterNumber = chapterNumber.toString().padLeft(3, '0');
    final results = <String, String?>{};

    // Test Abdul Basit Murattal
    final abdulBasitUrls = [
      'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/$formattedChapterNumber.mp3',
      'https://server8.mp3quran.net/abd_basit/Murattal/$formattedChapterNumber.mp3',
      'https://download.quranicaudio.com/qdc/abdul_baset/murattal/$formattedChapterNumber.mp3',
    ];
    results['Abdul Basit Murattal'] = await findFirstAccessibleUrl(abdulBasitUrls);

    // Test Mishary Alafasy
    final misharyUrls = [
      'https://everyayah.com/data/Mishary_Rashid_Alafasy_128kbps/$formattedChapterNumber.mp3',
      'https://server8.mp3quran.net/mishary_rashid_alafasy/Murattal/$formattedChapterNumber.mp3',
      'https://download.quranicaudio.com/qdc/mishary_rashid_alafasy/murattal/$formattedChapterNumber.mp3',
    ];
    results['Mishary Alafasy'] = await findFirstAccessibleUrl(misharyUrls);

    // Test Saad Al Ghamdi
    final saadUrls = [
      'https://everyayah.com/data/Saad_Al_Ghamdi_128kbps/$formattedChapterNumber.mp3',
      'https://server8.mp3quran.net/saad_al_ghamdi/Murattal/$formattedChapterNumber.mp3',
      'https://download.quranicaudio.com/qdc/saad_al_ghamdi/murattal/$formattedChapterNumber.mp3',
    ];
    results['Saad Al Ghamdi'] = await findFirstAccessibleUrl(saadUrls);

    return results;
  }

  /// Print test results in a formatted way
  static void printTestResults(Map<String, String?> results) {
    debugPrint('=== Audio URL Test Results ===');
    for (final entry in results.entries) {
      final reciter = entry.key;
      final url = entry.value;
      if (url != null) {
        debugPrint('✅ $reciter: $url');
      } else {
        debugPrint('❌ $reciter: No accessible URLs found');
      }
    }
    debugPrint('===============================');
  }
}
