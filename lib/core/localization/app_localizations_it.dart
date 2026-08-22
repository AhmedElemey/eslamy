// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Eslamy';

  @override
  String get retry => 'Riprova';

  @override
  String get cancel => 'Annulla';

  @override
  String get ok => 'OK';

  @override
  String get errorPageTitle => 'Errore';

  @override
  String get errorOccurredTitle => 'Si è verificato un errore';

  @override
  String get somethingWentWrongGeneric => 'Qualcosa è andato storto';

  @override
  String get goBack => 'Indietro';

  @override
  String get goHome => 'Vai alla home';

  @override
  String get noNetworkTitle => 'Nessuna connessione Internet';

  @override
  String get noNetworkMessage => 'Connettiti a Internet e riprova.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get sectionAppearance => 'Aspetto';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get sectionLanguage => 'Lingua';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageArabic => 'Arabo';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get sectionTextSize => 'Dimensione testo';

  @override
  String get textSizeDescription =>
      'Regola la dimensione del testo in tutta l\'app. 0 è il valore predefinito.';

  @override
  String get sectionDailyWerdTime => 'Orario del Wird giornaliero';

  @override
  String get pickTime => 'Scegli l\'orario';

  @override
  String get scheduleButton => 'Pianifica';

  @override
  String get werdTimeSavedAndScheduled =>
      'Orario del Wird salvato e pianificato';

  @override
  String get reminderScheduled => 'Promemoria pianificato';

  @override
  String get notificationsDisabledMessage =>
      'Le notifiche sono disattivate. Attivale nelle impostazioni di sistema.';

  @override
  String get testNowButton => 'Prova ora';

  @override
  String get testNotificationTitle => 'Notifica di prova';

  @override
  String get testNotificationBody =>
      'Se vedi questo messaggio, le notifiche funzionano';

  @override
  String get homeGreetingAssalamuAlaikum => 'ASSALAMU ALAIKUM';

  @override
  String get homeWelcomeBack => 'Bentornato';

  @override
  String get tabSurah => 'Sura';

  @override
  String get tabPara => 'Juz';

  @override
  String get tabPage => 'Pagina';

  @override
  String get tabHizb => 'Hizb';

  @override
  String get quranOriginMeccan => 'MECCANA';

  @override
  String get quranOriginMedinian => 'MEDINESE';

  @override
  String versesCountCaps(int count) {
    return '$count VERSETTI';
  }

  @override
  String get streakStatLabel => 'serie';

  @override
  String get streakDetailTitle => 'Serie di lettura';

  @override
  String get streakExplanationBody =>
      'La tua serie conta i giorni consecutivi in cui hai aperto Eslamy. Torna ogni giorno per mantenerla.';

  @override
  String get memorizedStatLabel => 'memorizzate';

  @override
  String streakDaysShort(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String memorizedOutOfTotal(int count, int total) {
    return '$count / $total';
  }

  @override
  String get qiblaDirectionTooltip => 'Direzione della qibla';

  @override
  String get homeHighlightAyahOfDayTitle => 'VERSETTO DEL GIORNO';

  @override
  String get homeHighlightAyahOfDayError =>
      'Impossibile caricare il versetto di oggi';

  @override
  String homeHighlightSurahAyahLabel(String surah, int ayah) {
    return '$surah · Versetto $ayah';
  }

  @override
  String get homeHighlightContinueReadingTitle => 'CONTINUA LA LETTURA';

  @override
  String get homeHighlightContinueReadingEmpty =>
      'Non hai ancora iniziato a leggere';

  @override
  String get homeHighlightContinueReadingCta => 'Continua';

  @override
  String homeHighlightAyahPageLabel(int ayah, int page) {
    return 'Versetto $ayah · Pagina $page';
  }

  @override
  String get homeHighlightDuaOfDayTitle => 'DUA DEL GIORNO';

  @override
  String get homeHighlightDuaOfDayError =>
      'Impossibile caricare la dua di oggi';

  @override
  String get widgetNextPrayerTitle => 'PROSSIMA PREGHIERA';

  @override
  String get widgetHijriDateTitle => 'DATA ISLAMICA DI OGGI';

  @override
  String get sectionHomeWidget => 'Widget Home';

  @override
  String get homeWidgetDescription =>
      'Scegli cosa mostrare nel widget della schermata Home';

  @override
  String get widgetCustomizationIntro =>
      'Attiva o disattiva gli elementi per controllare cosa ruota nel widget della schermata Home. L\'anteprima qui sotto corrisponde a quello che vedrai lì.';

  @override
  String get widgetCustomizationMinimumOneRequired =>
      'Mantieni almeno un elemento attivo.';

  @override
  String get widgetCustomizationLockScreenNote =>
      'I widget della Lock Screen aggiunti manualmente mostrano sempre un solo argomento e non sono influenzati da questa impostazione.';

  @override
  String get favoritesTitle => 'Preferiti';

  @override
  String get bookmarkedHadiths => 'Hadith salvati';

  @override
  String hadithsSavedCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString hadith salvati',
      one: '1 hadith salvato',
    );
    return '$_temp0';
  }

  @override
  String get bookmarkedQuran => 'Sure del Corano salvate';

  @override
  String surahsSavedCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString sure salvate',
      one: '1 sura salvata',
    );
    return '$_temp0';
  }

  @override
  String get noQuranFavoritesYetBody =>
      'Tocca il cuore mentre ascolti una sura\ne apparirà qui';

  @override
  String get failedToLoadFavorites => 'Impossibile caricare i tuoi preferiti';

  @override
  String get noFavoritesYetTitle => 'Nessun preferito';

  @override
  String get noFavoritesYetBody =>
      'Inizia a salvare gli hadith che ami\ne appariranno qui';

  @override
  String get removedFromFavorites => 'Rimosso dai preferiti';

  @override
  String get addedToFavorites => 'Aggiunto ai preferiti';

  @override
  String get clearAllFavoritesTitle => 'Cancella tutti i preferiti';

  @override
  String get clearAllFavoritesBody =>
      'Sei sicuro di voler rimuovere tutti i tuoi hadith preferiti? Questa azione non può essere annullata.';

  @override
  String get clearAllButton => 'Cancella tutto';

  @override
  String get allFavoritesCleared => 'Tutti i preferiti sono stati cancellati';

  @override
  String get justNow => 'Proprio ora';

  @override
  String daysAgo(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString giorni fa',
      one: '1 giorno fa',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ore fa',
      one: '1 ora fa',
    );
    return '$_temp0';
  }

  @override
  String get hadithCollectionTitle => 'Raccolta di Hadith';

  @override
  String searchBookHint(String bookName) {
    return 'Cerca in $bookName…';
  }

  @override
  String downloadingBookForOffline(String bookName) {
    return 'Download di $bookName per l\'uso offline…';
  }

  @override
  String failedToDownloadWithError(String error) {
    return 'Download non riuscito\n$error';
  }

  @override
  String get noHadithsMatchSearch =>
      'Nessun hadith corrisponde alla tua ricerca';

  @override
  String narratedBy(String narrator) {
    return 'Narrato da $narrator';
  }

  @override
  String get sharedFromEslamy => 'Condiviso da Eslamy';

  @override
  String get preparingShare => 'Preparazione…';

  @override
  String get shareAsImage => 'Condividi come immagine';

  @override
  String get hifzTrackerTitle => 'Monitoraggio Hifz';

  @override
  String get setReviewReminderTooltip => 'Imposta promemoria di ripasso';

  @override
  String failedToLoadSurahsWithError(String error) {
    return 'Impossibile caricare le sure\n$error';
  }

  @override
  String noSurahsMatchQuery(String query) {
    return 'Nessuna sura corrisponde a \"$query\"';
  }

  @override
  String noItemsMatchQuery(String label, String query) {
    return 'Nessun $label corrisponde a \"$query\"';
  }

  @override
  String juzNumberLabel(int number) {
    return 'Juz $number';
  }

  @override
  String startsAtSurahAyah(String surahName, int surah, int ayah) {
    return 'Inizia da $surahName $surah:$ayah';
  }

  @override
  String get loadingEllipsis => 'Caricamento…';

  @override
  String surahsMemorizedProgress(int memorized, int total) {
    return '$memorized di $total sure memorizzate';
  }

  @override
  String versesCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString versetti',
      one: '1 versetto',
    );
    return '$_temp0';
  }

  @override
  String get hifzReviewNotificationTitle => 'Ripasso Hifz';

  @override
  String get hifzReviewNotificationBody =>
      'È ora di ripassare ciò che hai memorizzato';

  @override
  String get dailyReviewReminderScheduled =>
      'Promemoria di ripasso giornaliero pianificato';

  @override
  String get prayerTimesTitle => 'Orari di preghiera';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Alba';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get amLabel => 'AM';

  @override
  String get pmLabel => 'PM';

  @override
  String failedToLoadPrayerTimesWithError(String error) {
    return 'Impossibile caricare gli orari di preghiera\n$error';
  }

  @override
  String get showingCairoFallback =>
      'Vengono mostrati gli orari del Cairo (predefinito). Attiva la posizione per orari precisi.';

  @override
  String get enableButton => 'Attiva';

  @override
  String get findQiblaDirection => 'Trova la direzione della qibla';

  @override
  String get qiblaDirectionTitle => 'Direzione della Qibla';

  @override
  String qiblaUnavailableWithError(String error) {
    return 'Direzione della qibla non disponibile\n$error';
  }

  @override
  String get waitingForCompassSensor =>
      'In attesa della bussola…\n(non disponibile su tutti i simulatori)';

  @override
  String get noCompassSensor => 'Questo dispositivo non ha una bussola.';

  @override
  String get facingQibla => 'Rivolto verso la Qibla ✓';

  @override
  String get rotateToAlign => 'Ruota per allinearti';

  @override
  String qiblaBearingHeading(String bearing, String heading) {
    return 'Direzione qibla: $bearing°  ·  Orientamento: $heading°';
  }

  @override
  String get allPrayersDoneLabel => 'PREGHIERE COMPLETATE';

  @override
  String get nextPrayerLabel => 'PROSSIMA PREGHIERA';

  @override
  String get fajrResumesAfterMidnight => 'Il Fajr riprende dopo mezzanotte';

  @override
  String get couldntLoadPrayerTimes =>
      'Impossibile caricare gli orari di preghiera';

  @override
  String get countdownNow => 'ora';

  @override
  String countdownHoursMinutes(int h, int m) {
    return 'tra ${h}h ${m}m';
  }

  @override
  String countdownMinutes(int m) {
    return 'tra ${m}m';
  }

  @override
  String get quranChaptersTitle => 'Capitoli del Corano';

  @override
  String get pauseAudioTooltip => 'Metti in pausa l\'audio';

  @override
  String get stopAudioTooltip => 'Interrompi l\'audio';

  @override
  String get loadingAudio => 'Caricamento audio...';

  @override
  String playingChapterWithReciter(String name) {
    return 'Riproduzione del capitolo con il recitatore: $name';
  }

  @override
  String realAudioNotAvailableReciter(String name) {
    return 'Audio reale non disponibile, viene riprodotto un audio di prova. Recitatore: $name';
  }

  @override
  String audioPlaybackErrorWithError(String error) {
    return 'Errore di riproduzione audio: $error';
  }

  @override
  String playingChapterNumberAudio(int number) {
    return 'Riproduzione audio del Capitolo $number';
  }

  @override
  String get failedToPlayAudioRetry =>
      'Impossibile riprodurre l\'audio. Riprova.';

  @override
  String get retryAction => 'Riprova';

  @override
  String autoAdvancingToChapter(int number, String name) {
    return 'Passaggio automatico al Capitolo $number: $name';
  }

  @override
  String get allChaptersCompleted => 'Tutti i capitoli completati!';

  @override
  String chapterNumberAudioLabel(int number) {
    return 'Audio del Capitolo $number';
  }

  @override
  String get audioPlayerLabel => 'Lettore audio';

  @override
  String get failedToLoadChapters => 'Impossibile caricare i capitoli';

  @override
  String versesCountRevelationType(int count, String type) {
    return '$count versetti • $type';
  }

  @override
  String get playAudioTooltip => 'Riproduci audio';

  @override
  String chapterWithNameTitle(int number, String name) {
    return 'Capitolo $number: $name';
  }

  @override
  String get pauseChapterAudioTooltip => 'Metti in pausa l\'audio del capitolo';

  @override
  String get playChapterAudioTooltip => 'Riproduci l\'audio del capitolo';

  @override
  String get loadingChapterAudio => 'Caricamento audio del capitolo...';

  @override
  String get chapterAudioStartedPlaying =>
      'Riproduzione audio del capitolo avviata';

  @override
  String get failedToPlayChapterAudioRetry =>
      'Impossibile riprodurre l\'audio del capitolo. Riprova.';

  @override
  String get chapterAudioLabel => 'Audio del capitolo';

  @override
  String get failedToLoadChapter => 'Impossibile caricare il capitolo';

  @override
  String get playAudioLabel => 'Riproduci audio';

  @override
  String get tafseerLabel => 'Tafsir';

  @override
  String chapterVerseTitle(int chapter, int verse) {
    return 'Capitolo $chapter, Versetto $verse';
  }

  @override
  String playingWithReciter(String name) {
    return 'Riproduzione con il recitatore: $name';
  }

  @override
  String get audioStartedPlaying => 'Riproduzione audio avviata';

  @override
  String get audioRecitationLabel => 'Recitazione audio';

  @override
  String get tapPlayToLoadAudio => 'Tocca play per caricare l\'audio';

  @override
  String get toggleTajweedColoringTooltip =>
      'Attiva/disattiva la colorazione del tajwid';

  @override
  String get tajweedLegendTitle => 'Legenda del Tajwid';

  @override
  String get tajweedLegendSubtitle =>
      'Tocca una lettera colorata nel testo per vedere la sua regola. I colori corrispondono a questa legenda.';

  @override
  String get repeatPracticeLabel => 'Ripeti per esercitarti';

  @override
  String get tafseerInterpretationLabel => 'Tafsir (interpretazione)';

  @override
  String get noTafseerAvailable =>
      'Nessun tafsir disponibile per questo versetto.';

  @override
  String get tafseerMuyassarLabel => 'Tafsir (Muyassar)';

  @override
  String get failedToLoadTafseer => 'Impossibile caricare il tafsir';

  @override
  String get quranReciterLabel => 'Recitatore del Corano';

  @override
  String get selectReciterPlaceholder => 'Seleziona un recitatore';

  @override
  String get activeForAudioLabel => 'Attivo per l\'audio';

  @override
  String get chooseReciterTitle => 'Scegli il recitatore';

  @override
  String get searchReciterHint => 'Cerca recitatore per nome';

  @override
  String get noRecitersFound => 'Nessun recitatore trovato';

  @override
  String get openAyahRangePlayerTooltip =>
      'Riproduci il capitolo o un intervallo di versetti';

  @override
  String get playFullSurahLabel => 'Capitolo completo';

  @override
  String get playAyahRangeLabel => 'Intervallo di versetti';

  @override
  String ayahRangeSummary(int from, int to, int count) {
    return 'Versetti $from–$to • $count versetti';
  }

  @override
  String fromAyahLabel(int ayah) {
    return 'Dal versetto $ayah';
  }

  @override
  String toAyahLabel(int ayah) {
    return 'Al versetto $ayah';
  }

  @override
  String get reciterRangeFallbackNotice =>
      'Questo recitatore non ha registrazioni separate per versetto, quindi verrà riprodotto l\'audio dell\'intero capitolo.';

  @override
  String get reciterRangeUnavailableNotice =>
      'Questo recitatore non ha registrazioni separate per versetto, quindi non è possibile selezionare un intervallo di versetti. Scegli un altro recitatore.';

  @override
  String nowPlayingRangeSubtitle(int ayah, int from, int to) {
    return 'Versetto $ayah • intervallo $from–$to';
  }

  @override
  String get nowPlayingPreviousAyahTooltip => 'Versetto precedente';

  @override
  String get nowPlayingNextAyahTooltip => 'Versetto successivo';

  @override
  String mushafPageLabel(int page) {
    return 'Pagina $page';
  }

  @override
  String mushafJuzLabel(int juz) {
    return 'Juz $juz';
  }

  @override
  String get mushafPreviousPageTooltip => 'Pagina precedente';

  @override
  String get mushafNextPageTooltip => 'Pagina successiva';

  @override
  String get jumpToPageTitle => 'Vai alla pagina';

  @override
  String get fromAyahFieldLabel => 'Da';

  @override
  String get toAyahFieldLabel => 'A';

  @override
  String get pageNumberHint => 'Numero di pagina';

  @override
  String get pageNotInThisSurah =>
      'Questa pagina non fa parte di questo capitolo';

  @override
  String get splashTagline =>
      'Il tuo compagno per il Corano, la preghiera\ne il culto quotidiano';

  @override
  String get dayStreakSingle => 'Serie di 1 giorno';

  @override
  String dayStreakCount(int count) {
    return 'Serie di $count giorni';
  }

  @override
  String genericErrorWithMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String get adhanAlertsTitle => 'Avvisi Adhan';

  @override
  String get adhanAlertsDescription =>
      'Ricevi una notifica per ognuna delle 5 preghiere quotidiane.';

  @override
  String get enabledLabel => 'Attivo';

  @override
  String get stopTooltip => 'Interrompi';

  @override
  String get previewTooltip => 'Anteprima';

  @override
  String get tasbihCounterTitle => 'Contatore Tasbih';

  @override
  String get resetTooltip => 'Azzera';

  @override
  String get targetReached => 'Obiettivo raggiunto ✓';

  @override
  String targetLabel(int target) {
    return 'Obiettivo: $target';
  }

  @override
  String get tapCircleHint =>
      'Tocca il cerchio per contare. Il tuo progresso viene salvato automaticamente.';

  @override
  String get duasAzkarTitle => 'Dua e Azkar';

  @override
  String couldNotLoadAzkarWithError(String error) {
    return 'Impossibile caricare gli Azkar\n$error';
  }

  @override
  String couldNotLoadSectionWithError(String error) {
    return 'Impossibile caricare questa sezione\n$error';
  }

  @override
  String get hijriCalendarTitle => 'Calendario Hijri';

  @override
  String get todayLabelCaps => 'OGGI';

  @override
  String hijriDateAh(int day, String month, int year) {
    return '$day $month $year AH';
  }

  @override
  String get hijriMonthMuharram => 'Muharram';

  @override
  String get hijriMonthSafar => 'Safar';

  @override
  String get hijriMonthRabiAlAwwal => 'Rabi\' al-Awwal';

  @override
  String get hijriMonthRabiAlThani => 'Rabi\' al-Thani';

  @override
  String get hijriMonthJumadaAlAwwal => 'Jumada al-Awwal';

  @override
  String get hijriMonthJumadaAlThani => 'Jumada al-Thani';

  @override
  String get hijriMonthRajab => 'Rajab';

  @override
  String get hijriMonthShaban => 'Sha\'ban';

  @override
  String get hijriMonthRamadan => 'Ramadan';

  @override
  String get hijriMonthShawwal => 'Shawwal';

  @override
  String get hijriMonthDhuAlQidah => 'Dhu al-Qi\'dah';

  @override
  String get hijriMonthDhuAlHijjah => 'Dhu al-Hijjah';

  @override
  String get upcomingLabel => 'Prossime ricorrenze';

  @override
  String get loadingUpcomingOccasions =>
      'Caricamento delle prossime ricorrenze…';

  @override
  String get noUpcomingOccasions => 'Nessuna ricorrenza imminente trovata.';

  @override
  String get todayCountdown => 'Oggi';

  @override
  String get tomorrowCountdown => 'Domani';

  @override
  String inDaysCountdown(int days) {
    return 'tra $days giorni';
  }

  @override
  String get monthJanuary => 'Gennaio';

  @override
  String get monthFebruary => 'Febbraio';

  @override
  String get monthMarch => 'Marzo';

  @override
  String get monthApril => 'Aprile';

  @override
  String get monthMay => 'Maggio';

  @override
  String get monthJune => 'Giugno';

  @override
  String get monthJuly => 'Luglio';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthSeptember => 'Settembre';

  @override
  String get monthOctober => 'Ottobre';

  @override
  String get monthNovember => 'Novembre';

  @override
  String get monthDecember => 'Dicembre';

  @override
  String get weekdaySun => 'D';

  @override
  String get weekdayMon => 'L';

  @override
  String get weekdayTue => 'M';

  @override
  String get weekdayWed => 'M';

  @override
  String get weekdayThu => 'G';

  @override
  String get weekdayFri => 'V';

  @override
  String get weekdaySat => 'S';

  @override
  String get chooseTranslationTitle => 'Scegli la traduzione';

  @override
  String get searchLanguageHint => 'Cerca lingua…';

  @override
  String couldNotLoadLanguagesWithError(String error) {
    return 'Impossibile caricare le lingue\n$error';
  }

  @override
  String get drawerSectionWorship => 'Culto';

  @override
  String get drawerSectionQuranStudy => 'Corano e studio';

  @override
  String get digitalMushaf => 'Mushaf digitale';

  @override
  String get quranTafseerTitle => 'Tafsir del Corano';

  @override
  String get hifzProgress => 'Progresso Hifz';

  @override
  String get hadithLabel => 'Hadith';

  @override
  String get quickAccessTasbih => 'Tasbih';

  @override
  String get weekdayMonday => 'Lunedì';

  @override
  String get weekdayTuesday => 'Martedì';

  @override
  String get weekdayWednesday => 'Mercoledì';

  @override
  String get weekdayThursday => 'Giovedì';

  @override
  String get weekdayFriday => 'Venerdì';

  @override
  String get weekdaySaturday => 'Sabato';

  @override
  String get weekdaySunday => 'Domenica';

  @override
  String get holidayIslamicNewYear => 'Capodanno islamico';

  @override
  String get holidayDayOfAshura => 'Giorno di Ashura';

  @override
  String get holidayMawlidAlNabi => 'Mawlid al-Nabi (nascita del Profeta)';

  @override
  String get holidayStartOfRamadan => 'Inizio del Ramadan';

  @override
  String get holidayLaylatAlQadr => 'Laylat al-Qadr (stimato)';

  @override
  String get holidayEidAlFitr => 'Eid al-Fitr';

  @override
  String get holidayDayOfArafah => 'Giorno di Arafah';

  @override
  String get holidayEidAlAdha => 'Eid al-Adha';

  @override
  String get navHomeLabel => 'Home';

  @override
  String get navQuranLabel => 'Corano';

  @override
  String get navQiblaLabel => 'Qibla';

  @override
  String get navPrayerLabel => 'Preghiera';

  @override
  String get navMoreLabel => 'Altro';

  @override
  String get searchSurahHint => 'Cerca per nome o numero…';

  @override
  String get searchJuzHint => 'Cerca per numero o sura iniziale…';

  @override
  String get searchPageHint => 'Vai al numero di pagina…';

  @override
  String get searchHizbHint => 'Vai al numero di Hizb…';

  @override
  String get hajjUmrahGuideTitle => 'Guida a Hajj e Umrah';

  @override
  String get hajjUmrahDisclaimer =>
      'I passaggi rituali e i testi delle dua provengono da una fonte comunitaria (licenza MIT), non da indicazioni ufficiali del Ministero del Hajj. Verifica con lo studioso del tuo gruppo prima di affidarti a questi contenuti per il tuo pellegrinaggio.';

  @override
  String get umrahTrackLabel => 'Umrah';

  @override
  String get hajjTrackLabel => 'Hajj';

  @override
  String get ritualStepsHeading => 'Passaggi';

  @override
  String get relevantDuasHeading => 'Dua per questo passaggio';

  @override
  String get edgeCasesHeading => 'Eccezioni e casi particolari';

  @override
  String stepsCompletedLabel(int done, int total) {
    return '$done / $total passaggi';
  }

  @override
  String get tawafSaiCounterTitle => 'Contatore di Tawaf e Sa\'i';

  @override
  String get tawafModeLabel => 'Tawaf';

  @override
  String get saiModeLabel => 'Sa\'i';

  @override
  String circuitCountLabel(int count, int target) {
    return '$count / $target';
  }

  @override
  String get tawafCompleteMessage =>
      'Tawaf completato — prega 2 rakaat dietro il Maqam Ibrahim';

  @override
  String get saiCompleteMessage => 'Sa\'i completato';

  @override
  String get pilgrimModeTooltip =>
      'Modalità Pellegrino — avvisi quando sei vicino a un luogo sacro';

  @override
  String get pilgrimModeLocationDenied =>
      'È necessaria l\'autorizzazione alla posizione per gli avvisi della Modalità Pellegrino';

  @override
  String pilgrimModeNear(String siteName) {
    return 'Sei vicino a $siteName';
  }

  @override
  String get nowPlayingTitle => 'In riproduzione';

  @override
  String get nowPlayingNextSurahTooltip => 'Sura successiva';

  @override
  String get nowPlayingPreviousSurahTooltip => 'Sura precedente';

  @override
  String get nowPlayingStopTooltip => 'Ferma';

  @override
  String get overlayPermissionTitle => 'Mostrare il player flottante?';

  @override
  String get overlayPermissionBody =>
      'Eslamy può mostrare una piccola bolla flottante sopra le altre app per controllare la riproduzione senza tornare all\'app. Vuoi attivarla?';

  @override
  String get overlayPermissionAllow => 'Attiva';

  @override
  String get overlayPermissionNotNow => 'Non ora';

  @override
  String get mosqueLocatorTitle => 'Moschee vicine';

  @override
  String get mosqueLocatorDirections => 'Indicazioni';

  @override
  String mosqueLocatorDistance(String distance) {
    return 'a $distance';
  }

  @override
  String get mosqueLocatorEmpty =>
      'Nessuna moschea trovata nelle vicinanze. Riprova più tardi.';

  @override
  String mosqueLocatorFailedWithError(String error) {
    return 'Impossibile caricare le moschee vicine\n$error';
  }

  @override
  String get mosqueLocatorUnnamedMosque => 'Moschea';

  @override
  String get mosqueLocatorApproximateLocation =>
      'Risultati basati sulla tua posizione approssimativa. Attiva la posizione precisa per risultati migliori.';

  @override
  String get mosqueLocatorCouldNotOpenMaps => 'Impossibile aprire Maps';

  @override
  String get mosqueLocatorStaleCache =>
      'Aggiornamento non riuscito — vengono mostrati gli ultimi risultati salvati. Trascina verso il basso per riprovare.';

  @override
  String get mosqueLocatorLocationDenied =>
      'Serve l\'autorizzazione alla posizione per trovare le moschee vicine.';

  @override
  String get mosqueLocatorLocationDeniedForever =>
      'L\'accesso alla posizione è disattivato per Eslamy. Attivalo nelle Impostazioni per trovare le moschee vicine.';

  @override
  String get mosqueLocatorLocationServicesOff =>
      'Attiva i servizi di localizzazione per trovare le moschee vicine.';

  @override
  String get mosqueLocatorOpenSettings => 'Apri impostazioni';

  @override
  String get mosqueLocatorUsingLastKnownLocation =>
      'Viene usata l\'ultima posizione nota. Le distanze potrebbero essere approssimative.';

  @override
  String get notificationChannelDailyWerd => 'Wird giornaliero';

  @override
  String get notificationChannelDailyWerdDescription =>
      'Promemoria quotidiano per il tuo Wird';

  @override
  String get notificationChannelAdhan => 'Adhan';

  @override
  String get notificationChannelAdhanDescription =>
      'Avviso all\'inizio di ogni preghiera';

  @override
  String get notificationChannelQuranPlayback => 'Recitazione del Corano';

  @override
  String adhanNotificationTitle(String name) {
    return 'Adhan — $name';
  }

  @override
  String adhanNotificationBody(String name) {
    return 'È l\'ora della preghiera di $name';
  }

  @override
  String get notificationFallbackTitle => 'Notifica';

  @override
  String get errorConnectionTimeout =>
      'Timeout di connessione. Controlla la connessione internet.';

  @override
  String get errorRequestTimeout =>
      'Timeout della richiesta, riprova più tardi';

  @override
  String get errorResponseTimeout =>
      'Timeout della risposta, riprova più tardi';

  @override
  String get errorUnauthorized => 'Non autorizzato';

  @override
  String get errorForbidden => 'Vietato';

  @override
  String get errorNotFound => 'Risorsa richiesta non trovata.';

  @override
  String get errorInternalServer => 'Errore interno del server';

  @override
  String get errorRateLimit =>
      'Limite di richieste superato, riprova più tardi';

  @override
  String get errorServerError => 'Errore del server. Riprova più tardi.';

  @override
  String get errorRequestCancelled => 'Richiesta annullata.';

  @override
  String get errorUnknown => 'Si è verificato un errore imprevisto';

  @override
  String get errorNoInternet =>
      'Nessuna connessione internet. Controlla la rete.';

  @override
  String errorRequestFailedWithStatus(String statusCode) {
    return 'Richiesta non riuscita con codice: $statusCode';
  }

  @override
  String distanceMeters(int count) {
    return '$count m';
  }

  @override
  String distanceKilometers(String count) {
    return '$count km';
  }

  @override
  String surahNumberLabel(int number) {
    return 'Sura $number';
  }

  @override
  String pageNumberLabel(int number) {
    return 'Pagina $number';
  }

  @override
  String hizbNumberLabel(int number) {
    return 'Hizb $number';
  }

  @override
  String get dhikrSubhanAllah => 'SubhanAllah';

  @override
  String get dhikrAlhamdulillah => 'Alhamdulillah';

  @override
  String get dhikrAllahuAkbar => 'Allahu Akbar';

  @override
  String get dhikrLaIlahaIllaAllah => 'La ilaha illa Allah';

  @override
  String get dhikrAstaghfirullah => 'Astaghfirullah';

  @override
  String get dhikrCustom => 'Personalizzato';

  @override
  String get tajweedHamzatUlWasl => 'Hamzat ul Wasl';

  @override
  String get tajweedSilent => 'Lettera muta';

  @override
  String get tajweedLamShamsiyyah => 'Lam Shamsiyyah';

  @override
  String get tajweedMaddaNormal => 'Prolungamento normale: 2 vocali';

  @override
  String get tajweedMaddaPermissible =>
      'Prolungamento consentito: 2, 4, 6 vocali';

  @override
  String get tajweedMaddaNecessary => 'Prolungamento necessario: 6 vocali';

  @override
  String get tajweedQalqalah => 'Qalqalah';

  @override
  String get tajweedMaddaObligatory => 'Prolungamento obbligatorio: 4-5 vocali';

  @override
  String get tajweedIkhfaShafawi => 'Ikhfa\' Shafawi - con Mim';

  @override
  String get tajweedIkhfa => 'Ikhfa\'';

  @override
  String get tajweedIdghamShafawi => 'Idgham Shafawi - con Mim';

  @override
  String get tajweedIqlab => 'Iqlab';

  @override
  String get tajweedIdghamGhunnah => 'Idgham - con Ghunnah';

  @override
  String get tajweedIdghamNoGhunnah => 'Idgham - senza Ghunnah';

  @override
  String get tajweedIdghamMutajanisayn => 'Idgham - Mutajanisayn';

  @override
  String get tajweedIdghamMutaqaribayn => 'Idgham - Mutaqaribayn';

  @override
  String get tajweedGhunnah => 'Ghunnah: 2 vocali';

  @override
  String get hadithBookBukhari => 'Sahih al-Bukhari';

  @override
  String get hadithBookMuslim => 'Sahih Muslim';

  @override
  String get hadithBookAbuDawud => 'Sunan Abu Dawud';

  @override
  String get hadithBookTirmidhi => 'Jami At-Tirmidhi';

  @override
  String get hadithBookNasai => 'Sunan an-Nasai';

  @override
  String get hadithBookIbnMajah => 'Sunan Ibn Majah';

  @override
  String get hadithBookMalik => 'Muwatta Malik';

  @override
  String get hadithBookNawawi => 'I 40 Hadith di an-Nawawi';

  @override
  String get hadithBookQudsi => '40 Hadith Qudsi';

  @override
  String get hadithBookDehlawi => 'I 40 Hadith di Shah Waliullah';

  @override
  String get reciterStyleMujawwadMelodic => 'Mujawwad (melodico)';

  @override
  String get reciterStyleMurattalSlow => 'Murattal (lento)';

  @override
  String get reciterStyleModern => 'Moderno';

  @override
  String get reciterStyleTraditional => 'Tradizionale';

  @override
  String get reciterStyleMurattal => 'Murattal';

  @override
  String get azkarCategoryMorning => 'Adhkar del mattino';

  @override
  String get azkarCategoryMorningDescription => 'Suppliche per il mattino';

  @override
  String get azkarCategoryEvening => 'Adhkar della sera';

  @override
  String get azkarCategoryEveningDescription => 'Suppliche per la sera';

  @override
  String get azkarCategoryWudu => 'Wudu e purificazione';

  @override
  String get azkarCategoryWuduDescription =>
      'Suppliche per l\'abluzione e la purificazione';

  @override
  String get azkarCategoryPrayer => 'Durante la preghiera';

  @override
  String get azkarCategoryPrayerDescription =>
      'Suppliche dette durante la salah';

  @override
  String get azkarCategoryAfterPrayer => 'Dopo la preghiera';

  @override
  String get azkarCategoryAfterPrayerDescription =>
      'Dhikr e suppliche dopo la salah';

  @override
  String get azkarCategorySleep => 'Sonno';

  @override
  String get azkarCategorySleepDescription => 'Prima di dormire e al risveglio';

  @override
  String get azkarCategoryFood => 'Cibo e bevande';

  @override
  String get azkarCategoryFoodDescription => 'Prima e dopo i pasti';

  @override
  String get azkarCategoryTravel => 'Viaggio';

  @override
  String get azkarCategoryTravelDescription => 'Suppliche per i viaggi';

  @override
  String get azkarCategoryHome => 'Casa';

  @override
  String get azkarCategoryHomeDescription => 'Entrare e uscire di casa';

  @override
  String get azkarCategoryMasjid => 'Moschea';

  @override
  String get azkarCategoryMasjidDescription => 'Entrare e uscire dalla moschea';

  @override
  String get azkarCategoryDistress => 'Angoscia e ansia';

  @override
  String get azkarCategoryDistressDescription =>
      'Suppliche nei momenti di difficoltà';

  @override
  String get azkarCategoryForgiveness => 'Perdono';

  @override
  String get azkarCategoryForgivenessDescription => 'Chiedere perdono ad Allah';

  @override
  String get azkarCategoryIllness => 'Malattia e guarigione';

  @override
  String get azkarCategoryIllnessDescription => 'Suppliche per i malati';

  @override
  String get azkarCategoryWeather => 'Tempo atmosferico';

  @override
  String get azkarCategoryWeatherDescription => 'Pioggia, tuono e vento';

  @override
  String get azkarCategoryKnowledge => 'Conoscenza';

  @override
  String get azkarCategoryKnowledgeDescription =>
      'Chiedere una conoscenza utile';

  @override
  String get azkarCategoryParents => 'Genitori';

  @override
  String get azkarCategoryParentsDescription => 'Suppliche per i genitori';

  @override
  String get azkarCategoryGuidance => 'Guida';

  @override
  String get azkarCategoryGuidanceDescription => 'Chiedere guida e direzione';

  @override
  String get azkarCategoryGratitude => 'Gratitudine';

  @override
  String get azkarCategoryGratitudeDescription => 'Ringraziare e lodare Allah';

  @override
  String get azkarCategoryProtection => 'Protezione';

  @override
  String get azkarCategoryProtectionDescription =>
      'Cercare rifugio e protezione';

  @override
  String get azkarCategoryDhikr => 'Dhikr';

  @override
  String get azkarCategoryDhikrDescription => 'Ricordo generale di Allah';

  @override
  String get azkarCategoryMarriage => 'Matrimonio e famiglia';

  @override
  String get azkarCategoryMarriageDescription =>
      'Suppliche per il matrimonio e la vita familiare';

  @override
  String get azkarCategoryHajj => 'Hajj e Umrah';

  @override
  String get azkarCategoryHajjDescription => 'Suppliche per il pellegrinaggio';

  @override
  String get azkarCategoryGrief => 'Lutto e perdita';

  @override
  String get azkarCategoryGriefDescription =>
      'Suppliche nei momenti di perdita e morte';

  @override
  String get azkarCategoryChildren => 'Figli';

  @override
  String get azkarCategoryChildrenDescription =>
      'Suppliche per i bambini e i neonati';

  @override
  String get azkarCategoryBusiness => 'Lavoro e sostentamento';

  @override
  String get azkarCategoryBusinessDescription =>
      'Suppliche per il guadagno e la ricchezza';

  @override
  String get azkarCategoryNightPrayer => 'Preghiera notturna';

  @override
  String get azkarCategoryNightPrayerDescription =>
      'Suppliche per tahajjud, witr e la notte';

  @override
  String get azkarCategoryQuranRecitation => 'Recitazione del Corano';

  @override
  String get azkarCategoryQuranRecitationDescription =>
      'Suppliche prima e durante la recitazione del Corano';
}
