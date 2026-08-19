class HadithItem {
  final int id;
  final String title;
  final String? narrator;
  final String? body;
  final String? book;
  final String? bookName;
  final num? hadithNumber;

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

String formatHadithNumber(num? number) {
  if (number == null) return '';
  if (number % 1 == 0) return number.toInt().toString();
  return number.toString();
}
