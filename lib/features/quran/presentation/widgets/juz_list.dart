import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/juz_starting_points.dart';
import '../controllers/quran_providers.dart';
import '../pages/quran_range_detail_page.dart';

/// The 30 Juz' (Para), each showing which surah it starts at — resolved
/// from the already-fetched chapters list rather than a hardcoded name
/// table, so it can never drift out of sync with the real data. Filterable
/// by Juz number or starting-surah name via [query].
class JuzList extends ConsumerWidget {
  const JuzList({super.key, this.query = ''});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final q = query.trim().toLowerCase();

    final entries = <(int juzNumber, int startSurah, int startAyah, String? startSurahName)>[];
    for (var i = 0; i < juzStartingPoints.length; i++) {
      final (startSurah, startAyah) = juzStartingPoints[i];
      final startSurahName = chaptersAsync.maybeWhen(
        data: (chapters) {
          for (final c in chapters) {
            if (c.number == startSurah) return c.englishName;
          }
          return null;
        },
        orElse: () => null,
      );
      entries.add((i + 1, startSurah, startAyah, startSurahName));
    }

    final filtered = q.isEmpty
        ? entries
        : entries
            .where((e) =>
                '${e.$1}' == q || (e.$4?.toLowerCase().contains(q) ?? false))
            .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No Juz matches "$query"', textAlign: TextAlign.center),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final (juzNumber, startSurah, startAyah, startSurahName) = filtered[index];

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white12
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.violet]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$juzNumber',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text('Juz $juzNumber', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(
              startSurahName != null ? 'Starts at $startSurahName $startSurah:$startAyah' : 'Loading…',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuranRangeDetailPage(
                    title: 'Juz $juzNumber',
                    rangeProvider: juzProvider(juzNumber),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
