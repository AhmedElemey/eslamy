import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../service/streak_database.dart';
import '../controllers/streak_providers.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(streakProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final today = DateTime.now();
    final last7 = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.goldAccent(context),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.currentStreak <= 1
                      ? context.l10n.dayStreakSingle
                      : context.l10n.dayStreakCount(state.currentStreak),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children:
                      last7.map((day) {
                        final active = state.recentActiveDates.contains(
                          formatDate(day),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  active
                                      ? AppColors.primary
                                      : (isDark
                                          ? Colors.white10
                                          : Colors.grey.withValues(
                                            alpha: 0.15,
                                          )),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
