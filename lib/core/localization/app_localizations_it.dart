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
  String get upcomingLabel => 'Prossime ricorrenze';

  @override
  String get loadingUpcomingOccasions =>
      'Caricamento delle prossime ricorrenze…';

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
}
