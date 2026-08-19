import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/request_controller.dart';
import '../models/mosque.dart';

final mosqueLocatorServiceProvider = Provider((ref) {
  final rc = ref.watch(requestControllerProvider);
  return MosqueLocatorService(requests: rc);
});

/// Nearby mosques via OpenStreetMap's free Overpass API — no key, no
/// billing account, no signup.
/// https://wiki.openstreetmap.org/wiki/Overpass_API
class MosqueLocatorService {
  final RequestController requests;

  MosqueLocatorService({required this.requests});

  /// Community Overpass mirrors turned out to be far less reliable than the
  /// official instance once the actual root cause (see [_userAgent]) was
  /// fixed: overpass.kumi.systems took 83s and overpass.private.coffee
  /// hung past 2 minutes in testing, vs. ~3s from overpass-api.de. Routing
  /// to them made the worst case dramatically worse, not better — so
  /// instead of failing over to different (unpredictable) infrastructure,
  /// retry the fast official one with backoff for transient errors.
  static const _baseUrl = 'https://overpass-api.de';

  /// Overpass's anti-bot filter rejects Dio's default "Dart/x.y (dart:io)"
  /// User-Agent with a 406. Overpass's own usage policy also expects a
  /// descriptive User-Agent identifying the calling app. See
  /// https://wiki.openstreetmap.org/wiki/Overpass_API#Introduction
  static const _userAgent = 'Eslamy/1.0 (Flutter; Islamic prayer companion app)';

  static const _maxAttempts = 3;

  /// Server-side query budget — kept comfortably under the client-side
  /// timeout below so a response that's about to arrive isn't cut off.
  static const _queryTimeoutSeconds = 20;

  /// overpass-api.de is a single free, unauthenticated, community-run
  /// instance with no SLA — it does go down (observed live 504s during
  /// testing). Cache the last successful result locally so a transient
  /// outage degrades to "possibly stale list" instead of "no mosques at
  /// all". See [getCachedNearby] / [_cacheResult].
  static const _cacheKey = 'mosque_locator_last_result_v1';

  Future<List<Mosque>> findNearby({
    required double latitude,
    required double longitude,
    List<int> radiusMetersAttempts = const [5000, 15000, 30000],
  }) async {
    List<Mosque> mosques = const [];
    for (final radiusMeters in radiusMetersAttempts) {
      mosques = await _queryAround(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );
      if (mosques.isNotEmpty) {
        debugPrint(
          'Mosque locator: ${mosques.length} results within ${radiusMeters}m '
          'of $latitude,$longitude',
        );
        break;
      }
      debugPrint(
        'Mosque locator: no results within ${radiusMeters}m of '
        '$latitude,$longitude; expanding radius',
      );
    }
    if (mosques.isNotEmpty) {
      await _cacheResult(latitude, longitude, mosques);
    }
    return mosques;
  }

