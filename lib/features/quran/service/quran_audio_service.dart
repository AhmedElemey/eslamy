class QuranAudioService {
  // Available reciters with enhanced data. `server` is the verified-working
  // base URL from mp3quran.net's official API (mp3quran.net/api/v3/reciters) —
  // each file is `${server}{surahNumber, zero-padded to 3 digits}.mp3`.
  static const Map<String, Map<String, String>> _reciters = {
    'Abdul_Basit_Mujawwad': {
      'id': '1',
      'englishName': 'Abdul Basit Mujawwad',
      'arabicName': 'عبد الباسط عبد الصمد',
      'style': 'Mujawwad (Melodic)',
      'server': 'https://server7.mp3quran.net/basit/Almusshaf-Al-Mojawwad/',
    },
    'Abdul_Basit_Murattal': {
      'id': '2',
      'englishName': 'Abdul Basit Murattal',
      'arabicName': 'عبد الباسط عبد الصمد',
      'style': 'Murattal (Slow)',
      'server': 'https://server7.mp3quran.net/basit/',
    },
    'Mishary_Rashid_Alafasy': {
      'id': '3',
      'englishName': 'Mishary Rashid Alafasy',
      'arabicName': 'مشاري راشد العفاسي',
      'style': 'Modern',
      'server': 'https://server8.mp3quran.net/afs/',
    },
    'Saad_Al_Ghamdi': {
      'id': '4',
      'englishName': 'Saad Al Ghamdi',
      'arabicName': 'سعد الغامدي',
      'style': 'Traditional',
      'server': 'https://server7.mp3quran.net/s_gmd/',
    },
    'Saud_Al_Shuraim': {
      'id': '5',
      'englishName': 'Saud Al Shuraim',
      'arabicName': 'سعود الشريم',
      'style': 'Traditional',
      'server': 'https://server7.mp3quran.net/shur/',
    },
    'Abdullah_Matroud': {
      'id': '6',
      'englishName': 'Abdullah Matroud',
      'arabicName': 'عبد الله المطرود',
      'style': 'Murattal',
      'server': 'https://server8.mp3quran.net/mtrod/',
    },
    'Muhammad_Ayyub': {
      'id': '7',
      'englishName': 'Muhammad Ayyub',
      'arabicName': 'محمد أيوب',
      'style': 'Traditional',
      'server': 'https://server8.mp3quran.net/ayyub/',
    },
    'Yasser_Al_Dosari': {
      'id': '8',
      'englishName': 'Yasser Al Dosari',
      'arabicName': 'ياسر الدوسري',
      'style': 'Modern',
      'server': 'https://server11.mp3quran.net/yasser/',
    },
    'Maher_Al_Muaiqly': {
      'id': '9',
      'englishName': 'Maher Al Muaiqly',
      'arabicName': 'ماهر المعيقلي',
      'style': 'Traditional',
      'server': 'https://server12.mp3quran.net/maher/',
    },
    'Muhammad_Al_Muhaisany': {
      'id': '10',
      'englishName': 'Muhammad Al Muhaisany',
      'arabicName': 'محمد المحيسني',
      'style': 'Modern',
      'server': 'https://server11.mp3quran.net/mhsny/',
    },
  };

  // everyayah.com folder for each reciter that has true per-ayah files
  // (verified against its directory listing and a live file fetch), used so
  // "play/loop this verse" actually plays that one verse instead of the
  // whole surah. Reciters not listed here have no per-ayah source and fall
  // back to the whole-surah file, same as before.
  static const Map<String, String> _everyayahFolders = {
    'Abdul_Basit_Mujawwad': 'Abdul_Basit_Mujawwad_128kbps',
    'Abdul_Basit_Murattal': 'Abdul_Basit_Murattal_192kbps',
    'Mishary_Rashid_Alafasy': 'Alafasy_128kbps',
    'Saad_Al_Ghamdi': 'Ghamadi_40kbps',
    'Saud_Al_Shuraim': 'Saood_ash-Shuraym_128kbps',
    'Abdullah_Matroud': 'Abdullah_Matroud_128kbps',
    'Muhammad_Ayyub': 'Muhammad_Ayyoub_128kbps',
    'Yasser_Al_Dosari': 'Yasser_Ad-Dussary_128kbps',
    'Maher_Al_Muaiqly': 'MaherAlMuaiqly128kbps',
    // Muhammad_Al_Muhaisany has no everyayah.com per-ayah folder.
  };

  static Future<String> getVerseAudioUrl(
    int chapterNumber,
    int verseNumber, {
    String? reciterId,
  }) async {
    final reciterKey = reciterId ?? 'Abdul_Basit_Mujawwad';
    final folder = _everyayahFolders[reciterKey];
    if (folder == null) {
      // No per-ayah source for this reciter — same whole-surah fallback as
      // before.
      return getChapterAudioUrl(chapterNumber, reciterId: reciterId);
    }
    final surah = chapterNumber.toString().padLeft(3, '0');
    final ayah = verseNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$folder/$surah$ayah.mp3';
  }

  static List<String> getAvailableReciters() {
    return _reciters.keys.toList();
  }

  static Map<String, String> getReciterInfo(String reciterKey) {
    return _reciters[reciterKey] ?? _reciters.values.first;
  }

  static List<Map<String, String>> getAllReciters() {
    return _reciters.entries
        .map((entry) => {'key': entry.key, ...entry.value})
        .toList();
  }

  static Future<String> getChapterAudioUrl(
    int chapterNumber, {
    String? reciterId,
  }) async {
    final reciterKey = reciterId ?? 'Abdul_Basit_Mujawwad';
    final server = _reciters[reciterKey]?['server'] ?? _reciters['Abdul_Basit_Murattal']!['server']!;
    final formattedChapterNumber = chapterNumber.toString().padLeft(3, '0');
    return '$server$formattedChapterNumber.mp3';
  }
}
