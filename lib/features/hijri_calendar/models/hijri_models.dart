class HijriDate {
  final int day;
  final int month;
  final String monthName;
  final int year;

  const HijriDate({
    required this.day,
    required this.month,
    required this.monthName,
    required this.year,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) => HijriDate(
    day: int.parse(json['day'] as String),
    month: json['month']['number'] as int,
    monthName: json['month']['en'] as String,
    year: int.parse(json['year'] as String),
  );
}

/// One Gregorian-calendar cell paired with its Hijri equivalent, as
/// returned by AlAdhan's gToHCalendar for a whole month at once.
class HijriCalendarDay {
  final DateTime gregorian;
  final int hijriDay;
  final int hijriMonth;
  final String hijriMonthName;
  final int hijriYear;

  const HijriCalendarDay({
    required this.gregorian,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriMonthName,
    required this.hijriYear,
  });

  factory HijriCalendarDay.fromJson(Map<String, dynamic> json) {
    final g = json['gregorian'] as Map<String, dynamic>;
    final h = json['hijri'] as Map<String, dynamic>;
    return HijriCalendarDay(
      gregorian: DateTime(
        int.parse(g['year'] as String),
        g['month']['number'] as int,
        int.parse(g['day'] as String),
      ),
      hijriDay: int.parse(h['day'] as String),
      hijriMonth: h['month']['number'] as int,
      hijriMonthName: h['month']['en'] as String,
      hijriYear: int.parse(h['year'] as String),
    );
  }
}
