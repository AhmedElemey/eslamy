import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../hadith/presentation/pages/hadith_books_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_providers.dart';
import '../../../prayer_times/presentation/widgets/prayer_times_card.dart';
import '../../../prayer_times/presentation/pages/qibla_page.dart';
import '../../../prayer_times/presentation/pages/prayer_times_page.dart';
import '../../../quran/presentation/widgets/reciter_selection_widget.dart';
import '../../../quran/presentation/pages/quran_index_page.dart';
import '../../../streaks/presentation/controllers/streak_providers.dart';
import '../../../hifz/presentation/pages/hifz_page.dart';
import '../../../hifz/presentation/controllers/hifz_providers.dart';
import '../../../tasbih/presentation/pages/tasbih_page.dart';
import '../../../duas/presentation/pages/azkar_categories_page.dart';
import '../../../hijri_calendar/presentation/pages/hijri_calendar_page.dart';
import '../widgets/app_drawer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final textMuted = isDark ? Colors.white60 : AppColors.muted;
    final headingColor = isDark ? Colors.white : const Color(0xFF16231F);
    final hijriDate = ref.watch(prayerTimesProvider).timings?.hijriDate;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            l10n.appTitle,
            style: TextStyle(fontWeight: FontWeight.w800, color: headingColor),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, color: headingColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
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
      drawer: const AppDrawer(),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
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
                        l10n.homeGreetingAssalamuAlaikum,
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.homeWelcomeBack,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: headingColor,
                            ),
                          ),
                          const Spacer(),
                          if (hijriDate != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                hijriDate,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
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
                const _QuickAccessRow(),
                const SizedBox(height: 10),
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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _QuranIndexEntryCard(headingColor: headingColor, textMuted: textMuted),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _HomeBottomDock(),
    );
  }
}

/// The floating quick-access dock at the bottom of Home. Redesigned from a
/// 3-item icon-only row (with one oversized "hero" circle) to a labelled
/// 5-item dock with an explicit "Home" active state, so it reads as an
/// anchored navigation surface rather than a handful of loose shortcuts —
/// and so it complements (rather than duplicates) the Quick Access row
/// above, which already covers Tasbih/Duas & Azkar/Hijri/Prayer Times.
class _HomeBottomDock extends StatelessWidget {
  const _HomeBottomDock();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <(IconData, String, bool, VoidCallback?)>[
      (Icons.home_rounded, l10n.navHomeLabel, true, null),
      (Icons.menu_book_rounded, l10n.navQuranLabel, false,
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuranIndexPage()))),
      (Icons.explore_outlined, l10n.navQiblaLabel, false,
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QiblaPage()))),
      (Icons.import_contacts_outlined, l10n.hadithLabel, false,
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HadithBooksPage()))),
      (Icons.bookmarks_outlined, l10n.favoritesTitle, false,
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesPage()))),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassCard(
        borderRadius: 26,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final item in items)
              _DockItem(icon: item.$1, label: item.$2, selected: item.$3, onTap: item.$4),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              height: 1.1,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Surfaces the features that would otherwise be buried in the drawer —
/// Tasbih, Duas & Azkar, and Hijri Calendar have no other entry point from
/// Home, so they get top-level real estate here.
class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <(IconData, String, Color, WidgetBuilder)>[
      (Icons.fingerprint_rounded, l10n.quickAccessTasbih, AppColors.primary, (_) => const TasbihPage()),
      (Icons.auto_awesome_outlined, l10n.duasAzkarTitle, AppColors.gold, (_) => const AzkarCategoriesPage()),
      (Icons.calendar_month_outlined, l10n.hijriCalendarTitle, AppColors.violet, (_) => const HijriCalendarPage()),
      (Icons.access_time_rounded, l10n.prayerTimesTitle, AppColors.primaryDeep, (_) => const PrayerTimesPage()),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final item in items) ...[
            Expanded(
              child: _QuickAccessTile(
                icon: item.$1,
                label: item.$2,
                color: item.$3,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: item.$4)),
              ),
            ),
            if (item != items.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
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
      value: context.l10n.streakDaysShort(streak),
      label: context.l10n.streakStatLabel,
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
      value: context.l10n.memorizedOutOfTotal(memorized, 114),
      label: context.l10n.memorizedStatLabel,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HifzPage()),
        );
      },
    );
  }
}

/// Replaces the old inline Surah/Para/Page/Hizb tab strip that used to sit
/// mid-scroll on Home — cramped, no search, four different content shapes
/// squeezed under one Expanded. This is a single entry point into the new
/// full-screen QuranIndexPage instead.
class _QuranIndexEntryCard extends StatelessWidget {
  const _QuranIndexEntryCard({required this.headingColor, required this.textMuted});

  final Color headingColor;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 20,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const QuranIndexPage()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.violet]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Digital Mushaf',
                  style: TextStyle(fontWeight: FontWeight.w800, color: headingColor, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Browse by Surah, Para, Page, or Hizb',
                  style: TextStyle(color: textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: textMuted),
        ],
      ),
    );
  }
}
