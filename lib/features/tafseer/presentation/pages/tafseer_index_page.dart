import 'package:flutter/material.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../quran/presentation/widgets/searchable_surah_list.dart';
import 'tafseer_chapter_page.dart';

class TafseerIndexPage extends StatefulWidget {
  const TafseerIndexPage({super.key});

  @override
  State<TafseerIndexPage> createState() => _TafseerIndexPageState();
}

class _TafseerIndexPageState extends State<TafseerIndexPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(l10n.quranTafseerTitle)),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: l10n.searchSurahHint,
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
              Expanded(
                child: SearchableSurahList(
                  query: _query,
                  chapterPageBuilder:
                      (chapterNumber, chapterName) => TafseerChapterPage(
                        chapterNumber: chapterNumber,
                        chapterName: chapterName,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
