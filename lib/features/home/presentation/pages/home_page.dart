import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../hadith/presentation/pages/hadith_books_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../prayer_times/presentation/widgets/prayer_times_card.dart';
import '../../../prayer_times/presentation/pages/qibla_page.dart';
import '../../../quran/presentation/widgets/reciter_selection_widget.dart';
import '../../../streaks/presentation/controllers/streak_providers.dart';
import '../../../hifz/presentation/pages/hifz_page.dart';
import '../../../hifz/presentation/controllers/hifz_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textMuted = isDark ? Colors.white60 : AppColors.muted;
    final headingColor = isDark ? Colors.white : const Color(0xFF16231F);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'Eslamy',
              style: TextStyle(fontWeight: FontWeight.w800, color: headingColor),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu_rounded, color: headingColor),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: headingColor),
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: AppBackground(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top > 0 ? 8 : 0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'ASSALAMU ALAIKUM',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome back',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: headingColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const PrayerTimesCard(),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Expanded(child: _StreakStatTile()),
                      SizedBox(width: 10),
                      Expanded(child: _HifzStatTile()),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const ReciterSelectionWidget(),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: AppColors.primary,
                    labelColor: headingColor,
                    unselectedLabelColor: textMuted,
                    tabs: const [
                      Tab(text: 'Surah'),
                      Tab(text: 'Para'),
                      Tab(text: 'Page'),
                      Tab(text: 'Hijb'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: TabBarView(
                    children: [
                      _SurahList(),
                      const Center(child: Text('Para')),
                      const Center(child: Text('Page')),
                      const Center(child: Text('Hijb')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: GlassCard(
            borderRadius: 28,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.bookmarks_outlined, color: textMuted),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FavoritesPage(),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HadithBooksPage(),
                      ),
                    );
                  },
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.violet],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(14),
                      child: Icon(Icons.menu_book_rounded, color: AppColors.white),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.explore_outlined, color: textMuted),
                  tooltip: 'Qibla direction',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const QiblaPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakStatTile extends ConsumerWidget {
  const _StreakStatTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider).currentStreak;
    return _StatTile(
      icon: const Text('🔥', style: TextStyle(fontSize: 20)),
      value: '$streak day${streak == 1 ? '' : 's'}',
      label: 'streak',
      onTap: () {},
    );
  }
}

class _HifzStatTile extends ConsumerWidget {
  const _HifzStatTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memorized = ref.watch(hifzProvider).length;
    return _StatTile(
      icon: const Icon(Icons.school_outlined, color: AppColors.primary, size: 22),
      value: '$memorized / 114',
      label: 'memorized',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HifzPage()),
        );
      },
    );
  }
}

class _SurahList extends StatelessWidget {
  const _SurahList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = Theme.of(context).textTheme.bodySmall?.color;
    final items = const [
      ['1', 'Al-Fatiah', 'MECCAN • 7 VERSES', 'الفاتحة'],
      ['2', 'Al-Baqarah', 'MEDINIAN • 286 VERSES', 'البقرة'],
      ['3', "Ali 'Imran", 'MECCAN • 200 VERSES', 'آل عمران'],
      ['4', 'An-Nisa', 'MECCAN • 176 VERSES', 'النساء'],
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final s = items[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.violet],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                s[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(s[1], style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(s[2], style: TextStyle(color: textMuted)),
            trailing: Text(
              s[3],
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/quran');
            },
          ),
        );
      },
    );
  }
}
