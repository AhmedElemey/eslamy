import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/now_playing_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/quran_providers.dart';

/// Messenger-style persistent bubble: shown over every screen in the app
/// (plugged into `MyApp`'s root `builder`, not `MainShell`, so pushed detail
/// routes don't hide it) whenever a surah is loaded, playing or paused.
/// Hidden while Now Playing is already the top route so it doesn't cover
/// that page's controls or push a duplicate route. Dragging repositions it
/// — closing it fully lives in the Android system overlay bubble, not here.
class QuranNowPlayingFab extends ConsumerStatefulWidget {
  const QuranNowPlayingFab({super.key});

  @override
  ConsumerState<QuranNowPlayingFab> createState() => _QuranNowPlayingFabState();
}

class _QuranNowPlayingFabState extends ConsumerState<QuranNowPlayingFab> {
  static const double _size = 56;
  static const double _tapSlop = 8;
  Offset? _offset;
  Offset? _pointerDown;
  bool _dragged = false;

  @override
  Widget build(BuildContext context) {
    final mediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final playing =
        ref.watch(playbackStateProvider).valueOrNull?.playing ?? false;
    if (mediaItem == null) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: RootRouteTracker.instance.currentRouteName,
      builder: (context, _) {
        if (RootRouteTracker.instance.isNowPlaying) {
          return const SizedBox.shrink();
        }

        final screenSize = MediaQuery.sizeOf(context);
        final padding = MediaQuery.paddingOf(context);
        final offset = _offset ??= Offset(
          screenSize.width - _size - 16,
          screenSize.height - padding.bottom - _size - 96,
        );

        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              _pointerDown = event.position;
              _dragged = false;
            },
            onPointerMove: (event) {
              final start = _pointerDown;
              if (start == null) return;
              if ((event.position - start).distance > _tapSlop) {
                _dragged = true;
                setState(() {
                  final next = Offset(
                    event.position.dx - _size / 2,
                    event.position.dy - _size / 2,
                  );
                  _offset = Offset(
                    next.dx.clamp(0, screenSize.width - _size),
                    next.dy.clamp(
                      padding.top,
                      screenSize.height - padding.bottom - _size,
                    ),
                  );
                });
              }
            },
            onPointerUp: (_) {
              if (!_dragged) {
                // Must not use Navigator.of(context): this widget is a Stack
                // sibling of MaterialApp's `child`, not a navigator descendant.
                openNowPlayingPage();
              }
              _pointerDown = null;
              _dragged = false;
            },
            onPointerCancel: (_) {
              _pointerDown = null;
              _dragged = false;
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
      },
    );
  }
}
