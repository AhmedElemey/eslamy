class AzkarCategory {
  final String id;
  final String name;
  final String description;

  const AzkarCategory({required this.id, required this.name, required this.description});

  factory AzkarCategory.fromJson(Map<String, dynamic> json) => AzkarCategory(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
  );
}

class AzkarItem {
  final int id;
  final String categoryId;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String source;
  final int repeat;

  const AzkarItem({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.source,
    required this.repeat,
  });

  factory AzkarItem.fromJson(Map<String, dynamic> json) => AzkarItem(
    id: json['id'] as int,
    categoryId: json['category'] as String,
    title: json['title'] as String? ?? '',
    arabic: json['arabic'] as String,
    transliteration: json['transliteration'] as String? ?? '',
    translation: json['translation'] as String? ?? '',
    source: json['source'] as String? ?? '',
    repeat: json['repeat'] as int? ?? 1,
  );
}

/// The response shape is identical whether it comes from the bundled asset
/// seed or the live UmmahAPI refresh, so both datasources parse into this.
class AzkarDataset {
  final List<AzkarCategory> categories;
  final List<AzkarItem> items;

  const AzkarDataset({required this.categories, required this.items});

  factory AzkarDataset.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final categoriesJson = data['categories'] as List<dynamic>;
    final duasJson = data['duas'] as List<dynamic>;
    return AzkarDataset(
      categories: categoriesJson
          .map((e) => AzkarCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: duasJson.map((e) => AzkarItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
