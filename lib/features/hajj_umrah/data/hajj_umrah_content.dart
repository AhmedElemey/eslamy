/// Ritual step/dua text adapted from the MIT-licensed "Hajj Companion"
/// project (https://github.com/faisaltheparttimecoder/hajj), Copyright (c)
/// 2026 Hajj Companion Contributors. That project's own README describes
/// its content as a personal/community memory aid, not official or
/// scholarly-vetted guidance — the same caveat applies here. Duas are
/// drawn from established hadith collections (cited per-entry below);
/// step ordering/wording follows commonly-taught practice and varies by
/// school and group leader, as repeatedly noted in the edge-case fields.
library;

import 'models/ritual_models.dart';

const List<RitualDua> hajjUmrahDuas = [
  RitualDua(
    id: 'talbiyah',
    name: 'The Talbiyah',
    arabic:
        'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، '
        'إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ',
    transliteration:
        'Labbayk Allahumma labbayk. Labbayk la sharika laka labbayk. '
        "Inna l-hamda wa-n-ni'mata laka wa-l-mulk. La sharika lak.",
    translation:
        'Here I am, O Allah, here I am. Here I am — You have no partner — '
        'here I am. Truly, all praise, grace, and sovereignty belong to '
        'You. You have no partner.',
    source: 'Sahih al-Bukhari 1549; Sahih Muslim 1184',
    note:
        'Recite from the moment of entering Ihram until you cast the '
        'first stone at Jamarat al-Aqabah on the 10th of Dhul Hijjah. '
        'Raise your voice (men) or say it quietly (women).',
    featured: true,
  ),
  RitualDua(
    id: 'entering_ihram',
    name: 'Intention (Niyyah) for Ihram',
    arabic:
        'اللَّهُمَّ إِنِّي أُرِيدُ الْحَجَّ فَيَسِّرْهُ لِي وَتَقَبَّلْهُ مِنِّي',
    transliteration:
        "Allahumma inni uridu l-hajja fa-yassirhu li wa-taqabbalhu minni.",
    translation:
        'O Allah, I intend to perform Hajj, so make it easy for me and '
        'accept it from me.',
    source:
        "Based on transmitted practice; wording varies — follow your group's scholar.",
    note:
        'The intention is made in the heart; the verbal expression is '
        'recommended. Speak it when you put on the Ihram garments at or '
        'before the Miqat.',
  ),
  RitualDua(
    id: 'black_stone',
    name: 'When Passing the Black Stone (each circuit)',
    arabic: 'بِسْمِ اللَّهِ، اللَّهُ أَكْبَرُ',
    transliteration: 'Bismillah, Allahu akbar.',
    translation: 'In the name of Allah, Allah is the Greatest.',
    source: 'Sahih al-Bukhari 1613',
    note:
        'Said each time you pass in line with the Black Stone, whether '
        'or not you can touch or kiss it. Raise your right hand in its '
        'direction.',
  ),
  RitualDua(
    id: 'between_rukns',
    name: 'Between the Yemeni Corner and the Black Stone',
    arabic:
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً '
        'وَقِنَا عَذَابَ النَّارِ',
    transliteration:
        "Rabbana atina fi d-dunya hasanatan wa-fi l-akhirati hasanatan "
        "wa-qina 'adhaba n-nar.",
    translation:
        'Our Lord, give us good in this world and good in the '
        'Hereafter, and protect us from the punishment of the Fire.',
    source:
        "Sunan Abi Dawud 1892; al-Bayhaqi — recited between the Yemeni "
        'Corner and the Black Stone during Tawaf.',
    note:
        'This is the only section of Tawaf where a specific dua is '
        'reported. The rest of the circuits are open for personal '
        'supplication.',
  ),
  RitualDua(
    id: 'safa_marwa_verse',
    name: 'Upon Approaching Safa — Quranic Verse',
    arabic:
        'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ، فَمَنْ حَجَّ الْبَيْتَ '
        'أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَنْ يَطَّوَّفَ بِهِمَا، وَمَنْ تَطَوَّعَ '
        'خَيْرًا فَإِنَّ اللَّهَ شَاكِرٌ عَلِيمٌ',
    transliteration:
        "Inna s-Safa wa-l-Marwata min sha'a'iri Llah. Fa-man hajja "
        "l-bayta awi 'tamara fa-la junaha 'alayhi an yattawwafa bihima. "
        "Wa-man tatawwa'a khayran fa-inna Llaha shakirun 'alim.",
    translation:
        'Indeed, Safa and Marwah are among the symbols of Allah. So '
        'whoever performs Hajj to the House or performs Umrah — there '
        'is no blame upon him for walking between them. And whoever '
        'volunteers good — then indeed, Allah is Appreciative and '
        'Knowing.',
    source:
        'Quran 2:158 — recited once when first approaching Safa (Sahih Muslim 1218).',
    note:
        "Recite this verse only the first time you climb Safa, before "
        "beginning Sa'i. It is not repeated.",
  ),
  RitualDua(
    id: 'safa_dua',
    name: 'On Top of Safa (and Marwah)',
    arabic:
        'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ '
        'وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ. لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ، أَنْجَزَ وَعْدَهُ '
        'وَنَصَرَ عَبْدَهُ وَهَزَمَ الْأَحْزَابَ وَحْدَهُ',
    transliteration:
        "La ilaha illa Llahu wahdahu la sharika lah, lahu l-mulku "
        "wa-lahu l-hamdu wa-huwa 'ala kulli shay'in qadir. La ilaha "
        "illa Llahu wahdah, anjaza wa'dahu wa-nasara 'abdahu wa-hazama "
        "l-ahzaba wahdah.",
    translation:
        'There is no god but Allah alone, with no partner. To Him '
        'belongs dominion and all praise, and He is over all things '
        'powerful. There is no god but Allah alone — He fulfilled His '
        'promise, granted victory to His servant, and defeated the '
        'confederates alone.',
    source: 'Sahih Muslim 1218',
    note:
        "Face the Ka'bah while on Safa and on Marwah. Recite this "
        'dhikr three times on each, raising your hands in supplication '
        'between repetitions. Then make personal dua.',
  ),
  RitualDua(
    id: 'arafah_dua',
    name: 'Best Dua at Arafah',
    arabic:
        'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ '
        'وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration:
        "La ilaha illa Llahu wahdahu la sharika lah, lahu l-mulku "
        "wa-lahu l-hamdu wa-huwa 'ala kulli shay'in qadir.",
    translation:
        'There is no god but Allah alone, with no partner. To Him '
        'belongs dominion and all praise, and He is over all things '
        'powerful.',
    source:
        "Jami' al-Tirmidhi 3585 — the Prophet ﷺ said: \"The best "
        'supplication is the supplication of the Day of Arafah."',
    note:
        'The day of Arafah is the heart of Hajj. Spend it in '
        'continuous dhikr, dua, and seeking forgiveness from Dhuhr '
        'until sunset. This is your greatest opportunity — supplicate '
        'for yourself, your family, and the Ummah.',
    featured: true,
  ),
  RitualDua(
    id: 'jamarat',
    name: 'When Casting Each Pebble at the Jamarat',
    arabic: 'اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu akbar.',
    translation: 'Allah is the Greatest.',
    source: 'Sahih al-Bukhari 1748',
    note:
        'Say "Allahu akbar" with each of the seven pebbles. Cast one '
        'stone at a time.',
  ),
  RitualDua(
    id: 'farewell_tawaf',
    name: 'Dua at Multazam (before Farewell)',
    arabic: '',
    transliteration: '',
    translation: '',
    source: '',
    note:
        "The Multazam is the wall between the Black Stone and the "
        "Ka'bah door. No specific dua is mandated here — it is a place "
        'of acceptance. Press your chest to the wall if you can, raise '
        'your hands, and pour out your heart in personal supplication. '
        'Ask whatever you need in this life and the next.',
  ),
  RitualDua(
    id: 'tawaf_wada',
    name: 'Farewell Tawaf — General Guidance',
    arabic: '',
    transliteration: '',
    translation: '',
    source: '',
    note:
        'No specific dua is prescribed for the Farewell Tawaf beyond '
        'what is recited during any Tawaf (Allahu akbar at the Black '
        'Stone, the dua between the Yemeni Corner and the Black Stone, '
        'and personal supplication otherwise). Make it a time of '
        'gratitude and farewell.',
  ),
  RitualDua(
    id: 'umrah_niyyah',
    name: 'Intention (Niyyah) for Umrah',
    arabic:
        'اللَّهُمَّ إِنِّي أُرِيدُ الْعُمْرَةَ فَيَسِّرْهَا لِي وَتَقَبَّلْهَا مِنِّي',
    transliteration:
        "Allahumma inni uridu l-'umrata fa-yassir-ha li wa-taqabbal-ha "
        'minni.',
    translation:
        'O Allah, I intend to perform Umrah — so make it easy for me '
        'and accept it from me.',
    source: 'Based on transmitted practice.',
    note:
        'Make this intention in your heart and say it aloud just '
        'before the plane reaches the Miqat (boundary), or when '
        'leaving Madinah for Makkah. Men should have already removed '
        'stitched clothing. After making the intention, immediately '
        'begin the Talbiyah.',
  ),
  RitualDua(
    id: 'entering_haram',
    name: 'Dua When Entering Masjid al-Haram (or any Masjid)',
    arabic:
        'بِسْمِ اللَّهِ وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ، اللَّهُمَّ افْتَحْ '
        'لِي أَبْوَابَ رَحْمَتِكَ',
    transliteration:
        "Bismillahi was-salatu was-salamu 'ala rasulillah. "
        "Allahummaf-tah li abwaba rahmatik.",
    translation:
        'In the name of Allah, and blessings and peace upon the '
        'Messenger of Allah. O Allah, open for me the doors of Your '
        'mercy.',
    source: 'Sahih Muslim 713',
    note:
        'Enter the Masjid with your right foot. Keep your gaze lowered '
        "with humility until you reach the Mataf (the open area "
        "around the Ka'bah). When you see the Ka'bah for the first "
        'time, raise your gaze and say "Allahu Akbar, La ilaha '
        'illallah" three times.',
  ),
  RitualDua(
    id: 'seeing_kabah',
    name: "Dua When First Seeing the Ka'bah",
    arabic: 'اللَّهُ أَكْبَرُ، لَا إِلَهَ إِلَّا اللَّهُ',
    transliteration: 'Allahu akbar. La ilaha illa Llah.',
    translation: 'Allah is the Greatest. There is no god but Allah.',
    source: 'Reported practice of the Companions.',
    note:
        "Recite three times when you first see the Ka'bah. Then read "
        'Durood Sharif and make as much dua as possible — this is one '
        'of the moments where dua is accepted. Ask for everything. '
        'Remember the whole Ummah in your dua.',
  ),
  RitualDua(
    id: 'rukne_yamani',
    name: 'Dua at Rukne Yamani (the Yemeni Corner)',
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
    transliteration:
        "Allahumma inni as'aluka l-'afwa wa-l-'afiyata fi d-dunya "
        "wa-l-akhirah.",
    translation:
        'O Allah, I ask You for pardon and well-being in this world '
        'and the Hereafter.',
    source: 'Sunan Abi Dawud 1892',
    note:
        'Touch the Yemeni Corner (the corner before the Black Stone) '
        'with your right hand or both hands if you can reach it '
        'easily. If it is far away, do not raise your hands — simply '
        'walk past it. Then from the Yemeni Corner to the Black '
        'Stone, recite the between-rukns dua.',
  ),
  RitualDua(
    id: 'maqam_ibrahim_salat',
    name: '2 Rakaat Behind Maqam Ibrahim (after Tawaf)',
    arabic: 'وَاتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّى',
    transliteration: "Wattakhidhu min maqami Ibrahima musalla.",
    translation: 'And take the standing place of Ibrahim as a place of prayer.',
    source: 'Quran 2:125 — recited when approaching Maqam Ibrahim after Tawaf.',
    note:
        'After completing 7 circuits of Tawaf, pray 2 rakaat behind '
        'Maqam Ibrahim — recite Surah Kafirun in the 1st rakaat and '
        'Surah Ikhlas in the 2nd. If Maqam Ibrahim is too crowded, '
        'these 2 rakaat can be prayed anywhere in the Masjid.',
  ),
  RitualDua(
    id: 'zamzam_dua',
    name: 'Dua When Drinking Zamzam',
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا وَاسِعًا وَشِفَاءً مِنْ '
        'كُلِّ دَاءٍ',
    transliteration:
        "Allahumma inni as'aluka 'ilman nafi'an, wa-rizqan wasi'an, "
        "wa-shifa'an min kulli da'.",
    translation:
        'O Allah, I ask You for beneficial knowledge, abundant '
        'provision, and cure from every disease.',
    source: 'Al-Hakim (Mustadrak) — reported practice.',
    note:
        'Face the Qiblah when drinking Zamzam. Drink in 3 breaths. The '
        'Prophet ﷺ said Zamzam is "for whatever purpose it is drunk" '
        '— so make dua for whatever you most need.',
    featured: true,
  ),
  RitualDua(
    id: 'sai_running_dua',
    name: "Dua During Sa'i",
    arabic: 'رَبِّ اغْفِرْ وَارْحَمْ، أَنْتَ الْأَعَزُّ الْأَكْرَمُ',
    transliteration: "Rabb-ighfir war-ham, anta l-a'azzu l-akram.",
    translation:
        'Lord, forgive and have mercy. You are the Most Majestic, the '
        'Most Generous.',
    source: "Reported practice during Sa'i.",
    note:
        "This dua is recommended throughout Sa'i. At the green light "
        'zones (between the two green pillars), men jog briskly — '
        "women walk at a normal pace. Safa to Marwah counts as one "
        'trip; Marwah back to Safa counts as another — 7 trips total, '
        'finishing at Marwah.',
  ),
  RitualDua(
    id: 'ihram_airport_dua',
    name: 'Dua After 2 Rakaat of Ihram (at Airport or Home)',
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ رِضَاكَ وَالْجَنَّةَ، وَأَعُوذُ بِكَ مِنْ سَخَطِكَ '
        'وَالنَّارِ، بِرَحْمَتِكَ يَا أَرْحَمَ الرَّاحِمِينَ',
    transliteration:
        "Allahumma inni as'aluka ridaka wa-l-jannata, wa-a'udhu bika "
        "min sakhatika wa-n-nar, bi-rahmatika ya arhama r-rahimin.",
    translation:
        'O Allah, I ask for Your pleasure and Your Paradise, and I '
        'seek refuge from Your anger and the Fire, by Your mercy, O '
        'Most Merciful of the merciful.',
    source: 'Reported practice.',
    note:
        'Read 2 rakaat Salat al-Ihram (Surah Kafirun in 1st rakaat, '
        'Surah Ikhlas in 2nd) — with head covered. After Salah, '
        'uncover your head and make this dua, then make the intention '
        'and immediately begin the Talbiyah.',
  ),
];

