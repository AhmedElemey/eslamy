import 'package:flutter/material.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/shell_app_bar.dart';
import '../../presentation/controllers/quran_providers.dart';
import '../widgets/juz_list.dart';
import '../widgets/quran_number_grid.dart';
import '../widgets/searchable_surah_list.dart';

class QuranIndexPage extends StatefulWidget {
  const QuranIndexPage({super.key});

  @override
  State<QuranIndexPage> createState() => _QuranIndexPageState();
}

class _QuranIndexPageState extends State<QuranIndexPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';
  int _previousTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _previousTabIndex) {
        _previousTabIndex = _tabController.index;
        _searchController.clear();
        setState(() => _query = '');
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [l10n.tabSurah, l10n.tabPara, l10n.tabPage, l10n.tabHizb];
    final hints = [
      l10n.searchSurahHint,
      l10n.searchJuzHint,
      l10n.searchPageHint,
      l10n.searchHizbHint,
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: ShellAwareAppBar(title: Text(l10n.digitalMushaf)),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  keyboardType:
                      _tabController.index >= 2
                          ? TextInputType.number
                          : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: hints[_tabController.index],
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon:
                        _query.isEmpty
                            ? null
                            : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.heading(context),
                unselectedLabelColor: AppColors.mutedText(context),
                tabs: tabs.map((t) => Tab(text: t)).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SearchableSurahList(query: _query),
                    JuzList(query: _query),
                    QuranNumberGrid(
                      count: 604,
                      labelPrefix: l10n.tabPage,
                      query: _query,
                      rangeProviderBuilder: (n) => quranPageProvider(n),
                    ),
                    QuranNumberGrid(
                      count: 240,
                      labelPrefix: l10n.tabHizb,
                      query: _query,
                      rangeProviderBuilder: (n) => hizbQuarterProvider(n),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
