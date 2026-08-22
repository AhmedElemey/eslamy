import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/error_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widget/widget_content.dart';
import '../../../../core/widget/widget_content_builder.dart';
import '../../../../core/widget/widget_content_kind.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../duas/presentation/controllers/azkar_providers.dart';
import '../../../hijri_calendar/presentation/controllers/hijri_calendar_providers.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_providers.dart';
import '../../../quran/presentation/controllers/quran_providers.dart';
import '../controllers/widget_preferences_providers.dart';

/// Lets the user pick which content kinds rotate through the home-screen
/// widget, with a live preview of each kind styled exactly like the native
/// widget (EslamyWidget.swift / EslamyWidgetProvider.kt) so what's shown
/// here is what actually ends up on the widget.
class WidgetCustomizationPage extends ConsumerWidget {
  const WidgetCustomizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final enabledAsync = ref.watch(widgetPreferencesProvider);

    final prayerState = ref.watch(prayerTimesProvider);
    final prayerSchedule = WidgetContentBuilder.prayerSchedule(
      prayerState,
      l10n,
    );
    final prayerDate = WidgetContentBuilder.prayerDateCompact(l10n);

    final contents = <WidgetContentKind, WidgetContent?>{
      WidgetContentKind.prayer: WidgetContentBuilder.prayer(prayerState, l10n),
      WidgetContentKind.ayah: ref
          .watch(ayahOfTheDayProvider)
          .maybeWhen(
            data: (ayah) => WidgetContentBuilder.ayah(ayah, l10n),
            orElse: () => null,
          ),
      WidgetContentKind.dua: ref
          .watch(duaOfTheDayProvider)
          .maybeWhen(
            data: (dua) => WidgetContentBuilder.dua(dua, l10n),
            orElse: () => null,
          ),
      WidgetContentKind.hijri: WidgetContentBuilder.hijri(
        ref.watch(hijriCalendarProvider),
        l10n,
      ),
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(l10n.sectionHomeWidget)),
      body: AppBackground(
        child: SafeArea(
          child: enabledAsync.when(
            data: (enabledKinds) {
              final enabledSet = enabledKinds.toSet();
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  Text(
                    l10n.widgetCustomizationIntro,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  for (final kind in WidgetContentKind.values) ...[
                    _WidgetKindCard(
                      kind: kind,
                      enabled: enabledSet.contains(kind),
                      content: contents[kind],
                      prayerSchedule:
                          kind == WidgetContentKind.prayer
                              ? prayerSchedule
                              : null,
                      prayerDate:
                          kind == WidgetContentKind.prayer ? prayerDate : null,
                      onToggle: (value) {
                        if (!value && enabledSet.length <= 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.widgetCustomizationMinimumOneRequired,
                              ),
                            ),
                          );
                          return;
                        }
                        ref
                            .read(widgetPreferencesProvider.notifier)
                            .toggle(kind);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    l10n.widgetCustomizationLockScreenNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedText(context),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.genericErrorWithMessage(localizedError(l10n, e)),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _WidgetKindCard extends StatelessWidget {
  const _WidgetKindCard({
    required this.kind,
    required this.enabled,
    required this.content,
    required this.onToggle,
    this.prayerSchedule,
    this.prayerDate,
  });

  final WidgetContentKind kind;
  final bool enabled;
  final WidgetContent? content;
  final ValueChanged<bool> onToggle;

  /// Only set (and only rendered) for [WidgetContentKind.prayer] — the
  /// Android home-screen widget's dedicated schedule row, see
  /// eslamy_widget_prayer_layout.xml.
  final List<PrayerScheduleEntry>? prayerSchedule;
  final String? prayerDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(kind.icon, color: AppColors.primary, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  kind.label(l10n),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Switch(value: enabled, onChanged: onToggle),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 12),
            content == null
                ? SizedBox(
                  height: 96,
                  child: Center(child: Text(l10n.loadingEllipsis)),
                )
                : kind == WidgetContentKind.prayer && prayerSchedule != null
                ? _PrayerWidgetPreview(
                  content: content!,
                  schedule: prayerSchedule!,
                  date: prayerDate ?? '',
                )
                : _WidgetPreview(content: content!),
          ],
        ],
      ),
    );
  }
}

/// Mirrors EslamyWidgetView.swift / eslamy_widget_layout.xml: same gradient,
/// same kicker/primary/secondary colors and roles.
class _WidgetPreview extends StatelessWidget {
  const _WidgetPreview({required this.content});

  final WidgetContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDeep, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(content.kind.icon, color: Colors.white, size: 12),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  content.kicker,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content.primary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (content.secondary.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              content.secondary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mirrors eslamy_widget_prayer_layout.xml / EslamyWidgetProvider.kt: light
/// parchment card, darker inset band behind the schedule row, dark teal
/// pill on the current prayer — the Prayer kind's own layout on Android is
/// nothing like the shared teal 3-line one every other kind still uses, so
/// it gets its own preview here too instead of going through
/// [_WidgetPreview].
class _PrayerWidgetPreview extends StatelessWidget {
  const _PrayerWidgetPreview({
    required this.content,
    required this.schedule,
    required this.date,
  });

  final WidgetContent content;
  final List<PrayerScheduleEntry> schedule;
  final String date;

  static const _muted = Color(0xFF6B736F);
  static const _ink = Color(0xFF1C2A26);
  static const _band = Color(0xFFF1EBE0);
  static const _activePill = Color(0xFF0B3D32);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFFFFCF6),
        border: Border.all(color: const Color(0xFFE6DFD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(content.kind.icon, color: _muted, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  content.kicker,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content.primary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: _band,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                for (final entry in schedule)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          entry.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: entry.isNext ? _ink : _muted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: entry.isNext ? _activePill : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entry.time,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: entry.isNext ? Colors.white : _ink,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
