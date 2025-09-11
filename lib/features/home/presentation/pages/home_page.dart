import 'package:flutter/material.dart';
import '../../../hadith/presentation/pages/hadith_list_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6C3BFF);
    const textMuted = Color(0xFF8E8E93);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: primary,
          centerTitle: false,
          titleSpacing: 0,
          title: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Quran App',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: primary),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded, color: primary),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Container(),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 4),
                    Text(
                      'Asslamualaikum',
                      style: TextStyle(color: textMuted, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tanvir Ahassan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _LastReadCard(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const TabBar(
                  isScrollable: true,
                  indicatorColor: primary,
                  labelColor: primary,
                  unselectedLabelColor: textMuted,
                  tabs: [
                    Tab(text: 'Surah'),
                    Tab(text: 'Para'),
                    Tab(text: 'Page'),
                    Tab(text: 'Hijb'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Expanded(
                child: TabBarView(
                  children: [
                    _SurahList(),
                    Center(child: Text('Para')),
                    Center(child: Text('Page')),
                    Center(child: Text('Hijb')),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.bookmarks_outlined, color: textMuted),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesPage(),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: const Icon(Icons.menu_book_rounded, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.mosque_outlined, color: textMuted),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: const HadithListSheet(),
                      ),
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

class _LastReadCard extends StatelessWidget {
  const _LastReadCard();

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6C3BFF);
    return Container(
      decoration: BoxDecoration(
        color: primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Last Read',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Al-Fatiah',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Ayah No: 1',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  const _SurahList();

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6C3BFF);
    const textMuted = Color(0xFF8E8E93);
    final items = const [
      ['1', 'Al-Fatiah', 'MECCAN • 7 VERSES', 'الفاتحة'],
      ['2', 'Al-Baqarah', 'MEDINIAN • 286 VERSES', 'البقرة'],
      ['3', "Ali 'Imran", 'MECCAN • 200 VERSES', 'آل عمران'],
      ['4', 'An-Nisa', 'MECCAN • 176 VERSES', 'النساء'],
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final s = items[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          leading: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              s[0],
              style: const TextStyle(color: primary, fontWeight: FontWeight.w700),
            ),
          ),
          title: Text(
            s[1],
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            s[2],
            style: const TextStyle(color: textMuted),
          ),
          trailing: Text(
            s[3],
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: primary, fontWeight: FontWeight.w700),
          ),
          onTap: () {},
        );
      },
    );
  }
}


