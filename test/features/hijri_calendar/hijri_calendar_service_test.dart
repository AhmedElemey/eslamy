import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eslamy/core/network/request_controller.dart';
import 'package:eslamy/features/hijri_calendar/models/hijri_models.dart';
import 'package:eslamy/features/hijri_calendar/service/hijri_calendar_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Responds with a fixed status/body for every request, without touching
/// the network, and records the [RequestOptions] each call was made with so
/// tests can assert on the URL path built by the service.
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

  final HijriCalendarService service;
  final _StubAdapter adapter;
}

_ServiceWithAdapter _serviceWith(List<ResponseBody Function()> responses) {
  final adapter = _StubAdapter(responses);
  final dio = Dio()..httpClientAdapter = adapter;
  return _ServiceWithAdapter(
    HijriCalendarService(requests: RequestController(dio)),
    adapter,
  );
}

ResponseBody _jsonResponse(Map<String, dynamic> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

String _dmy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

void main() {
  group('HijriCalendarService.fetchTodayHijri', () {
    test('hits /v1/gToH/<today DD-MM-YYYY> and parses data.hijri', () async {
      final harness = _serviceWith([
        () => _jsonResponse({
          'data': {
            'hijri': {
              'day': '10',
              'month': {'number': 3, 'en': 'Rabi al-Thani'},
              'year': '1447',
            },
          },
        }),
      ]);

      final result = await harness.service.fetchTodayHijri();

      expect(result.day, 10);
      expect(result.month, 3);
      expect(result.monthName, 'Rabi al-Thani');
      expect(result.year, 1447);

      final uri = harness.adapter.capturedRequests.single.uri;
      expect(uri.host, 'api.aladhan.com');
      expect(uri.path, '/v1/gToH/${_dmy(DateTime.now())}');
    });
  });

  group('HijriCalendarService.fetchMonthCalendar', () {
    test(
      'hits /v1/gToHCalendar/<month>/<year> and parses each day in order',
      () async {
        final harness = _serviceWith([
          () => _jsonResponse({
            'data': [
              {
                'gregorian': {
                  'day': '01',
                  'month': {'number': 9},
                  'year': '2026',
                },
                'hijri': {
                  'day': '19',
                  'month': {'number': 2, 'en': 'Safar'},
                  'year': '1447',
                },
              },
              {
                'gregorian': {
                  'day': '02',
                  'month': {'number': 9},
                  'year': '2026',
                },
                'hijri': {
                  'day': '20',
                  'month': {'number': 2, 'en': 'Safar'},
                  'year': '1447',
                },
              },
              {
                'gregorian': {
                  'day': '03',
                  'month': {'number': 9},
                  'year': '2026',
                },
                'hijri': {
                  'day': '21',
                  'month': {'number': 2, 'en': 'Safar'},
                  'year': '1447',
                },
              },
            ],
          }),
        ]);

        final result = await harness.service.fetchMonthCalendar(
          gregorianMonth: 9,
          gregorianYear: 2026,
        );

        expect(result, hasLength(3));
        expect(result.map((d) => d.gregorian), [
          DateTime(2026, 9, 1),
          DateTime(2026, 9, 2),
          DateTime(2026, 9, 3),
        ]);
        expect(result.map((d) => d.hijriDay), [19, 20, 21]);
        expect(result.every((d) => d.hijriMonth == 2), isTrue);
        expect(result.every((d) => d.hijriMonthName == 'Safar'), isTrue);
        expect(result.every((d) => d.hijriYear == 1447), isTrue);

        final uri = harness.adapter.capturedRequests.single.uri;
        expect(uri.path, '/v1/gToHCalendar/9/2026');
      },
    );
  });

  group('HijriCalendarService.hijriToGregorian', () {
    test(
      'hits /v1/hToG/<DD-MM-YYYY hijri> and parses data.gregorian into a DateTime',
      () async {
        final harness = _serviceWith([
          () => _jsonResponse({
            'data': {
              'gregorian': {
                'day': '15',
                'month': {'number': 3},
                'year': '2027',
              },
            },
          }),
        ]);

        final result = await harness.service.hijriToGregorian(
          day: 1,
          month: 9,
          year: 1449,
        );

        expect(result, DateTime(2027, 3, 15));

        final uri = harness.adapter.capturedRequests.single.uri;
        expect(uri.path, '/v1/hToG/01-09-1449');
      },
    );
  });

  group('model fromJson', () {
    test('HijriDate.fromJson reads day/year as ints from string fields', () {
      final date = HijriDate.fromJson({
        'day': '05',
        'month': {'number': 12, 'en': 'Dhu al-Hijjah'},
        'year': '1446',
      });

      expect(date.day, 5);
      expect(date.month, 12);
      expect(date.monthName, 'Dhu al-Hijjah');
      expect(date.year, 1446);
    });

    test(
      'HijriCalendarDay.fromJson builds the gregorian DateTime from string parts',
      () {
        final day = HijriCalendarDay.fromJson({
          'gregorian': {
            'day': '07',
            'month': {'number': 1},
            'year': '2026',
          },
          'hijri': {
            'day': '25',
            'month': {'number': 6, 'en': 'Jumada al-Thani'},
            'year': '1447',
          },
        });

        expect(day.gregorian, DateTime(2026, 1, 7));
        expect(day.hijriDay, 25);
        expect(day.hijriMonth, 6);
        expect(day.hijriMonthName, 'Jumada al-Thani');
        expect(day.hijriYear, 1447);
      },
    );
  });
}
