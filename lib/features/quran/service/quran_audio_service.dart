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
    'Abdulrahman_Al_Sudais': {
      'id': '11',
      'englishName': 'Abdul Rahman Al Sudais',
      'arabicName': 'عبد الرحمن السديس',
      'style': 'Traditional',
      'server': 'https://server11.mp3quran.net/sds/',
    },
    'Mahmoud_Khalil_Al_Husary': {
      'id': '12',
      'englishName': 'Mahmoud Khalil Al Husary',
      'arabicName': 'محمود خليل الحصري',
      'style': 'Traditional',
      'server': 'https://server13.mp3quran.net/husr/',
    },
    'Mohammed_Siddiq_Al_Minshawi': {
      'id': '13',
      'englishName': 'Mohammed Siddiq Al Minshawi',
      'arabicName': 'محمد صديق المنشاوي',
      'style': 'Traditional',
      'server': 'https://server10.mp3quran.net/minsh/',
    },
    'Ahmad_Al_Ajmy': {
      'id': '14',
      'englishName': 'Ahmad Al Ajmy',
      'arabicName': 'أحمد بن علي العجمي',
      'style': 'Traditional',
      'server': 'https://server10.mp3quran.net/ajm/',
    },
    'Hani_Ar_Rifai': {
      'id': '15',
      'englishName': 'Hani Ar Rifai',
      'arabicName': 'هاني الرفاعي',
      'style': 'Traditional',
      'server': 'https://server8.mp3quran.net/hani/',
    },
    'Nasser_Al_Qatami': {
      'id': '16',
      'englishName': 'Nasser Al Qatami',
      'arabicName': 'ناصر القطامي',
      'style': 'Modern',
      'server': 'https://server6.mp3quran.net/qtm/',
    },
    'Fares_Abbad': {
      'id': '17',
      'englishName': 'Fares Abbad',
      'arabicName': 'فارس عباد',
      'style': 'Modern',
      'server': 'https://server8.mp3quran.net/frs_a/',
    },
    'Salah_Bukhatir': {
      'id': '18',
      'englishName': 'Salah Bukhatir',
      'arabicName': 'صلاح بو خاطر',
      'style': 'Traditional',
      'server': 'https://server8.mp3quran.net/bu_khtr/',
    },
    'Muhammad_Jibreel': {
      'id': '19',
      'englishName': 'Muhammad Jibreel',
      'arabicName': 'محمد جبريل',
      'style': 'Traditional',
      'server': 'https://server8.mp3quran.net/jbrl/',
    },
    'Abu_Bakr_Al_Shatri': {
      'id': '20',
      'englishName': 'Abu Bakr Al Shatri',
      'arabicName': 'أبو بكر الشاطري',
      'style': 'Modern',
      'server': 'https://server11.mp3quran.net/shatri/',
    },
    'Muhammad_Al_Lohaidan': {
      'id': '21',
      'englishName': 'Muhammad Al Lohaidan',
      'arabicName': 'محمد اللحيدان',
      'style': 'Traditional',
      'server': 'https://server8.mp3quran.net/lhdan/',
    },
    'Abdulmohsen_Al_Qasim': {
      'id': '22',
      'englishName': 'Abdulmohsen Al Qasim',
      'arabicName': 'عبدالمحسن القاسم',
      'style': 'Traditional',
      'server': 'https://server8.mp3quran.net/qasm/',
    },
    'Ali_Jaber': {
      'id': '23',
      'englishName': 'Ali Jaber',
      'arabicName': 'علي جابر',
      'style': 'Traditional',
      'server': 'https://server11.mp3quran.net/a_jbr/',
    },
    'Mustafa_Ismail': {
      'id': '24',
      'englishName': 'Mustafa Ismail',
      'arabicName': 'مصطفى إسماعيل',
      'style': 'Mujawwad (Melodic)',
      'server': 'https://server8.mp3quran.net/mustafa/',
    },
    'Ali_Al_Hudhaify': {
      'id': '25',
      'englishName': 'Ali Al Hudhaify',
      'arabicName': 'علي بن عبدالرحمن الحذيفي',
      'style': 'Traditional',
      'server': 'https://server9.mp3quran.net/hthfi/',
    },
    'Muhammad_Al_Tablawy': {
      'id': '26',
      'englishName': 'Muhammad Al Tablawy',
      'arabicName': 'محمد الطبلاوي',
      'style': 'Mujawwad (Melodic)',
      'server': 'https://server12.mp3quran.net/tblawi/',
    },
    'Abdullah_Basfer': {
      'id': '27',
      'englishName': 'Abdullah Basfer',
      'arabicName': 'عبدالله بصفر',
      'style': 'Traditional',
      'server': 'https://server6.mp3quran.net/bsfr/',
    },
    'Bandar_Balilah': {
      'id': '28',
      'englishName': 'Bandar Balilah',
      'arabicName': 'بندر بليلة',
      'style': 'Modern',
      'server': 'https://server6.mp3quran.net/balilah/',
    },
    'Salah_Albudair': {
      'id': '29',
      'englishName': 'Salah Al Budair',
      'arabicName': 'صلاح البدير',
      'style': 'Traditional',
      'server': 'https://server6.mp3quran.net/s_bud/',
    },
    'Khalid_Al_Qahtani': {
      'id': '30',
      'englishName': 'Khalid Al Qahtani',
      'arabicName': 'خالد القحطاني',
      'style': 'Modern',
      'server': 'https://server10.mp3quran.net/qht/',
    },
    'Khalifa_Al_Tunaiji': {
      'id': '31',
      'englishName': 'Khalifa Al Tunaiji',
      'arabicName': 'خليفة الطنيجي',
      'style': 'Traditional',
      'server': 'https://server12.mp3quran.net/tnjy/',
    },
    'Wadee_Al_Yamani': {
      'id': '32',
      'englishName': 'Wadee Al Yamani',
      'arabicName': 'وديع اليمني',
      'style': 'Modern',
      'server': 'https://server6.mp3quran.net/wdee3/',
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

  /// Whether [reciterId] has true per-ayah recordings (everyayah.com), i.e.
  /// whether playing an ayah range actually steps through individual verse
  /// files rather than falling back to the whole-surah file for every step.
  static bool hasPerAyahAudio(String? reciterId) {
    return _everyayahFolders.containsKey(reciterId ?? 'Abdul_Basit_Mujawwad');
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
    final server =
        _reciters[reciterKey]?['server'] ??
        _reciters['Abdul_Basit_Murattal']!['server']!;
    final formattedChapterNumber = chapterNumber.toString().padLeft(3, '0');
    return '$server$formattedChapterNumber.mp3';
  }
}
