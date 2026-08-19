import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/request_controller.dart';
import '../models/hadith.dart';
import '../models/hadith_book.dart';

final hadithApiServiceProvider = Provider((ref) {
  final rc = ref.watch(requestControllerProvider);
  return HadithApiService(requests: rc);
});

final _narratorPattern = RegExp(
  r'^Narrated ([^:]{1,80}):\s*(.*)$',
  dotAll: true,
);

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

    final data = response.data;
    if (data is! Map) {
      throw FormatException(
        'Hadith edition $editionSlug (${book.slug}): expected JSON object, '
        'got ${data.runtimeType}',
      );
    }

    return parseHadithsDocument(
      Map<String, dynamic>.from(data),
      book,
      editionSlug: editionSlug,
    );
  }
}

/// Parses one fawazahmed0 edition document. Skips individual malformed or
/// empty entries instead of failing the whole book, and logs which ones.
@visibleForTesting
List<HadithItem> parseHadithsDocument(
  Map<String, dynamic> data,
  HadithBook book, {
  String? editionSlug,
}) {
  final label = editionSlug ?? book.editionSlug;
  final hadithsRaw = data['hadiths'];
  if (hadithsRaw is! List) {
    throw FormatException(
      'Hadith edition $label (${book.slug}): missing hadiths array',
    );
  }

  final items = <HadithItem>[];
  var skippedEmpty = 0;
  var skippedInvalid = 0;

  for (var i = 0; i < hadithsRaw.length; i++) {
    final raw = hadithsRaw[i];
    try {
      if (raw is! Map) {
        skippedInvalid++;
        debugPrint(
          'Hadith $label [$i]: expected object, got ${raw.runtimeType}',
        );
        continue;
      }
      final m = Map<String, dynamic>.from(raw);
      final number = m['hadithnumber'];
      if (number is! num) {
        skippedInvalid++;
        debugPrint(
          'Hadith $label [$i]: missing/invalid hadithnumber=${m['hadithnumber']}',
        );
        continue;
      }
      final rawText = (m['text'] as String?)?.trim() ?? '';
      if (rawText.isEmpty) {
        skippedEmpty++;
        debugPrint(
          'Hadith $label ${book.slug} #$number: empty text, skipping',
        );
        continue;
      }

      final match = _narratorPattern.firstMatch(rawText);
      final narrator = match?.group(1)?.trim();
      final body = match != null ? match.group(2)!.trim() : rawText;

      items.add(
        HadithItem(
          id: syntheticHadithId(book.slug, number),
          title: '${book.name} #${formatHadithNumber(number)}',
          narrator: narrator,
          body: body,
          book: book.slug,
          bookName: book.name,
          hadithNumber: number,
        ),
      );
    } catch (e, st) {
      skippedInvalid++;
      debugPrint('Hadith $label [$i] parse failed: $e\n$st');
    }
  }

  debugPrint(
    'Hadith $label (${book.slug}): parsed ${items.length}/'
    '${hadithsRaw.length} (empty=$skippedEmpty invalid=$skippedInvalid)',
  );
  return items;
}
