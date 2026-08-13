class HadithItem {
  final int id;
  final String title;
  final String? narrator;
  final String? body;
  final String? book;
  final String? bookName;
  final int? hadithNumber;

  const HadithItem({
    required this.id,
    this.title = '',
    this.narrator,
    this.body,
    this.book,
    this.bookName,
    this.hadithNumber,
  });
}
