import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widget/widget_content_kind.dart';
import '../../service/settings_database.dart';

/// The user's chosen set of content kinds that rotate through the home
/// screen widget (see WidgetCustomizationPage). Persisted locally;
/// WidgetSyncBootstrapper mirrors every change into the native-readable
/// store so the widget itself picks it up.
class WidgetPreferencesController
    extends AsyncNotifier<List<WidgetContentKind>> {
  @override
  Future<List<WidgetContentKind>> build() =>
      SettingsDatabase().getWidgetEnabledKinds();

  Future<void> setEnabledKinds(List<WidgetContentKind> kinds) async {
    if (kinds.isEmpty) return; // at least one kind must stay on
    state = AsyncData(kinds);
    await SettingsDatabase().setWidgetEnabledKinds(kinds);
  }

  /// Flips one kind on/off, no-op if that would leave nothing enabled.
  /// Rebuilds in canonical enum order so the rotation order stays
  /// deterministic regardless of which kind was toggled.
  Future<void> toggle(WidgetContentKind kind) async {
    final current = (state.valueOrNull ?? WidgetContentKind.values).toSet();
    if (!current.remove(kind)) current.add(kind);
    if (current.isEmpty) return;
    final ordered =
        WidgetContentKind.values.where(current.contains).toList();
    await setEnabledKinds(ordered);
  }
}

final widgetPreferencesProvider =
    AsyncNotifierProvider<WidgetPreferencesController, List<WidgetContentKind>>(
      () => WidgetPreferencesController(),
    );
