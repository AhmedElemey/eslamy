import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_provider.dart';

/// A thin controller over Dio centralizing request/response/error handling.
final requestControllerProvider = Provider<RequestController>((ref) {
  final dio = ref.watch(dioProvider);
  return RequestController(dio);
});

class RequestController {
  final Dio _dio;
  RequestController(this._dio);

  Future<Response<T>> get<T>(
    String path, {
    String? baseUrl,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final effectiveOptions = (options ?? Options()).copyWith();
      final uri = _composeUrl(baseUrl, path);
      final startedAt = DateTime.now();
      if (kDebugMode) {
        debugPrint('[GET] $uri');
        if (query != null && query.isNotEmpty) {
          debugPrint('[GET] query: $query');
        }
      }
      final res = await _dio.get<T>(
        uri,
        queryParameters: query,
        options: effectiveOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (kDebugMode) {
        final ms = DateTime.now().difference(startedAt).inMilliseconds;
        debugPrint('[GET] ${res.statusCode} $uri (${ms}ms)');
      }
      return res;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[GET][ERR] ${e.requestOptions.uri} ${e.type} ${e.message}');
      }
      return Future.error(e.errorMsg);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    String? baseUrl,
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final effectiveOptions = (options ?? Options()).copyWith();
      final uri = _composeUrl(baseUrl, path);
      final startedAt = DateTime.now();
      if (kDebugMode) {
        debugPrint('[POST] $uri');
        if (query != null && query.isNotEmpty) {
          debugPrint('[POST] query: $query');
        }
        if (data != null) {
          debugPrint(
            '[POST] body: ${data is String ? data : (data is Map || data is List ? data : data.toString())}',
          );
        }
      }
      final res = await _dio.post<T>(
        uri,
        data: data,
        queryParameters: query,
        options: effectiveOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      if (kDebugMode) {
        final ms = DateTime.now().difference(startedAt).inMilliseconds;
        debugPrint('[POST] ${res.statusCode} $uri (${ms}ms)');
      }
      return res;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[POST][ERR] ${e.requestOptions.uri} ${e.type} ${e.message}',
        );
      }
      return Future.error(e.errorMsg);
    }
  }

  String _composeUrl(String? baseUrl, String path) {
    if (baseUrl == null || baseUrl.isEmpty) return path;
    if (path.startsWith('http')) return path;
    final normalizedBase =
        baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }
}
