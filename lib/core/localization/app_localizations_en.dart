// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Eslamy';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get errorPageTitle => 'Error';

  @override
  String get errorOccurredTitle => 'An error occurred';

  @override
  String get somethingWentWrongGeneric => 'Something went wrong';

  @override
  String get goBack => 'Go Back';

  @override
  String get goHome => 'Go Home';

  @override
  String get noNetworkTitle => 'No Internet Connection';

  @override
  String get noNetworkMessage =>
      'Please connect to the internet and try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageItalian => 'Italian';

  @override
  String get sectionTextSize => 'Text size';

  @override
  String get textSizeDescription =>
      'Adjust the text size across the app. 0 is default.';

  @override
  String get sectionDailyWerdTime => 'Daily Wird time';

  @override
  String get pickTime => 'Pick time';

  @override
  String get scheduleButton => 'Schedule';

  @override
  String get werdTimeSavedAndScheduled => 'Wird time saved and scheduled';

  @override
  String get reminderScheduled => 'Reminder scheduled';

  @override
  String get notificationsDisabledMessage =>
      'Notifications are disabled. Enable them in system settings.';

  @override
  String get testNowButton => 'Test now';

  @override
  String get testNotificationTitle => 'Test Notification';

  @override
  String get testNotificationBody => 'If you see this, notifications work';

  @override
  String get homeGreetingAssalamuAlaikum => 'ASSALAMU ALAIKUM';

  @override
  String get homeWelcomeBack => 'Welcome back';

  @override
  String get tabSurah => 'Surah';

  @override
  String get tabPara => 'Juz';

  @override
  String get tabPage => 'Page';

  @override
  String get tabHizb => 'Hizb';

  @override
  String get quranOriginMeccan => 'MECCAN';

  @override
  String get quranOriginMedinian => 'MEDINIAN';

  @override
  String versesCountCaps(int count) {
    return '$count VERSES';
  }

  @override
  String get streakStatLabel => 'streak';

  @override
  String get memorizedStatLabel => 'memorized';

  @override
  String streakDaysShort(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String memorizedOutOfTotal(int count, int total) {
    return '$count / $total';
  }

  @override
  String get qiblaDirectionTooltip => 'Qibla direction';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get bookmarkedHadiths => 'Bookmarked Hadiths';

  @override
  String hadithsSavedCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString hadiths saved',
      one: '1 hadith saved',
    );
    return '$_temp0';
  }

  @override
  String get failedToLoadFavorites => 'Failed to load your favorites';

  @override
  String get noFavoritesYetTitle => 'No favorites yet';

  @override
  String get noFavoritesYetBody =>
      'Start bookmarking hadiths you love\nand they\'ll appear here';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get clearAllFavoritesTitle => 'Clear All Favorites';

  @override
  String get clearAllFavoritesBody =>
      'Are you sure you want to remove all your favorite hadiths? This action cannot be undone.';

  @override
  String get clearAllButton => 'Clear All';

  @override
  String get allFavoritesCleared => 'All favorites cleared';

  @override
  String get justNow => 'Just now';

  @override
  String daysAgo(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString days ago',
      one: '1 day ago',
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
      other: '$countString hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get hadithCollectionTitle => 'Hadith Collection';

  @override
  String searchBookHint(String bookName) {
    return 'Search $bookName…';
  }

  @override
  String downloadingBookForOffline(String bookName) {
    return 'Downloading $bookName for offline use…';
  }

  @override
  String failedToDownloadWithError(String error) {
    return 'Failed to download\n$error';
  }

  @override
  String get noHadithsMatchSearch => 'No hadiths match your search';

  @override
  String narratedBy(String narrator) {
    return 'Narrated $narrator';
  }

  @override
  String get sharedFromEslamy => 'Shared from Eslamy';

  @override
  String get preparingShare => 'Preparing…';

  @override
  String get shareAsImage => 'Share as image';

  @override
  String get hifzTrackerTitle => 'Hifz Tracker';

  @override
  String get setReviewReminderTooltip => 'Set review reminder';

  @override
  String failedToLoadSurahsWithError(String error) {
    return 'Failed to load surahs\n$error';
  }

  @override
  String noSurahsMatchQuery(String query) {
    return 'No surahs match \"$query\"';
  }

  @override
  String noItemsMatchQuery(String label, String query) {
    return 'No $label matches \"$query\"';
  }

  @override
  String juzNumberLabel(int number) {
    return 'Juz $number';
  }

  @override
  String startsAtSurahAyah(String surahName, int surah, int ayah) {
    return 'Starts at $surahName $surah:$ayah';
  }

  @override
  String get loadingEllipsis => 'Loading…';

  @override
  String surahsMemorizedProgress(int memorized, int total) {
    return '$memorized of $total surahs memorized';
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
      other: '$countString verses',
      one: '1 verse',
    );
    return '$_temp0';
  }

  @override
  String get hifzReviewNotificationTitle => 'Hifz Review';

  @override
  String get hifzReviewNotificationBody =>
      'Time to review what you\'ve memorized';

  @override
  String get dailyReviewReminderScheduled => 'Daily review reminder scheduled';

  @override
  String get prayerTimesTitle => 'Prayer Times';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

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
    return 'Failed to load prayer times\n$error';
  }

  @override
  String get showingCairoFallback =>
      'Showing times for Cairo (default). Enable location for accurate times.';

  @override
  String get enableButton => 'Enable';

  @override
  String get findQiblaDirection => 'Find Qibla direction';

  @override
  String get qiblaDirectionTitle => 'Qibla Direction';

  @override
  String qiblaUnavailableWithError(String error) {
    return 'Qibla direction unavailable\n$error';
  }

  @override
  String get waitingForCompassSensor =>
      'Waiting for compass sensor…\n(not available on all simulators)';

  @override
  String get noCompassSensor => 'This device has no compass sensor.';

  @override
  String get facingQibla => 'Facing Qibla ✓';

  @override
  String get rotateToAlign => 'Rotate to align';

  @override
  String qiblaBearingHeading(String bearing, String heading) {
    return 'Qibla bearing: $bearing°  ·  Heading: $heading°';
  }

  @override
  String get allPrayersDoneLabel => 'ALL PRAYERS DONE';

  @override
  String get nextPrayerLabel => 'NEXT PRAYER';

  @override
  String get fajrResumesAfterMidnight => 'Fajr resumes after midnight';

  @override
  String get couldntLoadPrayerTimes => 'Couldn\'t load prayer times';

  @override
  String get countdownNow => 'now';

  @override
  String countdownHoursMinutes(int h, int m) {
    return 'in ${h}h ${m}m';
  }

  @override
  String countdownMinutes(int m) {
    return 'in ${m}m';
  }

  @override
  String get quranChaptersTitle => 'Quran Chapters';

  @override
  String get pauseAudioTooltip => 'Pause Audio';

  @override
  String get stopAudioTooltip => 'Stop Audio';

  @override
  String get loadingAudio => 'Loading audio...';

  @override
  String playingChapterWithReciter(String name) {
    return 'Playing chapter with reciter: $name';
  }

  @override
  String realAudioNotAvailableReciter(String name) {
    return 'Real audio not available, playing test audio. Reciter: $name';
  }

  @override
  String audioPlaybackErrorWithError(String error) {
    return 'Audio playback error: $error';
  }

  @override
  String playingChapterNumberAudio(int number) {
    return 'Playing Chapter $number audio';
  }

  @override
  String get failedToPlayAudioRetry =>
      'Failed to play audio. Please try again.';

  @override
  String get retryAction => 'Retry';

  @override
  String autoAdvancingToChapter(int number, String name) {
    return 'Auto-advancing to Chapter $number: $name';
  }

  @override
  String get allChaptersCompleted => 'All chapters completed!';

  @override
  String chapterNumberAudioLabel(int number) {
    return 'Chapter $number Audio';
  }

  @override
  String get audioPlayerLabel => 'Audio Player';

  @override
  String get failedToLoadChapters => 'Failed to load chapters';

  @override
  String versesCountRevelationType(int count, String type) {
    return '$count verses • $type';
  }

  @override
  String get playAudioTooltip => 'Play Audio';

  @override
  String chapterWithNameTitle(int number, String name) {
    return 'Chapter $number: $name';
  }

  @override
  String get pauseChapterAudioTooltip => 'Pause Chapter Audio';

  @override
  String get playChapterAudioTooltip => 'Play Chapter Audio';

  @override
  String get loadingChapterAudio => 'Loading chapter audio...';

  @override
  String get chapterAudioStartedPlaying => 'Chapter audio started playing';

  @override
  String get failedToPlayChapterAudioRetry =>
      'Failed to play chapter audio. Please try again.';

  @override
  String get chapterAudioLabel => 'Chapter Audio';

  @override
  String get failedToLoadChapter => 'Failed to load chapter';

  @override
  String get playAudioLabel => 'Play Audio';

  @override
  String get tafseerLabel => 'Tafseer';

  @override
  String chapterVerseTitle(int chapter, int verse) {
    return 'Chapter $chapter, Verse $verse';
  }

  @override
  String playingWithReciter(String name) {
    return 'Playing with reciter: $name';
  }

  @override
  String get audioStartedPlaying => 'Audio started playing';

  @override
  String get audioRecitationLabel => 'Audio Recitation';

  @override
  String get tapPlayToLoadAudio => 'Tap play to load audio';

  @override
  String get toggleTajweedColoringTooltip => 'Toggle Tajweed coloring';

  @override
  String get tajweedLegendTitle => 'Tajweed Legend';

  @override
  String get tajweedLegendSubtitle =>
      'Tap any colored letter in the text to see its rule. Colors match this key.';

  @override
  String get repeatPracticeLabel => 'Repeat for practice';

  @override
  String get tafseerInterpretationLabel => 'Tafseer (Interpretation)';

  @override
  String get noTafseerAvailable => 'No tafseer available for this verse.';

  @override
  String get tafseerMuyassarLabel => 'Tafseer (Muyassar)';

  @override
  String get failedToLoadTafseer => 'Failed to load tafseer';

  @override
  String get quranReciterLabel => 'Quran Reciter';

  @override
  String get selectReciterPlaceholder => 'Select Reciter';

  @override
  String get activeForAudioLabel => 'Active for Audio';

  @override
  String get chooseReciterTitle => 'Choose Reciter';

  @override
  String get searchReciterHint => 'Search reciter by name';

  @override
  String get noRecitersFound => 'No reciters found';

  @override
  String get openAyahRangePlayerTooltip => 'Play surah or ayah range';

  @override
  String get playFullSurahLabel => 'Complete Surah';

  @override
  String get playAyahRangeLabel => 'Ayah Range';

  @override
  String ayahRangeSummary(int from, int to, int count) {
    return 'Ayah $from–$to • $count verses';
  }

  @override
  String fromAyahLabel(int ayah) {
    return 'From $ayah';
  }

  @override
  String toAyahLabel(int ayah) {
    return 'To $ayah';
  }

  @override
  String get reciterRangeFallbackNotice =>
      'This reciter has no separate ayah recordings, so the full surah audio plays instead for this range.';

  @override
  String get reciterRangeUnavailableNotice =>
      'This reciter doesn\'t have separate recordings for each ayah, so an ayah range can\'t be selected. Please choose a different reciter.';

  @override
  String nowPlayingRangeSubtitle(int ayah, int from, int to) {
    return 'Ayah $ayah • range $from–$to';
  }

  @override
  String get nowPlayingPreviousAyahTooltip => 'Previous Ayah';

  @override
  String get nowPlayingNextAyahTooltip => 'Next Ayah';

  @override
  String mushafPageLabel(int page) {
    return 'Page $page';
  }

  @override
  String mushafJuzLabel(int juz) {
    return 'Juz $juz';
  }

  @override
  String get mushafPreviousPageTooltip => 'Previous Page';

  @override
  String get mushafNextPageTooltip => 'Next Page';

  @override
  String get jumpToPageTitle => 'Go to Page';

  @override
  String get fromAyahFieldLabel => 'From';

  @override
  String get toAyahFieldLabel => 'To';

  @override
  String get pageNumberHint => 'Page number';

  @override
  String get pageNotInThisSurah => 'This page isn\'t part of this surah';

  @override
  String get splashTagline =>
      'Your companion for Quran, prayer\n& daily worship';

  @override
  String get dayStreakSingle => 'Day 1 streak';

  @override
  String dayStreakCount(int count) {
    return '$count day streak';
  }

  @override
  String genericErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get adhanAlertsTitle => 'Adhan Alerts';

  @override
  String get adhanAlertsDescription =>
      'Get notified at each of the 5 daily prayer times.';

  @override
  String get enabledLabel => 'Enabled';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get previewTooltip => 'Preview';

  @override
  String get tasbihCounterTitle => 'Tasbih Counter';

  @override
  String get resetTooltip => 'Reset';

  @override
  String get targetReached => 'Target reached ✓';

  @override
  String targetLabel(int target) {
    return 'Target: $target';
  }

  @override
  String get tapCircleHint =>
      'Tap the circle to count. Your progress is saved automatically.';

  @override
  String get duasAzkarTitle => 'Duas & Azkar';

  @override
  String couldNotLoadAzkarWithError(String error) {
    return 'Could not load Azkar\n$error';
  }

  @override
  String couldNotLoadSectionWithError(String error) {
    return 'Could not load this section\n$error';
  }

  @override
  String get hijriCalendarTitle => 'Hijri Calendar';

  @override
  String get todayLabelCaps => 'TODAY';

  @override
  String hijriDateAh(int day, String month, int year) {
    return '$day $month $year AH';
  }

  @override
  String get upcomingLabel => 'Upcoming';

  @override
  String get loadingUpcomingOccasions => 'Loading upcoming occasions…';

  @override
  String get todayCountdown => 'Today';

  @override
  String get tomorrowCountdown => 'Tomorrow';

  @override
  String inDaysCountdown(int days) {
    return 'in $days days';
  }

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get weekdaySun => 'S';

  @override
  String get weekdayMon => 'M';

  @override
  String get weekdayTue => 'T';

  @override
  String get weekdayWed => 'W';

  @override
  String get weekdayThu => 'T';

  @override
  String get weekdayFri => 'F';

  @override
  String get weekdaySat => 'S';

  @override
  String get chooseTranslationTitle => 'Choose Translation';

  @override
  String get searchLanguageHint => 'Search language…';

  @override
  String couldNotLoadLanguagesWithError(String error) {
    return 'Could not load languages\n$error';
  }

  @override
  String get drawerSectionWorship => 'Worship';

  @override
  String get drawerSectionQuranStudy => 'Quran & Study';

  @override
  String get digitalMushaf => 'Digital Mushaf';

  @override
  String get hifzProgress => 'Hifz Progress';

  @override
  String get hadithLabel => 'Hadith';

  @override
  String get quickAccessTasbih => 'Tasbih';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get holidayIslamicNewYear => 'Islamic New Year';

  @override
  String get holidayDayOfAshura => 'Day of Ashura';

  @override
  String get holidayMawlidAlNabi => 'Mawlid al-Nabi (Prophet\'s Birthday)';

  @override
  String get holidayStartOfRamadan => 'Start of Ramadan';

  @override
  String get holidayLaylatAlQadr => 'Laylat al-Qadr (est.)';

  @override
  String get holidayEidAlFitr => 'Eid al-Fitr';

  @override
  String get holidayDayOfArafah => 'Day of Arafah';

  @override
  String get holidayEidAlAdha => 'Eid al-Adha';

  @override
  String get navHomeLabel => 'Home';

  @override
  String get navQuranLabel => 'Quran';

  @override
  String get navQiblaLabel => 'Qibla';

  @override
  String get navPrayerLabel => 'Prayer';

  @override
  String get navMoreLabel => 'More';

  @override
  String get searchSurahHint => 'Search by name or number…';

  @override
  String get searchJuzHint => 'Search by number or starting surah…';

  @override
  String get searchPageHint => 'Jump to page number…';

  @override
  String get searchHizbHint => 'Jump to Hizb number…';

  @override
  String get hajjUmrahGuideTitle => 'Hajj & Umrah Guide';

  @override
  String get hajjUmrahDisclaimer =>
      'Ritual steps and dua text are community-sourced (MIT-licensed), not official Ministry of Hajj guidance. Verify with your group\'s scholar before relying on this for your pilgrimage.';

  @override
  String get umrahTrackLabel => 'Umrah';

  @override
  String get hajjTrackLabel => 'Hajj';

  @override
  String get ritualStepsHeading => 'Steps';

  @override
  String get relevantDuasHeading => 'Duas for this step';

  @override
  String get edgeCasesHeading => 'Exceptions & edge cases';

  @override
  String stepsCompletedLabel(int done, int total) {
    return '$done / $total steps';
  }

  @override
  String get tawafSaiCounterTitle => 'Tawaf & Sa\'i Counter';

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
      'Tawaf complete — pray 2 rakaat behind Maqam Ibrahim';

  @override
  String get saiCompleteMessage => 'Sa\'i complete';

  @override
  String get pilgrimModeTooltip =>
      'Pilgrim Mode — alerts when near a holy site';

  @override
  String get pilgrimModeLocationDenied =>
      'Location permission is needed for Pilgrim Mode alerts';

  @override
  String pilgrimModeNear(String siteName) {
    return 'You\'re near $siteName';
  }

  @override
  String get nowPlayingTitle => 'Now Playing';

  @override
  String get nowPlayingNextSurahTooltip => 'Next Surah';

  @override
  String get nowPlayingPreviousSurahTooltip => 'Previous Surah';

  @override
  String get nowPlayingStopTooltip => 'Stop';

  @override
  String get overlayPermissionTitle => 'Show floating player?';

  @override
  String get overlayPermissionBody =>
      'Eslamy can show a small floating bubble over other apps so you can control playback without switching back. Enable it?';

  @override
  String get overlayPermissionAllow => 'Enable';

  @override
  String get overlayPermissionNotNow => 'Not now';

  @override
  String get mosqueLocatorTitle => 'Mosque Locator';

  @override
  String get mosqueLocatorDirections => 'Directions';

  @override
  String mosqueLocatorDistance(String distance) {
    return '$distance away';
  }

  @override
  String get mosqueLocatorEmpty => 'No mosques found nearby. Try again later.';

  @override
  String mosqueLocatorFailedWithError(String error) {
    return 'Couldn\'t load nearby mosques\n$error';
  }

  @override
  String get mosqueLocatorUnnamedMosque => 'Mosque';

  @override
  String get mosqueLocatorApproximateLocation =>
      'Showing results for your approximate location. Enable precise location for better results.';

  @override
  String get mosqueLocatorCouldNotOpenMaps => 'Couldn\'t open Maps';

  @override
  String get mosqueLocatorStaleCache =>
      'Couldn\'t refresh — showing previously saved results. Pull down to try again.';

  @override
  String get mosqueLocatorLocationDenied =>
      'Location permission is needed to find mosques near you.';

  @override
  String get mosqueLocatorLocationDeniedForever =>
      'Location access is turned off for Eslamy. Enable it in Settings to find nearby mosques.';

  @override
  String get mosqueLocatorLocationServicesOff =>
      'Turn on Location Services to find mosques near you.';

  @override
  String get mosqueLocatorOpenSettings => 'Open settings';

  @override
  String get mosqueLocatorUsingLastKnownLocation =>
      'Using your last known location. Distances may be approximate.';

  @override
  String get notificationChannelDailyWerd => 'Daily Wird';

  @override
  String get notificationChannelDailyWerdDescription =>
      'Daily reminder for your Wird';

  @override
  String get notificationChannelAdhan => 'Adhan';

  @override
  String get notificationChannelAdhanDescription =>
      'Call-to-prayer alert at each prayer time';

  @override
  String get notificationChannelQuranPlayback => 'Quran playback';

  @override
  String adhanNotificationTitle(String name) {
    return 'Adhan — $name';
  }

  @override
  String adhanNotificationBody(String name) {
    return 'It is time for $name prayer';
  }

  @override
  String get notificationFallbackTitle => 'Notification';

  @override
  String get errorConnectionTimeout =>
      'Connection timeout. Please check your internet connection.';

  @override
  String get errorRequestTimeout => 'Request timeout, try again later';

  @override
  String get errorResponseTimeout => 'Response timeout, try again later';

  @override
  String get errorUnauthorized => 'Unauthorized';

  @override
  String get errorForbidden => 'Forbidden';

  @override
  String get errorNotFound => 'Requested resource not found.';

  @override
  String get errorInternalServer => 'Internal server error';

  @override
  String get errorRateLimit => 'Rate limit exceeded, try again later';

  @override
  String get errorServerError => 'Server error. Please try again later.';

  @override
  String get errorRequestCancelled => 'Request was cancelled.';

  @override
  String get errorUnknown => 'An unexpected error occurred';

  @override
  String get errorNoInternet =>
      'No internet connection. Please check your network.';

  @override
  String errorRequestFailedWithStatus(String statusCode) {
    return 'Request failed with status: $statusCode';
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
    return 'Surah $number';
  }

  @override
  String pageNumberLabel(int number) {
    return 'Page $number';
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
  String get dhikrCustom => 'Custom';

  @override
  String get tajweedHamzatUlWasl => 'Hamzat ul Wasl';

  @override
  String get tajweedSilent => 'Silent';

  @override
  String get tajweedLamShamsiyyah => 'Lam Shamsiyyah';

  @override
  String get tajweedMaddaNormal => 'Normal Prolongation: 2 Vowels';

  @override
  String get tajweedMaddaPermissible =>
      'Permissible Prolongation: 2, 4, 6 Vowels';

  @override
  String get tajweedMaddaNecessary => 'Necessary Prolongation: 6 Vowels';

  @override
  String get tajweedQalqalah => 'Qalqalah';

  @override
  String get tajweedMaddaObligatory => 'Obligatory Prolongation: 4-5 Vowels';

  @override
  String get tajweedIkhfaShafawi => 'Ikhfa\' Shafawi - With Meem';

  @override
  String get tajweedIkhfa => 'Ikhfa\'';

  @override
  String get tajweedIdghamShafawi => 'Idgham Shafawi - With Meem';

  @override
  String get tajweedIqlab => 'Iqlab';

  @override
  String get tajweedIdghamGhunnah => 'Idgham - With Ghunnah';

  @override
  String get tajweedIdghamNoGhunnah => 'Idgham - Without Ghunnah';

  @override
  String get tajweedIdghamMutajanisayn => 'Idgham - Mutajanisayn';

  @override
  String get tajweedIdghamMutaqaribayn => 'Idgham - Mutaqaribayn';

  @override
  String get tajweedGhunnah => 'Ghunnah: 2 Vowels';

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
  String get hadithBookNawawi => 'An-Nawawi\'s 40 Hadith';

  @override
  String get hadithBookQudsi => '40 Hadith Qudsi';

  @override
  String get hadithBookDehlawi => 'Shah Waliullah\'s 40 Hadith';

  @override
  String get reciterStyleMujawwadMelodic => 'Mujawwad (Melodic)';

  @override
  String get reciterStyleMurattalSlow => 'Murattal (Slow)';

  @override
  String get reciterStyleModern => 'Modern';

  @override
  String get reciterStyleTraditional => 'Traditional';

  @override
  String get reciterStyleMurattal => 'Murattal';

  @override
  String get azkarCategoryMorning => 'Morning Adhkar';

  @override
  String get azkarCategoryMorningDescription => 'Supplications for the morning';

  @override
  String get azkarCategoryEvening => 'Evening Adhkar';

  @override
  String get azkarCategoryEveningDescription => 'Supplications for the evening';

  @override
  String get azkarCategoryWudu => 'Wudu & Purification';

  @override
  String get azkarCategoryWuduDescription =>
      'Supplications for ablution and purification';

  @override
  String get azkarCategoryPrayer => 'During Prayer';

  @override
  String get azkarCategoryPrayerDescription =>
      'Supplications said during salah';

  @override
  String get azkarCategoryAfterPrayer => 'After Prayer';

  @override
  String get azkarCategoryAfterPrayerDescription =>
      'Dhikr and supplications after salah';

  @override
  String get azkarCategorySleep => 'Sleep';

  @override
  String get azkarCategorySleepDescription => 'Before sleeping and upon waking';

  @override
  String get azkarCategoryFood => 'Food & Drink';

  @override
  String get azkarCategoryFoodDescription => 'Before and after eating';

  @override
  String get azkarCategoryTravel => 'Travel';

  @override
  String get azkarCategoryTravelDescription => 'Supplications for journeys';

  @override
  String get azkarCategoryHome => 'Home';

  @override
  String get azkarCategoryHomeDescription => 'Entering and leaving the home';

  @override
  String get azkarCategoryMasjid => 'Masjid';

  @override
  String get azkarCategoryMasjidDescription =>
      'Entering and leaving the mosque';

  @override
  String get azkarCategoryDistress => 'Distress & Anxiety';

  @override
  String get azkarCategoryDistressDescription =>
      'Supplications during hardship';

  @override
  String get azkarCategoryForgiveness => 'Forgiveness';

  @override
  String get azkarCategoryForgivenessDescription =>
      'Seeking forgiveness from Allah';

  @override
  String get azkarCategoryIllness => 'Illness & Healing';

  @override
  String get azkarCategoryIllnessDescription => 'Supplications for the sick';

  @override
  String get azkarCategoryWeather => 'Weather';

  @override
  String get azkarCategoryWeatherDescription => 'Rain, thunder, and wind';

  @override
  String get azkarCategoryKnowledge => 'Knowledge';

  @override
  String get azkarCategoryKnowledgeDescription =>
      'Seeking beneficial knowledge';

  @override
  String get azkarCategoryParents => 'Parents';

  @override
  String get azkarCategoryParentsDescription => 'Supplications for parents';

  @override
  String get azkarCategoryGuidance => 'Guidance';

  @override
  String get azkarCategoryGuidanceDescription =>
      'Seeking guidance and direction';

  @override
  String get azkarCategoryGratitude => 'Gratitude';

  @override
  String get azkarCategoryGratitudeDescription => 'Thanking and praising Allah';

  @override
  String get azkarCategoryProtection => 'Protection';

  @override
  String get azkarCategoryProtectionDescription =>
      'Seeking refuge and protection';

  @override
  String get azkarCategoryDhikr => 'Dhikr';

  @override
  String get azkarCategoryDhikrDescription => 'General remembrance of Allah';

  @override
  String get azkarCategoryMarriage => 'Marriage & Family';

  @override
  String get azkarCategoryMarriageDescription =>
      'Supplications for marriage and family life';

  @override
  String get azkarCategoryHajj => 'Hajj & Umrah';

  @override
  String get azkarCategoryHajjDescription => 'Supplications for pilgrimage';

  @override
  String get azkarCategoryGrief => 'Grief & Loss';

  @override
  String get azkarCategoryGriefDescription =>
      'Supplications at times of loss and death';

  @override
  String get azkarCategoryChildren => 'Children';

  @override
  String get azkarCategoryChildrenDescription =>
      'Supplications for children and newborns';

  @override
  String get azkarCategoryBusiness => 'Business & Provision';

  @override
  String get azkarCategoryBusinessDescription =>
      'Supplications for livelihood and wealth';

  @override
  String get azkarCategoryNightPrayer => 'Night Prayer';

  @override
  String get azkarCategoryNightPrayerDescription =>
      'Supplications for tahajjud, witr and the night';

  @override
  String get azkarCategoryQuranRecitation => 'Quran Recitation';

  @override
  String get azkarCategoryQuranRecitationDescription =>
      'Supplications before and during Quran recitation';
}