/// Day-by-day Hajj guidance (Preparation Day through the Farewell Tawaf),
/// adapted from the same reference project.
const List<RitualPhase> hajjPhases = [
  RitualPhase(
    id: 'day-0',
    title: 'Day 0 — Preparation Day',
    subtitle: 'Ihram for Hajj & Final Preparations',
    date: '7th Dhul Hijjah',
    arabicDate: '٧ ذو الحجة',
    arabicName: 'يَوْم اسْتِعْدَاد الحَج',
    location: 'Your accommodation in Makkah',
    overview:
        'The 7th of Dhul Hijjah is the final day before the Hajj rites '
        'begin. Tomorrow you travel to Mina. Today, you prepare '
        'physically and spiritually — clipping nails, making ghusl, '
        'putting on Ihram for Hajj, and renewing your intention.\n\n'
        'This is a day of quiet preparation. Rest well. Avoid '
        'over-exerting yourself. Make sure your Mina bag is packed '
        'lightly — you will carry it on foot through some of the most '
        'crowded places on earth.',
    steps: [
      RitualStep(
        id: 'day-0.clip-nails',
        label: 'Clip nails, trim moustache, remove pubic and underarm hair',
        note:
            'These are all forbidden while in Ihram. Do them now before '
            'entering the sacred state.',
      ),
      RitualStep(
        id: 'day-0.pack-mina-bag',
        label: 'Pack your Mina bag — keep it as light as possible',
        note:
            'Pack: unscented soap, Quran, tissues, tasbeeh, medication, '
            'water bottle, snacks (dates/nuts), phone + charger + power '
            'bank, Ihram spare set, prayer mat. You will carry this for '
            'many hours.',
      ),
      RitualStep(
        id: 'day-0.confirm-qurbani',
        label:
            'Obtain the name and contact of the person doing your Udhiyah (Qurbani)',
        note:
            'If your group organises Qurbani, get the contact details '
            'now and note them. On Day 3, you must confirm 100% that it '
            'has been done before shaving your head.',
      ),
      RitualStep(
        id: 'day-0.note-salat-times',
        label:
            'Note the Makkah Salat times for Dhuhr, Asr, Maghrib, Isha, and Fajr',
        note:
            'You will need these in Mina, Arafah, and Muzdalifah. Save '
            'them to your phone or write them on paper.',
      ),
      RitualStep(
        id: 'day-0.ghusl',
        label: 'After Isha, perform ghusl (full ritual bath) for Ihram',
        note:
            'Use unscented soap. For men: perfume may be applied to the '
            'body at this point (not to the Ihram garments themselves). '
            'Women should be fully changed into their Ihram clothing.',
      ),
      RitualStep(
        id: 'day-0.put-on-ihram',
        label: 'Put on Ihram garments for Hajj',
        note:
            'Men: remove all stitched clothing and underwear, drape the '
            'rida (upper sheet) and izar (lower sheet). Women: any '
            'modest clothing — no white Ihram required, face and hands '
            'uncovered.',
      ),
      RitualStep(
        id: 'day-0.go-to-haram',
        label:
            'Go to the Haram Sharif if possible (recommended, not obligatory)',
        note:
            'It is recommended to make the intention for Hajj inside '
            'the Haram. If your accommodation is far, you may make the '
            'intention from there.',
      ),
      RitualStep(
        id: 'day-0.nafl-tawaf',
        label: 'Perform one nafl Tawaf if possible (for Tahiyatul Masjid)',
        note:
            'If too busy to perform Tawaf, read 2 rakaat Tahiyatul Masjid instead.',
      ),
      RitualStep(
        id: 'day-0.salat-ihram',
        label:
            'Read 2 rakaat Salat with the intention of Ihram (head covered, then uncover)',
        note:
            'In the 1st rakaat recite Surah Kafirun; in the 2nd recite '
            'Surah Ikhlas. After Salah, uncover your head and make dua.',
      ),
      RitualStep(
        id: 'day-0.niyyah-hajj',
        label: 'Make the intention (Niyyah) for Hajj — aloud',
      ),
      RitualStep(
        id: 'day-0.talbiyah',
        label:
            'Recite the Talbiyah 3 times — you are now in the state of Ihram',
        note:
            'From this moment, all Ihram prohibitions apply. Recite the '
            'Talbiyah frequently until you cast the first stone at '
            'Jamarat al-Aqabah on Day 3.',
      ),
      RitualStep(
        id: 'day-0.rest',
        label: 'Return to hotel and sleep — rest well before the days ahead',
        note:
            'Tomorrow begins the most physically demanding sequence of '
            'your life. Sleep early if you can.',
      ),
    ],
    duaIds: ['entering_ihram', 'talbiyah'],
    edgeCases: [
      'The intention for Hajj must be made before passing or leaving '
          'the Miqat boundary. If already in Makkah, make the intention '
          'before departing for Mina.',
      "Optional: some pilgrims perform the Sa'i for Hajj on this day "
          "after a nafl Tawaf (especially Tamattu' pilgrims who wish to "
          'complete it early). Consult your scholar.',
      'If your group travels to Mina before Fajr of the 8th, ensure '
          'you have entered Ihram before departing.',
      'Do not miss any Salat on the way to or in Mina. Plan travel '
          'time to account for prayer times.',
    ],
  ),
  RitualPhase(
    id: 'day-1',
    title: 'Day 1 — Yawm al-Tarwiyah',
    subtitle: 'The Day of Quenching',
    date: '8th Dhul Hijjah',
    arabicDate: '٨ ذو الحجة',
    arabicName: 'يَوْم التَّرْوِيَة',
    location: 'Your accommodation → Mina',
    overview:
        'The 8th of Dhul Hijjah marks the formal beginning of Hajj. '
        'Today you enter Ihram, make your intention, and travel to '
        'Mina — a valley about 8km from the Masjid al-Haram — where '
        'you will spend the day and night.\n\n'
        'The day is named "al-Tarwiyah" (quenching) from the practice '
        'of pilgrims in earlier centuries drawing and storing water '
        'for the journey to Arafah.\n\n'
        'Today is relatively calm. It is a day of preparation, prayer, '
        'and gathering. Settle in, stay hydrated, and rest as much as '
        'you can — tomorrow, Arafah, is the most important day of '
        'your life.',
    steps: [
      RitualStep(
        id: 'day-1.ghusl',
        label: 'Perform ghusl (full ritual bath) before entering Ihram',
        note:
            'Sunnah before Ihram. Use unscented soap. This is also when '
            'men may use perfume on the body — but not the Ihram '
            'garments themselves.',
      ),
      RitualStep(
        id: 'day-1.put-on-ihram',
        label:
            'Put on Ihram garments and make intention at or before the Miqat',
        note:
            'If you have already done Umrah and exited Ihram, you '
            're-enter Ihram for Hajj now. Men: two white seamless '
            'cloths. Women: any modest clothing. Say the Talbiyah aloud '
            '(men) or quietly (women).',
      ),
      RitualStep(
        id: 'day-1.talbiyah-begins',
        label: 'Begin reciting the Talbiyah — continue until Day 3',
        note:
            'Recite the Talbiyah frequently from now until you cast the '
            'first stone at Jamarat al-Aqabah on the morning of Day 3. '
            'This is a special time.',
      ),
      RitualStep(
        id: 'day-1.travel-mina',
        label: 'Travel to Mina (by bus, train, or on foot)',
        note:
            "Your Hajj group will coordinate transport. The Haramain "
            "train connects the Masha'ir. Arrival at Mina should be "
            'before Dhuhr prayer if possible, though pilgrims arrive '
            'throughout the day.',
      ),
      RitualStep(
        id: 'day-1.dhuhr-mina',
        label: 'Pray Dhuhr in Mina, shortened (2 rakaat) without combining',
        note:
            "The four prayers of Dhuhr, Asr, Maghrib, Isha, and the "
            "next day's Fajr are all prayed in Mina, shortened (qasr) "
            'but not combined. This is the Sunnah established by the '
            'Prophet ﷺ at Mina. Practices vary; follow your group\'s '
            'scholar.',
      ),
      RitualStep(
        id: 'day-1.asr-mina',
        label: 'Pray Asr in Mina, shortened (2 rakaat)',
      ),
      RitualStep(
        id: 'day-1.maghrib-mina',
        label: 'Pray Maghrib in Mina (3 rakaat, not shortened)',
      ),
      RitualStep(
        id: 'day-1.isha-mina',
        label: 'Pray Isha in Mina, shortened (2 rakaat)',
      ),
      RitualStep(
        id: 'day-1.sleep-mina',
        label: 'Sleep in Mina — rest well for the day of Arafah tomorrow',
        note:
            'Tents in Mina are shared and crowded. Sleep early if you '
            'can. Tomorrow, Arafah, is the heart of Hajj — you will '
            'want to be alert and present for it.',
      ),
      RitualStep(
        id: 'day-1.fajr-mina',
        label: 'Wake for Fajr and pray in Mina (the following morning)',
        note: 'Fajr on the 9th is prayed in Mina before departing for Arafah.',
      ),
    ],
    duaIds: ['talbiyah', 'entering_ihram'],
    edgeCases: [
      'If your package does not include Mina on the 8th, confirm with '
          'your group leader — spending the night in Mina on the 8th is '
          'Sunnah but not obligatory.',
      'Do not apply perfume to your Ihram garments — only to your '
          'body before wearing Ihram.',
      'If you are unsure whether you have passed the Miqat, enter '
          'Ihram early to be safe.',
      'Ihram prohibitions begin from the moment you make the '
          'intention, not just when you put on the garments. Be aware.',
    ],
  ),
  RitualPhase(
    id: 'day-2',
    title: 'Day 2 — Yawm Arafah',
    subtitle: 'The Heart of Hajj',
    date: '9th Dhul Hijjah',
    arabicDate: '٩ ذو الحجة',
    arabicName: 'يَوْم عَرَفَة',
    location: 'Mina → Arafah → Muzdalifah',
    overview:
        'The Prophet ﷺ said: "Hajj is Arafah." This is the day. '
        "Nothing — not the Ka'bah, not the Talbiyah, not the pebbles "
        '— carries the weight of this one afternoon.\n\n'
        'From Dhuhr until sunset, you will stand on the plain of '
        'Arafah in dua, remembrance, and seeking forgiveness. Allah '
        'descends to the nearest heaven and boasts to the angels '
        'about His pilgrims. Many sins of a lifetime are forgiven '
        'today. Be completely present.\n\n'
        'After sunset, you travel to Muzdalifah — an open plain — '
        'where you sleep under the stars, pray Maghrib and Isha '
        'combined, and collect your pebbles for the Jamarat.',
    steps: [
      RitualStep(
        id: 'day-2.fajr-mina',
        label: 'Pray Fajr in Mina',
        note:
            'This is the Fajr of the 9th. Pray in your tent in Mina before departing.',
      ),
      RitualStep(
        id: 'day-2.travel-arafah',
        label: 'Travel from Mina to Arafah after sunrise',
        note:
            'Departure is after Fajr and after sunrise. Do not travel '
            'before sunrise — the Sunnah is to travel after it. The '
            'Prophet ﷺ departed Mina after the sun had risen.',
      ),
      RitualStep(
        id: 'day-2.arrive-arafah',
        label: 'Arrive at Arafah and settle in your area',
        note:
            'You must be within the boundaries of Arafah (there are '
            'markers). Jabal ar-Rahmah (Mount of Mercy) is not '
            'required — the entire plain is valid. Seek shade. Stay '
            'hydrated.',
      ),
      RitualStep(
        id: 'day-2.dhuhr-asr-arafah',
        label:
            "Pray Dhuhr and Asr combined and shortened at Arafah (after the imam's khutbah)",
        note:
            'This is prayed at Dhuhr time (early), combined and '
            'shortened: 2 rakaat Dhuhr, then 2 rakaat Asr. Follow your '
            'group. This is established Sunnah.',
      ),
      RitualStep(
        id: 'day-2.wuquf',
        label:
            'Stand in dua and dhikr from Dhuhr until sunset — the Wuquf (standing)',
        note:
            'You do not have to physically stand — sitting, lying down, '
            'being in your tent are all fine. "Standing" means being '
            'present at Arafah during the time. Spend this time in '
            'sincere supplication. Weep if you can. Make dua for '
            'everything you have ever needed.',
      ),
      RitualStep(
        id: 'day-2.sunset-depart',
        label: 'Depart Arafah after sunset — do not leave before sunset',
        note:
            'Leaving Arafah before sunset is a violation that requires '
            'a Hady sacrifice. Wait until the sun has fully set. '
            'Recite Talbiyah as you depart.',
      ),
      RitualStep(
        id: 'day-2.travel-muzdalifah',
        label: 'Travel to Muzdalifah — be calm in the crowds',
        note:
            'The road from Arafah to Muzdalifah is extremely crowded. '
            'This is normal. Recite Talbiyah and dhikr. The Prophet ﷺ '
            'proceeded calmly and said, "O people, be calm."',
      ),
      RitualStep(
        id: 'day-2.maghrib-isha-muzdalifah',
        label: 'Pray Maghrib and Isha combined at Muzdalifah (at Isha time)',
        note:
            'These are combined at Isha time: 3 rakaat Maghrib then 2 '
            'rakaat Isha. This is Sunnah. Do not pray Maghrib '
            'separately on the road — delay it until you reach '
            'Muzdalifah.',
      ),
      RitualStep(
        id: 'day-2.collect-pebbles',
        label: 'Collect pebbles for the Jamarat',
        note:
            'Collect at least 49 pebbles (for 2 nights in Mina) or 70 '
            '(for 3 nights). Chickpea to marble-sized. You may also '
            'collect in Mina. No need to wash them.',
      ),
      RitualStep(
        id: 'day-2.sleep-muzdalifah',
        label: 'Sleep in Muzdalifah — under the open sky',
        note:
            'Most pilgrims sleep on the ground or mats. This is part '
            'of the Hajj. The elderly, ill, women, and their '
            'companions may leave Muzdalifah after midnight — this is '
            'a dispensation. Others remain until after Fajr.',
      ),
      RitualStep(
        id: 'day-2.fajr-muzdalifah',
        label: 'Wake early and pray Fajr at Muzdalifah',
        note:
            'Pray Fajr early, as the Prophet ﷺ prayed at the earliest '
            'permissible time in Muzdalifah. After Fajr, face the '
            'Qiblah and make dua until it is light.',
      ),
      RitualStep(
        id: 'day-2.mashaar-dua',
        label:
            "Make dua at al-Mash'ar al-Haram (Muzdalifah mosque) if possible",
        note:
            "Allah commanded pilgrims to remember Him at al-Mash'ar "
            'al-Haram (Quran 2:198). Face the Qiblah and make dua '
            'until it becomes bright. Not obligatory to be at the '
            'mosque itself.',
      ),
      RitualStep(
        id: 'day-2.depart-muzdalifah',
        label: 'Depart Muzdalifah for Mina before sunrise',
        note:
            'The Sunnah is to depart before sunrise on the 10th. '
            'Travel back to Mina for the stoning.',
      ),
    ],
    duaIds: ['talbiyah', 'arafah_dua', 'safa_dua'],
    edgeCases: [
      'You must be within the boundaries of Arafah — not outside '
          'them. The boundaries are clearly marked.',
      'If you arrive at Arafah after sunset but before Fajr of the '
          '10th, your Hajj is still valid — the Wuquf can be at night.',
      'Elderly, disabled, and ill pilgrims — and their companions — '
          'may leave Muzdalifah after midnight. This is a confirmed '
          'dispensation from the Prophet ﷺ.',
      'Do not leave Arafah before sunset. This is a serious '
          'violation.',
      'If you fall ill at Arafah, remain within the boundaries if at '
          'all possible — even lying down counts as Wuquf.',
      "Keep your group leader's number handy. Losing your group at "
          'Muzdalifah is extremely common.',
    ],
  ),
  RitualPhase(
    id: 'day-3',
    title: 'Day 3 — Yawm al-Nahr',
    subtitle: 'Eid al-Adha — The Day of Sacrifice',
    date: '10th Dhul Hijjah',
    arabicDate: '١٠ ذو الحجة',
    arabicName: 'يَوْم النَّحْر',
    location: 'Muzdalifah → Mina → Makkah → Mina',
    overview:
        'Today is Eid al-Adha and the busiest, most intensive day of '
        'Hajj. Four major rites are performed — ideally in this '
        'order: (1) Stone Jamarat al-Aqabah, (2) Sacrifice the Hady '
        'animal, (3) Shave or shorten the hair, (4) Perform Tawaf '
        "al-Ifadah and Sa'i in Makkah.\n\n"
        'After step 3, partial Tahallul (first exit from Ihram) '
        'takes effect: all Ihram restrictions are lifted except '
        'sexual relations with the spouse. Full Tahallul (second '
        'exit) takes effect after Tawaf al-Ifadah.\n\n'
        'This is a very physically demanding day. Pace yourself. Stay '
        'hydrated. The stoning area is extremely crowded — stay '
        'calm, keep moving, and do not stop in the walkways.',
    steps: [
      RitualStep(
        id: 'day-3.travel-mina',
        label: 'Travel from Muzdalifah to Mina before sunrise',
      ),
      RitualStep(
        id: 'day-3.stone-aqabah',
        label:
            'Stone Jamarat al-Aqabah: 7 pebbles, saying "Allahu akbar" with each',
        note:
            'This is the large Jamarat closest to Makkah. Cast 7 '
            'pebbles, one at a time, saying "Allahu akbar" with each. '
            'The Talbiyah stops here — you do not recite it after the '
            'first stone. Preferred time: after Fajr, but it is valid '
            'throughout the day and night.',
      ),
      RitualStep(
        id: 'day-3.talbiyah-stops',
        label:
            'Stop reciting the Talbiyah after the first stone at Jamarat al-Aqabah',
      ),
      RitualStep(
        id: 'day-3.hady-sacrifice',
        label:
            'Sacrifice the Hady animal (or confirm your operator has done so)',
        note:
            "Required for Tamattu' and Qiran pilgrims. Most Hajj "
            "packages include this and handle it through the Islamic "
            "Development Bank's sacrifice scheme. Confirm with your "
            'operator that your sacrifice has been performed before '
            'shaving.',
      ),
      RitualStep(
        id: 'day-3.shave-hair',
        label:
            'Men: Shave head (afdal) or shorten hair. Women: Cut a '
            'fingertip-length from the hair.',
        note:
            'Shaving (halq) is superior for men. Shortening (taqsir) is '
            'permitted. Barbers are available throughout Mina. After '
            'this act, partial Tahallul takes effect.',
      ),
      RitualStep(
        id: 'day-3.remove-ihram',
        label:
            'Remove Ihram garments — change into normal clothes (partial Tahallul)',
        note:
            'After shaving, all Ihram restrictions are lifted EXCEPT '
            'relations with the spouse. You may now use scented soap, '
            'wear regular clothes, cut nails, etc.',
      ),
      RitualStep(
        id: 'day-3.travel-makkah',
        label: 'Travel from Mina to Makkah for Tawaf al-Ifadah',
        note:
            'This is a heavy journey on the most crowded day. Be '
            "patient. Your group will coordinate.",
      ),
      RitualStep(
        id: 'day-3.tawaf-ifadah',
        label: "Perform Tawaf al-Ifadah — 7 circuits of the Ka'bah",
        note:
            'This is the obligatory Tawaf of Hajj. No special Ihram '
            'required — you are in normal clothes. This Tawaf is what '
            'most distinguishes Hajj from Umrah and is a pillar '
            '(rukn) of Hajj. Without it, Hajj is incomplete.',
      ),
      RitualStep(
        id: 'day-3.sai',
        label: "Perform Sa'i — 7 times between Safa and Marwah",
        note:
            "If you performed Sa'i after your Umrah (for Tamattu' "
            'pilgrims), some scholars say you need not repeat it. '
            "Others say it is required. Follow your group's scholar.",
      ),
      RitualStep(
        id: 'day-3.full-tahallul',
        label: 'Full Tahallul — all restrictions lifted after Tawaf al-Ifadah',
        note:
            "After completing Tawaf al-Ifadah (and Sa'i if required), "
            'full Tahallul is reached. Marital relations are now '
            'permitted.',
      ),
      RitualStep(
        id: 'day-3.return-mina',
        label: 'Return to Mina and sleep there for the night of the 11th',
        note:
            'Spending the nights of the 11th and 12th (and optionally '
            '13th) in Mina is required (wajib). Return before midnight '
            'if possible.',
      ),
    ],
    duaIds: [
      'jamarat',
      'black_stone',
      'between_rukns',
      'safa_marwa_verse',
      'safa_dua',
    ],
    edgeCases: [
      'The preferred order today is: stone, sacrifice, shave, tawaf. '
          'It is valid to do them in other orders — consult your '
          'scholar if needed.',
      'Tawaf al-Ifadah can be delayed to the 11th or 12th without '
          'penalty — useful if the crowds on the 10th are too severe.',
      'Women experiencing menstruation may delay Tawaf al-Ifadah '
          'until they are pure. Consult a scholar if there is a risk '
          'of missing your flight.',
      'Do not stop in the Jamarat walkway to make dua — keep moving. '
          'Dua after stoning can be made elsewhere.',
      "If you cannot complete Sa'i on Day 3, it can be done on Days "
          '4 or 5.',
    ],
  ),
  RitualPhase(
    id: 'day-4',
    title: 'Day 4 — 11th Dhul Hijjah',
    subtitle: 'First Day of Tashriq — Stone All Three Jamarat',
    date: '11th Dhul Hijjah',
    arabicDate: '١١ ذو الحجة',
    arabicName: 'أَوَّل أَيَّام التَّشْرِيق',
    location: 'Mina',
    overview:
        'Today you remain in Mina. The primary act is stoning all '
        'three Jamarat — small, middle, and large — in that order, '
        'with 7 pebbles each (21 total today).\n\n'
        'The stoning is performed after the sun passes its zenith '
        '(Dhuhr time). Do not stone before this. The window extends '
        'until sunset (with some scholars permitting until dawn, '
        'though daytime is strongly preferred).\n\n'
        'Use the rest of the day for prayer, dhikr, recitation of '
        'Quran, and rest. The Ayyam al-Tashriq (days of 11th, 12th, '
        '13th) are days for eating, drinking, and remembering Allah.',
    steps: [
      RitualStep(id: 'day-4.fajr-mina', label: 'Pray Fajr in Mina'),
      RitualStep(
        id: 'day-4.wait-dhuhr',
        label:
            'Wait until the sun passes its zenith (Dhuhr time) before stoning',
        note:
            'Stoning before Dhuhr on the 11th, 12th, and 13th is not '
            'permitted according to the majority of scholars.',
      ),
      RitualStep(
        id: 'day-4.stone-sughra',
        label:
            'Stone Jamarat al-Sughra (small): 7 pebbles, "Allahu akbar" with each',
        note: 'Start with the small Jamarat (furthest from Makkah).',
      ),
      RitualStep(
        id: 'day-4.dua-after-sughra',
        label:
            'After stoning al-Sughra: face the Qiblah, raise hands, make extended dua',
        note:
            'This is Sunnah — the Prophet ﷺ stood after stoning each of '
            'the first two Jamarat and made dua. The third (al-Aqabah) '
            'is not followed by dua on the spot.',
      ),
      RitualStep(
        id: 'day-4.stone-wusta',
        label:
            'Stone Jamarat al-Wusta (middle): 7 pebbles, "Allahu akbar" with each',
      ),
      RitualStep(
        id: 'day-4.dua-after-wusta',
        label:
            'After stoning al-Wusta: face the Qiblah, raise hands, make extended dua',
      ),
      RitualStep(
        id: 'day-4.stone-aqabah',
        label:
            'Stone Jamarat al-Aqabah (large): 7 pebbles, "Allahu akbar" with each',
        note:
            'No extended dua on the spot after al-Aqabah. Leave the area after stoning.',
      ),
      RitualStep(
        id: 'day-4.prayers-mina',
        label: 'Pray all five prayers in Mina, shortened',
      ),
      RitualStep(
        id: 'day-4.sleep-mina-night',
        label: 'Sleep in Mina (night of the 12th)',
        note:
            "Spending the night in Mina is required (wajib). If you "
            "leave Mina before sunset on the 12th, you may depart "
            "early (ta'ajjul). If you are still in Mina at sunset on "
            'the 12th, you must stay for the 13th as well.',
      ),
    ],
    duaIds: ['jamarat'],
    edgeCases: [
      'Stone in order: small, then middle, then large. This order is '
          'required.',
      'Do not stone before Dhuhr on Days 4, 5, and 6.',
      'After each of the first two Jamarat, stand facing the Qiblah '
          'and make dua. This Sunnah is easy to miss in the crowds — '
          'find a place to stand after moving away from the pillar.',
      'If the crowds are extremely severe, some scholars permit '
          'elderly and weak pilgrims to stone at night. Consult your '
          'scholar.',
    ],
  ),
  RitualPhase(
    id: 'day-5',
    title: 'Day 5 — 12th Dhul Hijjah',
    subtitle: 'Second Day of Tashriq — Stone and Optionally Depart',
    date: '12th Dhul Hijjah',
    arabicDate: '١٢ ذو الحجة',
    arabicName: 'ثَانِي أَيَّام التَّشْرِيق',
    location: 'Mina (→ Makkah for most pilgrims)',
    overview:
        'Today is the same as yesterday for stoning — all three '
        'Jamarat after Dhuhr, in order (small, middle, large), 7 '
        'pebbles each.\n\n'
        'After stoning, you have a choice: leave Mina before sunset '
        "(ta'ajjul — a valid dispensation, Quran 2:203) or stay for "
        'Day 6 if you remain past sunset.\n\n'
        'Before leaving Makkah entirely, you will perform the '
        "Farewell Tawaf (Tawaf al-Wada'). This should be the last "
        'thing you do before leaving the city.',
    steps: [
      RitualStep(id: 'day-5.fajr-mina', label: 'Pray Fajr in Mina'),
      RitualStep(
        id: 'day-5.wait-dhuhr',
        label: 'Wait until after Dhuhr time before stoning',
      ),
      RitualStep(
        id: 'day-5.stone-sughra',
        label: 'Stone Jamarat al-Sughra: 7 pebbles, "Allahu akbar" with each',
      ),
      RitualStep(
        id: 'day-5.dua-after-sughra',
        label: 'Stand after al-Sughra, face Qiblah, make dua',
      ),
      RitualStep(
        id: 'day-5.stone-wusta',
        label: 'Stone Jamarat al-Wusta: 7 pebbles, "Allahu akbar" with each',
      ),
      RitualStep(
        id: 'day-5.dua-after-wusta',
        label: 'Stand after al-Wusta, face Qiblah, make dua',
      ),
      RitualStep(
        id: 'day-5.stone-aqabah',
        label: 'Stone Jamarat al-Aqabah: 7 pebbles, "Allahu akbar" with each',
      ),
      RitualStep(
        id: 'day-5.decision',
        label: "Decide: leave Mina before sunset (ta'ajjul) or stay for Day 6",
        note:
            "If leaving: depart Mina before sunset. If staying: you "
            "must stone again tomorrow (13th). Most international "
            "pilgrims use the dispensation and depart today.",
      ),
      RitualStep(
        id: 'day-5.tawaf-wada',
        label: "Perform Tawaf al-Wada' (Farewell Tawaf) before leaving Makkah",
        note:
            "Required for non-Makkan pilgrims. 7 circuits of the "
            "Ka'bah. This should be your last act in Makkah before "
            'heading to the airport or bus.',
      ),
    ],
    duaIds: [
      'jamarat',
      'black_stone',
      'between_rukns',
      'tawaf_wada',
      'farewell_tawaf',
    ],
    edgeCases: [
      'If you leave Mina after sunset on the 12th, you must stay and '
          'stone on the 13th.',
      'Women experiencing menstruation are exempt from the Farewell '
          'Tawaf — they may depart without it. (Sahih Muslim 1328)',
      "Tawaf al-Wada' should ideally be the last thing you do. Avoid "
          'eating, shopping, or other activities in Makkah after it.',
    ],
  ),
  RitualPhase(
    id: 'day-6',
    title: 'Day 6 — 13th Dhul Hijjah (Optional)',
    subtitle: 'Third Day of Tashriq — Final Stoning',
    date: '13th Dhul Hijjah',
    arabicDate: '١٣ ذو الحجة',
    arabicName: 'ثَالِث أَيَّام التَّشْرِيق',
    location: 'Mina',
    isOptional: true,
    overview:
        'This day applies only to pilgrims who remained in Mina past '
        'sunset on the 12th, or who chose to stay voluntarily. '
        'Staying for the full three days of Tashriq is considered '
        'more virtuous.\n\n'
        'The rites today are the same as Days 4 and 5: stone all '
        'three Jamarat after Dhuhr, in order, 7 pebbles each.\n\n'
        'After stoning today, your Hajj rites are complete. Proceed '
        'to Makkah for the Farewell Tawaf (if you have not yet done '
        'it), then depart.',
    steps: [
      RitualStep(id: 'day-6.fajr-mina', label: 'Pray Fajr in Mina'),
      RitualStep(
        id: 'day-6.wait-dhuhr',
        label: 'Wait until after Dhuhr time before stoning',
      ),
      RitualStep(
        id: 'day-6.stone-sughra',
        label: 'Stone Jamarat al-Sughra: 7 pebbles, "Allahu akbar" with each',
      ),
      RitualStep(
        id: 'day-6.dua-after-sughra',
        label: 'Stand after al-Sughra, face Qiblah, make dua',
      ),
      RitualStep(
        id: 'day-6.stone-wusta',
        label: 'Stone Jamarat al-Wusta: 7 pebbles, "Allahu akbar" with each',
      ),
      RitualStep(
        id: 'day-6.dua-after-wusta',
        label: 'Stand after al-Wusta, face Qiblah, make dua',
      ),
      RitualStep(
        id: 'day-6.stone-aqabah',
        label: 'Stone Jamarat al-Aqabah: 7 pebbles, "Allahu akbar" with each',
      ),
      RitualStep(
        id: 'day-6.depart-mina',
        label: 'Depart Mina — Hajj rites are now complete',
      ),
      RitualStep(
        id: 'day-6.tawaf-wada',
        label: "Perform Tawaf al-Wada' before leaving Makkah (if not yet done)",
      ),
    ],
    duaIds: ['jamarat', 'black_stone', 'between_rukns', 'farewell_tawaf'],
    edgeCases: [
      'You must leave Mina before sunset on the 13th — there is no 14th stoning.',
    ],
  ),
  RitualPhase(
    id: 'farewell',
    title: 'Farewell Tawaf',
    subtitle: 'The Final Tawaf before leaving Makkah',
    date: 'Before leaving Makkah',
    arabicName: 'طَوَاف الْوَدَاع',
    location: 'Masjid al-Haram',
    overview:
        "Tawaf al-Wada' (the Farewell Tawaf) is required for all "
        'non-Makkan pilgrims before leaving Makkah. It is a wajib '
        '(required) act, and its omission requires a Hady sacrifice '
        'if not remedied.\n\n'
        'This should be the last act you perform in Makkah. After '
        'completing it, head directly to your transportation. Do not '
        'stop for shopping, meals, or other activities after '
        "completing Tawaf al-Wada'.\n\n"
        'Women experiencing menstruation are exempt from Tawaf '
        "al-Wada'.\n\n"
        "This is your goodbye to the Ka'bah. Allow yourself to be "
        'present in it.',
    steps: [
      RitualStep(
        id: 'farewell.tawaf',
        label: "Perform 7 circuits of the Ka'bah (Tawaf al-Wada')",
        note:
            'No specific Ihram required. Normal clothing. Say "Allahu '
            'akbar" when passing the Black Stone. Make personal dua '
            'during the tawaf.',
      ),
      RitualStep(
        id: 'farewell.two-rakaat',
        label: 'Pray 2 rakaat behind Maqam Ibrahim if possible',
      ),
      RitualStep(
        id: 'farewell.zamzam',
        label: 'Drink Zamzam water',
        note:
            'Face the Kabah, say "Bismillah," drink in three sips, and '
            'make dua. The Prophet ﷺ said Zamzam is "for whatever '
            'purpose it is drunk."',
      ),
      RitualStep(
        id: 'farewell.multazam',
        label: 'Supplicate at the Multazam if you can reach it',
        note:
            "The Multazam is the wall between the Black Stone and the "
            "Ka'bah door. Press yourself against it and pour out your "
            'heart. There is no specific dua — only your own.',
      ),
      RitualStep(
        id: 'farewell.depart',
        label: "Leave Makkah directly after Tawaf al-Wada'",
        note: 'Go straight to your transport. May Allah accept your Hajj.',
      ),
    ],
    duaIds: ['tawaf_wada', 'farewell_tawaf', 'black_stone', 'between_rukns'],
    edgeCases: [
      "If you shop or eat after Tawaf al-Wada' and then leave, some "
          'scholars say you must repeat it. Go straight to your '
          'transport after completing it.',
      'Women experiencing menstruation or post-natal bleeding are '
          'exempt and may depart without it.',
    ],
  ),
];

