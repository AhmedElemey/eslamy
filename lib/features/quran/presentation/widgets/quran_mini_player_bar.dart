import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/now_playing_navigation.dart';
import '../../../favorites/presentation/controllers/favorites_providers.dart';
import '../../data/surah_names.dart';
import '../../service/quran_audio_handler.dart';
import '../controllers/quran_providers.dart';
import 'reciter_avatar.dart';

/// Persistent bottom-docked mini player: shown over every screen in the app
/// (plugged into `MyApp`'s root `builder`, not `MainShell`, so pushed detail
/// routes don't hide it) whenever a surah is loaded, playing or paused.
/// Hidden while Now Playing is already the top route so it doesn't cover
/// that page's controls or push a duplicate route.
///
/// This is the in-app (foreground) player surface. While the app is
/// backgrounded, playback is represented instead by the native Android
/// floating overlay bubble (see `bubble_overlay_channel.dart`) — the two are
/// mutually exclusive by construction, since this widget only exists while
/// Flutter is actually rendering a frame.
class QuranMiniPlayerBar extends ConsumerStatefulWidget {
  const QuranMiniPlayerBar({super.key});

  @override
  ConsumerState<QuranMiniPlayerBar> createState() => _QuranMiniPlayerBarState();
}

class _QuranMiniPlayerBarState extends ConsumerState<QuranMiniPlayerBar> {
  static const Color _barColor = Color(0xFF15211C);
  static const double _bottomClearance = 70;
  static const double _collapsedSize = 56;

  /// Starts collapsed to a small round button on every screen; tapping it
  /// expands to the full bar. Not reset automatically — once expanded, it
  /// stays that way for the rest of the app session.
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // ref.watch below only re-renders on *changes*; the persisted favorite
    // list has to be loaded at least once so the heart icon's initial state
    // is correct instead of always starting unfavorited.
    Future.microtask(
      () => ref.read(quranFavoritesProvider.notifier).loadFavorites(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final playbackState = ref.watch(playbackStateProvider).valueOrNull;
    final handler = ref.watch(quranAudioHandlerProvider);
    if (mediaItem == null) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: RootRouteTracker.instance.currentRouteName,
      builder: (context, _) {
        if (RootRouteTracker.instance.isNowPlaying) {
          return const SizedBox.shrink();
        }

        final padding = MediaQuery.paddingOf(context);
        final playing = playbackState?.playing ?? false;

        final chapterNumber =
            mediaItem.extras?['chapterNumber'] as int? ?? handler.currentSurah;
        final isRangeMode = mediaItem.extras?['ayahNumber'] != null;
        final canGoPrevious =
            isRangeMode
                ? handler.hasPreviousInRange
                : chapterNumber > kFirstSurahNumber;
        final canGoNext =
            isRangeMode
                ? handler.hasNextInRange
                : chapterNumber < kLastSurahNumber;

        final liked = ref.watch(
          quranFavoritesProvider.select(
            (s) => s.favorites.any((f) => f.chapterNumber == chapterNumber),
          ),
        );
        final currentReciter = handler.currentReciter;
        final surahTitle = mediaItem.title;
        final reciterName = mediaItem.artist ?? currentReciter?.name;

        if (!_expanded) {
          return Positioned(
            right: 16,
            bottom: padding.bottom + _bottomClearance,
            child: Material(
              color: _barColor,
              elevation: 8,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setState(() => _expanded = true),
                child: SizedBox(
                  width: _collapsedSize,
                  height: _collapsedSize,
                  child: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }

        return Positioned(
          left: 16,
          right: 16,
          bottom: padding.bottom + _bottomClearance,
          child: Material(
            color: _barColor,
            elevation: 20,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        if (currentReciter != null)
                          ReciterAvatar(
                            reciterId: currentReciter.id,
                            name: currentReciter.name,
                            size: 36,
                          )
                        else
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                surahTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              if (reciterName != null)
                                Text(
                                  reciterName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _expanded = false),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  _ProgressLine(handler: handler, isRangeMode: isRangeMode),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () => openNowPlayingPage(),
                        icon: const Icon(Icons.menu_rounded),
                        color: Colors.white,
                      ),

                      const Spacer(),
                      IconButton(
                        onPressed:
                            canGoPrevious ? handler.skipToPrevious : null,
                        icon: const Icon(Icons.skip_previous_rounded),
                        color: Colors.white,
                        disabledColor: Colors.white24,
                      ),
                      const SizedBox(width: 4),
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: playing ? handler.pause : handler.play,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 26,
                              color: _barColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: canGoNext ? handler.skipToNext : null,
                        icon: const Icon(Icons.skip_next_rounded),
                        color: Colors.white,
                        disabledColor: Colors.white24,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          final index = chapterNumber - 1;
                          ref
                              .read(quranFavoritesProvider.notifier)
                              .toggle(
                                chapterNumber: chapterNumber,
                                chapterName: kSurahArabicNames[index],
                                chapterEnglishName: kSurahEnglishNames[index],
                              );
                        },
                        icon: Icon(
                          liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                        ),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Playback progress line spanning the bar's top edge, with live elapsed /
/// total duration labels underneath — mirrors the Now Playing page's slider.
///
/// Deliberately hand-rolled instead of a Material [Slider]: this widget
/// lives outside `MaterialApp`'s Navigator subtree (see
/// [QuranMiniPlayerBar]'s doc comment), so there's no ancestor `Overlay` for
/// `Slider`'s internal `OverlayPortal` to find — it throws "No Overlay
/// widget found" the instant it builds.
class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.handler, required this.isRangeMode});

  final QuranAudioHandler handler;
  final bool isRangeMode;

  static String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return d.inHours > 0
        ? '${d.inHours}:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds on every position tick from just_audio, so the elapsed label
    // keeps counting up live while playback continues, same as the slider.
    return StreamBuilder<Duration>(
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
        final duration = rawDuration < position ? position : rawDuration;
        final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds : 1;
        final fraction = (position.inMilliseconds / maxMs).clamp(0.0, 1.0);

        void seekToFraction(double f) {
          final target = Duration(
            milliseconds: (maxMs * f.clamp(0.0, 1.0)).round(),
          );
          isRangeMode ? handler.seekInRange(target) : handler.seek(target);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  // In RTL locales the track reads right-to-left (start =
                  // right edge), so both the fill/thumb position and the
                  // tap-to-seek math need to mirror — this hand-rolled bar
                  // doesn't get that for free the way a Material Slider
                  // would from ambient Directionality.
                  final isRtl = Directionality.of(context) == TextDirection.rtl;
                  void handleLocalDx(double dx) {
                    final raw = dx / width;
                    seekToFraction(isRtl ? 1 - raw : raw);
                  }

                  final double thumbLeft =
                      isRtl
                          ? (width * (1 - fraction) - 5).clamp(0, width - 10)
                          : (width * fraction - 5).clamp(0, width - 10);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => handleLocalDx(d.localPosition.dx),
                    onHorizontalDragUpdate:
                        (d) => handleLocalDx(d.localPosition.dx),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Align(
                          alignment:
                              isRtl
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: fraction,
                            child: Container(
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: thumbLeft,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
