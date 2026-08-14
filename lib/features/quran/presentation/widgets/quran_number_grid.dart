import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/quran_models.dart';
import '../pages/quran_range_detail_page.dart';

/// Dense numbered grid used for both mushaf pages (1..604) and Hizb
/// quarters (1..240) — both are "just a number, tap to jump" ranges with
/// too many entries to usefully show a subtitle per item (unlike Juz).
/// [query] narrows the grid to numbers containing the typed digits (e.g.
/// "5" matches 5, 15, 25, 50-59, ...) so jumping to a specific one doesn't
/// require scrolling through hundreds of tiles.
class QuranNumberGrid extends StatelessWidget {
  const QuranNumberGrid({
    super.key,
    required this.count,
    required this.labelPrefix,
    required this.rangeProviderBuilder,
    this.query = '',
  });

  final int count;
  final String labelPrefix;
  final ProviderListenable<AsyncValue<List<AyahWithSurah>>> Function(int number) rangeProviderBuilder;
  final String query;

  @override
  Widget build(BuildContext context) {
    final q = query.trim();
    final numbers = [
      for (var n = 1; n <= count; n++)
        if (q.isEmpty || '$n'.contains(q)) n,
    ];

    if (numbers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No $labelPrefix matches "$query"', textAlign: TextAlign.center),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: numbers.length,
      itemBuilder: (context, index) {
        final number = numbers[index];
        return _NumberTile(
          number: number,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuranRangeDetailPage(
                  title: '$labelPrefix $number',
                  rangeProvider: rangeProviderBuilder(number),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({required this.number, required this.onTap});

  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Center(
          child: Text(
            '$number',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
