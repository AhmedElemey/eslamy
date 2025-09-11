import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>(
  (ref) {
    final platform = Platform.isAndroid ? 'Android' : 'iOS';
    
    return Dio(BaseOptions(
      baseUrl: 'https://www.hadithapi.com/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept-Language': 'en-us',
        'Platform': platform,
      },
    ))
      ..interceptors.addAll([
        RateLimitInterceptor(),
      ]);
  },
);

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
  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 429) {
      throw DioException(
        requestOptions: err.requestOptions,
        type: DioExceptionType.badResponse,
        error: 'Rate limit exceeded, try again later',
      );
    } else {
      handler.next(err);
    }
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