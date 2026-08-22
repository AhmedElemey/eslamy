import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/hijri_models.dart';
import '../../models/islamic_holiday.dart';
import '../../service/hijri_calendar_service.dart';

class UpcomingHoliday {
  final IslamicHoliday holiday;
  final DateTime date;
  final int daysRemaining;

  const UpcomingHoliday({
    required this.holiday,
    required this.date,
    required this.daysRemaining,
  });
}

class HijriCalendarState {
  final int viewMonth;
  final int viewYear;
  final List<HijriCalendarDay> monthDays;
  final HijriDate? todayHijri;
  final List<UpcomingHoliday> upcoming;
  final bool isLoading;
  final bool upcomingLoading;
  final String? error;

  const HijriCalendarState({
    required this.viewMonth,
    required this.viewYear,
    this.monthDays = const [],
    this.todayHijri,
    this.upcoming = const [],
    this.isLoading = false,
    this.upcomingLoading = true,
    this.error,
  });

  HijriCalendarState copyWith({
    int? viewMonth,
    int? viewYear,
    List<HijriCalendarDay>? monthDays,
    HijriDate? todayHijri,
    List<UpcomingHoliday>? upcoming,
    bool? isLoading,
    bool? upcomingLoading,
    String? error,
  }) {
    return HijriCalendarState(
      viewMonth: viewMonth ?? this.viewMonth,
      viewYear: viewYear ?? this.viewYear,
      monthDays: monthDays ?? this.monthDays,
      todayHijri: todayHijri ?? this.todayHijri,
      upcoming: upcoming ?? this.upcoming,
      isLoading: isLoading ?? this.isLoading,
      upcomingLoading: upcomingLoading ?? this.upcomingLoading,
      error: error,
    );
  }
}

class HijriCalendarNotifier extends StateNotifier<HijriCalendarState> {
  HijriCalendarNotifier(this._service)
    : super(
        HijriCalendarState(
          viewMonth: DateTime.now().month,
          viewYear: DateTime.now().year,
        ),
      ) {
    _loadMonth();
    _loadTodayAndUpcoming();
  }

  final HijriCalendarService _service;

  Future<void> _loadMonth() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final days = await _service.fetchMonthCalendar(
        gregorianMonth: state.viewMonth,
        gregorianYear: state.viewYear,
      );
      if (!mounted) return;
      state = state.copyWith(monthDays: days, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _loadTodayAndUpcoming() async {
    try {
      final today = await _service.fetchTodayHijri();
      if (!mounted) return;
      state = state.copyWith(todayHijri: today);

      final now = DateTime.now();
      final todayDateOnly = DateTime(now.year, now.month, now.day);
      final results = await Future.wait(
        islamicHolidays.map((h) async {
          final passedThisYear =
              h.hijriMonth < today.month ||
              (h.hijriMonth == today.month && h.hijriDay < today.day);
          final targetYear = passedThisYear ? today.year + 1 : today.year;
          final date = await _service.hijriToGregorian(
            day: h.hijriDay,
            month: h.hijriMonth,
            year: targetYear,
          );
          return UpcomingHoliday(
            holiday: h,
            date: date,
            daysRemaining: date.difference(todayDateOnly).inDays,
          );
        }),
      );
      if (!mounted) return;
      results.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
      state = state.copyWith(upcoming: results, upcomingLoading: false);
    } catch (_) {
      // Upcoming-holiday countdowns are a bonus — leave the list empty on
      // failure, but still clear the loading flag so the UI shows a genuine
      // empty state instead of "loading" forever.
      if (mounted) state = state.copyWith(upcomingLoading: false);
    }
  }

  void goToMonth(int delta) {
    var month = state.viewMonth + delta;
    var year = state.viewYear;
    if (month > 12) {
      month = 1;
      year++;
    } else if (month < 1) {
      month = 12;
      year--;
    }
    state = state.copyWith(viewMonth: month, viewYear: year);
    _loadMonth();
  }
}

final hijriCalendarProvider =
    StateNotifierProvider<HijriCalendarNotifier, HijriCalendarState>((ref) {
      return HijriCalendarNotifier(ref.watch(hijriCalendarServiceProvider));
    });
