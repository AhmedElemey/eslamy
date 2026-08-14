import 'package:flutter/material.dart';

/// One Tajweed rule as encoded by Al Quran Cloud's `quran-tajweed` edition.
///
/// [code] is the single-letter bracket identifier used in the raw API text
/// (e.g. `h` in `[h:1[...]`) — see tajweed_text_parser.dart. Colors and
/// descriptions match the reference parser (islamic-network/alquran-tools,
/// Tajweed.php) so this app's coloring matches other Tajweed apps/PDFs.
class TajweedRule {
  final String code;
  final String key;
  final String englishName;
  final String arabicName;
  final Color color;

  const TajweedRule({
    required this.code,
    required this.key,
    required this.englishName,
    required this.arabicName,
    required this.color,
  });
}

/// All 17 Tajweed rules, keyed by their single-letter bracket code.
///
/// Note: the upstream PHP reference implementation has a bug where two rules
/// share the same array key and one silently overwrites the other (Madda
/// Necessary is lost). This map uses the code string as the key, so every
/// rule — including Madda Necessary — stays distinct.
const Map<String, TajweedRule> tajweedRules = {
  'h': TajweedRule(
    code: 'h',
    key: 'ham_wasl',
    englishName: 'Hamzat ul Wasl',
    arabicName: 'همزة الوصل',
    color: Color(0xFFAAAAAA),
  ),
  's': TajweedRule(
    code: 's',
    key: 'slnt',
    englishName: 'Silent',
    arabicName: 'حرف ساكن',
    color: Color(0xFFAAAAAA),
  ),
  'l': TajweedRule(
    code: 'l',
    key: 'laam_shamsiyah',
    englishName: 'Lam Shamsiyyah',
    arabicName: 'اللام الشمسية',
    color: Color(0xFFAAAAAA),
  ),
  'n': TajweedRule(
    code: 'n',
    key: 'madda_normal',
    englishName: 'Normal Prolongation: 2 Vowels',
    arabicName: 'مد طبيعي',
    color: Color(0xFF537FFF),
  ),
  'p': TajweedRule(
    code: 'p',
    key: 'madda_permissible',
    englishName: 'Permissible Prolongation: 2, 4, 6 Vowels',
    arabicName: 'مد جائز',
    color: Color(0xFF4050FF),
  ),
  'm': TajweedRule(
    code: 'm',
    key: 'madda_necessary',
    englishName: 'Necessary Prolongation: 6 Vowels',
    arabicName: 'مد لازم',
    color: Color(0xFF000EBC),
  ),
  'q': TajweedRule(
    code: 'q',
    key: 'qalqalah',
    englishName: 'Qalqalah',
    arabicName: 'قلقلة',
    color: Color(0xFFDD0008),
  ),
  'o': TajweedRule(
    code: 'o',
    key: 'madda_obligatory',
    englishName: 'Obligatory Prolongation: 4-5 Vowels',
    arabicName: 'مد واجب',
    color: Color(0xFF2144C1),
  ),
  'c': TajweedRule(
    code: 'c',
    key: 'ikhfa_shafawi',
    englishName: "Ikhfa' Shafawi - With Meem",
    arabicName: 'إخفاء شفوي',
    color: Color(0xFFD500B7),
  ),
  'f': TajweedRule(
    code: 'f',
    key: 'ikhfa',
    englishName: "Ikhfa'",
    arabicName: 'إخفاء',
    color: Color(0xFF9400A8),
  ),
  'w': TajweedRule(
    code: 'w',
    key: 'idgham_shafawi',
    englishName: 'Idgham Shafawi - With Meem',
    arabicName: 'إدغام شفوي',
    color: Color(0xFF58B800),
  ),
  'i': TajweedRule(
    code: 'i',
    key: 'iqlab',
    englishName: 'Iqlab',
    arabicName: 'إقلاب',
    color: Color(0xFF26BFFD),
  ),
  'a': TajweedRule(
    code: 'a',
    key: 'idgham_ghunnah',
    englishName: 'Idgham - With Ghunnah',
    arabicName: 'إدغام بغنة',
    color: Color(0xFF169200),
  ),
  'u': TajweedRule(
    code: 'u',
    key: 'idgham_no_ghunnah',
    englishName: 'Idgham - Without Ghunnah',
    arabicName: 'إدغام بغير غنة',
    color: Color(0xFF169200),
  ),
  'd': TajweedRule(
    code: 'd',
    key: 'idgham_mutajanisayn',
    englishName: 'Idgham - Mutajanisayn',
    arabicName: 'إدغام متجانسين',
    color: Color(0xFFA1A1A1),
  ),
  'b': TajweedRule(
    code: 'b',
    key: 'idgham_mutaqaribayn',
    englishName: 'Idgham - Mutaqaribayn',
    arabicName: 'إدغام متقاربين',
    color: Color(0xFFA1A1A1),
  ),
  'g': TajweedRule(
    code: 'g',
    key: 'ghunnah',
    englishName: 'Ghunnah: 2 Vowels',
    arabicName: 'غنة',
    color: Color(0xFFFF7E1E),
  ),
};
