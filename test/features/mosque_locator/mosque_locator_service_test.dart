import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eslamy/core/network/request_controller.dart';
import 'package:eslamy/features/mosque_locator/service/mosque_locator_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Responds with a fixed status/body for every request, without touching
/// the network — lets [MosqueLocatorService] be exercised end-to-end
/// (including its caching side effect) in a unit test.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.responses);

  /// One entry consumed per call, in order — lets a test simulate e.g.
  /// "first two calls time out, third succeeds".
  final List<ResponseBody Function()> responses;
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = responses[callCount.clamp(0, responses.length - 1)]();
    callCount++;
    return response;
  }

  @override
  void close({bool force = false}) {}
}

MosqueLocatorService _serviceWith(List<ResponseBody Function()> responses) {
  final dio = Dio()..httpClientAdapter = _StubAdapter(responses);
  return MosqueLocatorService(requests: RequestController(dio));
}

ResponseBody _okOverpassResponse() => ResponseBody.fromString(
  jsonEncode({
    'elements': [
      {
        'type': 'node',
        'id': 1,
        'lat': 30.05,
        'lon': 31.24,
        'tags': {
          'amenity': 'place_of_worship',
          'religion': 'muslim',
          'name': 'Test Mosque',
        },
      },
    ],
  }),
  200,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

ResponseBody _serverErrorResponse() =>
    ResponseBody.fromString('Server Error', 504);

void main() {
  group('MosqueLocatorService caching', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getCachedNearby returns null when nothing has been cached', () async {
      final service = _serviceWith([_okOverpassResponse]);
      expect(await service.getCachedNearby(), isNull);
    });

    test(
      'a successful findNearby caches its result for later retrieval',
      () async {
        final service = _serviceWith([_okOverpassResponse]);

        final live = await service.findNearby(
          latitude: 30.0444,
          longitude: 31.2357,
        );
        expect(live, hasLength(1));
        expect(live.single.name, 'Test Mosque');

        final cached = await service.getCachedNearby();
        expect(cached, isNotNull);
        expect(cached!.mosques, hasLength(1));
        expect(cached.mosques.single.name, 'Test Mosque');
        expect(cached.mosques.single.id, live.single.id);
        expect(
          cached.cachedAt.difference(DateTime.now()).abs(),
          lessThan(const Duration(seconds: 5)),
        );
      },
    );

    test(
      'a failed findNearby leaves an earlier cached result retrievable',
      () async {
        // First call succeeds and populates the cache...
        final warmedUp = _serviceWith([_okOverpassResponse]);
        await warmedUp.findNearby(latitude: 30.0444, longitude: 31.2357);

        // ...a later service instance (e.g. after the app restarts) hitting a
        // wall of 504s still finds that cached result on disk.
        final failingService = _serviceWith(
          List.filled(3, _serverErrorResponse),
        );
        await expectLater(
          failingService.findNearby(latitude: 30.0444, longitude: 31.2357),
          throwsA(anything),
        );

        final cached = await failingService.getCachedNearby();
        expect(cached, isNotNull);
        expect(cached!.mosques.single.name, 'Test Mosque');
      },
    );

    test('getCachedNearby ignores a result from a different city', () async {
      final service = _serviceWith([_okOverpassResponse]);
      await service.findNearby(latitude: 30.0444, longitude: 31.2357);

      final nearby = await service.getCachedNearby(
        latitude: 30.045,
        longitude: 31.236,
      );
      expect(nearby, isNotNull);

      final london = await service.getCachedNearby(
        latitude: 51.5074,
        longitude: -0.1278,
      );
      expect(london, isNull);
    });
  });

  group('parseOverpassResponse', () {
    test('maps a realistic Overpass response into Mosque objects', () {
      // Shape taken from https://wiki.openstreetmap.org/wiki/Overpass_API
      // for a `node/way ["amenity"="place_of_worship"] out center;` query.
      final data = {
        'elements': [
          {
            // A way (building outline) — only gets coordinates via `center`.
            'type': 'way',
            'id': 111,
            'center': {'lat': 30.0544, 'lon': 31.2457},
            'tags': {
              'amenity': 'place_of_worship',
              'religion': 'muslim',
              'name': 'Al Masaay Mosque',
              'addr:street': 'Saad Zaghloul St',
              'addr:city': 'Madinet Qewaisna',
            },
          },
          {
            // A node — direct lat/lon.
            'type': 'node',
            'id': 222,
            'lat': 30.0454,
            'lon': 31.2367,
            'tags': {
              'amenity': 'place_of_worship',
              'religion': 'muslim',
              'name': 'Fouad Mosque',
              'addr:housenumber': '12',
              'addr:street': 'El Gish St',
            },
          },
          {
            // Untagged / no name — a common case for small local musallas.
            'type': 'node',
            'id': 333,
            'lat': 30.0446,
            'lon': 31.2360,
            'tags': {'amenity': 'place_of_worship', 'religion': 'muslim'},
          },
        ],
      };

      final mosques = parseOverpassResponse(
        data,
        originLatitude: 30.0444,
        originLongitude: 31.2357,
      );

      expect(mosques, hasLength(3));

      // Sorted nearest-first, regardless of input order.
      expect(mosques.map((m) => m.id), ['node/333', 'node/222', 'way/111']);
      expect(mosques[0].distanceMeters, lessThan(mosques[1].distanceMeters));
      expect(mosques[1].distanceMeters, lessThan(mosques[2].distanceMeters));

      final near = mosques.firstWhere((m) => m.id == 'node/222');
      expect(near.name, 'Fouad Mosque');
      expect(near.address, '12 El Gish St');

      final unnamed = mosques.firstWhere((m) => m.id == 'node/333');
      expect(unnamed.name, isNull);
      expect(unnamed.address, isNull);

      final way = mosques.firstWhere((m) => m.id == 'way/111');
      expect(way.latitude, 30.0544);
      expect(way.longitude, 31.2457);
      expect(way.address, 'Saad Zaghloul St, Madinet Qewaisna');
    });

    test('skips elements with no usable coordinates', () {
      final mosques = parseOverpassResponse(
        {
          'elements': [
            {
              'type': 'relation',
              'id': 1,
              'tags': {'name': 'No center given'},
            },
          ],
        },
        originLatitude: 30.0,
        originLongitude: 31.0,
      );

      expect(mosques, isEmpty);
    });

    test('returns an empty list when the response has no elements key', () {
      final mosques = parseOverpassResponse(
        <String, dynamic>{},
        originLatitude: 30.0444,
        originLongitude: 31.2357,
      );

      expect(mosques, isEmpty);
    });

    test('deduplicates the same OSM feature listed twice', () {
      final mosques = parseOverpassResponse(
        {
          'elements': [
            {
              'type': 'node',
              'id': 1,
              'lat': 30.05,
              'lon': 31.24,
              'tags': {'name': 'A'},
            },
            {
              'type': 'node',
              'id': 1,
              'lat': 30.05,
              'lon': 31.24,
              'tags': {'name': 'A'},
            },
          ],
        },
        originLatitude: 30.0444,
        originLongitude: 31.2357,
      );
      expect(mosques, hasLength(1));
    });

    test('directionsUri encodes the destination for Google Maps', () {
      final mosques = parseOverpassResponse(
        {
          'elements': [
            {
              'type': 'node',
              'id': 999,
              'lat': 30.1,
              'lon': 31.2,
              'tags': {'name': 'Test Mosque'},
            },
          ],
        },
        originLatitude: 30.0,
        originLongitude: 31.0,
      );

      final uri = mosques.single.directionsUri;
      expect(uri.scheme, 'https');
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters['destination'], '30.1,31.2');
    });
  });
}
