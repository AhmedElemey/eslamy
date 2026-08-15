import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ritual_models.dart';
import '../../service/ritual_progress_service.dart';

final ritualProgressServiceProvider = Provider(
  (ref) => RitualProgressService(),
);

/// Which track (Umrah/Hajj) the checklist screen is currently showing.
final selectedRitualTrackProvider = StateProvider<RitualTrack>(
  (ref) => RitualTrack.umrah,
);

/// Set of completed ritual step ids, following hifz_providers.dart's
/// `StateNotifier<Set<...>>` shape.
class RitualProgressController extends StateNotifier<Set<String>> {
  RitualProgressController(this._service) : super(const {}) {
    _load();
  }

  final RitualProgressService _service;

  Future<void> _load() async {
    final completed = await _service.loadCompletedSteps();
    if (!mounted) return;
    state = completed;
  }

  Future<void> toggle(String stepId) async {
    final next = {...state};
    if (!next.remove(stepId)) {
      next.add(stepId);
    }
    state = next;
    await _service.saveCompletedSteps(next);
  }
}

final ritualProgressProvider =
    StateNotifierProvider<RitualProgressController, Set<String>>((ref) {
      return RitualProgressController(ref.watch(ritualProgressServiceProvider));
    });
