import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/display_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../service/quran_audio_handler.dart';
import '../controllers/quran_providers.dart';
import '../widgets/reciter_selection_widget.dart';

/// Full "Now Playing" surface — opened by tapping the persistent FAB (or the
/// Android floating bubble, once it foregrounds the app). Reads/controls the
/// single shared `QuranAudioHandler` so it always reflects whatever surah is
/// actually playing, regardless of which screen started it.
class QuranNowPlayingPage extends ConsumerWidget {
  const QuranNowPlayingPage({super.key});

  void _openReciterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReciterSelectionDialog(),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final handler = ref.watch(quranAudioHandlerProvider);
    final mediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final playbackState = ref.watch(playbackStateProvider).valueOrNull;
    final reciter = ref.watch(selectedReciterProvider);
    final chaptersAsync = ref.watch(chaptersProvider);

    final chapterNumber = mediaItem?.extras?['chapterNumber'] as int? ?? handler.currentSurah;
    final chapterName = chaptersAsync.maybeWhen(
      data: (chapters) {
        for (final c in chapters) {
          if (c.number == chapterNumber) {
            return localizedChapterName(
              context: context,
              arabicName: c.name,
              englishName: c.englishName,
            );
          }
        }
        return null;
      },
      orElse: () => null,
    );
    final playing = playbackState?.playing ?? false;
    final rangeAyah = mediaItem?.extras?['ayahNumber'] as int?;
    final rangeStart = mediaItem?.extras?['rangeStart'] as int?;
    final rangeEnd = mediaItem?.extras?['rangeEnd'] as int?;
    final isRangeMode = rangeAyah != null;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.heading(context)),
                    ),
                    Expanded(
                      child: Text(
                        l10n.nowPlayingTitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.textTheme(Theme.of(context).colorScheme).titleMedium,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const Spacer(),
                Icon(Icons.menu_book_rounded, size: 96, color: AppColors.primaryOnBg(context)),
                const SizedBox(height: 24),
                Text(
                  chapterName ?? mediaItem?.title ?? '',
                  style: AppTypography.textTheme(Theme.of(context).colorScheme).headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _openReciterPicker(context),
                  child: Text(
                    reciter?.name ?? '',
                    style: TextStyle(color: AppColors.mutedText(context), fontSize: 15),
                  ),
                ),
                if (isRangeMode) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.nowPlayingRangeSubtitle(
                      rangeAyah,
                      rangeStart ?? rangeAyah,
                      rangeEnd ?? rangeAyah,
                    ),
                    style: TextStyle(color: AppColors.mutedText(context), fontSize: 13),
                  ),
                ],
                const Spacer(),
                StreamBuilder<Duration>(
                  stream: handler.player.positionStream,
                  builder: (context, snapshot) {
                    final position =
                        isRangeMode
                            ? handler.rangeElapsedBeforeCurrent +
                                (snapshot.data ?? Duration.zero)
                            : (snapshot.data ?? Duration.zero);
                    final rawDuration =
                        isRangeMode
                            ? handler.rangeTotalDuration
                            : (handler.player.duration ?? Duration.zero);
                    // The range total is a running estimate — never let it
                    // show less than what's already elapsed.
                    final duration =
                        rawDuration < position ? position : rawDuration;
                    final max = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
                    final value = position.inMilliseconds.clamp(0, max.toInt()).toDouble();
                    return Column(
                      children: [
                        Slider(
                          value: value,
                          max: max,
                          activeColor: AppColors.primaryOnBg(context),
                          onChanged:
                              (v) =>
                                  isRangeMode
                                      ? handler.seekInRange(
                                        Duration(milliseconds: v.toInt()),
                                      )
                                      : handler.seek(
                                        Duration(milliseconds: v.toInt()),
                                      ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position), style: TextStyle(color: AppColors.mutedText(context))),
                              Text(_formatDuration(duration), style: TextStyle(color: AppColors.mutedText(context))),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 36,
                      tooltip:
                          isRangeMode
                              ? l10n.nowPlayingPreviousAyahTooltip
                              : l10n.nowPlayingPreviousSurahTooltip,
                      onPressed:
                          (isRangeMode
                                  ? handler.hasPreviousInRange
                                  : chapterNumber > kFirstSurahNumber)
                              ? handler.skipToPrevious
                              : null,
                      icon: Icon(Icons.skip_previous_rounded, color: AppColors.heading(context)),
                    ),
                    const SizedBox(width: 16),
                    Material(
                      color: AppColors.primaryOnBg(context),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: playing ? handler.pause : handler.play,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Icon(
                            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 36,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      iconSize: 36,
                      tooltip:
                          isRangeMode
                              ? l10n.nowPlayingNextAyahTooltip
                              : l10n.nowPlayingNextSurahTooltip,
                      onPressed:
                          (isRangeMode
                                  ? handler.hasNextInRange
                                  : chapterNumber < kLastSurahNumber)
                              ? handler.skipToNext
                              : null,
                      icon: Icon(Icons.skip_next_rounded, color: AppColors.heading(context)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () async {
                    await handler.stop();
                    if (context.mounted) Navigator.of(context).maybePop();
                  },
                  icon: Icon(Icons.stop_rounded, color: AppColors.mutedText(context)),
                  label: Text(
                    l10n.nowPlayingStopTooltip,
                    style: TextStyle(color: AppColors.mutedText(context)),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
