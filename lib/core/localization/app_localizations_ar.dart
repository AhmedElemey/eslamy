// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'إسلامي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'حسنًا';

  @override
  String get errorPageTitle => 'خطأ';

  @override
  String get errorOccurredTitle => 'حدث خطأ';

  @override
  String get somethingWentWrongGeneric => 'حدث خطأ ما';

  @override
  String get goBack => 'رجوع';

  @override
  String get goHome => 'الصفحة الرئيسية';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get sectionAppearance => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get sectionLanguage => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get sectionTextSize => 'حجم الخط';

  @override
  String get textSizeDescription =>
      'اضبط حجم الخط في جميع أنحاء التطبيق. 0 هو الحجم الافتراضي.';

  @override
  String get sectionDailyWerdTime => 'وقت الورد اليومي';

  @override
  String get pickTime => 'اختر الوقت';

  @override
  String get scheduleButton => 'جدولة';

  @override
  String get werdTimeSavedAndScheduled => 'تم حفظ وقت الورد وجدولته';

  @override
  String get reminderScheduled => 'تمت جدولة التذكير';

  @override
  String get notificationsDisabledMessage =>
      'الإشعارات معطّلة. فعّلها من إعدادات النظام.';

  @override
  String get testNowButton => 'اختبار الآن';

  @override
  String get testNotificationTitle => 'إشعار تجريبي';

  @override
  String get testNotificationBody => 'إذا رأيت هذا، فإن الإشعارات تعمل';

  @override
  String get sectionPushNotificationsFcm => 'إشعارات الدفع (FCM)';

  @override
  String get fetchingFcmToken => 'جارٍ جلب رمز FCM...';

  @override
  String get noFcmTokenYet => 'لا يوجد رمز بعد. تأكد من السماح بالإشعارات.';

  @override
  String get copyTokenButton => 'نسخ الرمز';

  @override
  String get tokenCopied => 'تم نسخ الرمز';

  @override
  String get homeGreetingAssalamuAlaikum => 'السلام عليكم';

  @override
  String get homeWelcomeBack => 'أهلاً بعودتك';

  @override
  String get tabSurah => 'سورة';

  @override
  String get tabPara => 'جزء';

  @override
  String get tabPage => 'صفحة';

  @override
  String get tabHizb => 'حزب';

  @override
  String get quranOriginMeccan => 'مكية';

  @override
  String get quranOriginMedinian => 'مدنية';

  @override
  String versesCountCaps(int count) {
    return '$count آية';
  }

  @override
  String get streakStatLabel => 'التتابع';

  @override
  String get memorizedStatLabel => 'المحفوظ';

  @override
  String streakDaysShort(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString يوم',
      many: '$countString يومًا',
      few: '$countString أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: '0 يوم',
    );
    return '$_temp0';
  }

  @override
  String memorizedOutOfTotal(int count, int total) {
    return '$count / $total';
  }

  @override
  String get qiblaDirectionTooltip => 'اتجاه القبلة';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get bookmarkedHadiths => 'الأحاديث المحفوظة';

  @override
  String hadithsSavedCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString حديث محفوظ',
      many: '$countString حديثًا محفوظًا',
      few: '$countString أحاديث محفوظة',
      two: 'حديثان محفوظان',
      one: 'حديث واحد محفوظ',
      zero: 'لا أحاديث محفوظة',
    );
    return '$_temp0';
  }

  @override
  String get failedToLoadFavorites => 'فشل تحميل المفضلة';

  @override
  String get noFavoritesYetTitle => 'لا توجد مفضلة بعد';

  @override
  String get noFavoritesYetBody => 'ابدأ بحفظ الأحاديث التي تحبها\nوستظهر هنا';

  @override
  String get removedFromFavorites => 'تمت الإزالة من المفضلة';

  @override
  String get addedToFavorites => 'تمت الإضافة إلى المفضلة';

  @override
  String get clearAllFavoritesTitle => 'حذف كل المفضلة';

  @override
  String get clearAllFavoritesBody =>
      'هل أنت متأكد أنك تريد إزالة جميع الأحاديث المفضلة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get clearAllButton => 'حذف الكل';

  @override
  String get allFavoritesCleared => 'تم حذف كل المفضلة';

  @override
  String get justNow => 'الآن';

  @override
  String daysAgo(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $countString يوم',
      many: 'منذ $countString يومًا',
      few: 'منذ $countString أيام',
      two: 'منذ يومين',
      one: 'منذ يوم واحد',
      zero: 'الآن',
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
      other: 'منذ $countString ساعة',
      many: 'منذ $countString ساعة',
      few: 'منذ $countString ساعات',
      two: 'منذ ساعتين',
      one: 'منذ ساعة واحدة',
      zero: 'الآن',
    );
    return '$_temp0';
  }

  @override
  String get hadithCollectionTitle => 'مجموعة الأحاديث';

  @override
  String searchBookHint(String bookName) {
    return 'ابحث في $bookName…';
  }

  @override
  String downloadingBookForOffline(String bookName) {
    return 'جارٍ تنزيل $bookName للاستخدام دون اتصال…';
  }

  @override
  String failedToDownloadWithError(String error) {
    return 'فشل التنزيل\n$error';
  }

  @override
  String get noHadithsMatchSearch => 'لا توجد أحاديث مطابقة لبحثك';

  @override
  String narratedBy(String narrator) {
    return 'رواه $narrator';
  }

  @override
  String get sharedFromEslamy => 'مشاركة من إسلامي';

  @override
  String get preparingShare => 'جارٍ التحضير…';

  @override
  String get shareAsImage => 'مشاركة كصورة';

  @override
  String get hifzTrackerTitle => 'متتبع الحفظ';

  @override
  String get setReviewReminderTooltip => 'ضبط تذكير المراجعة';

  @override
  String failedToLoadSurahsWithError(String error) {
    return 'فشل تحميل السور\n$error';
  }

  @override
  String surahsMemorizedProgress(int memorized, int total) {
    return 'تم حفظ $memorized من $total سورة';
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
      other: '$countString آية',
      many: '$countString آية',
      few: '$countString آيات',
      two: 'آيتان',
      one: 'آية واحدة',
      zero: '0 آية',
    );
    return '$_temp0';
  }

  @override
  String get hifzReviewNotificationTitle => 'مراجعة الحفظ';

  @override
  String get hifzReviewNotificationBody => 'حان وقت مراجعة ما حفظته';

  @override
  String get dailyReviewReminderScheduled => 'تمت جدولة تذكير المراجعة اليومي';

  @override
  String get prayerTimesTitle => 'مواقيت الصلاة';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get amLabel => 'ص';

  @override
  String get pmLabel => 'م';

  @override
  String failedToLoadPrayerTimesWithError(String error) {
    return 'فشل تحميل مواقيت الصلاة\n$error';
  }

  @override
  String get showingCairoFallback =>
      'يتم عرض مواقيت القاهرة (افتراضي). فعّل الموقع لعرض مواقيت دقيقة.';

  @override
  String get enableButton => 'تفعيل';

  @override
  String get findQiblaDirection => 'تحديد اتجاه القبلة';

  @override
  String get qiblaDirectionTitle => 'اتجاه القبلة';

  @override
  String qiblaUnavailableWithError(String error) {
    return 'تعذّر تحديد اتجاه القبلة\n$error';
  }

  @override
  String get waitingForCompassSensor =>
      'بانتظار حساس البوصلة…\n(غير متوفر في جميع أجهزة المحاكاة)';

  @override
  String get noCompassSensor => 'هذا الجهاز لا يحتوي على حساس بوصلة.';

  @override
  String get facingQibla => 'متجه نحو القبلة ✓';

  @override
  String get rotateToAlign => 'أدر الجهاز للمحاذاة';

  @override
  String qiblaBearingHeading(String bearing, String heading) {
    return 'اتجاه القبلة: $bearing°  ·  الاتجاه الحالي: $heading°';
  }

  @override
  String get allPrayersDoneLabel => 'انتهت جميع الصلوات';

  @override
  String get nextPrayerLabel => 'الصلاة القادمة';

  @override
  String get fajrResumesAfterMidnight => 'يُستأنف الفجر بعد منتصف الليل';

  @override
  String get couldntLoadPrayerTimes => 'تعذّر تحميل مواقيت الصلاة';

  @override
  String get countdownNow => 'الآن';

  @override
  String countdownHoursMinutes(int h, int m) {
    return 'خلال $h س $m د';
  }

  @override
  String countdownMinutes(int m) {
    return 'خلال $m د';
  }

  @override
  String get quranChaptersTitle => 'سور القرآن';

  @override
  String get pauseAudioTooltip => 'إيقاف الصوت مؤقتًا';

  @override
  String get stopAudioTooltip => 'إيقاف الصوت';

  @override
  String get loadingAudio => 'جارٍ تحميل الصوت...';

  @override
  String playingChapterWithReciter(String name) {
    return 'تشغيل السورة بصوت القارئ: $name';
  }

  @override
  String realAudioNotAvailableReciter(String name) {
    return 'الصوت الأصلي غير متاح، يتم تشغيل صوت تجريبي. القارئ: $name';
  }

  @override
  String audioPlaybackErrorWithError(String error) {
    return 'خطأ في تشغيل الصوت: $error';
  }

  @override
  String playingChapterNumberAudio(int number) {
    return 'جارٍ تشغيل صوت السورة $number';
  }

  @override
  String get failedToPlayAudioRetry => 'فشل تشغيل الصوت. حاول مرة أخرى.';

  @override
  String get retryAction => 'إعادة المحاولة';

  @override
  String autoAdvancingToChapter(int number, String name) {
    return 'الانتقال تلقائيًا إلى السورة $number: $name';
  }

  @override
  String get allChaptersCompleted => 'اكتملت جميع السور!';

  @override
  String chapterNumberAudioLabel(int number) {
    return 'صوت السورة $number';
  }

  @override
  String get audioPlayerLabel => 'مشغل الصوت';

  @override
  String get failedToLoadChapters => 'فشل تحميل السور';

  @override
  String versesCountRevelationType(int count, String type) {
    return '$count آية • $type';
  }

  @override
  String get playAudioTooltip => 'تشغيل الصوت';

  @override
  String chapterWithNameTitle(int number, String name) {
    return 'السورة $number: $name';
  }

  @override
  String get pauseChapterAudioTooltip => 'إيقاف صوت السورة مؤقتًا';

  @override
  String get playChapterAudioTooltip => 'تشغيل صوت السورة';

  @override
  String get loadingChapterAudio => 'جارٍ تحميل صوت السورة...';

  @override
  String get chapterAudioStartedPlaying => 'بدأ تشغيل صوت السورة';

  @override
  String get failedToPlayChapterAudioRetry =>
      'فشل تشغيل صوت السورة. حاول مرة أخرى.';

  @override
  String get chapterAudioLabel => 'صوت السورة';

  @override
  String get failedToLoadChapter => 'فشل تحميل السورة';

  @override
  String get playAudioLabel => 'تشغيل الصوت';

  @override
  String get tafseerLabel => 'التفسير';

  @override
  String chapterVerseTitle(int chapter, int verse) {
    return 'السورة $chapter، الآية $verse';
  }

  @override
  String playingWithReciter(String name) {
    return 'التشغيل بصوت القارئ: $name';
  }

  @override
  String get audioStartedPlaying => 'بدأ تشغيل الصوت';

  @override
  String get audioRecitationLabel => 'التلاوة الصوتية';

  @override
  String get tapPlayToLoadAudio => 'اضغط تشغيل لتحميل الصوت';

  @override
  String get toggleTajweedColoringTooltip => 'تبديل تلوين التجويد';

  @override
  String get tajweedLegendTitle => 'مفتاح أحكام التجويد';

  @override
  String get tajweedLegendSubtitle =>
      'اضغط على أي حرف ملوّن في النص لمعرفة حكمه. الألوان مطابقة لهذا المفتاح.';

  @override
  String get repeatPracticeLabel => 'التكرار للتدريب';

  @override
  String get tafseerInterpretationLabel => 'التفسير';

  @override
  String get noTafseerAvailable => 'لا يوجد تفسير متاح لهذه الآية.';

  @override
  String get tafseerMuyassarLabel => 'التفسير الميسر';

  @override
  String get failedToLoadTafseer => 'فشل تحميل التفسير';

  @override
  String get quranReciterLabel => 'قارئ القرآن';

  @override
  String get selectReciterPlaceholder => 'اختر القارئ';

  @override
  String get activeForAudioLabel => 'مفعّل للصوت';

  @override
  String get chooseReciterTitle => 'اختر القارئ';

  @override
  String get splashTagline => 'رفيقك للقرآن والصلاة\nوالعبادة اليومية';

  @override
  String get dayStreakSingle => 'يوم واحد متتابع';

  @override
  String dayStreakCount(int count) {
    return '$count يوم متتابع';
  }

  @override
  String genericErrorWithMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String get adhanAlertsTitle => 'تنبيهات الأذان';

  @override
  String get adhanAlertsDescription =>
      'احصل على إشعار عند كل صلاة من الصلوات الخمس.';

  @override
  String get enabledLabel => 'مفعّل';

  @override
  String get stopTooltip => 'إيقاف';

  @override
  String get previewTooltip => 'معاينة';

  @override
  String get tasbihCounterTitle => 'عداد التسبيح';

  @override
  String get resetTooltip => 'إعادة الضبط';

  @override
  String get targetReached => 'تم بلوغ الهدف ✓';

  @override
  String targetLabel(int target) {
    return 'الهدف: $target';
  }

  @override
  String get tapCircleHint => 'اضغط على الدائرة للعد. يُحفظ تقدمك تلقائيًا.';

  @override
  String get duasAzkarTitle => 'الأدعية والأذكار';

  @override
  String couldNotLoadAzkarWithError(String error) {
    return 'تعذّر تحميل الأذكار\n$error';
  }

  @override
  String couldNotLoadSectionWithError(String error) {
    return 'تعذّر تحميل هذا القسم\n$error';
  }

  @override
  String get hijriCalendarTitle => 'التقويم الهجري';

  @override
  String get todayLabelCaps => 'اليوم';

  @override
  String hijriDateAh(int day, String month, int year) {
    return '$day $month $year هـ';
  }

  @override
  String get upcomingLabel => 'المناسبات القادمة';

  @override
  String get loadingUpcomingOccasions => 'جارٍ تحميل المناسبات القادمة…';

  @override
  String get todayCountdown => 'اليوم';

  @override
  String get tomorrowCountdown => 'غدًا';

  @override
  String inDaysCountdown(int days) {
    return 'خلال $days يوم';
  }

  @override
  String get monthJanuary => 'يناير';

  @override
  String get monthFebruary => 'فبراير';

  @override
  String get monthMarch => 'مارس';

  @override
  String get monthApril => 'أبريل';

  @override
  String get monthMay => 'مايو';

  @override
  String get monthJune => 'يونيو';

  @override
  String get monthJuly => 'يوليو';

  @override
  String get monthAugust => 'أغسطس';

  @override
  String get monthSeptember => 'سبتمبر';

  @override
  String get monthOctober => 'أكتوبر';

  @override
  String get monthNovember => 'نوفمبر';

  @override
  String get monthDecember => 'ديسمبر';

  @override
  String get weekdaySun => 'ح';

  @override
  String get weekdayMon => 'ن';

  @override
  String get weekdayTue => 'ث';

  @override
  String get weekdayWed => 'ر';

  @override
  String get weekdayThu => 'خ';

  @override
  String get weekdayFri => 'ج';

  @override
  String get weekdaySat => 'س';

  @override
  String get chooseTranslationTitle => 'اختر الترجمة';

  @override
  String get searchLanguageHint => 'ابحث عن لغة…';

  @override
  String couldNotLoadLanguagesWithError(String error) {
    return 'تعذّر تحميل اللغات\n$error';
  }

  @override
  String get drawerSectionWorship => 'العبادات';

  @override
  String get drawerSectionQuranStudy => 'القرآن والدراسة';

  @override
  String get digitalMushaf => 'المصحف الرقمي';

  @override
  String get hifzProgress => 'تقدّم الحفظ';

  @override
  String get hadithLabel => 'الحديث';

  @override
  String get quickAccessTasbih => 'تسبيح';

  @override
  String get weekdayMonday => 'الاثنين';

  @override
  String get weekdayTuesday => 'الثلاثاء';

  @override
  String get weekdayWednesday => 'الأربعاء';

  @override
  String get weekdayThursday => 'الخميس';

  @override
  String get weekdayFriday => 'الجمعة';

  @override
  String get weekdaySaturday => 'السبت';

  @override
  String get weekdaySunday => 'الأحد';

  @override
  String get holidayIslamicNewYear => 'رأس السنة الهجرية';

  @override
  String get holidayDayOfAshura => 'يوم عاشوراء';

  @override
  String get holidayMawlidAlNabi => 'المولد النبوي الشريف';

  @override
  String get holidayStartOfRamadan => 'بداية رمضان';

  @override
  String get holidayLaylatAlQadr => 'ليلة القدر (تقريبًا)';

  @override
  String get holidayEidAlFitr => 'عيد الفطر';

  @override
  String get holidayDayOfArafah => 'يوم عرفة';

  @override
  String get holidayEidAlAdha => 'عيد الأضحى';

  @override
  String get navHomeLabel => 'الرئيسية';

  @override
  String get navQuranLabel => 'القرآن';

  @override
  String get navQiblaLabel => 'القبلة';
}
