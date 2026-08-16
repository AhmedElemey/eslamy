import 'package:flutter/material.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/number_seal.dart';
import '../../../duas/presentation/pages/azkar_categories_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../hadith/presentation/pages/hadith_books_page.dart';
import '../../../hajj_umrah/presentation/pages/hajj_umrah_home_page.dart';
import '../../../hifz/presentation/pages/hifz_page.dart';
import '../../../hijri_calendar/presentation/pages/hijri_calendar_page.dart';
import '../../../mosque_locator/presentation/pages/mosque_locator_page.dart';
import '../../../prayer_times/presentation/pages/qibla_page.dart';
import '../../../quran/presentation/widgets/reciter_selection_widget.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../tasbih/presentation/pages/tasbih_page.dart';
import '../../../../shared/widgets/shell_app_bar.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <_MoreItem>[
      _MoreItem(
        Icons.donut_large_outlined,
        l10n.tasbihCounterTitle,
        const TasbihPage(),
      ),
      _MoreItem(
        Icons.auto_awesome_outlined,
        l10n.duasAzkarTitle,
        const AzkarCategoriesPage(),
      ),
      _MoreItem(
        Icons.mosque_outlined,
        l10n.hajjUmrahGuideTitle,
        const HajjUmrahHomePage(),
      ),
      _MoreItem(
        Icons.explore_outlined,
        l10n.qiblaDirectionTitle,
        const QiblaPage(),
      ),
      _MoreItem(
        Icons.near_me_outlined,
        l10n.mosqueLocatorTitle,
        const MosqueLocatorPage(),
      ),
      _MoreItem(
        Icons.import_contacts_outlined,
        l10n.hadithLabel,
        const HadithBooksPage(),
      ),
      _MoreItem(
        Icons.bookmarks_outlined,
        l10n.favoritesTitle,
        const FavoritesPage(),
      ),
      _MoreItem(
        Icons.calendar_month_outlined,
        l10n.hijriCalendarTitle,
        const HijriCalendarPage(),
      ),
      _MoreItem(Icons.school_outlined, l10n.hifzProgress, const HifzPage()),
      _MoreItem(
        Icons.settings_outlined,
        l10n.settingsTitle,
        const SettingsPage(),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: ShellAwareAppBar(title: Text(l10n.navMoreLabel)),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const ReciterSelectionWidget(),
              const SizedBox(height: 8),
              for (final item in items) ...[
                GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => item.page));
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: IconSeal(icon: item.icon),
                    title: Text(item.label),
                    trailing: Icon(
                      chevronFor(context),
                      color: AppColors.mutedText(context),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem(this.icon, this.label, this.page);
  final IconData icon;
  final String label;
  final Widget page;
}
