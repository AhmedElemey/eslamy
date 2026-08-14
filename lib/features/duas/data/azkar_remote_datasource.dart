import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/request_controller.dart';
import 'models/azkar_models.dart';

final azkarRemoteDataSourceProvider = Provider((ref) {
  final rc = ref.watch(requestControllerProvider);
  return AzkarRemoteDataSource(requests: rc);
});

/// Live refresh source: UmmahAPI's free, no-API-key duas endpoint. Same
/// response shape as the bundled asset seed, so a successful fetch can
/// directly replace the cache.
class AzkarRemoteDataSource {
  final RequestController requests;

  AzkarRemoteDataSource({required this.requests});

  static const _baseUrl = 'https://www.ummahapi.com';

  Future<AzkarDataset> fetch() async {
    final response = await requests.get('/api/duas', baseUrl: _baseUrl);
    return AzkarDataset.fromJson(response.data as Map<String, dynamic>);
  }
}
