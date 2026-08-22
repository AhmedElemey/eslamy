import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/dhikr_preset.dart';
import '../../service/tasbih_preferences_service.dart';

final tasbihPreferencesServiceProvider = Provider(
  (ref) => TasbihPreferencesService(),
);

class TasbihState {
  final DhikrPreset preset;
  final int count;
  final List<DhikrPreset> customPresets;

  const TasbihState({
    required this.preset,
    required this.count,
    this.customPresets = const [],
  });

  TasbihState copyWith({
    DhikrPreset? preset,
    int? count,
    List<DhikrPreset>? customPresets,
  }) {
    return TasbihState(
      preset: preset ?? this.preset,
      count: count ?? this.count,
      customPresets: customPresets ?? this.customPresets,
    );
  }
}

class TasbihNotifier extends StateNotifier<TasbihState> {
  TasbihNotifier(this._prefs)
    : super(TasbihState(preset: dhikrPresets.first, count: 0)) {
    _restore();
  }

  final TasbihPreferencesService _prefs;

  Future<void> _restore() async {
    final customPresets = await _prefs.getCustomPresets();
    final savedId = await _prefs.getSelectedPresetId();
    final preset = [
      ...dhikrPresets,
      ...customPresets,
    ].firstWhere((p) => p.id == savedId, orElse: () => dhikrPresets.first);
    final count = await _prefs.getCount(preset.id);
    if (!mounted) return;
    state = TasbihState(
      preset: preset,
      count: count,
      customPresets: customPresets,
    );
  }

  Future<void> increment() async {
    final next = state.count + 1;
    state = state.copyWith(count: next);
    await _prefs.setCount(state.preset.id, next);
  }

  Future<void> reset() async {
    state = state.copyWith(count: 0);
    await _prefs.setCount(state.preset.id, 0);
  }

  Future<void> selectPreset(DhikrPreset preset) async {
    final count = await _prefs.getCount(preset.id);
    if (!mounted) return;
    state = state.copyWith(preset: preset, count: count);
    await _prefs.setSelectedPresetId(preset.id);
  }

  /// Adds a dhikr/dua the user typed in themselves (see the "Custom" dialog
  /// on TasbihPage), persists it alongside the built-in presets, and
  /// switches straight to it.
  Future<void> addCustomPreset({
    required String arabicText,
    required int target,
  }) async {
    final preset = DhikrPreset(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      arabic: arabicText,
      englishName: arabicText,
      target: target,
    );
    await _prefs.addCustomPreset(preset);
    state = state.copyWith(customPresets: [...state.customPresets, preset]);
    await selectPreset(preset);
  }
}

final tasbihProvider = StateNotifierProvider<TasbihNotifier, TasbihState>((
  ref,
) {
  return TasbihNotifier(ref.watch(tasbihPreferencesServiceProvider));
});
