import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/streak_database.dart';

final streakDatabaseProvider = Provider((ref) => StreakDatabase());

class StreakState {
  final int currentStreak;
  final Set<String> recentActiveDates;

  const StreakState({
    this.currentStreak = 0,
    this.recentActiveDates = const {},
  });
}

/// Records today's visit once per StreakController lifetime (the app's) and
/// derives the current streak from the stored day log. Not autoDispose: this
/// is read from the home screen for as long as the app runs.
class StreakController extends StateNotifier<StreakState> {
  StreakController(this._db) : super(const StreakState()) {
    _load();
  }

  final StreakDatabase _db;

  Future<void> _load() async {
    await _db.recordToday();
    final dates = await _db.getActiveDates(lookbackDays: 30);
    if (!mounted) return;
    state = StreakState(
      currentStreak: _computeStreak(dates),
      recentActiveDates: dates,
    );
  }

  int _computeStreak(Set<String> dates) {
    var streak = 0;
    var day = DateTime.now();
    while (dates.contains(formatDate(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

final streakProvider = StateNotifierProvider<StreakController, StreakState>((
  ref,
) {
  return StreakController(ref.watch(streakDatabaseProvider));
});
