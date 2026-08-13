import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/hifz_database.dart';

final hifzDatabaseProvider = Provider((ref) => HifzDatabase());

/// Set of memorized surah numbers (1-114). Not autoDispose: the home screen
/// entry card reads this alongside the dedicated Hifz page.
class HifzController extends StateNotifier<Set<int>> {
  HifzController(this._db) : super(const {}) {
    _load();
  }

  final HifzDatabase _db;

  Future<void> _load() async {
    final memorized = await _db.getMemorizedSurahs();
    if (!mounted) return;
    state = memorized;
  }

  Future<void> toggle(int surahNumber) async {
    if (state.contains(surahNumber)) {
      await _db.unmarkMemorized(surahNumber);
      state = {...state}..remove(surahNumber);
    } else {
      await _db.markMemorized(surahNumber);
      state = {...state, surahNumber};
    }
  }
}

final hifzProvider = StateNotifierProvider<HifzController, Set<int>>((ref) {
  return HifzController(ref.watch(hifzDatabaseProvider));
});
