class HadithItem {
  final int id;
  final String title;
  final String? narrator;
  final String? body;

  const HadithItem({
    required this.id,
    this.title = '',
    this.narrator,
    this.body,
  });
}

class HadithPage {
  final List<HadithItem> items;
  final int currentPage;
  final bool hasMore;

  const HadithPage({
    required this.items,
    required this.currentPage,
    required this.hasMore,
  });
}


