// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Casa Pointage';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get loginHeroSubtitle => 'فضاء المشرف · مستخدمو المفوض إليهم';

  @override
  String get loginHeroTagline => 'تسجيل حضور المستخدمين\nبالتعرف على الوجه.';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginIdLabel => 'اسم المستخدم';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginShowPassword => 'إظهار كلمة المرور';

  @override
  String get loginHidePassword => 'إخفاء كلمة المرور';

  @override
  String get loginSubmit => 'تسجيل الدخول';

  @override
  String get loginLoading => 'جارٍ تسجيل الدخول…';

  @override
  String get loginFooter =>
      'تطبيق مخصص لمشرفي المفوض إليهم.\nنسيت كلمة المرور؟ اتصل بمصلحة الموارد البشرية لدى المفوض إليه.';

  @override
  String get loginErrorBoth => 'أدخل اسم المستخدم وكلمة المرور.';

  @override
  String get loginErrorId => 'أدخل اسم المستخدم.';

  @override
  String get loginErrorPassword => 'أدخل كلمة المرور.';

  @override
  String get loginErrorInvalid => 'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String get faceRecognized => 'تم التعرف على الوجه';

  @override
  String arrivalAt(String time) {
    return 'الوصول $time';
  }

  @override
  String get tabsLabel => 'التنقل الرئيسي';

  @override
  String get tabTeam => 'الفريق';

  @override
  String get tabEnrolment => 'التسجيل';

  @override
  String get tabHistory => 'السجل';

  @override
  String get tabProfile => 'الملف';

  @override
  String get tabClockIn => 'تسجيل';

  @override
  String get tabClockInSemantic => 'تسجيل حضور شخص';

  @override
  String get shiftMorning => 'مناوبة الصباح';

  @override
  String get shiftAfternoon => 'مناوبة بعد الزوال';

  @override
  String get shiftNight => 'مناوبة الليل';

  @override
  String get functionSupervisor => 'مشرف';

  @override
  String get functionSweeperMale => 'كناس';

  @override
  String get functionSweeperFemale => 'كناسة';

  @override
  String get functionDriver => 'سائق';

  @override
  String get functionLoader => 'عامل جمع';

  @override
  String get functionSweeperDriver => 'سائق كناسة آلية';

  @override
  String get functionTeamLead => 'رئيس الفريق';

  @override
  String get syncOffline => 'غير متصل';

  @override
  String syncOfflinePending(int count) {
    return 'غير متصل · $count';
  }

  @override
  String syncPending(int count) {
    return '$count في الانتظار';
  }

  @override
  String get syncDone => 'متزامن مع الموارد البشرية';

  @override
  String get teamPeopleClockedIn => 'أشخاص مسجلون';

  @override
  String get teamClockMe => 'تسجيل حضوري';

  @override
  String get teamClockMyExit => 'خروجي';

  @override
  String get teamMeClockedIn => 'تم تسجيل حضورك';

  @override
  String get teamMeNotClockedIn => 'لم تسجل حضورك بعد';

  @override
  String get teamMeClockBeforeTeam => 'سجل حضورك قبل فريقك';

  @override
  String get teamMeEnrolFirst => 'سجل وجهك أولًا';

  @override
  String get teamMeSupervisorDaily => 'المشرف يسجل حضوره أيضًا كل يوم';

  @override
  String teamMeArrival(String time) {
    return 'الوصول على الساعة $time';
  }

  @override
  String teamMeExit(String time) {
    return 'الخروج على الساعة $time';
  }

  @override
  String get teamSearchLabel => 'البحث عن شخص';

  @override
  String get teamSearchHint => 'الاسم، رقم التأجير، الوظيفة';

  @override
  String get teamEmpty => 'لا يوجد شخص مطابق.';

  @override
  String teamArrivedAt(String time) {
    return 'وصل على الساعة $time';
  }

  @override
  String get teamManualTag => 'يدوي';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterNotClocked => 'غير المسجلين';

  @override
  String get filterPresent => 'الحاضرون';

  @override
  String get filterLate => 'التأخرات';

  @override
  String get filterAbsent => 'الغائبون';

  @override
  String get filterOut => 'الخارجون';

  @override
  String get filterNotEnrolled => 'بدون تسجيل الوجه';

  @override
  String get statusPresent => 'حاضر';

  @override
  String get statusOut => 'خرج';

  @override
  String get statusLate => 'متأخر';

  @override
  String get statusAbsentJustified => 'غياب مبرر';

  @override
  String get statusNotClocked => 'غير مسجل';

  @override
  String get statusNotEnrolled => 'وجه غير مسجل';

  @override
  String get statusPendingSync => 'في انتظار الإرسال';

  @override
  String get absenceSickness => 'مرض';

  @override
  String get absenceLeave => 'عطلة';

  @override
  String get absenceFamilyEvent => 'مناسبة عائلية';

  @override
  String get absenceOther => 'آخر';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get scanTitleTeam => 'تسجيل حضور شخص';

  @override
  String get scanClose => 'إغلاق';

  @override
  String get scanFlipCamera => 'تبديل الكاميرا';

  @override
  String get faceHintMultiple => 'وجه واحد فقط داخل الإطار';

  @override
  String get faceHintTooFar => 'اقترب أكثر';

  @override
  String get faceHintTooClose => 'ابتعد قليلًا';

  @override
  String get faceHintCenter => 'ضع الوجه في وسط البيضاوي';

  @override
  String get faceHintStraight => 'انظر إلى الأمام';

  @override
  String get faceHintLight => 'يلزم مزيد من الإضاءة';

  @override
  String get scanDetectTitle => 'ضع الوجه داخل الإطار';

  @override
  String get scanDetectHint => 'إضاءة جيدة، بدون قبعة أو نظارات شمسية';

  @override
  String get scanAnalyseTitle => 'تحليل الوجه…';

  @override
  String get scanAnalyseHint => 'لا تتحرك';

  @override
  String get scanLiveTitle => 'التحقق من الحضور الفعلي';

  @override
  String get scanTurnFirst => 'أدر رأسك إلى جانب';

  @override
  String get scanTurnSecond => 'الآن إلى الجانب الآخر';

  @override
  String get scanFailedTitle => 'لم يُتعرف على الوجه';

  @override
  String get scanFailedHint => 'أعد المحاولة أو استعمل التسجيل اليدوي';

  @override
  String scanMatchScore(int score) {
    return 'تطابق $score %';
  }

  @override
  String scanAtDepot(String depot) {
    return 'في $depot';
  }

  @override
  String get scanOutsideDepot => 'خارج المستودع';

  @override
  String get scanAssignment => 'التعيين اليومي';

  @override
  String get scanEdit => 'تعديل';

  @override
  String scanLateBy(String amount) {
    return 'تأخر $amount · السبب اختياري';
  }

  @override
  String get unitHour => 'س';

  @override
  String lateAmount(int minutes, String hours) {
    return '$minutes د · $hours';
  }

  @override
  String personLateBy(String amount) {
    return 'التأخر : $amount';
  }

  @override
  String teamArrivedLate(String time, String amount) {
    return 'وصل في $time · تأخر $amount';
  }

  @override
  String get personShiftStart => 'ساعة بداية الدورة';

  @override
  String get personShiftEnd => 'ساعة نهاية الدورة';

  @override
  String get lateReasonTransport => 'النقل';

  @override
  String get lateReasonPersonal => 'سبب شخصي';

  @override
  String get lateReasonMedical => 'سبب طبي';

  @override
  String get lateReasonOther => 'آخر';

  @override
  String scanConfirmArrival(String time) {
    return 'تأكيد الوصول على الساعة $time';
  }

  @override
  String scanConfirmExit(String time) {
    return 'تأكيد الخروج على الساعة $time';
  }

  @override
  String get scanNotThisPerson => 'ليس الشخص الصحيح';

  @override
  String get scanRetry => 'إعادة المحاولة';

  @override
  String get scanManual => 'تسجيل يدوي';

  @override
  String get scanManualLink => 'لم يُتعرف على الوجه؟ تسجيل يدوي';

  @override
  String get personToday => 'اليوم';

  @override
  String get personArrival => 'الوصول';

  @override
  String get personExit => 'الخروج';

  @override
  String get personNotYet => 'لم يُسجَّل بعد';

  @override
  String get personAssignment => 'التعيين';

  @override
  String get personLateReason => 'سبب التأخر';

  @override
  String get personAbsence => 'الغياب';

  @override
  String personMethodFace(int score) {
    return 'الوجه $score %';
  }

  @override
  String personMethodManual(String reason) {
    return 'يدوي · $reason';
  }

  @override
  String get personManualArrival => 'تسجيل يدوي';

  @override
  String get personManualExit => 'تسجيل الخروج يدويًا';

  @override
  String get personEnrol => 'تسجيل الوجه';

  @override
  String get personDeclareAbsence => 'التصريح بغياب';

  @override
  String get personReportAnomaly => 'الإبلاغ عن خلل';

  @override
  String get personNotFound => 'الشخص غير موجود';

  @override
  String get personClockArrival => 'تسجيل الحضور';

  @override
  String get personClockExit => 'تسجيل الانصراف';

  @override
  String get personFaceEnrolled => 'الوجه مسجل';

  @override
  String get personFaceMissing => 'الوجه غير مسجل';

  @override
  String get personFaceRedo => 'إعادة';

  @override
  String get personFaceDo => 'تسجيل';

  @override
  String get personHistory => 'السجل';

  @override
  String get personHistoryTitle => 'سجل آخر 14 يومًا';

  @override
  String get personRest => 'راحة';

  @override
  String get paginationPrevious => 'الصفحة السابقة';

  @override
  String get paginationNext => 'الصفحة التالية';

  @override
  String paginationPage(int page) {
    return 'الصفحة $page';
  }

  @override
  String paginationRange(int from, int to, int total) {
    return '$from–$to من $total';
  }

  @override
  String get teamSearchClear => 'مسح البحث';

  @override
  String get teamRefresh => 'تحديث';

  @override
  String get syncScreenTitle => 'المزامنة';

  @override
  String get syncConnected => 'متصل بالشبكة';

  @override
  String get syncOfflineTitle => 'غير متصل';

  @override
  String get syncOfflineHint =>
      'تبقى البيانات على الهاتف وتُرسل بمجرد عودة الشبكة.';

  @override
  String get syncListTitle => 'في انتظار الإرسال';

  @override
  String get syncEmpty => 'تم إرسال كل شيء إلى وحدة الموارد البشرية';

  @override
  String get syncNow => 'أرسل الآن';

  @override
  String get syncSent => 'تم الإرسال';

  @override
  String syncItemArrival(String time) {
    return 'الوصول $time';
  }

  @override
  String syncItemExit(String time) {
    return 'الخروج $time';
  }

  @override
  String syncItemAbsence(String reason) {
    return 'غياب · $reason';
  }

  @override
  String syncItemAnomaly(String kind) {
    return 'خلل · $kind';
  }

  @override
  String get profileSector => 'القطاع';

  @override
  String get profileDelegate => 'المفوَّض له';

  @override
  String get profileDepot => 'مكان التسجيل';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String profileLanguageValue(String language) {
    return 'اللغة : $language';
  }

  @override
  String get profileTeam => 'الفريق';

  @override
  String profileTeamCount(int count) {
    return '$count أشخاص';
  }

  @override
  String get profileSynced => 'تمت المزامنة مع وحدة الموارد البشرية';

  @override
  String get profileSyncedHint => 'تم إرسال التسجيلات والحضور.';

  @override
  String get profileOffline => 'بدون اتصال';

  @override
  String get profileOfflineHint =>
      'تبقى التسجيلات على الهاتف إلى حين عودة الشبكة.';

  @override
  String profilePending(int count) {
    return '$count عنصر في الانتظار';
  }

  @override
  String get profilePendingHint => 'الإرسال التلقائي جارٍ.';

  @override
  String get profileSend => 'إرسال';

  @override
  String get profileHelp => 'المساعدة';

  @override
  String get profileLogoutConfirm => 'تسجيل الخروج';

  @override
  String profileLogoutPending(int count) {
    return 'تنبيه: $count عنصر لم يُرسل بعد.';
  }

  @override
  String get helpEnrolLead => '1. تسجيل الوجوه :';

  @override
  String get helpEnrolText => 'مرة واحدة لكل شخص وبموافقته، من تبويب التسجيل.';

  @override
  String get helpClockLead => '2. تسجيل الحضور :';

  @override
  String get helpClockText =>
      'كل يوم يحضر الشخص أمامك. المس «تسجيل» وضع وجهه داخل الإطار. يتم اكتشاف الحضور أو الانصراف تلقائيًا.';

  @override
  String get helpSelfLead => '3. أنت أيضًا :';

  @override
  String get helpSelfText => 'سجل حضورك بزر «تسجيل حضوري».';

  @override
  String get helpFailedLead => 'وجه غير معروف :';

  @override
  String get helpFailedText =>
      'أعد المحاولة بإضاءة أفضل، وإلا استعمل التسجيل اليدوي (الصورة والسبب إلزاميان).';

  @override
  String profileVersion(String version) {
    return 'كازا بوانتاج · الإصدار $version';
  }

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileLogoutTitle => 'تسجيل الخروج؟';

  @override
  String get profileLogoutBody =>
      'سيتعين عليك إدخال المعرّف وكلمة المرور من جديد.';

  @override
  String get profileCancel => 'إلغاء';

  @override
  String get historyTitle => 'سجل التسجيلات';

  @override
  String get historyTodayShort => 'اليوم';

  @override
  String get historyFilterManual => 'يدوي';

  @override
  String get historyLateWord => 'متأخر';

  @override
  String get historyFace => 'الوجه';

  @override
  String get historyToday => 'اليوم';

  @override
  String get historyYesterday => 'أمس';

  @override
  String historyPresentCount(int present, int total) {
    return '$present / $total حاضرون';
  }

  @override
  String historyLate(int count) {
    return '$count متأخرون';
  }

  @override
  String historyAbsent(int count) {
    return '$count غائبون';
  }

  @override
  String historyMissing(int count) {
    return '$count غير مسجّلين';
  }

  @override
  String get historySubtitle => 'آخر 7 أيام';

  @override
  String get enrolTitle => 'تسجيل الوجوه';

  @override
  String enrolProgress(int done, int total) {
    return '$done / $total أشخاص مسجلون';
  }

  @override
  String get enrolSectionTodo => 'للتسجيل';

  @override
  String get enrolSectionDone => 'المسجلون';

  @override
  String get enrolAction => 'تسجيل';

  @override
  String get enrolYou => '(أنت)';

  @override
  String get enrolRegistered => 'مسجل';

  @override
  String enrolRegisteredOn(String date) {
    return 'مسجل في $date';
  }

  @override
  String personFaceDate(String date) {
    return 'في $date';
  }

  @override
  String get enrolAllDone => 'تم تسجيل جميع أفراد الفريق.';

  @override
  String get faceEnrolTitle => 'تسجيل الوجه';

  @override
  String get enrolConsentTitle => 'تسجيل الوجه';

  @override
  String get enrolConsentFace =>
      'يُسجَّل الوجه مرة واحدة فقط، ثم يتم التعرف عليه عند كل تسجيل حضور.';

  @override
  String get enrolConsentShield =>
      'يُحفظ قالب مشفّر فقط في وحدة الموارد البشرية، دون أي صورة.';

  @override
  String get enrolConsentLock => 'يُستعمل فقط لتسجيل الحضور.';

  @override
  String get enrolConsentSelf => 'أوافق على تسجيل وجهي لأجل تسجيل الحضور.';

  @override
  String get enrolConsentTeam =>
      'تم إخبار الشخص وهو يوافق على تسجيل وجهه لأجل تسجيل الحضور.';

  @override
  String get enrolConsentRequired => 'موافقة الشخص إلزامية.';

  @override
  String get enrolBegin => 'ابدأ';

  @override
  String get enrolScanMove => 'حرّك رأسك ببطء';

  @override
  String get enrolScanCircle => 'لإكمال الدائرة';

  @override
  String get enrolScanCircleAgain => 'لإكمال الدائرة مرة ثانية';

  @override
  String get enrolScanFirstDone => 'انتهى المسح الأول';

  @override
  String get enrolScanOneMore => 'دورة أخرى للإنهاء';

  @override
  String get enrolSaving => 'الإرسال إلى وحدة الموارد البشرية…';

  @override
  String get enrolSaved => 'تم تسجيل الوجه';

  @override
  String get enrolSentHr => 'تم الإرسال إلى وحدة الموارد البشرية';

  @override
  String get enrolQualityLow => 'الالتقاط غير كافٍ، أعد المسح.';

  @override
  String get enrolPoseFront => 'انظر إلى الأمام';

  @override
  String get enrolPoseLeft => 'أدر رأسك ببطء إلى اليسار';

  @override
  String get enrolPoseRight => 'أدر رأسك ببطء إلى اليمين';

  @override
  String enrolStep(int current, int total) {
    return 'المرحلة $current من $total';
  }

  @override
  String get enrolDone => 'تم تسجيل الوجه';

  @override
  String enrolDoneHint(String name) {
    return 'يمكن لـ $name الآن التسجيل بالتعرف على الوجه.';
  }

  @override
  String get enrolFinish => 'إنهاء';

  @override
  String get anomalyTitle => 'الإبلاغ عن خلل';

  @override
  String get anomalyStepKind => '1. نوع الخلل';

  @override
  String get anomalyStepComment => 'تعليق';

  @override
  String get anomalyDay => 'اليوم المعني';

  @override
  String get anomalyTime => 'الساعة الصحيحة';

  @override
  String get anomalyClockError => 'خطأ في التسجيل';

  @override
  String get anomalyWrongAssignment => 'تعيين خاطئ';

  @override
  String get anomalyEquipment => 'معدات معطلة';

  @override
  String get anomalyIncident => 'حادث';

  @override
  String get anomalyOther => 'آخر';

  @override
  String get anomalyCommentHint => 'مثال: نسي تسجيل انصرافه أمس';

  @override
  String get anomalySubmit => 'إرسال إلى وحدة الموارد البشرية';

  @override
  String get anomalyIncomplete => 'اختر نوع الخلل';

  @override
  String get anomalyIncompleteComment => 'صف الخلل';

  @override
  String get anomalySaved => 'تم الإبلاغ عن الخلل';

  @override
  String get personAnomalies => 'خلل مُبلَّغ عنه';

  @override
  String get absenceTitle => 'التصريح بغياب';

  @override
  String get absenceStepReason => '1. السبب';

  @override
  String get absenceStepDates => '2. الفترة';

  @override
  String get absenceStepComment => '3. ملاحظة (اختياري)';

  @override
  String get absenceFrom => 'من';

  @override
  String get absenceTo => 'إلى';

  @override
  String get absenceCommentHint => 'مثال: تم تسليم شهادة طبية';

  @override
  String get absenceSubmit => 'إرسال إلى وحدة الموارد البشرية';

  @override
  String get absenceIncomplete => 'اختر السبب';

  @override
  String get absenceSaved => 'تم التصريح بالغياب';

  @override
  String get manualTitle => 'تسجيل يدوي';

  @override
  String get manualSubtitle => 'استثناء · تراقبه الموارد البشرية';

  @override
  String get manualWarning =>
      'يُستعمل فقط عند فشل التعرف على الوجه. الصورة والسبب إلزاميان.';

  @override
  String get manualLabelPerson => 'الشخص';

  @override
  String get manualLabelReason => 'السبب';

  @override
  String get manualLabelPhoto => 'صورة الشخص';

  @override
  String get manualPhotoAdded => 'تمت إضافة الصورة';

  @override
  String get manualPhotoRemove => 'إزالة الصورة';

  @override
  String get manualKindArrival => 'حضور';

  @override
  String get manualKindExit => 'انصراف';

  @override
  String get manualErrorPerson => 'اختر الشخص.';

  @override
  String get manualErrorReason => 'اختر السبب.';

  @override
  String get manualErrorPhoto => 'الصورة إلزامية للتسجيل اليدوي.';

  @override
  String manualConfirm(String time) {
    return 'تسجيل الحضور على الساعة $time';
  }

  @override
  String get manualStepPerson => '1. الشخص';

  @override
  String get manualStepReason => '2. سبب التسجيل اليدوي';

  @override
  String get manualStepPhoto => '3. صورة الإثبات';

  @override
  String get manualChange => 'تغيير';

  @override
  String get manualNoResult => 'لم يتم العثور على أي شخص';

  @override
  String get manualReasonFaceFailed => 'لم يُتعرف على الوجه';

  @override
  String get manualReasonNotEnrolled => 'الوجه غير مسجّل';

  @override
  String get manualReasonCamera => 'مشكل في الكاميرا';

  @override
  String get manualReasonOther => 'آخر';

  @override
  String get manualPhotoHint => 'صوّر الشخص: الصورة تبرّر التسجيل اليدوي.';

  @override
  String get manualPhotoTake => 'التقاط الصورة';

  @override
  String get manualPhotoRetake => 'إعادة الالتقاط';

  @override
  String get manualPhotoError => 'تعذّر فتح الكاميرا';

  @override
  String get manualIncomplete => 'اختر الشخص والسبب والتقط الصورة';

  @override
  String get assignmentManualSweeping => 'الكنس اليدوي';

  @override
  String get assignmentMechanicalSweeping => 'الكنس الآلي';

  @override
  String get assignmentCollection => 'جمع النفايات المنزلية والمماثلة';

  @override
  String get assignmentSupervision => 'تأطير القطاع';

  @override
  String get assignmentCircuit => 'المسار';

  @override
  String assignmentCircuitLine(String circuit) {
    return 'المسار $circuit';
  }

  @override
  String get assignmentVehicle => 'عربة أو مركبة';

  @override
  String get assignmentReadRfid => 'قراءة شارة RFID للعربة أو المركبة';

  @override
  String get assignmentRfidHint => 'قرّب القارئ من شارة RFID للعربة أو المركبة';

  @override
  String get assignmentSave => 'مصادقة';

  @override
  String get assignmentChanged => 'تم تعديل التعيين';

  @override
  String get doneArrival => 'تم تسجيل الوصول';

  @override
  String get doneExit => 'تم تسجيل الخروج';

  @override
  String get doneManualSuffix => '(يدوي)';

  @override
  String get doneSaved => 'تم التسجيل والإحالة على وحدة الموارد البشرية.';

  @override
  String get doneSavedOffline =>
      'تم الحفظ على الهاتف. الإرسال إلى وحدة الموارد البشرية عند عودة الشبكة.';

  @override
  String get doneNext => 'تسجيل الشخص الموالي';

  @override
  String get doneBack => 'العودة إلى الفريق';

  @override
  String get loadErrorTitle => 'تعذر تحميل البيانات';

  @override
  String get loadRetry => 'إعادة المحاولة';

  @override
  String get kioskTitle => 'تسجيل الحضور';

  @override
  String get kioskLoading => 'جارٍ تحميل الوجوه…';

  @override
  String get kioskSending => 'جارٍ تسجيل الحضور…';

  @override
  String get kioskNotRecognised => 'لم يتم التعرف على الوجه، حاول مرة أخرى';

  @override
  String get kioskNoFaces => 'لا توجد وجوه مسجلة لهذا المستودع.';

  @override
  String get kioskArrival => 'تم تسجيل الدخول';

  @override
  String get kioskExit => 'تم تسجيل الخروج';

  @override
  String get kioskFarFromDepot => 'تم التسجيل خارج المستودع';
}
