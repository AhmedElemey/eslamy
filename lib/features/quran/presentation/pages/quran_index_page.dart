import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../presentation/controllers/quran_providers.dart';
import '../widgets/juz_list.dart';
import '../widgets/quran_number_grid.dart';
import '../widgets/searchable_surah_list.dart';

/// Full-screen "browse the Quran" experience — Surah / Para (Juz) / Page /
/// Hizb, each with its own search or jump-to-number field. Previously this
/// was a cramped tab strip wedged into the middle of the scrolling Home
/// page (four different content shapes squeezed under one Expanded, no way
/// to search 114 surahs or jump to 1 of 604 pages without endless
/// scrolling); giving it a dedicated screen fixes both.
class QuranIndexPage extends StatefulWidget {
  const QuranIndexPage({super.key});

  @override
  State<QuranIndexPage> createState() => _QuranIndexPageState();
}

class _QuranIndexPageState extends State<QuranIndexPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';

  static const _tabs = ['Surah', 'Para', 'Page', 'Hizb'];
  static const _hints = [
    'Search by name or number…',
    'Search by number or starting surah…',
    'Jump to page number…',
    'Jump to Hizb number…',
  ];

  int _previousTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _previousTabIndex) {
        _previousTabIndex = _tabController.index;
        // Each tab searches something different, so clear rather than carry
        // a stale query (e.g. a surah name) into a numeric jump field.
        _searchController.clear();
        setState(() => _query = '');
      } else {
        // Rebuild so the search hint/keyboard type follow mid-swipe too.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Digital Mushaf')),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  keyboardType: _tabController.index >= 2 ? TextInputType.number : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: _hints[_tabController.index],
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: isDark ? Colors.white : const Color(0xFF16231F),
                unselectedLabelColor: isDark ? Colors.white60 : AppColors.muted,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SearchableSurahList(query: _query),
                    JuzList(query: _query),
                    QuranNumberGrid(
                      count: 604,
                      labelPrefix: 'Page',
                      query: _query,
                      rangeProviderBuilder: (n) => quranPageProvider(n),
                    ),
                    QuranNumberGrid(
                      count: 240,
                      labelPrefix: 'Hizb',
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
