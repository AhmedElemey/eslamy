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
  String get sectionTextSize => 'Text size';

  @override
  String get textSizeDescription =>
      'Adjust the text size across the app. 0 is default.';

  @override
  String get sectionDailyWerdTime => 'Daily Werd time';

  @override
  String get pickTime => 'Pick time';

  @override
  String get scheduleButton => 'Schedule';

  @override
  String get werdTimeSavedAndScheduled => 'Werd time saved and scheduled';

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
  String get sectionPushNotificationsFcm => 'Push notifications (FCM)';

  @override
  String get fetchingFcmToken => 'Fetching FCM token...';

  @override
  String get noFcmTokenYet => 'No token yet. Ensure notifications are allowed.';

  @override
  String get copyTokenButton => 'Copy token';

  @override
  String get tokenCopied => 'Token copied';

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
  String get developerToolsTitle => 'Developer tools';

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
}
