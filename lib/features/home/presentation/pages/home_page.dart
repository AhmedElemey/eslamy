import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/shell_app_bar.dart';
import '../../../duas/presentation/pages/azkar_categories_page.dart';
import '../../../hifz/presentation/pages/hifz_page.dart';
import '../../../hifz/presentation/controllers/hifz_providers.dart';
import '../../../hijri_calendar/presentation/pages/hijri_calendar_page.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_providers.dart';
import '../../../prayer_times/presentation/pages/qibla_page.dart';
import '../../../prayer_times/presentation/widgets/prayer_times_card.dart';
import '../../../settings/presentation/controllers/language_providers.dart';
import '../../../streaks/presentation/controllers/streak_providers.dart';
import '../../../tasbih/presentation/pages/tasbih_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final headingColor = AppColors.heading(context);
    final hijriDate = ref.watch(prayerTimesProvider).timings?.hijriDate;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: ShellAwareAppBar(
        title: Text(
          l10n.appTitle,
          style: TextStyle(fontWeight: FontWeight.w800, color: headingColor),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language_outlined, color: headingColor),
            tooltip: l10n.sectionLanguage,
            onPressed: () => _showLanguagePicker(context, ref),
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      l10n.homeGreetingAssalamuAlaikum,
                      style: TextStyle(
                        color: AppColors.primaryOnBg(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.homeWelcomeBack,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: headingColor,
                          ),
                        ),
                        const Spacer(),
                        if (hijriDate != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              hijriDate,
                              style: TextStyle(
                                color: AppColors.goldAccent(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: PrayerTimesCard(),
              ),
              const SizedBox(height: 16),
              const _QuickAccessRow(),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _StreakStatTile()),
                    SizedBox(width: 10),
                    Expanded(child: _HifzStatTile()),
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

void _showLanguagePicker(BuildContext context, WidgetRef ref) {
  final l10n = context.l10n;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l10n.sectionLanguage,
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final languageAsync = ref.watch(languageProvider);
                  return languageAsync.when(
                    data: (current) => Column(
                      children: [
                        for (final language in AppLanguage.values)
                          ListTile(
                            title: Text(_languageLabel(l10n, language)),
                            trailing: current == language
                                ? Icon(
                                    Icons.check_rounded,
                                    color: AppColors.primaryOnBg(context),
                                  )
                                : null,
                            onTap: () {
                              ref
                                  .read(languageProvider.notifier)
                                  .setLanguage(language);
                              Navigator.of(sheetContext).pop();
                            },
                          ),
                      ],
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _languageLabel(AppLocalizations l10n, AppLanguage language) =>
    switch (language) {
      AppLanguage.english => l10n.languageEnglish,
      AppLanguage.arabic => l10n.languageArabic,
      AppLanguage.italian => l10n.languageItalian,
    };

class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <(IconData, String, WidgetBuilder)>[
      (Icons.donut_large_outlined, l10n.quickAccessTasbih, (_) => const TasbihPage()),
      (Icons.auto_awesome_outlined, l10n.duasAzkarTitle, (_) => const AzkarCategoriesPage()),
      (Icons.explore_outlined, l10n.qiblaDirectionTitle, (_) => const QiblaPage()),
      (Icons.calendar_month_outlined, l10n.hijriCalendarTitle, (_) => const HijriCalendarPage()),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final item in items) ...[
            Expanded(
              child: _QuickAccessTile(
                icon: item.$1,
                label: item.$2,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: item.$3),
                ),
              ),
            ),
            if (item != items.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryOnBg(context), size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.heading(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.heading(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.mutedText(context),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakStatTile extends ConsumerWidget {
  const _StreakStatTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider).currentStreak;
    return _StatTile(
      icon: Icon(
        Icons.local_fire_department_outlined,
        color: AppColors.goldAccent(context),
        size: 22,
      ),
      value: context.l10n.streakDaysShort(streak),
      label: context.l10n.streakStatLabel,
      onTap: () {},
    );
  }
}

class _HifzStatTile extends ConsumerWidget {
  const _HifzStatTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memorized = ref.watch(hifzProvider).length;
    return _StatTile(
      icon: Icon(
        Icons.school_outlined,
        color: AppColors.primaryOnBg(context),
        size: 22,
      ),
      value: context.l10n.memorizedOutOfTotal(memorized, 114),
      label: context.l10n.memorizedStatLabel,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HifzPage()),
        );
      },
    );
  }
}
