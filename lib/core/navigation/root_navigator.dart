import 'package:flutter/widgets.dart';

/// Shared with `MyApp`'s `MaterialApp(navigatorKey: ...)`. Anything that
/// needs to push a route from OUTSIDE the Navigator's own subtree — the
/// persistent audio FAB (a `Stack` sibling of `MaterialApp`'s `child` inside
/// its `builder`, not a descendant) or a callback fired from `main()` itself
/// — must go through this key rather than `Navigator.of(context)`, which
/// throws once nothing above `context` is a Navigator.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
