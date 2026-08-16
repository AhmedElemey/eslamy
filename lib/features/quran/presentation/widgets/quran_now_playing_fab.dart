import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/root_navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/quran_providers.dart';

/// Messenger-style persistent bubble: shown over every screen in the app
/// (plugged into `MyApp`'s root `builder`, not `MainShell`, so pushed detail
/// routes don't hide it) whenever a surah is loaded, playing or paused.
/// Dragging it around only repositions it — closing it fully lives in the
/// Android system overlay bubble, not here.
class QuranNowPlayingFab extends ConsumerStatefulWidget {
  const QuranNowPlayingFab({super.key});

  @override
  ConsumerState<QuranNowPlayingFab> createState() => _QuranNowPlayingFabState();
}

class _QuranNowPlayingFabState extends ConsumerState<QuranNowPlayingFab> {
  static const double _size = 56;
  Offset? _offset;

  @override
  Widget build(BuildContext context) {
    final mediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    if (mediaItem == null) return const SizedBox.shrink();

    final playing = ref.watch(playbackStateProvider).valueOrNull?.playing ?? false;
    final screenSize = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final offset = _offset ??= Offset(
      screenSize.width - _size - 16,
      screenSize.height - padding.bottom - _size - 96,
    );

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final next = offset + details.delta;
            _offset = Offset(
              next.dx.clamp(0, screenSize.width - _size),
              next.dy.clamp(padding.top, screenSize.height - padding.bottom - _size),
            );
          });
        },
        onTap: () {
          // This widget sits OUTSIDE the Navigator's own subtree — a Stack
          // sibling of MaterialApp's `child` inside its `builder`, not a
          // descendant — so `Navigator.of(context)` throws here. Must go
          // through the shared key instead.
          rootNavigatorKey.currentState?.pushNamed('/now-playing');
        },
        child: Material(
          elevation: 6,
          color: AppColors.primaryOnBg(context),
          shape: const CircleBorder(),
          child: SizedBox(
            width: _size,
            height: _size,
            child: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
