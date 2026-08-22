import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/display_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/islamic_pattern_painter.dart';
import '../../../duas/presentation/pages/azkar_categories_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../hadith/presentation/pages/hadith_books_page.dart';
import '../../../hajj_umrah/presentation/pages/hajj_umrah_home_page.dart';
import '../../../hifz/presentation/pages/hifz_page.dart';
import '../../../tafseer/presentation/pages/tafseer_index_page.dart';
import '../../../hijri_calendar/presentation/pages/hijri_calendar_page.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_providers.dart';
import '../../../prayer_times/presentation/pages/qibla_page.dart';
import '../../../quran/presentation/controllers/quran_providers.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../tasbih/presentation/pages/tasbih_page.dart';
import '../controllers/shell_providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final timings = ref.watch(prayerTimesProvider).timings;
    final hijriDate =
        timings == null
            ? null
            : localizedHijriDateAh(
              l10n,
              day: timings.hijriDay,
              month: timings.hijriMonth,
              year: timings.hijriYear,
            );
    final today = DateTime.now();
    // Reserve room below the last item for the global mini player when
    // something is loaded, so it doesn't cover the bottom menu entries.
    final miniPlayerActive =
        ref.watch(currentMediaItemProvider).valueOrNull != null;

    final sections = <_DrawerSection>[
      _DrawerSection(null, [
        _DrawerItem(Icons.home_rounded, l10n.navHomeLabel, tabIndex: 0),
      ]),
      _DrawerSection(l10n.drawerSectionWorship, [
        _DrawerItem(
          Icons.access_time_rounded,
          l10n.prayerTimesTitle,
          tabIndex: 2,
        ),
        _DrawerItem(
          Icons.explore_outlined,
          l10n.qiblaDirectionTooltip,
          pageBuilder: () => const QiblaPage(),
        ),
        _DrawerItem(
          Icons.donut_large_outlined,
          l10n.tasbihCounterTitle,
          pageBuilder: () => const TasbihPage(),
        ),
        _DrawerItem(
          Icons.auto_awesome_outlined,
          l10n.duasAzkarTitle,
          pageBuilder: () => const AzkarCategoriesPage(),
        ),
        _DrawerItem(
          Icons.calendar_month_outlined,
          l10n.hijriCalendarTitle,
          pageBuilder: () => const HijriCalendarPage(),
        ),
        _DrawerItem(
          Icons.mosque_outlined,
          l10n.hajjUmrahGuideTitle,
          pageBuilder: () => const HajjUmrahHomePage(),
        ),
      ]),
      _DrawerSection(l10n.drawerSectionQuranStudy, [
        _DrawerItem(Icons.menu_book_rounded, l10n.digitalMushaf, tabIndex: 1),
        _DrawerItem(
          Icons.auto_stories_outlined,
          l10n.quranTafseerTitle,
          pageBuilder: () => const TafseerIndexPage(),
        ),
        _DrawerItem(
          Icons.school_outlined,
          l10n.hifzProgress,
          pageBuilder: () => const HifzPage(),
        ),
        _DrawerItem(
          Icons.import_contacts_outlined,
          l10n.hadithLabel,
          pageBuilder: () => const HadithBooksPage(),
        ),
        _DrawerItem(
          Icons.bookmarks_outlined,
          l10n.favoritesTitle,
          pageBuilder: () => const FavoritesPage(),
        ),
      ]),
      _DrawerSection(null, [
        _DrawerItem(Icons.grid_view_outlined, l10n.navMoreLabel, tabIndex: 3),
        _DrawerItem(
          Icons.settings_outlined,
          l10n.settingsTitle,
          pageBuilder: () => const SettingsPage(),
        ),
      ]),
    ];

    return Drawer(
      backgroundColor: AppColors.pageBackground(context),
      child: ListView(
        padding: EdgeInsets.only(bottom: miniPlayerActive ? 190 : 0),
        children: [
          _DrawerHeader(
            hijriDate: hijriDate,
            today: today,
            appTitle: l10n.appTitle,
          ),
          for (final section in sections) ...[
            if (section.title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Text(
                  section.title!.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.mutedText(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            for (final item in section.items)
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppColors.primaryOnBg(context),
                    size: 19,
                  ),
                ),
                title: Text(
                  item.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  if (item.tabIndex != null) {
                    ref.read(mainTabIndexProvider.notifier).state =
                        item.tabIndex!;
                    return;
                  }
                  final page = item.pageBuilder?.call();
                  if (page == null) return;
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => page));
                },
              ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DrawerSection {
  const _DrawerSection(this.title, this.items);
  final String? title;
  final List<_DrawerItem> items;
}

class _DrawerItem {
  _DrawerItem(this.icon, this.label, {this.pageBuilder, this.tabIndex});
  final IconData icon;
  final String label;
  final Widget? Function()? pageBuilder;
  final int? tabIndex;
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.hijriDate,
    required this.today,
    required this.appTitle,
  });

  final String? hijriDate;
  final DateTime today;
  final String appTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weekdays = [
      l10n.weekdayMonday,
      l10n.weekdayTuesday,
      l10n.weekdayWednesday,
      l10n.weekdayThursday,
      l10n.weekdayFriday,
      l10n.weekdaySaturday,
      l10n.weekdaySunday,
    ];
    final months = [
      l10n.monthJanuary,
      l10n.monthFebruary,
      l10n.monthMarch,
      l10n.monthApril,
      l10n.monthMay,
      l10n.monthJune,
      l10n.monthJuly,
      l10n.monthAugust,
      l10n.monthSeptember,
      l10n.monthOctober,
      l10n.monthNovember,
      l10n.monthDecember,
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDeepest,
            AppColors.primaryDeep,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            const Positioned.fill(child: IslamicPatternOverlay()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  appTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${weekdays[today.weekday - 1]}, ${today.day} ${months[today.month - 1]}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hijriDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    hijriDate!,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
