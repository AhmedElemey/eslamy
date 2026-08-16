import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/request_controller.dart';
import '../models/hadith.dart';
import '../models/hadith_book.dart';

final hadithApiServiceProvider = Provider((ref) {
  final rc = ref.watch(requestControllerProvider);
  return HadithApiService(requests: rc);
});

final _narratorPattern = RegExp(r'^Narrated ([^:]{1,80}):\s*(.*)$', dotAll: true);

/// Open, free, no-API-key hadith dataset: fawazahmed0/hadith-api, served via
/// jsdelivr's GitHub CDN. Each book is fetched as a single JSON file and
/// cached locally (see HadithCacheDatabase) so it only needs one download.
class HadithApiService {
  final RequestController requests;

  HadithApiService({required this.requests});

  static const _cdnBase =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';

  Future<List<HadithItem>> fetchBook(
    HadithBook book, {
    required String editionSlug,
    ProgressCallback? onProgress,
  }) async {
    final response = await requests.get(
      '/editions/$editionSlug.min.json',
      baseUrl: _cdnBase,
      onReceiveProgress: onProgress,
    );

    final data = response.data as Map<String, dynamic>;
    final hadithsRaw = data['hadiths'] as List<dynamic>;

    return hadithsRaw.map((e) {
      final m = e as Map<String, dynamic>;
      final number = (m['hadithnumber'] as num).toInt();
      final rawText = (m['text'] as String).trim();
      final match = _narratorPattern.firstMatch(rawText);
      final narrator = match?.group(1)?.trim();
      final body = match != null ? match.group(2)!.trim() : rawText;

      return HadithItem(
        id: syntheticHadithId(book.slug, number),
        title: '${book.name} #$number',
        narrator: narrator,
        body: body,
        book: book.slug,
        bookName: book.name,
        hadithNumber: number,
      );
    }).toList();
  }
}
