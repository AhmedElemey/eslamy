import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static const AndroidNotificationChannel _dailyChannel =
      AndroidNotificationChannel(
        'daily_werd_v2',
        'Daily Werd',
        description: 'Daily reminder for your Werd',
        importance: Importance.high,
      );

  // The full adhan recording (assets/audio/adhan_alafasy.mp3, played in-app
  // via just_audio — see settings_page.dart's preview button) is a Flutter
  // asset, which OS notification sounds can't reference directly: Android
  // and iOS both need a short native-resource clip instead (android/app/src
  // /main/res/raw/adhan_call.wav, ios/Runner/adhan_call.caf, an 18s trim of
  // the opening takbir with a fade-out — regenerate both from the source
  // mp3 if a different excerpt is wanted). Channel id carries a _v2 suffix
  // because Android locks a channel's sound at creation time; bump it again
  // if the sound file ever changes, or existing installs won't hear it.
  static const AndroidNotificationChannel _adhanChannel =
      AndroidNotificationChannel(
        'adhan_calls_v2',
        'Adhan',
        description: 'Call-to-prayer alert at each prayer time',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan_call'),
      );

  static const _adhanPrayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const _adhanBaseId = 3000;

  Future<void> init() async {
    // Timezone setup
    tz.initializeTimeZones();
    try {
      final String localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      // Fallback to device default if we fail to get timezone name
      // tz.local remains whatever timezone package defaults to
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    // Ensure Android channel exists
    final androidImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(_dailyChannel);
      await androidImpl.createNotificationChannel(_adhanChannel);
      // Drop the pre-_v2 channel so it doesn't linger as a dead entry in
      // system settings for installs upgrading from the default-sound version.
      await androidImpl.deleteNotificationChannel('adhan_calls');
    }
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    // Android 13+
    final androidImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    bool androidGranted = true;
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      androidGranted = granted ?? true;
      // Android 12+ requires separate "Alarms & reminders" access for
      // exactAllowWhileIdle scheduling; without it, scheduleAdhan() would
      // silently degrade to inexact delivery. Send the user to the system
      // settings screen for it up front, same as the notification prompt.
      final canScheduleExact = await androidImpl.canScheduleExactNotifications();
      if (canScheduleExact == false) {
        await androidImpl.requestExactAlarmsPermission();
      }
    }

    final ios =
        _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    final mac =
        _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return (granted ?? false) && androidGranted;
    }
    if (mac != null) {
      final granted = await mac.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return (granted ?? false) && androidGranted;
    }
    return androidGranted; // Android result
  }

  Future<bool> areNotificationsEnabled() async {
    final androidImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidImpl != null) {
      final enabled = await androidImpl.areNotificationsEnabled();
      return enabled ?? true;
    }
    // On iOS/macOS, if app didn't crash on permission request, assume enabled.
    return true;
  }

  Future<void> scheduleDaily({
    required TimeOfDay time,
    required String title,
    required String body,
    int id = 1001,
  }) async {
    if (!_initialized) {
      await init();
    }
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    final androidDetails = AndroidNotificationDetails(
      _dailyChannel.id,
      _dailyChannel.name,
      channelDescription: _dailyChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    if (kDebugMode) {
      final hh = time.hour.toString().padLeft(2, '0');
      final mm = time.minute.toString().padLeft(2, '0');
      debugPrint('Scheduled daily notification at $hh:$mm');
    }
  }

  /// Schedules one Adhan alert per prayer for [today] and [tomorrow]
  /// (name -> time maps, Sunrise excluded by the caller) — covering two
  /// days so alerts keep firing even if the app isn't reopened tomorrow.
  /// Previously-scheduled Adhan alerts are cancelled first.
  Future<void> scheduleAdhan({
    required Map<String, DateTime> today,
    required Map<String, DateTime> tomorrow,
  }) async {
    if (!_initialized) {
      await init();
    }
    for (var i = 0; i < _adhanPrayerNames.length * 2; i++) {
      await _plugin.cancel(_adhanBaseId + i);
    }

    // Exact-alarm access can be off (never granted, or revoked later in
    // system settings) even though notification permission is granted.
    // Fall back to inexact delivery rather than let zonedSchedule throw and
    // have the alert vanish silently — a few minutes late beats never.
    final androidImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final canScheduleExact =
        await androidImpl?.canScheduleExactNotifications() ?? true;
    final scheduleMode =
        canScheduleExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle;

    final androidDetails = AndroidNotificationDetails(
      _adhanChannel.id,
      _adhanChannel.name,
      channelDescription: _adhanChannel.description,
      importance: Importance.max,
      priority: Priority.max,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'adhan_call.caf',
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var id = _adhanBaseId;
    for (final day in [today, tomorrow]) {
      for (final name in _adhanPrayerNames) {
        final notificationId = id;
        id++;
        final time = day[name];
        if (time == null) continue;
        final scheduled = tz.TZDateTime.from(time, tz.local);
        if (scheduled.isBefore(now)) continue;
        await _plugin.zonedSchedule(
          notificationId,
          'Adhan — $name',
          'It is time for $name prayer',
          scheduled,
          details,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: scheduleMode,
        );
      }
    }
  }

  /// Cancels all pending Adhan alerts (today + tomorrow), e.g. when the
  /// user turns Adhan Alerts off — otherwise already-scheduled alerts
  /// would keep firing until they naturally expire.
  Future<void> cancelAdhan() async {
    if (!_initialized) {
      await init();
    }
    for (var i = 0; i < _adhanPrayerNames.length * 2; i++) {
      await _plugin.cancel(_adhanBaseId + i);
    }
  }

  Future<void> showNow({required String title, required String body}) async {
    if (!_initialized) {
      await init();
    }
    final androidDetails = AndroidNotificationDetails(
      _dailyChannel.id,
      _dailyChannel.name,
      channelDescription: _dailyChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(2001, title, body, details);
  }
}
