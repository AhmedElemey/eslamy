class DhikrPreset {
  final String id;
  final String arabic;
  final String englishName;
  final int target;

  const DhikrPreset({
    required this.id,
    required this.arabic,
    required this.englishName,
    required this.target,
  });

  factory DhikrPreset.fromJson(Map<String, dynamic> json) => DhikrPreset(
    id: json['id'] as String,
    arabic: json['arabic'] as String,
    englishName: json['englishName'] as String,
    target: json['target'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'arabic': arabic,
    'englishName': englishName,
    'target': target,
  };
}

const List<DhikrPreset> dhikrPresets = [
  DhikrPreset(
    id: 'subhanallah',
    arabic: 'سُبْحَانَ اللَّهِ',
    englishName: 'SubhanAllah',
    target: 33,
  ),
  DhikrPreset(
    id: 'alhamdulillah',
    arabic: 'الْحَمْدُ لِلَّهِ',
    englishName: 'Alhamdulillah',
    target: 33,
  ),
  DhikrPreset(
    id: 'allahuakbar',
    arabic: 'اللَّهُ أَكْبَرُ',
    englishName: 'Allahu Akbar',
    target: 34,
  ),
  DhikrPreset(
    id: 'lailahaillallah',
    arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
    englishName: 'La ilaha illa Allah',
    target: 100,
  ),
  DhikrPreset(
    id: 'astaghfirullah',
    arabic: 'أَسْتَغْفِرُ اللَّهَ',
    englishName: 'Astaghfirullah',
    target: 100,
  ),
  DhikrPreset(
    id: 'custom',
    arabic: 'ذِكْر',
    englishName: 'Custom',
    target: 100,
  ),
];
