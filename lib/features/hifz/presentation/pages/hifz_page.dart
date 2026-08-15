import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../quran/models/quran_models.dart';
import '../../../quran/presentation/controllers/quran_providers.dart';
import '../../../settings/service/settings_database.dart';
import '../controllers/hifz_providers.dart';

const _hifzReviewNotificationId = 1002;
const _hifzReviewTimeKey = 'hifz_review_time';

class HifzPage extends ConsumerWidget {
  const HifzPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final memorized = ref.watch(hifzProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.hifzTrackerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: l10n.setReviewReminderTooltip,
            onPressed: () => _pickReviewTime(context),
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: chaptersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.failedToLoadSurahsWithError(e.toString()))),
            data: (chapters) => _buildList(context, chapters, memorized, ref),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<QuranChapter> chapters,
    Set<int> memorized,
    WidgetRef ref,
  ) {
    final total = chapters.length;
    final progress = total == 0 ? 0.0 : memorized.length / total;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.surahsMemorizedProgress(memorized.length, total),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: chapters.length,
            itemExtent: 64,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              final isMemorized = memorized.contains(chapter.number);
              return CheckboxListTile(
                value: isMemorized,
                onChanged: (_) =>
                    ref.read(hifzProvider.notifier).toggle(chapter.number),
                activeColor: AppColors.primary,
                title: Text(chapter.englishName),
                subtitle: Text(context.l10n.versesCount(chapter.numberOfAyahs)),
                secondary: Text('${chapter.number}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickReviewTime(BuildContext context) async {
    final db = SettingsDatabase();
    final current = await db.getTimeValue(_hifzReviewTimeKey);
    if (!context.mounted) return;
    final l10n = context.l10n;

    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? const TimeOfDay(hour: 20, minute: 0),
    );
    if (picked == null) return;

    await db.setTimeValue(_hifzReviewTimeKey, picked);
    await NotificationService().requestPermissions();
    await NotificationService().scheduleDaily(
      id: _hifzReviewNotificationId,
      time: picked,
      title: l10n.hifzReviewNotificationTitle,
      body: l10n.hifzReviewNotificationBody,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.dailyReviewReminderScheduled)),
    );
  }
}
