import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager_android/workmanager_android.dart';
import 'package:workmanager_platform_interface/workmanager_platform_interface.dart';

import '../../features/prayer_times/models/prayer_times.dart';
import '../../features/prayer_times/service/location_service.dart';
import '../../features/prayer_times/service/prayer_times_service.dart';
import '../../features/settings/service/settings_database.dart';
import '../network/dio_provider.dart';
import '../network/request_controller.dart';
import '../../features/settings/presentation/controllers/language_providers.dart';
import 'notification_service.dart';

/// scheduleAdhan() only ever covers today + tomorrow, and is otherwise only
/// re-run when the app is opened (see PrayerTimesNotifier.load). A device
/// reboot clears every AlarmManager alarm the OS is holding, so without this,
/// a user who reboots and doesn't reopen the app within that window gets no
/// adhan alerts until they do. This periodic WorkManager task re-runs the
/// same scheduling independently of the app being open — and AndroidX
/// WorkManager itself (via its own bundled manifest, merged automatically)
/// already re-enqueues persisted periodic tasks after reboot, so no separate
/// boot receiver is needed here.
///
/// Uses workmanager_android directly rather than the workmanager meta
/// package: at the time of writing, workmanager_android's last 0.9.x release
/// needs a newer workmanager_platform_interface than workmanager_apple's
/// last 0.9.x release implements, and the next workmanager major version
/// requires a newer Flutter SDK than this project targets. Android is also
/// the only platform that needs this — iOS local notifications already
/// survive a reboot on their own — so depending on the Android platform
/// package alone sidesteps the conflict entirely instead of overriding
/// around it.
const adhanRescheduleTaskName = 'adhanRescheduleTask';
const _adhanRescheduleUniqueName = 'adhan-reschedule';

@pragma('vm:entry-point')
void adhanRescheduleCallbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  WorkmanagerFlutterApi.setUp(_AdhanRescheduleFlutterApi());
}

class _AdhanRescheduleFlutterApi extends WorkmanagerFlutterApi {
  @override
  Future<bool> executeTask(
    String taskName,
    Map<String?, Object?>? inputData,
  ) async {
    if (taskName != adhanRescheduleTaskName) return true;
    try {
      final enabled = await SettingsDatabase().getAdhanEnabled();
      if (!enabled) return true;

      final cached = await LocationService().getCachedPosition();
      // No cached fix yet (e.g. adhan was never scheduled before this
      // device rebooted) — nothing to reschedule from; the next app open
      // will populate it via the normal foreground flow.
      if (cached == null) return true;
      final (lat, lng) = cached;

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      // This isolate builds its own Dio directly rather than going through
      // dioProvider, so it must add the same rate-limit retry itself —
      // aladhan.com is a shared, keyless free API that 429s under real
      // multi-user load, and without a retry a single 429 here used to
      // abort this periodic reschedule with nothing rescheduled at all.
      dio.interceptors.add(RateLimitInterceptor(dio));
      final service = PrayerTimesService(requests: RequestController(dio));
      final today = await service.fetchTimings(latitude: lat, longitude: lng);

      Map<String, DateTime> asMap(DailyPrayerTimes d) => {
        for (final p in d.prayers)
          if (p.name != 'Sunrise') p.name: p.time,
      };
      // Fetched separately so a failed/rate-limited fetch for tomorrow
      // doesn't also throw away today's already-fetched alerts.
      DailyPrayerTimes? tomorrow;
      try {
        tomorrow = await service.fetchTimings(
          latitude: lat,
          longitude: lng,
          date: DateTime.now().add(const Duration(days: 1)),
        );
      } catch (e, st) {
        debugPrint(
          'Adhan reschedule: failed to fetch tomorrow\'s timings: $e\n$st',
        );
      }
      await NotificationService().scheduleAdhan(
        today: asMap(today),
        tomorrow: tomorrow == null ? {} : asMap(tomorrow),
        l10n: await loadStoredLocalizations(),
      );
    } catch (e, st) {
      // Best-effort background refresh — leave whatever was already
      // scheduled untouched on failure rather than surfacing an error
      // with no UI to show it in. Still log it: this isolate never calls
      // Firebase.initializeApp() (unlike the main isolate or
      // _firebaseMessagingBackgroundHandler above), so Crashlytics isn't
      // available here — debugPrint is still visible via `adb logcat` on a
      // release build, which a bare silent catch was not.
      debugPrint('Adhan reschedule task failed: $e\n$st');
    }
    return true;
  }

  @override
  Future<void> backgroundChannelInitialized() async {}
}

/// Registers the periodic reschedule task. Safe to call on every app start:
/// [ExistingPeriodicWorkPolicy.keep] makes repeat registrations a no-op
/// while the task is already enqueued. No-op on non-Android platforms.
Future<void> registerAdhanRescheduleTask() async {
  if (!Platform.isAndroid) return;
  final workmanager = WorkmanagerAndroid();
  await workmanager.initialize(adhanRescheduleCallbackDispatcher);
  await workmanager.registerPeriodicTask(
    _adhanRescheduleUniqueName,
    adhanRescheduleTaskName,
    frequency: const Duration(hours: 12),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.connected),
  );
}
