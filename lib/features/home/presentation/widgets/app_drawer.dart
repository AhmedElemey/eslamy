import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/islamic_pattern_painter.dart';
import '../../../duas/presentation/pages/azkar_categories_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../hadith/presentation/pages/hadith_books_page.dart';
import '../../../hifz/presentation/pages/hifz_page.dart';
import '../../../hijri_calendar/presentation/pages/hijri_calendar_page.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_providers.dart';
import '../../../prayer_times/presentation/pages/prayer_times_page.dart';
import '../../../prayer_times/presentation/pages/qibla_page.dart';
import '../../../quran/presentation/pages/quran_index_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../tasbih/presentation/pages/tasbih_page.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hijriDate = ref.watch(prayerTimesProvider).timings?.hijriDate;
    final today = DateTime.now();

    final sections = <_DrawerSection>[
      _DrawerSection(null, [
        _DrawerItem(Icons.home_rounded, l10n.appTitle, () => null),
      ]),
      _DrawerSection(l10n.drawerSectionWorship, [
        _DrawerItem(
          Icons.access_time_rounded,
          l10n.prayerTimesTitle,
          () => const PrayerTimesPage(),
        ),
        _DrawerItem(
          Icons.explore_outlined,
          l10n.qiblaDirectionTooltip,
          () => const QiblaPage(),
        ),
        _DrawerItem(
          Icons.fingerprint_rounded,
          l10n.tasbihCounterTitle,
          () => const TasbihPage(),
        ),
        _DrawerItem(
          Icons.auto_awesome_outlined,
          l10n.duasAzkarTitle,
          () => const AzkarCategoriesPage(),
        ),
        _DrawerItem(
          Icons.calendar_month_outlined,
          l10n.hijriCalendarTitle,
          () => const HijriCalendarPage(),
        ),
      ]),
      _DrawerSection(l10n.drawerSectionQuranStudy, [
        _DrawerItem(
          Icons.menu_book_rounded,
          l10n.digitalMushaf,
          () => const QuranIndexPage(),
        ),
        _DrawerItem(
          Icons.school_outlined,
          l10n.hifzProgress,
          () => const HifzPage(),
        ),
        _DrawerItem(
          Icons.import_contacts_outlined,
          l10n.hadithLabel,
          () => const HadithBooksPage(),
        ),
        _DrawerItem(
          Icons.bookmarks_outlined,
          l10n.favoritesTitle,
          () => const FavoritesPage(),
        ),
      ]),
      _DrawerSection(null, [
        _DrawerItem(
          Icons.settings_outlined,
          l10n.settingsTitle,
          () => const SettingsPage(),
        ),
      ]),
    ];

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
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
                  style: const TextStyle(
                    color: AppColors.muted,
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
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: AppColors.primary, size: 19),
                ),
                title: Text(
                  item.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  final page = item.pageBuilder();
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
  _DrawerItem(this.icon, this.label, this.pageBuilder);
  final IconData icon;
  final String label;
  final Widget? Function() pageBuilder;
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
          colors: [AppColors.primaryDeep, AppColors.primary, AppColors.violet],
          stops: [0, 0.55, 1],
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
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
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
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hijriDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    hijriDate!,
                    style: TextStyle(
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
