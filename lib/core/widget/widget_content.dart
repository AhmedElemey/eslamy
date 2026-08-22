import 'widget_content_kind.dart';

/// The three text lines rendered on the widget for one [WidgetContentKind] —
/// shared shape between what gets pushed to the native widgets and what the
/// in-app preview (WidgetCustomizationPage) renders, so they can never drift
/// apart.
class WidgetContent {
  final WidgetContentKind kind;
  final String kicker;
  final String primary;
  final String secondary;

  const WidgetContent({
    required this.kind,
    required this.kicker,
    required this.primary,
    required this.secondary,
  });
}

/// One column of the Android home-screen widget's Prayer-kind schedule row
/// (see eslamy_widget_prayer_layout.xml) — the 5 canonical daily prayers
/// (no Sunrise, matching how the in-app Prayer Times page and most prayer
/// apps present "today's schedule"), with [isNext] marking the one to
/// highlight.
class PrayerScheduleEntry {
  final String name;
  final String time;
  final bool isNext;

  const PrayerScheduleEntry({
    required this.name,
    required this.time,
    required this.isNext,
  });
}
