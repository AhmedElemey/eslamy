import 'package:home_widget/home_widget.dart';

import 'widget_content_kind.dart';

/// Bridges Flutter data to the native home-screen and Lock Screen widgets
/// (iOS WidgetKit extension `EslamyWidgetExtension` / Android
/// `EslamyWidgetProvider`).
///
/// Both native widgets read plain string keys from shared storage — an App
/// Group `UserDefaults` suite on iOS, `SharedPreferences` on Android — so
/// this class only needs to write those keys and ask the OS to redraw.
class WidgetDataService {
  WidgetDataService._();

  /// Must match the `com.apple.security.application-groups` entry in both
  /// Runner.entitlements and EslamyWidgetExtension.entitlements.
  static const String _appGroupId = 'group.com.eslamy.eslamy';

  /// Must match EslamyWidgetProvider's class name (Android). Android has no
  /// Lock Screen widget surface, so it only ever gets the one home-screen
  /// widget regardless of content kind.
  static const String _androidProviderName = 'EslamyWidgetProvider';

  /// Every distinct iOS `kind:` string that reads `widget_<prefix>_*` keys —
  /// the rotating home-screen widget (reads all prefixes) plus one
  /// single-purpose Lock Screen widget per content kind (see
  /// EslamyWidgetBundle.swift). All must be reloaded whenever that prefix's
  /// data changes, since WidgetKit only reloads the exact kind you name.
  static const Map<String, List<String>> _iosKindsByPrefix = {
    'prayer': ['EslamyWidget', 'EslamyPrayerLockWidget'],
    'ayah': ['EslamyWidget', 'EslamyAyahLockWidget'],
    'dua': ['EslamyWidget', 'EslamyDuaLockWidget'],
    'hijri': ['EslamyWidget', 'EslamyHijriLockWidget'],
  };

  static Future<void> pushPrayer({
    required String kicker,
    required String primary,
    required String secondary,
  }) => _push('prayer', kicker: kicker, primary: primary, secondary: secondary);

  static Future<void> pushAyah({
    required String kicker,
    required String primary,
    required String secondary,
  }) => _push('ayah', kicker: kicker, primary: primary, secondary: secondary);

  static Future<void> pushDua({
    required String kicker,
    required String primary,
    required String secondary,
  }) => _push('dua', kicker: kicker, primary: primary, secondary: secondary);

  /// Today's Hijri date — feeds both the rotating home-screen widget and the
  /// dedicated Hijri Lock Screen widget.
  static Future<void> pushHijri({
    required String kicker,
    required String primary,
    required String secondary,
  }) => _push('hijri', kicker: kicker, primary: primary, secondary: secondary);

  /// Tells the native rotating home-screen widget which kinds the user has
  /// switched on (see WidgetCustomizationPage) and their rotation order.
  /// Only reloads `EslamyWidget` — the single-purpose Lock Screen widgets
  /// each show one kind regardless of this setting, so they don't need it.
  static Future<void> pushEnabledKinds(List<WidgetContentKind> kinds) async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.saveWidgetData<String>(
      'widget_enabled_kinds',
      kinds.map((k) => k.storageKey).join(','),
    );
    await HomeWidget.updateWidget(
      androidName: _androidProviderName,
      iOSName: 'EslamyWidget',
    );
  }

  static Future<void> _push(
    String prefix, {
    required String kicker,
    required String primary,
    required String secondary,
  }) async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.saveWidgetData<String>('widget_${prefix}_kicker', kicker);
    await HomeWidget.saveWidgetData<String>(
      'widget_${prefix}_primary',
      primary,
    );
    await HomeWidget.saveWidgetData<String>(
      'widget_${prefix}_secondary',
      secondary,
    );
    for (final iosKind in _iosKindsByPrefix[prefix]!) {
      await HomeWidget.updateWidget(
        androidName: _androidProviderName,
        iOSName: iosKind,
      );
    }
  }
}
