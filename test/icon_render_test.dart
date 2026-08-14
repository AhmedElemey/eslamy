import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eslamy/core/theme/app_colors.dart';
import 'package:eslamy/shared/widgets/islamic_pattern_painter.dart';

const _canvas = 1024.0;

Future<void> _capture(
  WidgetTester tester,
  Widget child,
  String goldenPath,
) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: key,
        child: SizedBox(width: _canvas, height: _canvas, child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(find.byKey(key), matchesGoldenFile(goldenPath));
}

void main() {
  testWidgets('render app icon assets', (tester) async {
    tester.view.physicalSize = const Size(_canvas, _canvas);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Flattened icon for iOS + legacy Android: full gradient + glyph, opaque.
    await _capture(
      tester,
      Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDeep, AppColors.primary, AppColors.violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const Positioned.fill(child: IslamicPatternOverlay(tileSize: 128, opacity: 0.10)),
          const Center(
            child: Icon(Icons.mosque, color: Colors.white, size: 620),
          ),
        ],
      ),
      '../assets/images/app_icon.png',
    );

    // Adaptive-icon background layer (Android 8+): gradient + pattern only.
    await _capture(
      tester,
      const Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDeep, AppColors.primary, AppColors.violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(child: IslamicPatternOverlay(tileSize: 128, opacity: 0.10)),
        ],
      ),
      '../assets/images/app_icon_background.png',
    );

    // Adaptive-icon foreground layer: glyph only, transparent, kept inside
    // the ~66% safe zone so it survives circular/squircle system masks.
    await _capture(
      tester,
      const Center(
        child: Icon(Icons.mosque, color: Colors.white, size: 460),
      ),
      '../assets/images/app_icon_foreground.png',
    );
  });
}
