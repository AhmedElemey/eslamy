import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/request_controller.dart';
import '../models/hijri_models.dart';

final hijriCalendarServiceProvider = Provider((ref) {
  final rc = ref.watch(requestControllerProvider);
  return HijriCalendarService(requests: rc);
});

String _dmy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

/// Aladhan API — same free, no-API-key host used for prayer times/qibla.
class HijriCalendarService {
  final RequestController requests;

  HijriCalendarService({required this.requests});

  static const _baseUrl = 'https://api.aladhan.com';

  Future<HijriDate> fetchTodayHijri() async {
    final response = await requests.get(
      '/v1/gToH/${_dmy(DateTime.now())}',
      baseUrl: _baseUrl,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return HijriDate.fromJson(data['hijri'] as Map<String, dynamic>);
  }

  Future<List<HijriCalendarDay>> fetchMonthCalendar({
    required int gregorianMonth,
    required int gregorianYear,
  }) async {
    final response = await requests.get(
      '/v1/gToHCalendar/$gregorianMonth/$gregorianYear',
      baseUrl: _baseUrl,
    );
    final days = response.data['data'] as List<dynamic>;
    return days.map((e) => HijriCalendarDay.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Gregorian date a given Hijri day/month/year falls on — used to turn a
  /// holiday's fixed Hijri date into a countdown against today.
  Future<DateTime> hijriToGregorian({
    required int day,
    required int month,
    required int year,
  }) async {
    final hijriDate =
        '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
    final response = await requests.get('/v1/hToG/$hijriDate', baseUrl: _baseUrl);
    final g = response.data['data']['gregorian'] as Map<String, dynamic>;
    return DateTime(
      int.parse(g['year'] as String),
      g['month']['number'] as int,
      int.parse(g['day'] as String),
    );
  }
}