  Future<List<Mosque>> _queryAround({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    // `building=mosque` catches OSM features that omit religion=muslim.
    final query = '''
[out:json][timeout:$_queryTimeoutSeconds];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  node["building"="mosque"](around:$radiusMeters,$latitude,$longitude);
  way["building"="mosque"](around:$radiusMeters,$latitude,$longitude);
);
out center;
''';

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await requests.get(
          '/api/interpreter',
          baseUrl: _baseUrl,
          query: {'data': query},
          options: Options(
            headers: {'User-Agent': _userAgent},
            sendTimeout: const Duration(seconds: _queryTimeoutSeconds + 8),
            receiveTimeout: const Duration(seconds: _queryTimeoutSeconds + 8),
          ),
        );

        return parseOverpassResponse(
          response.data as Map<String, dynamic>,
          originLatitude: latitude,
          originLongitude: longitude,
        );
      } catch (e) {
        final isLastAttempt = attempt == _maxAttempts;
        if (isLastAttempt || !_isTransient(e)) rethrow;
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw StateError('unreachable');
  }

  /// [RequestController.get] already unwraps [DioException] into a plain
  /// friendly [String] (see [DioExceptionX.errorMsg] in dio_provider.dart)
  /// before it reaches callers, so transience is judged from that message
  /// rather than a DioException type/status check.
  bool _isTransient(Object error) {
    final message = error.toString();
    return message.contains('timeout') ||
        message.contains('Rate limit exceeded') ||
        message.contains('[502]') ||
        message.contains('[503]') ||
        message.contains('[504]');
  }

  Future<void> _cacheResult(
    double latitude,
    double longitude,
    List<Mosque> mosques,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'latitude': latitude,
      'longitude': longitude,
      'cachedAt': DateTime.now().toIso8601String(),
      'mosques': mosques.map((m) => m.toJson()).toList(),
    });
    await prefs.setString(_cacheKey, payload);
  }

  /// Last successful fetch, only if it was taken near [latitude]/[longitude]
  /// and is not older than [maxAge]. Distances are recomputed for the
  /// current origin so a cache hit is still sorted nearest-first.
  Future<CachedMosqueResult?> getCachedNearby({
    double? latitude,
    double? longitude,
    double maxOriginDriftMeters = 2000,
    Duration maxAge = const Duration(hours: 24),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(decoded['cachedAt'] as String);
      if (DateTime.now().difference(cachedAt) > maxAge) {
        debugPrint('Mosque locator: cache expired at $cachedAt');
        return null;
      }

      final originLat = (decoded['latitude'] as num?)?.toDouble();
      final originLng = (decoded['longitude'] as num?)?.toDouble();
      if (latitude != null &&
          longitude != null &&
          originLat != null &&
          originLng != null) {
        final drift = Geolocator.distanceBetween(
          latitude,
          longitude,
          originLat,
          originLng,
        );
        if (drift > maxOriginDriftMeters) {
          debugPrint(
            'Mosque locator: cache origin drift ${drift.round()}m > '
            '${maxOriginDriftMeters.round()}m — ignoring stale city',
          );
          return null;
        }
      }

      var mosques = (decoded['mosques'] as List)
          .map((m) => Mosque.fromJson(m as Map<String, dynamic>))
          .toList();
      if (latitude != null && longitude != null) {
        mosques = mosques
            .map(
              (m) => Mosque(
                id: m.id,
                name: m.name,
                address: m.address,
                latitude: m.latitude,
                longitude: m.longitude,
                distanceMeters: Geolocator.distanceBetween(
                  latitude,
                  longitude,
                  m.latitude,
                  m.longitude,
                ),
              ),
            )
            .toList()
          ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      }
      return CachedMosqueResult(
        mosques: mosques,
        cachedAt: cachedAt,
        latitude: originLat,
        longitude: originLng,
      );
    } catch (e, st) {
      debugPrint('Mosque locator: corrupt cache: $e\n$st');
      return null;
    }
  }
}

class CachedMosqueResult {
  final List<Mosque> mosques;
  final DateTime cachedAt;
  final double? latitude;
  final double? longitude;

  const CachedMosqueResult({
    required this.mosques,
    required this.cachedAt,
    this.latitude,
    this.longitude,
  });
}

/// Maps a raw Overpass `[out:json]` response into [Mosque]s, sorted
/// nearest-first. Pulled out of [MosqueLocatorService] so the mapping logic
/// can be unit-tested against a fixed JSON fixture without network access.
List<Mosque> parseOverpassResponse(
  Map<String, dynamic> data, {
  required double originLatitude,
  required double originLongitude,
}) {
  final elements = data['elements'] as List?;
  if (elements == null) return const [];

  final seen = <String>{};
  final mosques =
      elements
          .map((raw) {
            final el = raw as Map<String, dynamic>;
            final tags = (el['tags'] as Map<String, dynamic>?) ?? const {};

            // Nodes carry lat/lon directly; ways/relations only get a
            // center point when the query uses `out center;`.
            var lat = (el['lat'] as num?)?.toDouble();
            var lng = (el['lon'] as num?)?.toDouble();
            if (lat == null || lng == null) {
              final center = el['center'] as Map<String, dynamic>?;
              lat = (center?['lat'] as num?)?.toDouble();
              lng = (center?['lon'] as num?)?.toDouble();
            }
            if (lat == null || lng == null) return null;

            final id = '${el['type']}/${el['id']}';
            if (!seen.add(id)) return null;

            final name = tags['name'] as String?;

            return Mosque(
              id: id,
              name: (name != null && name.trim().isNotEmpty) ? name : null,
              address: _formatAddress(tags),
              latitude: lat,
              longitude: lng,
              distanceMeters: Geolocator.distanceBetween(
                originLatitude,
                originLongitude,
                lat,
                lng,
              ),
            );
          })
          .whereType<Mosque>()
          .toList()
        ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

  return mosques;
}

String? _formatAddress(Map<String, dynamic> tags) {
  final houseAndStreet =
      [tags['addr:housenumber'], tags['addr:street']]
          .whereType<String>()
          .where((s) => s.trim().isNotEmpty)
          .join(' ');
  final city = tags['addr:city'] as String?;

  final parts =
      [
        houseAndStreet,
        if (city != null && city.trim().isNotEmpty) city,
      ].where((s) => s.isNotEmpty).toList();

  if (parts.isEmpty) return null;
  return parts.join(', ');
}
