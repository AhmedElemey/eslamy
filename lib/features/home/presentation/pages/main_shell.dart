import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../prayer_times/presentation/pages/prayer_times_page.dart';
import '../../../quran/presentation/pages/quran_index_page.dart';
import '../controllers/shell_providers.dart';
import '../widgets/app_drawer.dart';
import 'home_page.dart';
import 'more_page.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(mainTabIndexProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: index,
        children: const [
          HomePage(),
          QuranIndexPage(),
          PrayerTimesPage(),
          MorePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(mainTabIndexProvider.notifier).state = i,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navHomeLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book_rounded),
            label: l10n.navQuranLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.access_time_rounded),
            selectedIcon: const Icon(Icons.access_time_filled_rounded),
            label: l10n.navPrayerLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l10n.navMoreLabel,
          ),
        ],
      ),
    );
  }
}