/// Step-by-step Umrah guidance, from home departure through completion.
const List<RitualPhase> umrahPhases = [
  RitualPhase(
    id: 'umrah.home',
    title: 'At Home Before Leaving',
    subtitle: 'Preparation',
    overview:
        'These acts are performed at home before departing for the '
        'airport. If it is difficult to put on the Ihram at the '
        'airport, men may put on at least the lower part (izar) from '
        'home. Women should change into their Ihram clothing at '
        'home.',
    steps: [
      RitualStep(
        id: 'umrah.home.ghusl',
        label:
            'Perform ghusl, clip nails, trim moustache, remove pubic and underarm hair',
        note:
            'All of these are prohibited in the state of Ihram. Do '
            'them before leaving the house. For men: perfume may be '
            'applied to the body now — but not to the Ihram garments '
            'themselves.',
      ),
      RitualStep(
        id: 'umrah.home.nafl',
        label: 'Read 2 rakaat nafl for ease of journey (if not a Makruh time)',
        note:
            'Recite Surah Kafirun in the 1st rakaat and Surah Ikhlas in '
            'the 2nd. After Salah, make dua — send Durood to the '
            'Prophet ﷺ, thank Allah for the opportunity, ask for ease '
            'of journey, repent from all sins, and seek protection '
            'from nafs and Shaytan.',
      ),
      RitualStep(
        id: 'umrah.home.farewell',
        label: 'Meet family and friends and leave in a happy state',
        note:
            'Remain in dhikr during the journey and stop for Salat on '
            'the way if required. Do NOT miss any Salat — plan the '
            'journey taking into account possible traffic.',
      ),
    ],
  ),
  RitualPhase(
    id: 'umrah.airport',
    title: 'At the Airport — Putting On Ihram',
    subtitle: 'Before departure',
    overview:
        'If travelling direct to Makkah, put on Ihram at the airport '
        'if not already done at home. It is not recommended to put '
        'on Ihram on the plane — the space is very limited.',
    steps: [
      RitualStep(
        id: 'umrah.airport.checkin',
        label: 'Check in luggage first',
        note:
            'Ensure you have not exceeded the baggage weight allowance '
            'and that your hand luggage is within the permitted size. '
            'Keep all personal documents (passport, tickets) on your '
            'person in a small bag or money belt.',
      ),
      RitualStep(
        id: 'umrah.airport.wudu',
        label:
            'Perform wudu and apply Itar (perfume) to body — then put on Ihram',
        note:
            'Apply perfume to the body only, not the Ihram sheets '
            'themselves. Men: remove all stitched clothing and '
            'underwear. Put on the izar (lower sheet) and rida (upper '
            'sheet). Women: any modest clothing covering the body.',
      ),
      RitualStep(
        id: 'umrah.airport.flip-flops',
        label:
            'Men: put on flip-flops and put shoes and stitched clothing away',
        note:
            'Men must not wear footwear that covers the central bone '
            'on the top of the foot while in Ihram.',
      ),
      RitualStep(
        id: 'umrah.airport.salat-ihram',
        label:
            'Read 2 rakaat Salat al-Ihram (if not a Makruh time) — head covered',
      ),
      RitualStep(
        id: 'umrah.airport.dua-ihram',
        label:
            'After Salah, make dua — then go to the toilet and renew wudu before boarding',
      ),
    ],
  ),
  RitualPhase(
    id: 'umrah.plane',
    title: 'On the Plane',
    subtitle: 'In flight',
    overview:
        'Read all Salat at their correct times during the flight. If '
        'going directly to Jeddah, make the Niyyah for Umrah before '
        'the plane reaches the Miqat (boundary).',
    steps: [
      RitualStep(
        id: 'umrah.plane.salat',
        label: 'Read all Salat at correct times — do not delay or miss any',
        note:
            'Read Maghrib when you can see the sunset. Check with the '
            'crew if needed. Do not use scented refreshing towels '
            'provided on the plane while in Ihram.',
      ),
      RitualStep(
        id: 'umrah.plane.niyyah',
        label:
            'Before reaching the Miqat: make the Niyyah (intention) for Umrah — bare-headed for men',
        note:
            'If you have not yet put on the upper Ihram sheet, do so '
            'before making the intention. The crew or apps can inform '
            'you when the Miqat is approaching.',
      ),
      RitualStep(
        id: 'umrah.plane.talbiyah',
        label: 'Immediately after the Niyyah, begin reciting the Talbiyah',
        note:
            'Men recite aloud; women recite quietly. Continue reciting '
            'the Talbiyah frequently throughout the journey until you '
            'begin Tawaf.',
      ),
    ],
    duaIds: ['umrah_niyyah', 'talbiyah'],
  ),
  RitualPhase(
    id: 'umrah.jeddah',
    title: 'At Jeddah Airport',
    subtitle: 'Arrival',
    overview:
        'After landing, you will board a bus to a waiting area. Keep '
        'reciting the Talbiyah and stay engaged in worship during '
        'any waits — there can be long queues at immigration.',
    steps: [
      RitualStep(
        id: 'umrah.jeddah.immigration',
        label: 'Pass through immigration — have all documents ready',
        note:
            'Immigration officers will check your visa, immunisation '
            "certificate, and passport. You will receive a transport "
            "ticket and a sticker on your passport for your Mu'allim.",
      ),
      RitualStep(
        id: 'umrah.jeddah.passport',
        label:
            "Be aware: your passport will be held by your Hajj operator/Mu'allim",
      ),
      RitualStep(
        id: 'umrah.jeddah.luggage',
        label:
            'Collect luggage and meet the rest of your group at baggage claim',
      ),
      RitualStep(
        id: 'umrah.jeddah.coach',
        label: 'Board coach to Makkah — checkpoints will be passed on the way',
      ),
    ],
  ),
  RitualPhase(
    id: 'umrah.makkah',
    title: 'Arriving at Makkah — Entering the Haram',
    subtitle: 'First sight of the Kabah',
    overview:
        'After arriving at the hotel, perform wudu (or ghusl if '
        'needed) then make your way to Masjid al-Haram. Try to enter '
        'through Bab al-Umrah if possible. Keep your eyes lowered '
        "with humility until you reach the Mataf and see the Ka'bah.",
    steps: [
      RitualStep(
        id: 'umrah.makkah.wudu',
        label: 'Perform wudu (or ghusl if needed)',
      ),
      RitualStep(
        id: 'umrah.makkah.enter-haram',
        label:
            'Enter the Haram with your right foot, reciting the dua for entering',
      ),
      RitualStep(
        id: 'umrah.makkah.see-kabah',
        label:
            "When you see the Ka'bah for the first time, raise your gaze and recite three times",
        note:
            '"Allahu Akbar, La ilaha illallah" — three times. Then '
            'read Durood Sharif and make as much dua as possible. This '
            'is one of the moments where dua is accepted.',
      ),
    ],
    duaIds: ['entering_haram', 'seeing_kabah'],
  ),
  RitualPhase(
    id: 'umrah.tawaf',
    title: "Tawaf — Circling the Ka'bah",
    subtitle: '7 circuits',
    overview:
        "Tawaf is the circumambulation of the Ka'bah 7 times in an "
        'anti-clockwise direction, beginning and ending at the Black '
        'Stone. You must have wudu. If you have a tasbeeh with 7 '
        'beads, use it to count the circuits — or use the Tawaf '
        'counter in this guide.',
    steps: [
      RitualStep(
        id: 'umrah.tawaf.stop-talbiyah',
        label: 'Stop reciting the Talbiyah when you begin Tawaf',
        note: 'Ensure you have wudu before starting.',
      ),
      RitualStep(
        id: 'umrah.tawaf.idtiba',
        label:
            "Men: perform Idtiba' — drape the rida' under the right armpit, exposing the right shoulder",
        note:
            "This is done for every Tawaf that is followed by Sa'i. "
            "Do Idtiba' for all 7 rounds. After the 2 rakaat Salat at "
            'Maqam Ibrahim, cover both shoulders again.',
      ),
      RitualStep(
        id: 'umrah.tawaf.black-stone',
        label: 'Begin at the Black Stone — face it and perform Istilam',
        note:
            'Position yourself so your right shoulder is in line with '
            'the left-hand side of the Black Stone (NOT directly in '
            'front). Make the Niyyah for Tawaf, then kiss the Black '
            'Stone if possible, touch it with your right hand, or face '
            'your palms towards it and say "Bismillah Allahu Akbar."',
      ),
      RitualStep(
        id: 'umrah.tawaf.raml',
        label:
            'Men: perform Raml for the first 3 rounds — walk briskly with chest out',
        note:
            'Raml is performed by men for the first 3 rounds only. For '
            'the remaining 4 rounds, walk at a normal pace.',
      ),
      RitualStep(
        id: 'umrah.tawaf.circuits',
        label: 'Complete 7 circuits — make dua and dhikr throughout',
        note:
            "Walk anti-clockwise around the Ka'bah keeping it to your "
            'left. At the Yemeni Corner (Rukne Yamani), touch it with '
            'your right hand if possible. From the Yemeni Corner to '
            'the Black Stone, recite the between-rukns dua.',
      ),
      RitualStep(
        id: 'umrah.tawaf.final-istilam',
        label: 'After 7 circuits, perform the final Istilam (8th in total)',
      ),
      RitualStep(
        id: 'umrah.tawaf.two-rakaat',
        label: 'Pray 2 rakaat Wajib Salat behind Maqam Ibrahim',
        note:
            'If Maqam Ibrahim is too crowded, pray anywhere else in '
            'the Masjid. If it is a Makruh time, wait until it passes.',
      ),
      RitualStep(
        id: 'umrah.tawaf.dua-multazam',
        label: 'After Salah: make dua at the Multazam if you can reach it',
      ),
      RitualStep(
        id: 'umrah.tawaf.zamzam',
        label: 'Drink Zamzam water — as much as possible',
        note:
            'Face the Qiblah, drink in 3 breaths, then return to the '
            'Black Stone and perform Istilam again before Sa\'i.',
      ),
    ],
    duaIds: [
      'black_stone',
      'rukne_yamani',
      'between_rukns',
      'maqam_ibrahim_salat',
      'zamzam_dua',
    ],
  ),
  RitualPhase(
    id: 'umrah.sai',
    title: "Sa'i — Between Safa and Marwah",
    subtitle: '7 trips',
    overview:
        "Sa'i is walking 7 times between the hills of Safa and "
        "Marwah, commemorating Hajar's search for water. Begin at "
        'Safa and end at Marwah. Safa to Marwah = 1 trip; Marwah to '
        'Safa = 1 trip. 7 trips total, ending at Marwah.',
    steps: [
      RitualStep(
        id: 'umrah.sai.approach-safa',
        label:
            "Follow signs for the Masa (Sa'i area) and approach Safa with intention for Sa'i",
        note:
            'The Safa/Marwah verse is recited only once, at the '
            'beginning.',
      ),
      RitualStep(
        id: 'umrah.sai.safa-dua',
        label:
            "At Safa: climb as far as possible, face the Ka'bah, and make dua",
      ),
      RitualStep(
        id: 'umrah.sai.walk',
        label: 'Proceed towards Marwah — men jog between the green lights',
        note:
            'Between the two sets of green pillars, men jog briskly. '
            'At all other places, walk at a normal pace. Women do not '
            'jog.',
      ),
      RitualStep(
        id: 'umrah.sai.marwah-dua',
        label:
            "At Marwah: face the Ka'bah direction and repeat the same duas as at Safa",
        note: 'Continue until you have completed 7 trips, finishing at Marwah.',
      ),
      RitualStep(
        id: 'umrah.sai.complete',
        label: "After the 7th trip ending at Marwah, Sa'i is complete",
        note:
            "It is Mustahab to pray 2 rakaat nafl anywhere in the Haram after Sa'i.",
      ),
    ],
    duaIds: ['safa_marwa_verse', 'safa_dua', 'sai_running_dua'],
  ),
  RitualPhase(
    id: 'umrah.hair',
    title: 'Hair Cutting — Completing Umrah',
    subtitle: 'Halq / Taqseer',
    overview:
        'Umrah is not complete until the hair is cut. For men, '
        'completely shaving the head is more rewarding than '
        'trimming. Do not cut or shave hair on the street.',
    steps: [
      RitualStep(
        id: 'umrah.hair.barber',
        label:
            'Men: go to a barber — shave the head completely or shorten the hair',
        note:
            'Start shaving from the right side. Do NOT use perfumed '
            'soap or product on the head — confirm with the barber.',
      ),
      RitualStep(
        id: 'umrah.hair.women',
        label:
            'Women: cut approximately one inch (fingertip-length) from the end of the hair',
        note:
            'Wrap the hair around a finger and cut it. This can be done back at the hotel.',
      ),
      RitualStep(
        id: 'umrah.hair.complete',
        label: 'Umrah is now complete — all Ihram restrictions are lifted',
        note:
            'You may now wear normal clothing, use perfume, and resume '
            "all normal activities. For Tamattu' pilgrims, you will "
            're-enter Ihram for Hajj on the 7th Dhul Hijjah.',
      ),
    ],
  ),
];

