/// How an Adhan alert should be delivered for a prayer time relative to [now].
enum AdhanDelivery {
  /// Prayer already passed earlier today — do not notify.
  skip,

  /// Prayer time's hour:minute is the current clock minute — notify now.
  showNow,

  /// Prayer is still ahead — schedule an OS notification.
  schedule,
}

/// Compares wall-clock hour and minute (seconds ignored), matching how prayer
/// times are displayed in the app (`HH:MM`).
AdhanDelivery adhanDeliveryFor(DateTime prayerTime, DateTime now) {
  final prayerMinute = DateTime(
    prayerTime.year,
    prayerTime.month,
    prayerTime.day,
    prayerTime.hour,
    prayerTime.minute,
  );
  final nowMinute = DateTime(
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute,
  );
  if (prayerMinute.isAfter(nowMinute)) return AdhanDelivery.schedule;
  if (prayerMinute == nowMinute) return AdhanDelivery.showNow;
  return AdhanDelivery.skip;
}
