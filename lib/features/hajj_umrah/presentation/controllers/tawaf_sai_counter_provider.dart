import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/tawaf_sai_counter_service.dart';

enum TawafSaiMode { tawaf, sai }

const tawafSaiTarget = 7;

final tawafSaiCounterServiceProvider = Provider(
  (ref) => TawafSaiCounterService(),
);

class TawafSaiCounterState {
  const TawafSaiCounterState({required this.mode, required this.count});

  final TawafSaiMode mode;
  final int count;

  TawafSaiCounterState copyWith({TawafSaiMode? mode, int? count}) {
    return TawafSaiCounterState(
      mode: mode ?? this.mode,
      count: count ?? this.count,
    );
  }
}

/// Circuit counter for Tawaf (around the Ka'bah) and Sa'i (between Safa
/// and Marwah) — both count to 7, tracked and persisted separately so
/// switching modes doesn't lose progress. Mirrors tasbih_providers.dart.
class TawafSaiCounterNotifier extends StateNotifier<TawafSaiCounterState> {
  TawafSaiCounterNotifier(this._service)
    : super(const TawafSaiCounterState(mode: TawafSaiMode.tawaf, count: 0)) {
    _restore();
  }

  final TawafSaiCounterService _service;

  Future<void> _restore() async {
    final count = await _service.getTawafCount();
    if (!mounted) return;
    state = state.copyWith(count: count);
  }

  Future<void> increment() async {
    if (state.count >= tawafSaiTarget) return;
    final next = state.count + 1;
    state = state.copyWith(count: next);
    await _save(next);
  }

  Future<void> reset() async {
    state = state.copyWith(count: 0);
    await _save(0);
  }

  Future<void> selectMode(TawafSaiMode mode) async {
    if (mode == state.mode) return;
    final count =
        mode == TawafSaiMode.tawaf
            ? await _service.getTawafCount()
            : await _service.getSaiCount();
    if (!mounted) return;
    state = TawafSaiCounterState(mode: mode, count: count);
  }

  Future<void> _save(int count) {
    return state.mode == TawafSaiMode.tawaf
        ? _service.setTawafCount(count)
        : _service.setSaiCount(count);
  }
}

final tawafSaiCounterProvider =
    StateNotifierProvider<TawafSaiCounterNotifier, TawafSaiCounterState>((ref) {
      return TawafSaiCounterNotifier(ref.watch(tawafSaiCounterServiceProvider));
    });
