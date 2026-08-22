import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/request_controller.dart';
import '../models/prayer_times.dart';

final prayerTimesServiceProvider = Provider((ref) {
  final rc = ref.watch(requestControllerProvider);
  return PrayerTimesService(requests: rc);
});

const _prayerOrder = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

/// Aladhan API (https://aladhan.com/prayer-times-api) — free, no API key.
class PrayerTimesService {
  final RequestController requests;

  PrayerTimesService({required this.requests});

  Future<DailyPrayerTimes> fetchTimings({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    final day = date ?? DateTime.now();
    final ts = (day.millisecondsSinceEpoch / 1000).round();
    final response = await requests.get(
      '/v1/timings/$ts',
      baseUrl: 'https://api.aladhan.com',
      query: {
        'latitude': latitude,
        'longitude': longitude,
        // Muslim World League — widely used global default.
        'method': 3,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final timings = data['timings'] as Map<String, dynamic>;
    final hijri = data['date']['hijri'] as Map<String, dynamic>;

    final prayers =
        _prayerOrder.map((name) {
          final raw = (timings[name] as String).split(' ').first;
          final parts = raw.split(':');
          final time = DateTime(
            day.year,
            day.month,
            day.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
          return PrayerTime(name: name, time: time);
        }).toList();

    return DailyPrayerTimes(
      date: day,
      prayers: prayers,
      hijriDay: int.parse(hijri['day'].toString()),
      hijriMonth: hijri['month']['number'] as int,
      hijriYear: int.parse(hijri['year'].toString()),
    );
  }

  Future<double> fetchQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    final response = await requests.get(
      '/v1/qibla/$latitude/$longitude',
      baseUrl: 'https://api.aladhan.com',
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['direction'] as num).toDouble();
  }
}