/// Geofence-style holy sites for Pilgrim Mode proximity alerts.
/// Coordinates are public knowledge, not part of the licensed content.
const List<HolySite> holySites = [
  HolySite(
    id: 'mina',
    name: 'Mina (Tent City)',
    arabicName: 'مِنى',
    latitude: 21.4164,
    longitude: 39.8913,
    radiusMeters: 800,
    description:
        'The valley where pilgrims spend the nights of the 8th, '
        '11th, 12th (and optionally 13th) of Dhul Hijjah, and stone '
        'the Jamarat.',
    relatedPhaseId: 'day-1',
  ),
  HolySite(
    id: 'arafah',
    name: 'Mount Arafah',
    arabicName: 'عَرَفَة',
    latitude: 21.3547,
    longitude: 39.9841,
    radiusMeters: 1500,
    description:
        'The plain of standing (Wuquf) on the 9th of Dhul Hijjah — '
        'the heart of Hajj.',
    relatedPhaseId: 'day-2',
  ),
  HolySite(
    id: 'muzdalifah',
    name: 'Muzdalifah',
    arabicName: 'مُزْدَلِفَة',
    latitude: 21.3905,
    longitude: 39.9326,
    radiusMeters: 1000,
    description:
        'The open plain between Arafah and Mina where pilgrims '
        'gather pebbles and sleep under the sky on the night of the '
        '9th/10th.',
    relatedPhaseId: 'day-2',
  ),
  HolySite(
    id: 'masjid-al-haram',
    name: 'Masjid al-Haram',
    arabicName: 'الْمَسْجِد الْحَرَام',
    latitude: 21.4225,
    longitude: 39.8262,
    radiusMeters: 500,
    description:
        "The Grand Mosque surrounding the Ka'bah — site of Tawaf "
        "and Sa'i.",
    relatedPhaseId: 'umrah.tawaf',
  ),
];

RitualDua? duaById(String id) {
  for (final dua in hajjUmrahDuas) {
    if (dua.id == id) return dua;
  }
  return null;
}
