const _westernToArabicIndicDigits = {
  '0': '٠',
  '1': '١',
  '2': '٢',
  '3': '٣',
  '4': '٤',
  '5': '٥',
  '6': '٦',
  '7': '٧',
  '8': '٨',
  '9': '٩',
};

/// Renders [number] using Arabic-Indic digits (e.g. `91` -> `٩١`), as
/// expected for ayah/verse markers in an Arabic Quran UI.
String toArabicIndicDigits(int number) {
  return number
      .toString()
      .split('')
      .map((digit) => _westernToArabicIndicDigits[digit] ?? digit)
      .join();
}
