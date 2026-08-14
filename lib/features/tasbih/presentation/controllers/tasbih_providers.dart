import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/dhikr_preset.dart';
import '../../service/tasbih_preferences_service.dart';

final tasbihPreferencesServiceProvider = Provider((ref) => TasbihPreferencesService());

class TasbihState {
  final DhikrPreset preset;
  final int count;

  const TasbihState({required this.preset, required this.count});

  TasbihState copyWith({DhikrPreset? preset, int? count}) {
    return TasbihState(preset: preset ?? this.preset, count: count ?? this.count);
  }
}

class TasbihNotifier extends StateNotifier<TasbihState> {
  TasbihNotifier(this._prefs) : super(TasbihState(preset: dhikrPresets.first, count: 0)) {
    _restore();
  }

  final TasbihPreferencesService _prefs;

  Future<void> _restore() async {
    final savedId = await _prefs.getSelectedPresetId();
    final preset = dhikrPresets.firstWhere(
      (p) => p.id == savedId,
      orElse: () => dhikrPresets.first,
    );
    final count = await _prefs.getCount(preset.id);
    if (!mounted) return;
    state = TasbihState(preset: preset, count: count);
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
    state = TasbihState(preset: preset, count: count);
    await _prefs.setSelectedPresetId(preset.id);
  }
}

final tasbihProvider = StateNotifierProvider<TasbihNotifier, TasbihState>((ref) {
  return TasbihNotifier(ref.watch(tasbihPreferencesServiceProvider));
});
