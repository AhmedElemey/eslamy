import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('it'),
  ];

  /// App display name, kept as a brand name across locales
  ///
  /// In en, this message translates to:
  /// **'Eslamy'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @errorPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPageTitle;

  /// No description provided for @errorOccurredTitle.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurredTitle;

  /// No description provided for @somethingWentWrongGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrongGeneric;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @noNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noNetworkTitle;

  /// No description provided for @noNetworkMessage.
  ///
  /// In en, this message translates to:
  /// **'Please connect to the internet and try again.'**
  String get noNetworkMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @sectionTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get sectionTextSize;

  /// No description provided for @textSizeDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust the text size across the app. 0 is default.'**
  String get textSizeDescription;

  /// No description provided for @sectionDailyWerdTime.
  ///
  /// In en, this message translates to:
  /// **'Daily Wird time'**
  String get sectionDailyWerdTime;

  /// No description provided for @pickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get pickTime;

  /// No description provided for @scheduleButton.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleButton;

  /// No description provided for @werdTimeSavedAndScheduled.
  ///
  /// In en, this message translates to:
  /// **'Wird time saved and scheduled'**
  String get werdTimeSavedAndScheduled;

  /// No description provided for @reminderScheduled.
  ///
  /// In en, this message translates to:
  /// **'Reminder scheduled'**
  String get reminderScheduled;

  /// No description provided for @notificationsDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled. Enable them in system settings.'**
  String get notificationsDisabledMessage;

  /// No description provided for @testNowButton.
  ///
  /// In en, this message translates to:
  /// **'Test now'**
  String get testNowButton;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'If you see this, notifications work'**
  String get testNotificationBody;

  /// No description provided for @homeGreetingAssalamuAlaikum.
  ///
  /// In en, this message translates to:
  /// **'ASSALAMU ALAIKUM'**
  String get homeGreetingAssalamuAlaikum;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeWelcomeBack;

  /// No description provided for @tabSurah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get tabSurah;

  /// No description provided for @tabPara.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get tabPara;

  /// No description provided for @tabPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get tabPage;

  /// No description provided for @tabHizb.
  ///
  /// In en, this message translates to:
  /// **'Hizb'**
  String get tabHizb;

  /// No description provided for @quranOriginMeccan.
  ///
  /// In en, this message translates to:
  /// **'MECCAN'**
  String get quranOriginMeccan;

  /// No description provided for @quranOriginMedinian.
  ///
  /// In en, this message translates to:
  /// **'MEDINIAN'**
  String get quranOriginMedinian;

  /// No description provided for @versesCountCaps.
  ///
  /// In en, this message translates to:
  /// **'{count} VERSES'**
  String versesCountCaps(int count);

  /// No description provided for @streakStatLabel.
  ///
  /// In en, this message translates to:
  /// **'streak'**
  String get streakStatLabel;

  /// No description provided for @streakDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading Streak'**
  String get streakDetailTitle;

  /// No description provided for @streakExplanationBody.
  ///
  /// In en, this message translates to:
  /// **'Your streak counts consecutive days you\'ve opened Eslamy. Come back daily to keep it going.'**
  String get streakExplanationBody;

  /// No description provided for @memorizedStatLabel.
  ///
  /// In en, this message translates to:
  /// **'memorized'**
  String get memorizedStatLabel;

  /// No description provided for @streakDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String streakDaysShort(num count);

  /// No description provided for @memorizedOutOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} / {total}'**
  String memorizedOutOfTotal(int count, int total);

  /// No description provided for @qiblaDirectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Qibla direction'**
  String get qiblaDirectionTooltip;

  /// No description provided for @homeHighlightAyahOfDayTitle.
  ///
  /// In en, this message translates to:
  /// **'AYAH OF THE DAY'**
  String get homeHighlightAyahOfDayTitle;

  /// No description provided for @homeHighlightAyahOfDayError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load today\'s ayah'**
  String get homeHighlightAyahOfDayError;

  /// No description provided for @homeHighlightSurahAyahLabel.
  ///
  /// In en, this message translates to:
  /// **'{surah} · Ayah {ayah}'**
  String homeHighlightSurahAyahLabel(String surah, int ayah);

  /// No description provided for @homeHighlightContinueReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE READING'**
  String get homeHighlightContinueReadingTitle;

  /// No description provided for @homeHighlightContinueReadingEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t started reading yet'**
  String get homeHighlightContinueReadingEmpty;

  /// No description provided for @homeHighlightContinueReadingCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get homeHighlightContinueReadingCta;

  /// No description provided for @homeHighlightAyahPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Ayah {ayah} · Page {page}'**
  String homeHighlightAyahPageLabel(int ayah, int page);

  /// No description provided for @homeHighlightDuaOfDayTitle.
  ///
  /// In en, this message translates to:
  /// **'DUA OF THE DAY'**
  String get homeHighlightDuaOfDayTitle;

  /// No description provided for @homeHighlightDuaOfDayError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load today\'s dua'**
  String get homeHighlightDuaOfDayError;

  /// No description provided for @widgetNextPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'NEXT PRAYER'**
  String get widgetNextPrayerTitle;

  /// No description provided for @widgetHijriDateTitle.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S HIJRI DATE'**
  String get widgetHijriDateTitle;

  /// No description provided for @sectionHomeWidget.
  ///
  /// In en, this message translates to:
  /// **'Home Widget'**
  String get sectionHomeWidget;

  /// No description provided for @homeWidgetDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose what shows on your home screen widget'**
  String get homeWidgetDescription;

  /// No description provided for @widgetCustomizationIntro.
  ///
  /// In en, this message translates to:
  /// **'Turn items on or off to control what rotates through your home screen widget. Each preview below matches what you\'ll see there.'**
  String get widgetCustomizationIntro;

  /// No description provided for @widgetCustomizationMinimumOneRequired.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one item on.'**
  String get widgetCustomizationMinimumOneRequired;

  /// No description provided for @widgetCustomizationLockScreenNote.
  ///
  /// In en, this message translates to:
  /// **'Lock Screen widgets you add yourself always show a single topic and aren\'t affected by this.'**
  String get widgetCustomizationLockScreenNote;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @bookmarkedHadiths.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked Hadiths'**
  String get bookmarkedHadiths;

  /// No description provided for @hadithsSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hadith saved} other{{count} hadiths saved}}'**
  String hadithsSavedCount(num count);

  /// No description provided for @bookmarkedQuran.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked Quran'**
  String get bookmarkedQuran;

  /// No description provided for @surahsSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 surah saved} other{{count} surahs saved}}'**
  String surahsSavedCount(num count);

  /// No description provided for @noQuranFavoritesYetBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart while listening to a surah\nand it\'ll appear here'**
  String get noQuranFavoritesYetBody;

  /// No description provided for @failedToLoadFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to load your favorites'**
  String get failedToLoadFavorites;

  /// No description provided for @noFavoritesYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYetTitle;

  /// No description provided for @noFavoritesYetBody.
  ///
  /// In en, this message translates to:
  /// **'Start bookmarking hadiths you love\nand they\'ll appear here'**
  String get noFavoritesYetBody;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @clearAllFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Favorites'**
  String get clearAllFavoritesTitle;

  /// No description provided for @clearAllFavoritesBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all your favorite hadiths? This action cannot be undone.'**
  String get clearAllFavoritesBody;

  /// No description provided for @clearAllButton.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllButton;

  /// No description provided for @allFavoritesCleared.
  ///
  /// In en, this message translates to:
  /// **'All favorites cleared'**
  String get allFavoritesCleared;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String daysAgo(num count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String hoursAgo(num count);

  /// No description provided for @hadithCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Hadith Collection'**
  String get hadithCollectionTitle;

  /// No description provided for @searchBookHint.
  ///
  /// In en, this message translates to:
  /// **'Search {bookName}…'**
  String searchBookHint(String bookName);

  /// No description provided for @downloadingBookForOffline.
  ///
  /// In en, this message translates to:
  /// **'Downloading {bookName} for offline use…'**
  String downloadingBookForOffline(String bookName);

  /// No description provided for @failedToDownloadWithError.
  ///
  /// In en, this message translates to:
  /// **'Failed to download\n{error}'**
  String failedToDownloadWithError(String error);

  /// No description provided for @noHadithsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No hadiths match your search'**
  String get noHadithsMatchSearch;

  /// No description provided for @narratedBy.
  ///
  /// In en, this message translates to:
  /// **'Narrated {narrator}'**
  String narratedBy(String narrator);

  /// No description provided for @sharedFromEslamy.
  ///
  /// In en, this message translates to:
  /// **'Shared from Eslamy'**
  String get sharedFromEslamy;

  /// No description provided for @preparingShare.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get preparingShare;

  /// No description provided for @shareAsImage.
  ///
  /// In en, this message translates to:
  /// **'Share as image'**
  String get shareAsImage;

  /// No description provided for @hifzTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Hifz Tracker'**
  String get hifzTrackerTitle;

  /// No description provided for @setReviewReminderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Set review reminder'**
  String get setReviewReminderTooltip;

  /// No description provided for @failedToLoadSurahsWithError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load surahs\n{error}'**
  String failedToLoadSurahsWithError(String error);

  /// No description provided for @noSurahsMatchQuery.
  ///
  /// In en, this message translates to:
  /// **'No surahs match \"{query}\"'**
  String noSurahsMatchQuery(String query);

  /// No description provided for @noItemsMatchQuery.
  ///
  /// In en, this message translates to:
  /// **'No {label} matches \"{query}\"'**
  String noItemsMatchQuery(String label, String query);

  /// No description provided for @juzNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String juzNumberLabel(int number);

  /// No description provided for @startsAtSurahAyah.
  ///
  /// In en, this message translates to:
  /// **'Starts at {surahName} {surah}:{ayah}'**
  String startsAtSurahAyah(String surahName, int surah, int ayah);

  /// No description provided for @loadingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingEllipsis;

  /// No description provided for @surahsMemorizedProgress.
  ///
  /// In en, this message translates to:
  /// **'{memorized} of {total} surahs memorized'**
  String surahsMemorizedProgress(int memorized, int total);

  /// No description provided for @versesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 verse} other{{count} verses}}'**
  String versesCount(num count);

  /// No description provided for @hifzReviewNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Hifz Review'**
  String get hifzReviewNotificationTitle;

  /// No description provided for @hifzReviewNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Time to review what you\'ve memorized'**
  String get hifzReviewNotificationBody;

  /// No description provided for @dailyReviewReminderScheduled.
  ///
  /// In en, this message translates to:
  /// **'Daily review reminder scheduled'**
  String get dailyReviewReminderScheduled;

  /// No description provided for @prayerTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimesTitle;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @amLabel.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get amLabel;

  /// No description provided for @pmLabel.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pmLabel;

  /// No description provided for @failedToLoadPrayerTimesWithError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load prayer times\n{error}'**
  String failedToLoadPrayerTimesWithError(String error);

  /// No description provided for @showingCairoFallback.
  ///
  /// In en, this message translates to:
  /// **'Showing times for Cairo (default). Enable location for accurate times.'**
  String get showingCairoFallback;

  /// No description provided for @enableButton.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enableButton;

  /// No description provided for @prayerTimesLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed for accurate prayer times and Adhan alerts.'**
  String get prayerTimesLocationDenied;

  /// No description provided for @prayerTimesLocationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location access is turned off for Eslamy. Enable it in Settings for accurate prayer times and Adhan alerts.'**
  String get prayerTimesLocationDeniedForever;

  /// No description provided for @prayerTimesLocationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on Location Services for accurate prayer times and Adhan alerts.'**
  String get prayerTimesLocationServicesOff;

  /// No description provided for @findQiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Find Qibla direction'**
  String get findQiblaDirection;

  /// No description provided for @qiblaDirectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirectionTitle;

  /// No description provided for @qiblaUnavailableWithError.
  ///
  /// In en, this message translates to:
  /// **'Qibla direction unavailable\n{error}'**
  String qiblaUnavailableWithError(String error);

  /// No description provided for @waitingForCompassSensor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for compass sensor…\n(not available on all simulators)'**
  String get waitingForCompassSensor;

  /// No description provided for @noCompassSensor.
  ///
  /// In en, this message translates to:
  /// **'This device has no compass sensor.'**
  String get noCompassSensor;

  /// No description provided for @facingQibla.
  ///
  /// In en, this message translates to:
  /// **'Facing Qibla ✓'**
  String get facingQibla;

  /// No description provided for @rotateToAlign.
  ///
  /// In en, this message translates to:
  /// **'Rotate to align'**
  String get rotateToAlign;

  /// No description provided for @qiblaBearingHeading.
  ///
  /// In en, this message translates to:
  /// **'Qibla bearing: {bearing}°  ·  Heading: {heading}°'**
  String qiblaBearingHeading(String bearing, String heading);

  /// No description provided for @allPrayersDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'ALL PRAYERS DONE'**
  String get allPrayersDoneLabel;

  /// No description provided for @nextPrayerLabel.
  ///
  /// In en, this message translates to:
  /// **'NEXT PRAYER'**
  String get nextPrayerLabel;

  /// No description provided for @fajrResumesAfterMidnight.
  ///
  /// In en, this message translates to:
  /// **'Fajr resumes after midnight'**
  String get fajrResumesAfterMidnight;

  /// No description provided for @couldntLoadPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load prayer times'**
  String get couldntLoadPrayerTimes;

  /// No description provided for @countdownNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get countdownNow;

  /// No description provided for @countdownHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {h}h {m}m'**
  String countdownHoursMinutes(int h, int m);

  /// No description provided for @countdownMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {m}m'**
  String countdownMinutes(int m);

  /// No description provided for @quranChaptersTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran Chapters'**
  String get quranChaptersTitle;

  /// No description provided for @pauseAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause Audio'**
  String get pauseAudioTooltip;

  /// No description provided for @stopAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop Audio'**
  String get stopAudioTooltip;

  /// No description provided for @loadingAudio.
  ///
  /// In en, this message translates to:
  /// **'Loading audio...'**
  String get loadingAudio;

  /// No description provided for @playingChapterWithReciter.
  ///
  /// In en, this message translates to:
  /// **'Playing chapter with reciter: {name}'**
  String playingChapterWithReciter(String name);

  /// No description provided for @realAudioNotAvailableReciter.
  ///
  /// In en, this message translates to:
  /// **'Real audio not available, playing test audio. Reciter: {name}'**
  String realAudioNotAvailableReciter(String name);

  /// No description provided for @audioPlaybackErrorWithError.
  ///
  /// In en, this message translates to:
  /// **'Audio playback error: {error}'**
  String audioPlaybackErrorWithError(String error);

  /// No description provided for @playingChapterNumberAudio.
  ///
  /// In en, this message translates to:
  /// **'Playing Chapter {number} audio'**
  String playingChapterNumberAudio(int number);

  /// No description provided for @failedToPlayAudioRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to play audio. Please try again.'**
  String get failedToPlayAudioRetry;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @autoAdvancingToChapter.
  ///
  /// In en, this message translates to:
  /// **'Auto-advancing to Chapter {number}: {name}'**
  String autoAdvancingToChapter(int number, String name);

  /// No description provided for @allChaptersCompleted.
  ///
  /// In en, this message translates to:
  /// **'All chapters completed!'**
  String get allChaptersCompleted;

  /// No description provided for @chapterNumberAudioLabel.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number} Audio'**
  String chapterNumberAudioLabel(int number);

  /// No description provided for @audioPlayerLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio Player'**
  String get audioPlayerLabel;

  /// No description provided for @failedToLoadChapters.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chapters'**
  String get failedToLoadChapters;

  /// No description provided for @versesCountRevelationType.
  ///
  /// In en, this message translates to:
  /// **'{count} verses • {type}'**
  String versesCountRevelationType(int count, String type);

  /// No description provided for @playAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play Audio'**
  String get playAudioTooltip;

  /// No description provided for @chapterWithNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}: {name}'**
  String chapterWithNameTitle(int number, String name);

  /// No description provided for @pauseChapterAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause Chapter Audio'**
  String get pauseChapterAudioTooltip;

  /// No description provided for @playChapterAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play Chapter Audio'**
  String get playChapterAudioTooltip;

  /// No description provided for @loadingChapterAudio.
  ///
  /// In en, this message translates to:
  /// **'Loading chapter audio...'**
  String get loadingChapterAudio;

  /// No description provided for @chapterAudioStartedPlaying.
  ///
  /// In en, this message translates to:
  /// **'Chapter audio started playing'**
  String get chapterAudioStartedPlaying;

  /// No description provided for @failedToPlayChapterAudioRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to play chapter audio. Please try again.'**
  String get failedToPlayChapterAudioRetry;

  /// No description provided for @chapterAudioLabel.
  ///
  /// In en, this message translates to:
  /// **'Chapter Audio'**
  String get chapterAudioLabel;

  /// No description provided for @failedToLoadChapter.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chapter'**
  String get failedToLoadChapter;

  /// No description provided for @playAudioLabel.
  ///
  /// In en, this message translates to:
  /// **'Play Audio'**
  String get playAudioLabel;

  /// No description provided for @tafseerLabel.
  ///
  /// In en, this message translates to:
  /// **'Tafseer'**
  String get tafseerLabel;

  /// No description provided for @chapterVerseTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapter {chapter}, Verse {verse}'**
  String chapterVerseTitle(int chapter, int verse);

  /// No description provided for @playingWithReciter.
  ///
  /// In en, this message translates to:
  /// **'Playing with reciter: {name}'**
  String playingWithReciter(String name);

  /// No description provided for @audioStartedPlaying.
  ///
  /// In en, this message translates to:
  /// **'Audio started playing'**
  String get audioStartedPlaying;

  /// No description provided for @audioRecitationLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio Recitation'**
  String get audioRecitationLabel;

  /// No description provided for @tapPlayToLoadAudio.
  ///
  /// In en, this message translates to:
  /// **'Tap play to load audio'**
  String get tapPlayToLoadAudio;

  /// No description provided for @toggleTajweedColoringTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle Tajweed coloring'**
  String get toggleTajweedColoringTooltip;

  /// No description provided for @tajweedLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Tajweed Legend'**
  String get tajweedLegendTitle;

  /// No description provided for @tajweedLegendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap any colored letter in the text to see its rule. Colors match this key.'**
  String get tajweedLegendSubtitle;

  /// No description provided for @repeatPracticeLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat for practice'**
  String get repeatPracticeLabel;

  /// No description provided for @tafseerInterpretationLabel.
  ///
  /// In en, this message translates to:
  /// **'Tafseer (Interpretation)'**
  String get tafseerInterpretationLabel;

  /// No description provided for @noTafseerAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tafseer available for this verse.'**
  String get noTafseerAvailable;

  /// No description provided for @tafseerMuyassarLabel.
  ///
  /// In en, this message translates to:
  /// **'Tafseer (Muyassar)'**
  String get tafseerMuyassarLabel;

  /// No description provided for @failedToLoadTafseer.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tafseer'**
  String get failedToLoadTafseer;

  /// No description provided for @quranReciterLabel.
  ///
  /// In en, this message translates to:
  /// **'Quran Reciter'**
  String get quranReciterLabel;

  /// No description provided for @selectReciterPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select Reciter'**
  String get selectReciterPlaceholder;

  /// No description provided for @activeForAudioLabel.
  ///
  /// In en, this message translates to:
  /// **'Active for Audio'**
  String get activeForAudioLabel;

  /// No description provided for @chooseReciterTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Reciter'**
  String get chooseReciterTitle;

  /// No description provided for @searchReciterHint.
  ///
  /// In en, this message translates to:
  /// **'Search reciter by name'**
  String get searchReciterHint;

  /// No description provided for @noRecitersFound.
  ///
  /// In en, this message translates to:
  /// **'No reciters found'**
  String get noRecitersFound;

  /// No description provided for @openAyahRangePlayerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play surah or ayah range'**
  String get openAyahRangePlayerTooltip;

  /// No description provided for @playFullSurahLabel.
  ///
  /// In en, this message translates to:
  /// **'Complete Surah'**
  String get playFullSurahLabel;

  /// No description provided for @playAyahRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Ayah Range'**
  String get playAyahRangeLabel;

  /// No description provided for @ayahRangeSummary.
  ///
  /// In en, this message translates to:
  /// **'Ayah {from}–{to} • {count} verses'**
  String ayahRangeSummary(int from, int to, int count);

  /// No description provided for @fromAyahLabel.
  ///
  /// In en, this message translates to:
  /// **'From {ayah}'**
  String fromAyahLabel(int ayah);

  /// No description provided for @toAyahLabel.
  ///
  /// In en, this message translates to:
  /// **'To {ayah}'**
  String toAyahLabel(int ayah);

  /// No description provided for @reciterRangeFallbackNotice.
  ///
  /// In en, this message translates to:
  /// **'This reciter has no separate ayah recordings, so the full surah audio plays instead for this range.'**
  String get reciterRangeFallbackNotice;

  /// No description provided for @reciterRangeUnavailableNotice.
  ///
  /// In en, this message translates to:
  /// **'This reciter doesn\'t have separate recordings for each ayah, so an ayah range can\'t be selected. Please choose a different reciter.'**
  String get reciterRangeUnavailableNotice;

  /// No description provided for @nowPlayingRangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ayah {ayah} • range {from}–{to}'**
  String nowPlayingRangeSubtitle(int ayah, int from, int to);

  /// No description provided for @nowPlayingPreviousAyahTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous Ayah'**
  String get nowPlayingPreviousAyahTooltip;

  /// No description provided for @nowPlayingNextAyahTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next Ayah'**
  String get nowPlayingNextAyahTooltip;

  /// No description provided for @mushafPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String mushafPageLabel(int page);

  /// No description provided for @mushafJuzLabel.
  ///
  /// In en, this message translates to:
  /// **'Juz {juz}'**
  String mushafJuzLabel(int juz);

  /// No description provided for @mushafPreviousPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous Page'**
  String get mushafPreviousPageTooltip;

  /// No description provided for @mushafNextPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next Page'**
  String get mushafNextPageTooltip;

  /// No description provided for @jumpToPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Go to Page'**
  String get jumpToPageTitle;

  /// No description provided for @fromAyahFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromAyahFieldLabel;

  /// No description provided for @toAyahFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toAyahFieldLabel;

  /// No description provided for @pageNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Page number'**
  String get pageNumberHint;

  /// No description provided for @pageNotInThisSurah.
  ///
  /// In en, this message translates to:
  /// **'This page isn\'t part of this surah'**
  String get pageNotInThisSurah;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your companion for Quran, prayer\n& daily worship'**
  String get splashTagline;

  /// No description provided for @dayStreakSingle.
  ///
  /// In en, this message translates to:
  /// **'Day 1 streak'**
  String get dayStreakSingle;

  /// No description provided for @dayStreakCount.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String dayStreakCount(int count);

  /// No description provided for @genericErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String genericErrorWithMessage(String message);

  /// No description provided for @adhanAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Adhan Alerts'**
  String get adhanAlertsTitle;

  /// No description provided for @adhanAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get notified at each of the 5 daily prayer times.'**
  String get adhanAlertsDescription;

  /// No description provided for @enabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledLabel;

  /// No description provided for @stopTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopTooltip;

  /// No description provided for @previewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewTooltip;

  /// No description provided for @tasbihCounterTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasbih Counter'**
  String get tasbihCounterTitle;

  /// No description provided for @resetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetTooltip;

  /// No description provided for @targetReached.
  ///
  /// In en, this message translates to:
  /// **'Target reached ✓'**
  String get targetReached;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target: {target}'**
  String targetLabel(int target);

  /// No description provided for @tapCircleHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the circle to count. Your progress is saved automatically.'**
  String get tapCircleHint;

  /// No description provided for @addCustomDhikrTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Dhikr'**
  String get addCustomDhikrTitle;

  /// No description provided for @customDhikrTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Dhikr or dua'**
  String get customDhikrTextLabel;

  /// No description provided for @customDhikrTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target count'**
  String get customDhikrTargetLabel;

  /// No description provided for @customDhikrTextRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a dhikr or dua'**
  String get customDhikrTextRequired;

  /// No description provided for @customDhikrTargetInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a target greater than 0'**
  String get customDhikrTargetInvalid;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @duasAzkarTitle.
  ///
  /// In en, this message translates to:
  /// **'Duas & Azkar'**
  String get duasAzkarTitle;

  /// No description provided for @couldNotLoadAzkarWithError.
  ///
  /// In en, this message translates to:
  /// **'Could not load Azkar\n{error}'**
  String couldNotLoadAzkarWithError(String error);

  /// No description provided for @couldNotLoadSectionWithError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this section\n{error}'**
  String couldNotLoadSectionWithError(String error);

  /// No description provided for @hijriCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Hijri Calendar'**
  String get hijriCalendarTitle;

  /// No description provided for @todayLabelCaps.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayLabelCaps;

  /// No description provided for @hijriDateAh.
  ///
  /// In en, this message translates to:
  /// **'{day} {month} {year} AH'**
  String hijriDateAh(int day, String month, int year);

  /// No description provided for @hijriMonthMuharram.
  ///
  /// In en, this message translates to:
  /// **'Muharram'**
  String get hijriMonthMuharram;

  /// No description provided for @hijriMonthSafar.
  ///
  /// In en, this message translates to:
  /// **'Safar'**
  String get hijriMonthSafar;

  /// No description provided for @hijriMonthRabiAlAwwal.
  ///
  /// In en, this message translates to:
  /// **'Rabi\' al-Awwal'**
  String get hijriMonthRabiAlAwwal;

  /// No description provided for @hijriMonthRabiAlThani.
  ///
  /// In en, this message translates to:
  /// **'Rabi\' al-Thani'**
  String get hijriMonthRabiAlThani;

  /// No description provided for @hijriMonthJumadaAlAwwal.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Awwal'**
  String get hijriMonthJumadaAlAwwal;

  /// No description provided for @hijriMonthJumadaAlThani.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Thani'**
  String get hijriMonthJumadaAlThani;

  /// No description provided for @hijriMonthRajab.
  ///
  /// In en, this message translates to:
  /// **'Rajab'**
  String get hijriMonthRajab;

  /// No description provided for @hijriMonthShaban.
  ///
  /// In en, this message translates to:
  /// **'Sha\'ban'**
  String get hijriMonthShaban;

  /// No description provided for @hijriMonthRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get hijriMonthRamadan;

  /// No description provided for @hijriMonthShawwal.
  ///
  /// In en, this message translates to:
  /// **'Shawwal'**
  String get hijriMonthShawwal;

  /// No description provided for @hijriMonthDhuAlQidah.
  ///
  /// In en, this message translates to:
  /// **'Dhu al-Qi\'dah'**
  String get hijriMonthDhuAlQidah;

  /// No description provided for @hijriMonthDhuAlHijjah.
  ///
  /// In en, this message translates to:
  /// **'Dhu al-Hijjah'**
  String get hijriMonthDhuAlHijjah;

  /// No description provided for @upcomingLabel.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingLabel;

  /// No description provided for @loadingUpcomingOccasions.
  ///
  /// In en, this message translates to:
  /// **'Loading upcoming occasions…'**
  String get loadingUpcomingOccasions;

  /// No description provided for @noUpcomingOccasions.
  ///
  /// In en, this message translates to:
  /// **'No upcoming occasions found.'**
  String get noUpcomingOccasions;

  /// No description provided for @todayCountdown.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayCountdown;

  /// No description provided for @tomorrowCountdown.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrowCountdown;

  /// No description provided for @inDaysCountdown.
  ///
  /// In en, this message translates to:
  /// **'in {days} days'**
  String inDaysCountdown(int days);

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySun;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySat;

  /// No description provided for @chooseTranslationTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Translation'**
  String get chooseTranslationTitle;

  /// No description provided for @searchLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Search language…'**
  String get searchLanguageHint;

  /// No description provided for @couldNotLoadLanguagesWithError.
  ///
  /// In en, this message translates to:
  /// **'Could not load languages\n{error}'**
  String couldNotLoadLanguagesWithError(String error);

  /// No description provided for @drawerSectionWorship.
  ///
  /// In en, this message translates to:
  /// **'Worship'**
  String get drawerSectionWorship;

  /// No description provided for @drawerSectionQuranStudy.
  ///
  /// In en, this message translates to:
  /// **'Quran & Study'**
  String get drawerSectionQuranStudy;

  /// No description provided for @digitalMushaf.
  ///
  /// In en, this message translates to:
  /// **'Digital Mushaf'**
  String get digitalMushaf;

  /// No description provided for @quranTafseerTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran Tafseer'**
  String get quranTafseerTitle;

  /// No description provided for @hifzProgress.
  ///
  /// In en, this message translates to:
  /// **'Hifz Progress'**
  String get hifzProgress;

  /// No description provided for @hadithLabel.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get hadithLabel;

  /// No description provided for @quickAccessTasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get quickAccessTasbih;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @holidayIslamicNewYear.
  ///
  /// In en, this message translates to:
  /// **'Islamic New Year'**
  String get holidayIslamicNewYear;

  /// No description provided for @holidayDayOfAshura.
  ///
  /// In en, this message translates to:
  /// **'Day of Ashura'**
  String get holidayDayOfAshura;

  /// No description provided for @holidayMawlidAlNabi.
  ///
  /// In en, this message translates to:
  /// **'Mawlid al-Nabi (Prophet\'s Birthday)'**
  String get holidayMawlidAlNabi;

  /// No description provided for @holidayStartOfRamadan.
  ///
  /// In en, this message translates to:
  /// **'Start of Ramadan'**
  String get holidayStartOfRamadan;

  /// No description provided for @holidayLaylatAlQadr.
  ///
  /// In en, this message translates to:
  /// **'Laylat al-Qadr (est.)'**
  String get holidayLaylatAlQadr;

  /// No description provided for @holidayEidAlFitr.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Fitr'**
  String get holidayEidAlFitr;

  /// No description provided for @holidayDayOfArafah.
  ///
  /// In en, this message translates to:
  /// **'Day of Arafah'**
  String get holidayDayOfArafah;

  /// No description provided for @holidayEidAlAdha.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Adha'**
  String get holidayEidAlAdha;

  /// No description provided for @navHomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHomeLabel;

  /// No description provided for @navQuranLabel.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get navQuranLabel;

  /// No description provided for @navQiblaLabel.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get navQiblaLabel;

  /// No description provided for @navPrayerLabel.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get navPrayerLabel;

  /// No description provided for @navMoreLabel.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMoreLabel;

  /// No description provided for @searchSurahHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or number…'**
  String get searchSurahHint;

  /// No description provided for @searchJuzHint.
  ///
  /// In en, this message translates to:
  /// **'Search by number or starting surah…'**
  String get searchJuzHint;

  /// No description provided for @searchPageHint.
  ///
  /// In en, this message translates to:
  /// **'Jump to page number…'**
  String get searchPageHint;

  /// No description provided for @searchHizbHint.
  ///
  /// In en, this message translates to:
  /// **'Jump to Hizb number…'**
  String get searchHizbHint;

  /// No description provided for @hajjUmrahGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Hajj & Umrah Guide'**
  String get hajjUmrahGuideTitle;

  /// No description provided for @hajjUmrahDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Ritual steps and dua text are community-sourced (MIT-licensed), not official Ministry of Hajj guidance. Verify with your group\'s scholar before relying on this for your pilgrimage.'**
  String get hajjUmrahDisclaimer;

  /// No description provided for @umrahTrackLabel.
  ///
  /// In en, this message translates to:
  /// **'Umrah'**
  String get umrahTrackLabel;

  /// No description provided for @hajjTrackLabel.
  ///
  /// In en, this message translates to:
  /// **'Hajj'**
  String get hajjTrackLabel;

  /// No description provided for @ritualStepsHeading.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get ritualStepsHeading;

  /// No description provided for @relevantDuasHeading.
  ///
  /// In en, this message translates to:
  /// **'Duas for this step'**
  String get relevantDuasHeading;

  /// No description provided for @edgeCasesHeading.
  ///
  /// In en, this message translates to:
  /// **'Exceptions & edge cases'**
  String get edgeCasesHeading;

  /// No description provided for @stepsCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} steps'**
  String stepsCompletedLabel(int done, int total);

  /// No description provided for @tawafSaiCounterTitle.
  ///
  /// In en, this message translates to:
  /// **'Tawaf & Sa\'i Counter'**
  String get tawafSaiCounterTitle;

  /// No description provided for @tawafModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Tawaf'**
  String get tawafModeLabel;

  /// No description provided for @saiModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Sa\'i'**
  String get saiModeLabel;

  /// No description provided for @circuitCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} / {target}'**
  String circuitCountLabel(int count, int target);

  /// No description provided for @tawafCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Tawaf complete — pray 2 rakaat behind Maqam Ibrahim'**
  String get tawafCompleteMessage;

  /// No description provided for @saiCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Sa\'i complete'**
  String get saiCompleteMessage;

  /// No description provided for @pilgrimModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pilgrim Mode — alerts when near a holy site'**
  String get pilgrimModeTooltip;

  /// No description provided for @pilgrimModeLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed for Pilgrim Mode alerts'**
  String get pilgrimModeLocationDenied;

  /// No description provided for @pilgrimModeNear.
  ///
  /// In en, this message translates to:
  /// **'You\'re near {siteName}'**
  String pilgrimModeNear(String siteName);

  /// No description provided for @nowPlayingTitle.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlayingTitle;

  /// No description provided for @nowPlayingNextSurahTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next Surah'**
  String get nowPlayingNextSurahTooltip;

  /// No description provided for @nowPlayingPreviousSurahTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous Surah'**
  String get nowPlayingPreviousSurahTooltip;

  /// No description provided for @nowPlayingStopTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get nowPlayingStopTooltip;

  /// No description provided for @overlayPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Show floating player?'**
  String get overlayPermissionTitle;

  /// No description provided for @overlayPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Eslamy can show a small floating bubble over other apps so you can control playback without switching back. Enable it?'**
  String get overlayPermissionBody;

  /// No description provided for @overlayPermissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get overlayPermissionAllow;

  /// No description provided for @overlayPermissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get overlayPermissionNotNow;

  /// No description provided for @mosqueLocatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Mosque Locator'**
  String get mosqueLocatorTitle;

  /// No description provided for @mosqueLocatorDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get mosqueLocatorDirections;

  /// No description provided for @mosqueLocatorDistance.
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String mosqueLocatorDistance(String distance);

  /// No description provided for @mosqueLocatorEmpty.
  ///
  /// In en, this message translates to:
  /// **'No mosques found nearby. Try again later.'**
  String get mosqueLocatorEmpty;

  /// No description provided for @mosqueLocatorFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load nearby mosques\n{error}'**
  String mosqueLocatorFailedWithError(String error);

  /// No description provided for @mosqueLocatorUnnamedMosque.
  ///
  /// In en, this message translates to:
  /// **'Mosque'**
  String get mosqueLocatorUnnamedMosque;

  /// No description provided for @mosqueLocatorApproximateLocation.
  ///
  /// In en, this message translates to:
  /// **'Showing results for your approximate location. Enable precise location for better results.'**
  String get mosqueLocatorApproximateLocation;

  /// No description provided for @mosqueLocatorCouldNotOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open Maps'**
  String get mosqueLocatorCouldNotOpenMaps;

  /// No description provided for @mosqueLocatorStaleCache.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh — showing previously saved results. Pull down to try again.'**
  String get mosqueLocatorStaleCache;

  /// No description provided for @mosqueLocatorLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to find mosques near you.'**
  String get mosqueLocatorLocationDenied;

  /// No description provided for @mosqueLocatorLocationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location access is turned off for Eslamy. Enable it in Settings to find nearby mosques.'**
  String get mosqueLocatorLocationDeniedForever;

  /// No description provided for @mosqueLocatorLocationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on Location Services to find mosques near you.'**
  String get mosqueLocatorLocationServicesOff;

  /// No description provided for @mosqueLocatorOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get mosqueLocatorOpenSettings;

  /// No description provided for @mosqueLocatorUsingLastKnownLocation.
  ///
  /// In en, this message translates to:
  /// **'Using your last known location. Distances may be approximate.'**
  String get mosqueLocatorUsingLastKnownLocation;

  /// No description provided for @notificationChannelDailyWerd.
  ///
  /// In en, this message translates to:
  /// **'Daily Wird'**
  String get notificationChannelDailyWerd;

  /// No description provided for @notificationChannelDailyWerdDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder for your Wird'**
  String get notificationChannelDailyWerdDescription;

  /// No description provided for @notificationChannelAdhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get notificationChannelAdhan;

  /// No description provided for @notificationChannelAdhanDescription.
  ///
  /// In en, this message translates to:
  /// **'Call-to-prayer alert at each prayer time'**
  String get notificationChannelAdhanDescription;

  /// No description provided for @notificationChannelQuranPlayback.
  ///
  /// In en, this message translates to:
  /// **'Quran playback'**
  String get notificationChannelQuranPlayback;

  /// No description provided for @adhanNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Adhan — {name}'**
  String adhanNotificationTitle(String name);

  /// No description provided for @adhanNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'It is time for {name} prayer'**
  String adhanNotificationBody(String name);

  /// No description provided for @notificationFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationFallbackTitle;

  /// No description provided for @errorConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout. Please check your internet connection.'**
  String get errorConnectionTimeout;

  /// No description provided for @errorRequestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout, try again later'**
  String get errorRequestTimeout;

  /// No description provided for @errorResponseTimeout.
  ///
  /// In en, this message translates to:
  /// **'Response timeout, try again later'**
  String get errorResponseTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Requested resource not found.'**
  String get errorNotFound;

  /// No description provided for @errorInternalServer.
  ///
  /// In en, this message translates to:
  /// **'Internal server error'**
  String get errorInternalServer;

  /// No description provided for @errorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Rate limit exceeded, try again later'**
  String get errorRateLimit;

  /// No description provided for @errorServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServerError;

  /// No description provided for @errorRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request was cancelled.'**
  String get errorRequestCancelled;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get errorUnknown;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get errorNoInternet;

  /// No description provided for @errorRequestFailedWithStatus.
  ///
  /// In en, this message translates to:
  /// **'Request failed with status: {statusCode}'**
  String errorRequestFailedWithStatus(String statusCode);

  /// No description provided for @distanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{count} m'**
  String distanceMeters(int count);

  /// No description provided for @distanceKilometers.
  ///
  /// In en, this message translates to:
  /// **'{count} km'**
  String distanceKilometers(String count);

  /// No description provided for @surahNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Surah {number}'**
  String surahNumberLabel(int number);

  /// No description provided for @pageNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String pageNumberLabel(int number);

  /// No description provided for @hizbNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Hizb {number}'**
  String hizbNumberLabel(int number);

  /// No description provided for @dhikrSubhanAllah.
  ///
  /// In en, this message translates to:
  /// **'SubhanAllah'**
  String get dhikrSubhanAllah;

  /// No description provided for @dhikrAlhamdulillah.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get dhikrAlhamdulillah;

  /// No description provided for @dhikrAllahuAkbar.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get dhikrAllahuAkbar;

  /// No description provided for @dhikrLaIlahaIllaAllah.
  ///
  /// In en, this message translates to:
  /// **'La ilaha illa Allah'**
  String get dhikrLaIlahaIllaAllah;

  /// No description provided for @dhikrAstaghfirullah.
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullah'**
  String get dhikrAstaghfirullah;

  /// No description provided for @dhikrCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get dhikrCustom;

  /// No description provided for @tajweedHamzatUlWasl.
  ///
  /// In en, this message translates to:
  /// **'Hamzat ul Wasl'**
  String get tajweedHamzatUlWasl;

  /// No description provided for @tajweedSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get tajweedSilent;

  /// No description provided for @tajweedLamShamsiyyah.
  ///
  /// In en, this message translates to:
  /// **'Lam Shamsiyyah'**
  String get tajweedLamShamsiyyah;

  /// No description provided for @tajweedMaddaNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Prolongation: 2 Vowels'**
  String get tajweedMaddaNormal;

  /// No description provided for @tajweedMaddaPermissible.
  ///
  /// In en, this message translates to:
  /// **'Permissible Prolongation: 2, 4, 6 Vowels'**
  String get tajweedMaddaPermissible;

  /// No description provided for @tajweedMaddaNecessary.
  ///
  /// In en, this message translates to:
  /// **'Necessary Prolongation: 6 Vowels'**
  String get tajweedMaddaNecessary;

  /// No description provided for @tajweedQalqalah.
  ///
  /// In en, this message translates to:
  /// **'Qalqalah'**
  String get tajweedQalqalah;

  /// No description provided for @tajweedMaddaObligatory.
  ///
  /// In en, this message translates to:
  /// **'Obligatory Prolongation: 4-5 Vowels'**
  String get tajweedMaddaObligatory;

  /// No description provided for @tajweedIkhfaShafawi.
  ///
  /// In en, this message translates to:
  /// **'Ikhfa\' Shafawi - With Meem'**
  String get tajweedIkhfaShafawi;

  /// No description provided for @tajweedIkhfa.
  ///
  /// In en, this message translates to:
  /// **'Ikhfa\''**
  String get tajweedIkhfa;

  /// No description provided for @tajweedIdghamShafawi.
  ///
  /// In en, this message translates to:
  /// **'Idgham Shafawi - With Meem'**
  String get tajweedIdghamShafawi;

  /// No description provided for @tajweedIqlab.
  ///
  /// In en, this message translates to:
  /// **'Iqlab'**
  String get tajweedIqlab;

  /// No description provided for @tajweedIdghamGhunnah.
  ///
  /// In en, this message translates to:
  /// **'Idgham - With Ghunnah'**
  String get tajweedIdghamGhunnah;

  /// No description provided for @tajweedIdghamNoGhunnah.
  ///
  /// In en, this message translates to:
  /// **'Idgham - Without Ghunnah'**
  String get tajweedIdghamNoGhunnah;

  /// No description provided for @tajweedIdghamMutajanisayn.
  ///
  /// In en, this message translates to:
  /// **'Idgham - Mutajanisayn'**
  String get tajweedIdghamMutajanisayn;

  /// No description provided for @tajweedIdghamMutaqaribayn.
  ///
  /// In en, this message translates to:
  /// **'Idgham - Mutaqaribayn'**
  String get tajweedIdghamMutaqaribayn;

  /// No description provided for @tajweedGhunnah.
  ///
  /// In en, this message translates to:
  /// **'Ghunnah: 2 Vowels'**
  String get tajweedGhunnah;

  /// No description provided for @hadithBookBukhari.
  ///
  /// In en, this message translates to:
  /// **'Sahih al-Bukhari'**
  String get hadithBookBukhari;

  /// No description provided for @hadithBookMuslim.
  ///
  /// In en, this message translates to:
  /// **'Sahih Muslim'**
  String get hadithBookMuslim;

  /// No description provided for @hadithBookAbuDawud.
  ///
  /// In en, this message translates to:
  /// **'Sunan Abu Dawud'**
  String get hadithBookAbuDawud;

  /// No description provided for @hadithBookTirmidhi.
  ///
  /// In en, this message translates to:
  /// **'Jami At-Tirmidhi'**
  String get hadithBookTirmidhi;

  /// No description provided for @hadithBookNasai.
  ///
  /// In en, this message translates to:
  /// **'Sunan an-Nasai'**
  String get hadithBookNasai;

  /// No description provided for @hadithBookIbnMajah.
  ///
  /// In en, this message translates to:
  /// **'Sunan Ibn Majah'**
  String get hadithBookIbnMajah;

  /// No description provided for @hadithBookMalik.
  ///
  /// In en, this message translates to:
  /// **'Muwatta Malik'**
  String get hadithBookMalik;

  /// No description provided for @hadithBookNawawi.
  ///
  /// In en, this message translates to:
  /// **'An-Nawawi\'s 40 Hadith'**
  String get hadithBookNawawi;

  /// No description provided for @hadithBookQudsi.
  ///
  /// In en, this message translates to:
  /// **'40 Hadith Qudsi'**
  String get hadithBookQudsi;

  /// No description provided for @hadithBookDehlawi.
  ///
  /// In en, this message translates to:
  /// **'Shah Waliullah\'s 40 Hadith'**
  String get hadithBookDehlawi;

  /// No description provided for @reciterStyleMujawwadMelodic.
  ///
  /// In en, this message translates to:
  /// **'Mujawwad (Melodic)'**
  String get reciterStyleMujawwadMelodic;

  /// No description provided for @reciterStyleMurattalSlow.
  ///
  /// In en, this message translates to:
  /// **'Murattal (Slow)'**
  String get reciterStyleMurattalSlow;

  /// No description provided for @reciterStyleModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get reciterStyleModern;

  /// No description provided for @reciterStyleTraditional.
  ///
  /// In en, this message translates to:
  /// **'Traditional'**
  String get reciterStyleTraditional;

  /// No description provided for @reciterStyleMurattal.
  ///
  /// In en, this message translates to:
  /// **'Murattal'**
  String get reciterStyleMurattal;

  /// No description provided for @azkarCategoryMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning Adhkar'**
  String get azkarCategoryMorning;

  /// No description provided for @azkarCategoryMorningDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications for the morning'**
  String get azkarCategoryMorningDescription;

  /// No description provided for @azkarCategoryEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening Adhkar'**
  String get azkarCategoryEvening;

  /// No description provided for @azkarCategoryEveningDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications for the evening'**
  String get azkarCategoryEveningDescription;

  /// No description provided for @azkarCategoryWudu.
  ///
  /// In en, this message translates to:
  /// **'Wudu & Purification'**
  String get azkarCategoryWudu;

  /// No description provided for @azkarCategoryWuduDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications for ablution and purification'**
  String get azkarCategoryWuduDescription;

  /// No description provided for @azkarCategoryPrayer.
  ///
  /// In en, this message translates to:
  /// **'During Prayer'**
  String get azkarCategoryPrayer;

  /// No description provided for @azkarCategoryPrayerDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications said during salah'**
  String get azkarCategoryPrayerDescription;

  /// No description provided for @azkarCategoryAfterPrayer.
  ///
  /// In en, this message translates to:
  /// **'After Prayer'**
  String get azkarCategoryAfterPrayer;

  /// No description provided for @azkarCategoryAfterPrayerDescription.
  ///
  /// In en, this message translates to:
  /// **'Dhikr and supplications after salah'**
  String get azkarCategoryAfterPrayerDescription;

  /// No description provided for @azkarCategorySleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get azkarCategorySleep;

  /// No description provided for @azkarCategorySleepDescription.
  ///
  /// In en, this message translates to:
  /// **'Before sleeping and upon waking'**
  String get azkarCategorySleepDescription;

  /// No description provided for @azkarCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Drink'**
  String get azkarCategoryFood;

  /// No description provided for @azkarCategoryFoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Before and after eating'**
  String get azkarCategoryFoodDescription;

  /// No description provided for @azkarCategoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get azkarCategoryTravel;

  /// No description provided for @azkarCategoryTravelDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications for journeys'**
  String get azkarCategoryTravelDescription;

  /// No description provided for @azkarCategoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get azkarCategoryHome;

  /// No description provided for @azkarCategoryHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Entering and leaving the home'**
  String get azkarCategoryHomeDescription;

  /// No description provided for @azkarCategoryMasjid.
  ///
  /// In en, this message translates to:
  /// **'Masjid'**
  String get azkarCategoryMasjid;

  /// No description provided for @azkarCategoryMasjidDescription.
  ///
  /// In en, this message translates to:
  /// **'Entering and leaving the mosque'**
  String get azkarCategoryMasjidDescription;

  /// No description provided for @azkarCategoryDistress.
  ///
  /// In en, this message translates to:
  /// **'Distress & Anxiety'**
  String get azkarCategoryDistress;

  /// No description provided for @azkarCategoryDistressDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications during hardship'**
  String get azkarCategoryDistressDescription;

  /// No description provided for @azkarCategoryForgiveness.
  ///
  /// In en, this message translates to:
  /// **'Forgiveness'**
  String get azkarCategoryForgiveness;

  /// No description provided for @azkarCategoryForgivenessDescription.
  ///
  /// In en, this message translates to:
  /// **'Seeking forgiveness from Allah'**
  String get azkarCategoryForgivenessDescription;

  /// No description provided for @azkarCategoryIllness.
  ///
  /// In en, this message translates to:
  /// **'Illness & Healing'**
  String get azkarCategoryIllness;

  /// No description provided for @azkarCategoryIllnessDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications for the sick'**
  String get azkarCategoryIllnessDescription;

  /// No description provided for @azkarCategoryWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get azkarCategoryWeather;

  /// No description provided for @azkarCategoryWeatherDescription.
  ///
  /// In en, this message translates to:
  /// **'Rain, thunder, and wind'**
  String get azkarCategoryWeatherDescription;

  /// No description provided for @azkarCategoryKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get azkarCategoryKnowledge;

  /// No description provided for @azkarCategoryKnowledgeDescription.
  ///
  /// In en, this message translates to:
  /// **'Seeking beneficial knowledge'**
  String get azkarCategoryKnowledgeDescription;

  /// No description provided for @azkarCategoryParents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get azkarCategoryParents;

  /// No description provided for @azkarCategoryParentsDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications for parents'**
  String get azkarCategoryParentsDescription;

  /// No description provided for @azkarCategoryGuidance.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get azkarCategoryGuidance;

  /// No description provided for @azkarCategoryGuidanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Seeking guidance and direction'**
  String get azkarCategoryGuidanceDescription;

  /// No description provided for @azkarCategoryGratitude.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get azkarCategoryGratitude;

  /// No description provided for @azkarCategoryGratitudeDescription.
  ///
  /// In en, this message translates to:
  /// **'Thanking and praising Allah'**
  String get azkarCategoryGratitudeDescription;

  /// No description provided for @azkarCategoryProtection.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get azkarCategoryProtection;

  /// No description provided for @azkarCategoryProtectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Seeking refuge and protection'**
  String get azkarCategoryProtectionDescription;

  /// No description provided for @azkarCategoryDhikr.
  ///
  /// In en, this message translates to:
  /// **'Dhikr'**
  String get azkarCategoryDhikr;

  /// No description provided for @azkarCategoryDhikrDescription.
  ///
  /// In en, this message translates to:
  /// **'General remembrance of Allah'**
  String get azkarCategoryDhikrDescription;

  /// No description provided for @azkarCategoryMarriage.
  ///
  /// In en, this message translates to:
  /// **'Marriage & Family'**
  String get azkarCategoryMarriage;

  /// No description provided for @azkarCategoryMarriageDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications for marriage and family life'**
  String get azkarCategoryMarriageDescription;

  /// No description provided for @azkarCategoryHajj.
  ///
  /// In en, this message translates to:
  /// **'Hajj & Umrah'**
  String get azkarCategoryHajj;

  /// No description provided for @azkarCategoryHajjDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications for pilgrimage'**
  String get azkarCategoryHajjDescription;

  /// No description provided for @azkarCategoryGrief.
  ///
  /// In en, this message translates to:
  /// **'Grief & Loss'**
  String get azkarCategoryGrief;

  /// No description provided for @azkarCategoryGriefDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications at times of loss and death'**
  String get azkarCategoryGriefDescription;

  /// No description provided for @azkarCategoryChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get azkarCategoryChildren;

  /// No description provided for @azkarCategoryChildrenDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications for children and newborns'**
  String get azkarCategoryChildrenDescription;

  /// No description provided for @azkarCategoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business & Provision'**
  String get azkarCategoryBusiness;

  /// No description provided for @azkarCategoryBusinessDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications for livelihood and wealth'**
  String get azkarCategoryBusinessDescription;

  /// No description provided for @azkarCategoryNightPrayer.
  ///
  /// In en, this message translates to:
  /// **'Night Prayer'**
  String get azkarCategoryNightPrayer;

  /// No description provided for @azkarCategoryNightPrayerDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications for tahajjud, witr and the night'**
  String get azkarCategoryNightPrayerDescription;

  /// No description provided for @azkarCategoryQuranRecitation.
  ///
  /// In en, this message translates to:
  /// **'Quran Recitation'**
  String get azkarCategoryQuranRecitation;

  /// No description provided for @azkarCategoryQuranRecitationDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplications before and during Quran recitation'**
  String get azkarCategoryQuranRecitationDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
