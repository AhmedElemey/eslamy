import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eslamy/core/network/request_controller.dart';
import 'package:eslamy/features/prayer_times/service/prayer_times_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Responds with a fixed status/body for every request, without touching
/// the network, and records the [RequestOptions] each call was made with so
/// tests can assert on the URL path and query params built by the service.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.responses);

  final List<ResponseBody Function()> responses;
  int callCount = 0;
  final List<RequestOptions> capturedRequests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequests.add(options);
    final response = responses[callCount.clamp(0, responses.length - 1)]();
    callCount++;
    return response;
  }

  @override
  void close({bool force = false}) {}
}

class _ServiceWithAdapter {
  _ServiceWithAdapter(this.service, this.adapter);

  final PrayerTimesService service;
  final _StubAdapter adapter;
}

_ServiceWithAdapter _serviceWith(List<ResponseBody Function()> responses) {
  final adapter = _StubAdapter(responses);
  final dio = Dio()..httpClientAdapter = adapter;
  return _ServiceWithAdapter(
    PrayerTimesService(requests: RequestController(dio)),
    adapter,
  );
}

ResponseBody _jsonResponse(Map<String, dynamic> body) => ResponseBody.fromString(
  jsonEncode(body),
  200,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

Map<String, dynamic> _timingsPayload({
  Map<String, String>? timings,
  Object hijriDay = '17',
  int hijriMonthNumber = 2,
  Object hijriYear = '1447',
}) => {
  'data': {
    'timings':
        timings ??
        {
          'Fajr': '04:32 (EET)',
          'Sunrise': '05:58 (EET)',
          'Dhuhr': '11:52 (EET)',
          'Asr': '15:20 (EET)',
          'Maghrib': '17:45 (EET)',
          'Isha': '19:10 (EET)',
        },
    'date': {
      'hijri': {
        'day': hijriDay,
        'month': {'number': hijriMonthNumber},
        'year': hijriYear,
      },
    },
  },
};

void main() {
  group('PrayerTimesService.fetchTimings', () {
    test(
      'hits /v1/timings/<unix-seconds> with latitude/longitude/method query params',
      () async {
        final harness = _serviceWith([() => _jsonResponse(_timingsPayload())]);
        final date = DateTime(2026, 9, 3, 12);

        await harness.service.fetchTimings(
          latitude: 30.0444,
          longitude: 31.2357,
          date: date,
        );

        final options = harness.adapter.capturedRequests.single;
        final expectedTs = (date.millisecondsSinceEpoch / 1000).round();
        expect(options.uri.host, 'api.aladhan.com');
        expect(options.uri.path, '/v1/timings/$expectedTs');
        expect(options.queryParameters['latitude'], 30.0444);
        expect(options.queryParameters['longitude'], 31.2357);
        expect(options.queryParameters['method'], 3);
      },
    );

    test(
      'parses all 6 prayers in order, stripping the trailing timezone annotation',
      () async {
        final harness = _serviceWith([() => _jsonResponse(_timingsPayload())]);
        final date = DateTime(2026, 9, 3);

        final result = await harness.service.fetchTimings(
          latitude: 30.0444,
          longitude: 31.2357,
          date: date,
        );

        expect(result.date, date);
        expect(result.prayers, hasLength(6));
        expect(
          result.prayers.map((p) => p.name),
          ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'],
        );
        expect(result.prayers[0].time, DateTime(2026, 9, 3, 4, 32));
        expect(result.prayers[1].time, DateTime(2026, 9, 3, 5, 58));
        expect(result.prayers[2].time, DateTime(2026, 9, 3, 11, 52));
        expect(result.prayers[3].time, DateTime(2026, 9, 3, 15, 20));
        expect(result.prayers[4].time, DateTime(2026, 9, 3, 17, 45));
        expect(result.prayers[5].time, DateTime(2026, 9, 3, 19, 10));

        expect(result.hijriDay, 17);
        expect(result.hijriMonth, 2);
        expect(result.hijriYear, 1447);
      },
    );

    test('parses hijri day/year given as JSON numbers, not just strings', () async {
      final harness = _serviceWith([
        () => _jsonResponse(
          _timingsPayload(hijriDay: 17, hijriYear: 1447),
        ),
      ]);

      final result = await harness.service.fetchTimings(
        latitude: 30.0444,
        longitude: 31.2357,
        date: DateTime(2026, 9, 3),
      );

      expect(result.hijriDay, 17);
      expect(result.hijriYear, 1447);
    });
  });

  group('PrayerTimesService.fetchQiblaDirection', () {
    test('hits /v1/qibla/<lat>/<lng> and parses an integer-valued direction', () async {
      final harness = _serviceWith([
        () => _jsonResponse({
          'data': {'direction': 135},
        }),
      ]);

      final direction = await harness.service.fetchQiblaDirection(
        latitude: 30.0444,
        longitude: 31.2357,
      );

      expect(direction, 135.0);
      expect(direction, isA<double>());

      final uri = harness.adapter.capturedRequests.single.uri;
      expect(uri.path, '/v1/qibla/30.0444/31.2357');
    });

    test('parses a fractional direction', () async {
      final harness = _serviceWith([
        () => _jsonResponse({
          'data': {'direction': 134.567},
        }),
      ]);

      final direction = await harness.service.fetchQiblaDirection(
        latitude: 30.0444,
        longitude: 31.2357,
      );

      expect(direction, 134.567);
    });
  });
}
