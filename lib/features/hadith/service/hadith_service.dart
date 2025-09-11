import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../hadith_constants.dart';
import '../models/hadith.dart';

final hadithServiceProvider = Provider((ref) {
  final dioClient = ref.watch(dioProvider);
  return HadithService(client: dioClient);
});

class HadithService {
  final Dio client;

  HadithService({required this.client});

  Future<HadithPage> fetchHadiths({required int page, int limit = 20}) async {
    try {
      final response = await client.get('/hadiths/', queryParameters: {
        'apiKey': hadithApiKey,
        'page': page,
        'per_page': limit,
      });

      if (response.statusCode != 200) {
        return Future.error("Something went wrong");
      }

      final data = response.data as Map<String, dynamic>;

      // API may return one of:
      // { hadiths: { data: [...], current_page, last_page } }
      // { hadiths: [...], meta: { current_page, last_page } }
      // { data: [...], meta: {...} }
      List<dynamic> hadithsRaw = const [];
      int currentPageFromApi = page;
      int lastPageFromApi = page;

      final hadithsValue = data['hadiths'];
      if (hadithsValue is List) {
        hadithsRaw = hadithsValue;
      } else if (hadithsValue is Map<String, dynamic>) {
        hadithsRaw = (hadithsValue['data'] ?? hadithsValue['items'] ?? []) as List<dynamic>;
        currentPageFromApi = int.tryParse('${hadithsValue['current_page'] ?? hadithsValue['currentPage'] ?? page}') ?? page;
        lastPageFromApi = int.tryParse('${hadithsValue['last_page'] ?? hadithsValue['lastPage'] ?? currentPageFromApi}') ?? currentPageFromApi;
      } else {
        hadithsRaw = (data['data'] ?? data['items'] ?? []) as List<dynamic>;
      }

      final items = hadithsRaw.map((e) {
        final m = e as Map<String, dynamic>;
        return HadithItem(
          id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}') ?? 0,
          title: '${m['title'] ?? m['hadith'] ?? m['slug'] ?? ''}',
          narrator: m['narrator']?.toString(),
          body: m['body']?.toString() ?? m['arabic']?.toString() ?? m['hadithArabic']?.toString(),
        );
      }).toList();

      // Meta fallback if not read above
      if (currentPageFromApi == page && lastPageFromApi == page) {
        final meta = (data['meta'] ?? data['pagination'] ?? {}) as Map<String, dynamic>;
        currentPageFromApi = int.tryParse('${meta['current_page'] ?? meta['currentPage'] ?? page}') ?? page;
        lastPageFromApi = int.tryParse('${meta['last_page'] ?? meta['lastPage'] ?? currentPageFromApi}') ?? currentPageFromApi;
      }

      return HadithPage(items: items, currentPage: currentPageFromApi, hasMore: currentPageFromApi < lastPageFromApi);
    } catch (exception) {
      if (exception.runtimeType == DioException) {
        return Future.error("Something went wrong");
      }
      rethrow;
    }
  }
}