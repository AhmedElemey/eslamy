class PrayerTime {
  final String name;
  final DateTime time;

  const PrayerTime({required this.name, required this.time});
}

class DailyPrayerTimes {
  final DateTime date;
  final List<PrayerTime> prayers;
  final int hijriDay;
  final int hijriMonth;
  final int hijriYear;

  const DailyPrayerTimes({
    required this.date,
    required this.prayers,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
  });

  /// The next prayer still ahead today, or null if Isha has already passed.
  PrayerTime? get nextPrayer {
    final now = DateTime.now();
    for (final p in prayers) {
      if (p.time.isAfter(now)) return p;
    }
    return null;
  }
}
