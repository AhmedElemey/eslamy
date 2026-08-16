import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../controllers/language_providers.dart';
import '../controllers/settings_providers.dart';
import '../controllers/theme_mode_providers.dart';
import '../../service/settings_database.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_providers.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Icon-badge + title used at the top of every settings card, matching the
/// icon-in-rounded-box language used in the drawer and quick-access tiles.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textSize = ref.watch(textSizeProvider);
    final themeModeAsync = ref.watch(themeModeProvider);
    final languageAsync = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDeep, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.mosque, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text(l10n.settingsTitle),
          ],
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.brightness_6_outlined,
                      title: l10n.sectionAppearance,
                    ),
                    const SizedBox(height: 12),
                    themeModeAsync.when(
                      data:
                          (mode) => SegmentedButton<ThemeMode>(
                            segments: [
                              ButtonSegment(
                                value: ThemeMode.system,
                                label: Text(l10n.themeSystem),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Text(l10n.themeLight),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Text(l10n.themeDark),
                              ),
                            ],
                            selected: {mode},
                            onSelectionChanged: (selection) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(selection.first);
                            },
                          ),
                      loading: () => const CircularProgressIndicator(),
                      error:
                          (e, _) =>
                              Text(l10n.genericErrorWithMessage(e.toString())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.translate_rounded,
                      title: l10n.sectionLanguage,
                    ),
                    const SizedBox(height: 12),
                    languageAsync.when(
                      data:
                          (language) => SegmentedButton<AppLanguage>(
                            segments: [
                              ButtonSegment(
                                value: AppLanguage.english,
                                label: Text(l10n.languageEnglish),
                              ),
                              ButtonSegment(
                                value: AppLanguage.arabic,
                                label: Text(l10n.languageArabic),
                              ),
                              ButtonSegment(
                                value: AppLanguage.italian,
                                label: Text(l10n.languageItalian),
                              ),
                            ],
                            selected: {language},
                            onSelectionChanged: (selection) {
                              ref
                                  .read(languageProvider.notifier)
                                  .setLanguage(selection.first);
                            },
                          ),
                      loading: () => const CircularProgressIndicator(),
                      error:
                          (e, _) =>
                              Text(l10n.genericErrorWithMessage(e.toString())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.format_size_rounded,
                      title: l10n.sectionTextSize,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.textSizeDescription,
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
                                final idx = v.round().clamp(
                                  0,
                                  options.length - 1,
                                );
                                final delta = options[idx];
                                ref
                                    .read(textSizeProvider.notifier)
                                    .setTextSize(delta);
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:
                                  options
                                      .map((e) => Text(e.toString()))
                                      .toList(),
                            ),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error:
                          (e, _) =>
                              Text(l10n.genericErrorWithMessage(e.toString())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.auto_stories_outlined,
                      title: l10n.sectionDailyWerdTime,
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<TimeOfDay?>(
                      future: SettingsDatabase().getWerdTime(),
                      builder: (context, snap) {
                        final current = snap.data;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                final now = TimeOfDay.now();
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: current ?? now,
                                );
                                if (picked != null) {
                                  await SettingsDatabase().setWerdTime(picked);
                                  await NotificationService()
                                      .requestPermissions();
                                  await NotificationService().scheduleDaily(
                                    time: picked,
                                    title: l10n.sectionDailyWerdTime,
                                    body: l10n.werdTimeSavedAndScheduled,
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.werdTimeSavedAndScheduled,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                current != null
                                    ? '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}'
                                    : l10n.pickTime,
                              ),
                            ),
                            FilledButton(
                              onPressed: () async {
                                await NotificationService()
                                    .requestPermissions();
                                final t =
                                    await SettingsDatabase().getWerdTime();
                                if (t != null) {
                                  await NotificationService().scheduleDaily(
                                    time: t,
                                    title: l10n.sectionDailyWerdTime,
                                    body: l10n.werdTimeSavedAndScheduled,
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.reminderScheduled),
                                    ),
                                  );
                                }
                              },
                              child: Text(l10n.scheduleButton),
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                await NotificationService()
                                    .requestPermissions();
                                final enabled =
                                    await NotificationService()
                                        .areNotificationsEnabled();
                                if (!enabled) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.notificationsDisabledMessage,
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                await NotificationService().showNow(
                                  title: l10n.testNotificationTitle,
                                  body: l10n.testNotificationBody,
                                );
                              },
                              child: Text(l10n.testNowButton),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.mosque,
                      title: l10n.adhanAlertsTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.adhanAlertsDescription,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    const _AdhanToggleRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdhanToggleRow extends ConsumerStatefulWidget {
  const _AdhanToggleRow();

  @override
  ConsumerState<_AdhanToggleRow> createState() => _AdhanToggleRowState();
}

class _AdhanToggleRowState extends ConsumerState<_AdhanToggleRow> {
  bool? _enabled;

  @override
  void initState() {
    super.initState();
    SettingsDatabase().getAdhanEnabled().then((value) {
      if (!mounted) return;
      setState(() => _enabled = value);
    });
  }

  Future<void> _onChanged(bool value) async {
    setState(() => _enabled = value);
    await SettingsDatabase().setAdhanEnabled(value);
    if (value) {
      await NotificationService().requestPermissions();
    }
    if (!mounted) return;
    // Apply immediately — schedule or cancel alerts right away instead of
    // waiting for the next cold-start prayer-times load to notice the
    // saved flag.
    await ref.read(prayerTimesProvider.notifier).applyAdhanEnabledChange(value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled ?? true;
    return Row(
      children: [
        Expanded(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.enabledLabel),
            value: enabled,
            onChanged: _enabled == null ? null : _onChanged,
          ),
        ),
        const _AdhanPreviewButton(),
      ],
    );
  }
}

/// Plays a short preview of the bundled adhan recording using its own
/// AudioPlayer instance (kept separate from the Quran feature's shared
/// player) so it doesn't interfere with any Quran playback in progress.
class _AdhanPreviewButton extends StatefulWidget {
  const _AdhanPreviewButton();

  @override
  State<_AdhanPreviewButton> createState() => _AdhanPreviewButtonState();
}

class _AdhanPreviewButtonState extends State<_AdhanPreviewButton> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSubscription;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _stateSubscription = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        setState(() => _playing = false);
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.stop();
      if (!mounted) return;
      setState(() => _playing = false);
      return;
    }
    setState(() => _playing = true);
    await _player.setAsset('assets/audio/adhan_alafasy.mp3');
    await _player.play();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip:
          _playing ? context.l10n.stopTooltip : context.l10n.previewTooltip,
      icon: Icon(
        _playing ? Icons.stop_circle_outlined : Icons.play_circle_outline,
      ),
      onPressed: _toggle,
    );
  }
}
