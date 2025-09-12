import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allow features to append custom interceptors by overriding this provider
final extraInterceptorsProvider = Provider<List<Interceptor>>(
  (ref) => const [],
);

/// Simple connectivity gate. Cancels request if DNS lookup fails quickly.
class StopIfNoInternetInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 2));
      if (result.isEmpty || result.first.rawAddress.isEmpty) {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: 'No internet connection',
          ),
        );
      }
    } on SocketException {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'No internet connection',
        ),
      );
    } on TimeoutException {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'No internet connection',
        ),
      );
    }
    handler.next(options);
  }
}

/// Session handling placeholder: passes through by default
class SessionExpiredInterceptor extends Interceptor {}

/// Lightweight logger in debug mode
class SimpleLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[DIO][REQ] ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[DIO][RES] ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[DIO][ERR] ${err.type} ${err.requestOptions.uri}: ${err.message}');
    }
    handler.next(err);
  }
}
