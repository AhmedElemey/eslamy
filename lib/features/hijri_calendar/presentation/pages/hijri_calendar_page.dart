import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/hijri_models.dart';
import '../../models/islamic_holiday.dart';
import '../controllers/hijri_calendar_providers.dart';

List<String> _monthNames(AppLocalizations l10n) => [
      l10n.monthJanuary, l10n.monthFebruary, l10n.monthMarch, l10n.monthApril,
      l10n.monthMay, l10n.monthJune, l10n.monthJuly, l10n.monthAugust,
      l10n.monthSeptember, l10n.monthOctober, l10n.monthNovember, l10n.monthDecember,
    ];
List<String> _weekdayLabels(AppLocalizations l10n) => [
      l10n.weekdaySun, l10n.weekdayMon, l10n.weekdayTue, l10n.weekdayWed,
      l10n.weekdayThu, l10n.weekdayFri, l10n.weekdaySat,
    ];

class HijriCalendarPage extends ConsumerWidget {
  const HijriCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hijriCalendarProvider);
    final notifier = ref.read(hijriCalendarProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(l10n.hijriCalendarTitle)),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.todayHijri != null) _TodayCard(hijri: state.todayHijri!),
              const SizedBox(height: 16),
              GlassCard(
                borderRadius: 20,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () => notifier.goToMonth(-1),
                        ),
                        Text(
                          '${_monthNames(context.l10n)[state.viewMonth - 1]} ${state.viewYear}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () => notifier.goToMonth(1),
                        ),
                      ],
                    ),
                    if (state.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      )
                    else if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(state.error!, textAlign: TextAlign.center),
                      )
                    else
                      _MonthGrid(days: state.monthDays),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.upcomingLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (state.upcoming.isEmpty)
                Text(l10n.loadingUpcomingOccasions, style: const TextStyle(color: AppColors.muted))
              else
                ...state.upcoming.map((u) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _UpcomingTile(item: u),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.hijri});

  final HijriDate hijri;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 20,
      child: Column(
        children: [
          Text(context.l10n.todayLabelCaps, style: const TextStyle(color: AppColors.gold, letterSpacing: 1.2, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            context.l10n.hijriDateAh(hijri.day, hijri.monthName, hijri.year),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.days});

  final List<HijriCalendarDay> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();
    final leadingBlanks = days.first.gregorian.weekday % 7;
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          Row(
            children: _weekdayLabels(context.l10n)
                .map((w) => Expanded(
                      child: Center(
                        child: Text(w, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: leadingBlanks + days.length,
            itemBuilder: (context, i) {
              if (i < leadingBlanks) return const SizedBox.shrink();
              final day = days[i - leadingBlanks];
              final isToday = day.gregorian.year == today.year &&
                  day.gregorian.month == today.month &&
                  day.gregorian.day == today.day;
              final isHoliday = islamicHolidays.any(
                (h) => h.hijriDay == day.hijriDay && h.hijriMonth == day.hijriMonth,
              );
              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: isToday
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${day.gregorian.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isToday ? AppColors.primaryOnBg(context) : null,
                          ),
                        ),
                        Text(
                          '${day.hijriDay}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isToday
                                ? AppColors.primaryOnBg(context)
                                : AppColors.mutedText(context),
                          ),
                        ),
                      ],
                    ),
                    if (isHoliday)
                      Positioned(
                        bottom: 2,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.goldDeep,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.item});

  final UpcomingHoliday item;

  @override
  Widget build(BuildContext context) {
    final days = item.daysRemaining;
    final l10n = context.l10n;
    final label = days == 0
        ? l10n.todayCountdown
        : days == 1
            ? l10n.tomorrowCountdown
            : l10n.inDaysCountdown(days);
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.mosque_outlined, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.holiday.localizedName(l10n),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${item.holiday.hijriDay} / ${item.holiday.hijriMonth}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText(context),
                  ),
                ),
              ],
            ),
          ),
          Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
