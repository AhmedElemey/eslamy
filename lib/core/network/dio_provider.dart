import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'interceptors.dart';

final dioProvider = Provider<Dio>((ref) {
  final platform = Platform.isAndroid ? 'Android' : 'iOS';

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'en-us',
        'Platform': platform,
      },
    ),
  );
  dio.interceptors.addAll([
    SessionExpiredInterceptor(),
    RateLimitInterceptor(dio),
    SimpleLogInterceptor(),
    ...ref.read(extraInterceptorsProvider),
  ]);
  return dio;
});

extension DioExceptionX on DioException {
  String get errorMsg {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout, try again later';
      case DioExceptionType.sendTimeout:
        return 'Request timeout, try again later';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout, try again later';
      case DioExceptionType.badResponse:
        if (response == null && error is String) return error as String;
        switch (response?.statusCode) {
          case 401:
            return '[${response?.statusCode}] Unauthorized';
          case 403:
            return '[${response?.statusCode}] Forbidden';
          case 404:
            return '[${response?.statusCode}] Not found';
          case 500:
            return '[${response?.statusCode}] Internal server error';
          case 429:
            return 'Rate limit exceeded, try again later';
          default:
            return '[${response?.statusCode}] Server Error';
        }
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'An unknown error occurred';
    }
  }
}

class RateLimitInterceptor implements Interceptor {
  RateLimitInterceptor(this._dio);

  final Dio _dio;

  // aladhan.com (prayer times/qibla) is a shared, keyless free API — under
  // real multi-user load (unlike solo dev testing) it 429s far more often,
  // and a 429 while fetching Adhan alert times used to fail scheduling
  // outright with no retry, silently leaving zero Adhan alerts scheduled.
  // Retry a couple of times with backoff before giving up.
  static const _retryDelays = [Duration(seconds: 2), Duration(seconds: 5)];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 429) {
      handler.next(err);
      return;
    }
    for (final delay in _retryDelays) {
      await Future.delayed(delay);
      try {
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } on DioException catch (retryErr) {
        if (retryErr.response?.statusCode != 429) {
          handler.next(retryErr);
          return;
        }
        // Still rate limited — fall through and try the next delay.
      }
    }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        type: DioExceptionType.badResponse,
        error: 'Rate limit exceeded, try again later',
      ),
    );
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}
