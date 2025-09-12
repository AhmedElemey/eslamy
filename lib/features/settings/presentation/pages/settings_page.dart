import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_providers.dart';
import '../../service/settings_database.dart';
import '../../../../core/notifications/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textSize = ref.watch(textSizeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Text size', style: theme.textTheme.titleMedium),
              Text(
                'Adjust the text size across the app. 0 is default.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              textSize.when(
                data: (current) {
                  const options = [0, 4, 8, 10];
                  final currentIndex = options
                      .indexOf(current)
                      .clamp(0, options.length - 1);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        value: currentIndex.toDouble(),
                        min: 0,
                        max: (options.length - 1).toDouble(),
                        divisions: options.length - 1,
                        label: options[currentIndex].toString(),
                        onChanged: (v) {
                          final idx = v.round().clamp(0, options.length - 1);
                          final delta = options[idx];
                          ref
                              .read(textSizeProvider.notifier)
                              .setTextSize(delta);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            options.map((e) => Text(e.toString())).toList(),
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text('Daily Werd time', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              FutureBuilder<TimeOfDay?>(
                future: SettingsDatabase().getWerdTime(),
                builder: (context, snap) {
                  final current = snap.data;
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final now = TimeOfDay.now();
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: current ?? now,
                            );
                            if (picked != null) {
                              await SettingsDatabase().setWerdTime(picked);
                              await NotificationService().requestPermissions();
                              await NotificationService().scheduleDaily(
                                time: picked,
                                title: 'Daily Werd',
                                body: 'It\'s time for your daily werd',
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Werd time saved and scheduled',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            current != null
                                ? '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}'
                                : 'Pick time',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () async {
                          await NotificationService().requestPermissions();
                          final t = await SettingsDatabase().getWerdTime();
                          if (t != null) {
                            await NotificationService().scheduleDaily(
                              time: t,
                              title: 'Daily Werd',
                              body: 'It\'s time for your daily werd',
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder scheduled'),
                              ),
                            );
                          }
                        },
                        child: const Text('Schedule'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () async {
                          await NotificationService().requestPermissions();
                          final enabled =
                              await NotificationService()
                                  .areNotificationsEnabled();
                          if (!enabled) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Notifications are disabled. Enable them in system settings.',
                                ),
                              ),
                            );
                            return;
                          }
                          await NotificationService().showNow(
                            title: 'Test Notification',
                            body: 'If you see this, notifications work',
                          );
                        },
                        child: const Text('Test now'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Push notifications (FCM)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              FutureBuilder<String?>(
                future: FirebaseMessaging.instance.getToken(),
                builder: (context, snap) {
                  final token = snap.data;
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Text('Fetching FCM token...');
                  }
                  if (token == null || token.isEmpty) {
                    return const Text(
                      'No token yet. Ensure notifications are allowed.',
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(token, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: token));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Token copied')),
                          );
                        },
                        child: const Text('Copy token'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
