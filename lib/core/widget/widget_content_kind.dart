import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

/// The distinct pieces of content that can appear on the home-screen widget.
/// Every kind is always available as a single-purpose iOS Lock Screen widget
/// too (see EslamyWidgetBundle.swift) — the user's on/off choice here only
/// governs which kinds rotate through the shared home-screen widget.
enum WidgetContentKind { prayer, ayah, dua, hijri }

extension WidgetContentKindX on WidgetContentKind {
  /// Matches the `widget_<prefix>_*` key prefix written by WidgetDataService
  /// and read by both native widgets, and the token used inside the
  /// `widget_enabled_kinds` CSV list.
  String get storageKey => switch (this) {
    WidgetContentKind.prayer => 'prayer',
    WidgetContentKind.ayah => 'ayah',
    WidgetContentKind.dua => 'dua',
    WidgetContentKind.hijri => 'hijri',
  };

  /// Mirrors the SF Symbol used per kind on the iOS widget
  /// (EslamyWidgetKind.systemImageName).
  IconData get icon => switch (this) {
    WidgetContentKind.prayer => Icons.access_time_filled_rounded,
    WidgetContentKind.ayah => Icons.menu_book_rounded,
    WidgetContentKind.dua => Icons.volunteer_activism_rounded,
    WidgetContentKind.hijri => Icons.calendar_month_rounded,
  };

  String label(AppLocalizations l10n) => switch (this) {
    WidgetContentKind.prayer => l10n.widgetNextPrayerTitle,
    WidgetContentKind.ayah => l10n.homeHighlightAyahOfDayTitle,
    WidgetContentKind.dua => l10n.homeHighlightDuaOfDayTitle,
    WidgetContentKind.hijri => l10n.widgetHijriDateTitle,
  };

  static WidgetContentKind? fromStorageKey(String key) {
    for (final kind in WidgetContentKind.values) {
      if (kind.storageKey == key) return kind;
    }
    return null;
  }
}
