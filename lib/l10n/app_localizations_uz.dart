// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'MU Study';

  @override
  String get shellMuStudy => 'MU Study';

  @override
  String get languageTitle => 'Tilni tanlang';

  @override
  String get languageSubtitle =>
      'Buni istalgan vaqtda Profil bo‘limida o‘zgartirishingiz mumkin.';

  @override
  String get languageEnglish => 'Inglizcha';

  @override
  String get languageRussian => 'Ruscha';

  @override
  String get languageUzbek => 'O‘zbekcha';

  @override
  String get languageEnglishNative => 'English';

  @override
  String get languageRussianNative => 'Русский';

  @override
  String get languageUzbekNative => 'O‘zbekcha';

  @override
  String get languageContinue => 'Davom etish';

  @override
  String get languageSection => 'Til';

  @override
  String get languageHint => 'Ilova tili';

  @override
  String get loginWelcome => 'Xush kelibsiz';

  @override
  String get loginSubtitle => 'MU Study ish maydoniga kiring';

  @override
  String get loginUsername => 'Foydalanuvchi nomi';

  @override
  String get loginPassword => 'Parol';

  @override
  String get loginSignIn => 'Kirish';

  @override
  String get loginMissingFields => 'Foydalanuvchi nomi va parolni kiriting';

  @override
  String get loginIncorrect => 'Foydalanuvchi nomi yoki parol noto‘g‘ri';

  @override
  String get loginFailed =>
      'Kirib bo‘lmadi. Ulanishni tekshirib, qayta urinib ko‘ring.';

  @override
  String get loginConfigError =>
      'Noto‘g‘ri sozlama. Qo‘llab-quvvatlashga murojaat qiling.';

  @override
  String get loginConfigMissing => 'Sozlama yo‘q. .env faylini tekshiring.';

  @override
  String get accountDisabled =>
      'Hisob o‘chirilgan. Administratorga murojaat qiling.';

  @override
  String get navDashboard => 'Bosh sahifa';

  @override
  String get navAssignments => 'Topshiriqlar';

  @override
  String get navMarks => 'Baholar';

  @override
  String get navAttendance => 'Davomat';

  @override
  String get navNotifications => 'Bildirishnomalar';

  @override
  String get navProfile => 'Profil';

  @override
  String get navUsers => 'Foydalanuvchilar';

  @override
  String get navGroups => 'Guruhlar';

  @override
  String get navAnalytics => 'Tahlil';

  @override
  String get navGradebook => 'Jurnal';

  @override
  String get navChat => 'Chat';

  @override
  String get navFocus => 'Fokus';

  @override
  String get focusTitle => 'Fokus';

  @override
  String get focusSubtitle => 'Tinch o‘qish — bir vaqtda bitta topshiriq.';

  @override
  String get focusTodaysFocus => 'Bugungi fokus';

  @override
  String get focusTodaysFocusSubtitle =>
      '3 tagacha ochiq topshiriq — muddat muhim emas';

  @override
  String get focusAlsoDue => 'Yana topshiriqlar';

  @override
  String get focusContinueHomework => 'Uy ishini davom ettirish';

  @override
  String get focusOpenAssignment => 'Topshiriqni ochish';

  @override
  String get focusEmptyTitle => 'Hali topshiriq yo‘q';

  @override
  String get focusEmptySubtitle =>
      'O‘qituvchi topshiriq e’lon qilganda, shu yerda fokus sessiyasini boshlashingiz mumkin.';

  @override
  String get focusChooseMode => 'Qanday fokususlanasiz?';

  @override
  String get focusModePomodoro => 'Pomodoro';

  @override
  String get focusModePomodoroHint => '25 daqiqa, so‘ng tanaffus';

  @override
  String get focusModeFree => 'Erkin sessiya';

  @override
  String get focusModeFreeHint => 'To‘xtatgunicha hisoblash';

  @override
  String get focusDoNotDisturb => 'Chat o‘chirilgan';

  @override
  String get focusChatMuteHint =>
      'Sessiya davomida chat belgilari yashirinadi. Bildirishnomalar fonda keladi.';

  @override
  String get focusPause => 'Pauza';

  @override
  String get focusResume => 'Davom etish';

  @override
  String get focusPaused => 'Pauza';

  @override
  String get focusEndSession => 'Tugatish';

  @override
  String get focusSessionComplete => 'Sessiya tugadi';

  @override
  String get focusSessionCompleteSubtitle => 'Yaxshi ish. Qisqa xulosa:';

  @override
  String get focusTimeUp => 'Vaqt tugadi!';

  @override
  String get focusTimeUpSubtitle =>
      'Pomodoro tugadi. Qisqa tanaffus oling, so‘ng davom eting.';

  @override
  String focusMinutesFocused(String duration) {
    return 'Fokus: $duration';
  }

  @override
  String get focusOptionalNote => 'Ixtiyoriy eslatma';

  @override
  String get focusOptionalNoteHint => 'masalan, 3-vazifada qiyinchilik';

  @override
  String get focusSaveAndOpen => 'Saqlash va topshiriqni ochish';

  @override
  String get focusDone => 'Tayyor';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatSearchHint => 'Guruh yoki o‘qituvchi qidirish';

  @override
  String get chatEmptyTitle => 'Hali chatlar yo‘q';

  @override
  String get chatEmptySubtitle => 'Sinfga yozish uchun guruhga qo‘shiling.';

  @override
  String get chatNoMessagesYet => 'Hali xabarlar yo‘q';

  @override
  String get chatMessageDeleted => 'Xabar o‘chirildi';

  @override
  String get chatPreviewImage => 'Rasm';

  @override
  String get chatPreviewVideo => 'Video';

  @override
  String get chatVideoPlaybackSpeed => 'Ijro tezligi';

  @override
  String get chatVideoSpeedNormal => '1x';

  @override
  String chatVideoSpeedValue(double speed) {
    final intl.NumberFormat speedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String speedString = speedNumberFormat.format(speed);

    return '${speedString}x';
  }

  @override
  String get chatVideoRewind10 => '-10s';

  @override
  String get chatVideoForward10 => '+10s';

  @override
  String get chatVideoCouldNotPlay => 'Videoni ijro etib bo‘lmadi';

  @override
  String get chatPreviewVoice => 'Ovozli xabar';

  @override
  String get chatPreviewFile => 'Fayl';

  @override
  String get chatOpenFile => 'Ochish';

  @override
  String get chatOpenFileFailed => 'Faylni ochib bo‘lmadi.';

  @override
  String get chatYou => 'Siz';

  @override
  String chatTeacherMembers(String teacher, int count) {
    return '$teacher · $count a’zo';
  }

  @override
  String chatOnlineCount(int count) {
    return '$count onlayn';
  }

  @override
  String get chatReact => 'Reaksiya';

  @override
  String get chatCopyText => 'Matnni nusxalash';

  @override
  String get chatCopied => 'Nusxa olindi';

  @override
  String get chatReply => 'Javob berish';

  @override
  String chatReplyTo(String name) {
    return '$name ga javob';
  }

  @override
  String get chatReplyDeleted => 'O‘chirilgan xabar';

  @override
  String get chatReplyNotFound => 'Asl xabar topilmadi';

  @override
  String get chatMessageHint => 'Xabar…';

  @override
  String get chatAttachImage => 'Rasm';

  @override
  String get chatAttachVideo => 'Video';

  @override
  String get chatAttachFile => 'Fayl';

  @override
  String chatTyping(String names) {
    return '$names yozmoqda…';
  }

  @override
  String chatRecording(String time) {
    return 'Yozilmoqda $time';
  }

  @override
  String chatUploading(String name) {
    return '$name yuklanmoqda…';
  }

  @override
  String chatSendFailed(String error) {
    return 'Yuborib bo‘lmadi: $error';
  }

  @override
  String get chatMicDenied => 'Ovozli xabar uchun mikrofon ruxsati kerak.';

  @override
  String get chatEditTitle => 'Xabarni tahrirlash';

  @override
  String get chatDeleteTitle => 'Xabar o‘chirilsinmi?';

  @override
  String get chatDeleteBody => 'Xabar xonadagi barcha uchun o‘chiriladi.';

  @override
  String chatDeleteSelectedTitle(int count) {
    return '$count ta xabar o‘chirilsinmi?';
  }

  @override
  String get chatDeleteSelectedBody =>
      'Tanlangan xabarlar xonadagi barcha uchun o‘chiriladi.';

  @override
  String chatSelectedCount(int count) {
    return '$count ta tanlandi';
  }

  @override
  String get chatSelectMessages => 'Xabarlarni tanlash';

  @override
  String get chatSelect => 'Tanlash';

  @override
  String get commonSelectAll => 'Hammasini tanlash';

  @override
  String get chatEdited => 'tahrir';

  @override
  String get chatDateToday => 'Bugun';

  @override
  String get chatDateYesterday => 'Kecha';

  @override
  String get chatRoleAdmin => 'admin';

  @override
  String get chatRoleTeacher => 'o‘qituvchi';

  @override
  String get commonSave => 'Saqlash';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonSubmit => 'Yuborish';

  @override
  String get commonDelete => 'O‘chirish';

  @override
  String get commonEdit => 'Tahrirlash';

  @override
  String get commonClose => 'Yopish';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get commonTryAgain => 'Qayta urinib ko‘ring';

  @override
  String get commonLoading => 'Yuklanmoqda…';

  @override
  String get commonError => 'Nimadir noto‘g‘ri ketdi';

  @override
  String commonErrorWithDetails(String error) {
    return 'Xato: $error';
  }

  @override
  String commonCouldNotSave(String error) {
    return 'Saqlab bo‘lmadi: $error';
  }

  @override
  String get commonSignOut => 'Chiqish';

  @override
  String get commonSaveDraft => 'Qoralamani saqlash';

  @override
  String get commonOpen => 'Ochish';

  @override
  String get commonCreate => 'Yaratish';

  @override
  String get commonAssign => 'Biriktirish';

  @override
  String get commonReset => 'Tiklash';

  @override
  String get commonAdd => 'Qo‘shish';

  @override
  String get commonLoadMore => 'Yana yuklash';

  @override
  String get commonExport => 'Eksport';

  @override
  String commonExportFailed(String error) {
    return 'Eksport bo‘lmadi: $error';
  }

  @override
  String get marksTermAll => 'Butun davr';

  @override
  String marksTermSemester(String yearRange, int semester) {
    return '$yearRange · $semester-semestr';
  }

  @override
  String get marksExportCsv => 'CSV eksport';

  @override
  String get marksExportDone => 'Baholar eksport qilindi';

  @override
  String get commonTeacher => 'O‘qituvchi';

  @override
  String get commonStudent => 'O‘quvchi';

  @override
  String get commonAdmin => 'Administrator';

  @override
  String get commonWorkspace => 'Ish maydoni';

  @override
  String get commonNoDueDate => 'Muddat yo‘q';

  @override
  String commonDueDate(String date) {
    return 'Muddat $date';
  }

  @override
  String get homeworkDueThisWeek => 'Shu hafta';

  @override
  String get homeworkDueThisWeekSubtitle => 'Kechikkan va yaqin muddatlar';

  @override
  String get homeworkNoDueThisWeek => 'Shu hafta muddat yo‘q';

  @override
  String get homeworkNoDueThisWeekSubtitle =>
      'Keyingi hafta muddatlarigacha bo‘sh.';

  @override
  String homeworkOverdue(String date) {
    return 'Muddati o‘tgan · $date';
  }

  @override
  String get homeworkDueToday => 'Bugun muddat';

  @override
  String get homeworkDueTomorrow => 'Ertaga muddat';

  @override
  String homeworkDueInDays(int days) {
    return '$days kundan keyin';
  }

  @override
  String get homeworkLateBadge => 'Kechikkan';

  @override
  String get commonProgress => 'Jarayon';

  @override
  String get commonSubject => 'Fan';

  @override
  String get commonType => 'Tur';

  @override
  String get commonTitle => 'Sarlavha';

  @override
  String get commonDescription => 'Tavsif';

  @override
  String get commonGroup => 'Guruh';

  @override
  String get commonMessage => 'Xabar';

  @override
  String get commonScore => 'Ball';

  @override
  String get commonFeedback => 'Izoh';

  @override
  String get commonStudents => 'O‘quvchilar';

  @override
  String get commonCannotUndo => 'Bu amalni bekor qilib bo‘lmaydi.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileFullName => 'To‘liq ism';

  @override
  String get profileNotSignedIn => 'Tizimga kiritilmagan';

  @override
  String get profileAccount => 'Hisob';

  @override
  String get profileAccountSettings => 'Hisob sozlamalari';

  @override
  String get profileSignOutAdmin => 'Admin konsolidan chiqish';

  @override
  String get profileSettings => 'Sozlamalar';

  @override
  String get profileAppearance => 'Ko‘rinish';

  @override
  String get profileThemeLight => 'Yorug‘';

  @override
  String get profileThemeDark => 'Qorong‘u';

  @override
  String get profileThemeSystem => 'Tizim';

  @override
  String get profileStyle => 'Uslub';

  @override
  String get profileStyleModern => 'Zamonaviy professional';

  @override
  String get profileStyleNature => 'Tabiat qog‘ozi';

  @override
  String get profileStyleSoftNeu => 'Neumorfizm';

  @override
  String get profileStyleMonochrome => 'Monoxrom ish maydoni';

  @override
  String get profileEditName => 'Ismni o‘zgartirish';

  @override
  String get profileNameUpdated => 'Ism yangilandi';

  @override
  String get profileChangePhoto => 'Rasmni o‘zgartirish';

  @override
  String get profilePhotoUpdated => 'Rasm yangilandi';

  @override
  String get profileChangePassword => 'Parolni o‘zgartirish';

  @override
  String get profileCurrentPassword => 'Joriy parol';

  @override
  String get profileNewPassword => 'Yangi parol';

  @override
  String get profileConfirmPassword => 'Yangi parolni tasdiqlang';

  @override
  String get profilePasswordChanged => 'Parol yangilandi';

  @override
  String get profilePasswordMismatch => 'Yangi parollar mos emas';

  @override
  String get profilePasswordTooShort => 'Kamida 8 ta belgi';

  @override
  String get profilePasswordHint => 'Parolni unutsangiz, admindan so‘rang.';

  @override
  String get profileShortcuts => 'Tezkor havolalar';

  @override
  String get profileYourGroups => 'Guruhlaringiz';

  @override
  String get profileNoGroups => 'Guruh biriktirilmagan';

  @override
  String profileGroupsCount(int count) {
    return '$count ta guruh';
  }

  @override
  String get profileAverageLabel => 'Davr o‘rtachasi';

  @override
  String get profileAttendanceLabel => 'Davomat';

  @override
  String get profileShareProgress => 'Natija hisobotini ulashish';

  @override
  String get profileNotifications => 'Bildirishnomalar';

  @override
  String get profileClearCache => 'Keshni tozalash';

  @override
  String get profileClearCacheWarn1Title => 'Kesh tozalansinmi?';

  @override
  String get profileClearCacheWarn1Body =>
      'Oflayn chat xabarlari va yuklab olingan rasmlar, videolar, ovozli xabarlar va fayllar o‘chiriladi. Ularni qayta yuklash uchun internet kerak bo‘ladi.';

  @override
  String get profileClearCacheWarn2Title => 'Ishonchingiz komilmi?';

  @override
  String get profileClearCacheWarn2Body =>
      'Bu amalni bekor qilib bo‘lmaydi. Chat keshi shu qurilmadan o‘chiriladi.';

  @override
  String get profileClearCacheConfirm => 'Keshni tozalash';

  @override
  String get profileClearCacheDone => 'Kesh tozalandi';

  @override
  String profileAppVersion(String version) {
    return 'MU Study · v$version';
  }

  @override
  String get profileSubject => 'Fan';

  @override
  String get greetingMorning => 'Xayrli tong';

  @override
  String get greetingAfternoon => 'Xayrli kun';

  @override
  String get greetingEvening => 'Xayrli kech';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get greetingLoadingTitle => 'Xayrli tong, foydalanuvchi';

  @override
  String get greetingLoadingSubtitle => 'Shaxsiy salomlashuv yuklanmoqda...';

  @override
  String get studentHomeSubtitle => 'Sizning o‘quv maydoningiz';

  @override
  String get continueLearning => 'O‘qishni davom ettirish';

  @override
  String get continueLearningSubtitle => 'To‘xtagan joyingizdan davom eting';

  @override
  String get everythingCompleted => 'Hammasi bajarilgan.';

  @override
  String get caughtUpToday => 'Bugun hammasi tayyor.';

  @override
  String get homeworkPack => 'Uy vazifasi to‘plami';

  @override
  String get staticTask => 'Oddiy topshiriq';

  @override
  String get staticAssignment => 'Oddiy';

  @override
  String get upcomingAssignments => 'Yaqin topshiriqlar';

  @override
  String get stayOnTrack => 'Rejada qoling';

  @override
  String get loadingAnnouncements => 'E’lonlar yuklanmoqda...';

  @override
  String get notificationsCardTitle => 'Bildirishnomalar';

  @override
  String unreadAlerts(int count) {
    return 'Sizda $count ta yangi bildirishnoma bor';
  }

  @override
  String get upToDate => 'Hammasi yangilangan';

  @override
  String get announcementsTitle => 'E’lonlar';

  @override
  String get announcementsSubtitle => 'O‘qituvchilaringizdan';

  @override
  String get announcementsEmpty => 'E’lonlar yo‘q';

  @override
  String get announcementsEmptyTeacher =>
      'Muhim yangiliklarni o‘quvchilar bilan ulashing.';

  @override
  String get announcementsEmptyAdmin =>
      'Platforma bo‘ylab e’lonlar shu yerda paydo bo‘ladi.';

  @override
  String get announcementsReadMore => 'Batafsil';

  @override
  String get announcementsShowLess => 'Yig‘ish';

  @override
  String announcementsViewAll(int count) {
    return 'Barchasini ko‘rish ($count)';
  }

  @override
  String get announcementsAll => 'Barcha e’lonlar';

  @override
  String get announcementsNew => 'Yangi e’lon';

  @override
  String get announcementsPost => 'E’lonni joylash';

  @override
  String get announcementsEdit => 'E’lonni tahrirlash';

  @override
  String get announcementsDeleteTitle => 'E’lon o‘chirilsinmi?';

  @override
  String get announcementsDeleteBody =>
      'U guruhdagi barcha a’zolar uchun o‘chiriladi.';

  @override
  String get announcementsByAdmin => 'Ma’muriyat';

  @override
  String get announcementsShareUpdates =>
      'Guruhlaringiz bilan yangiliklar ulashing';

  @override
  String get assignmentsTitle => 'Topshiriqlar';

  @override
  String get assignmentsEmpty => 'Topshiriqlar yo‘q';

  @override
  String get assignmentsEmptySubtitle => 'Hammasi bajarilgan!';

  @override
  String get assignmentsEmptyTeacher =>
      'Boshlash uchun birinchi topshiriqni yarating.';

  @override
  String get assignmentsLearningPath => 'O‘quv yo‘li';

  @override
  String get assignmentsActive => 'Faol topshiriqlar';

  @override
  String get assignmentDetails => 'Topshiriq tafsilotlari';

  @override
  String get assignmentNotFound => 'Topshiriq topilmadi';

  @override
  String get assignmentTasks => 'Vazifalar';

  @override
  String get assignmentTasksSubtitle =>
      'To‘plamni yakunlash uchun hammasini bajaring';

  @override
  String get assignmentNew => 'Yangi topshiriq';

  @override
  String get assignmentManage => 'Topshiriqlarni boshqarish';

  @override
  String get assignmentManageSubtitle =>
      'Oddiy yoki uy vazifasi to‘plamlarini yarating';

  @override
  String get marksTitle => 'Baholarim';

  @override
  String get marksOverallAverage => 'Umumiy o‘rtacha';

  @override
  String get marksNoneYet => 'Hali baholar yo‘q.';

  @override
  String marksBasedOn(String label, int count) {
    return '$label · $count ta baho asosida.';
  }

  @override
  String get marksByCategory => 'Turkumlar bo‘yicha';

  @override
  String get marksWhereStrongest => 'Eng kuchli tomonlaringiz';

  @override
  String get marksAll => 'Barcha baholar';

  @override
  String get marksNewestFirst => 'Avval yangilari';

  @override
  String get marksEmptyTitle => 'Hali baholar yo‘q';

  @override
  String get marksEmptySubtitle => 'O‘qituvchi baholari shu yerda ko‘rinadi.';

  @override
  String get progressReportTitle => 'Natija hisoboti';

  @override
  String get progressReportShare => 'Natijani ulashish';

  @override
  String get progressReportSharing => 'Hisobot tayyorlanmoqda…';

  @override
  String get progressReportDone => 'Hisobot ulashishga tayyor';

  @override
  String progressReportFailed(String error) {
    return 'Ulashib bo‘lmadi: $error';
  }

  @override
  String get progressReportNeedGroup =>
      'Hisobot ulashish uchun guruhga qo‘shiling.';

  @override
  String get progressReportAttendance => 'Davomat';

  @override
  String get progressReportAttendanceRate => 'Davomat foizi';

  @override
  String get progressReportNoAttendance =>
      'Bu muddat uchun davomat yozilmagan.';

  @override
  String get progressReportSessions => 'mashg‘ulot';

  @override
  String get progressReportMarksCounted => 'baho';

  @override
  String get progressReportRecentMarks => 'So‘nggi baholar';

  @override
  String progressReportGeneratedOn(String date) {
    return 'Yaratilgan: $date';
  }

  @override
  String get marksNoRecorded => 'Baholar yozilmagan';

  @override
  String get marksNoRecordedSubtitle =>
      'Birdaniga baho qo‘yish uchun «Sinfni baholash»dan foydalaning.';

  @override
  String get marksRecent => 'So‘nggi baholar';

  @override
  String get marksRecentSubtitle => 'Guruh bo‘yicha oxirgi yozuvlar';

  @override
  String get marksStudentsHeader => 'O‘quvchilar';

  @override
  String get marksStudentsSubtitle =>
      'Barcha baholarning o‘rtacha og‘irlikli bali';

  @override
  String get marksNoStudents => 'Bu guruhda o‘quvchilar yo‘q';

  @override
  String get marksNoStudentsSubtitle =>
      'Administrator guruhingizga o‘quvchilarni biriktirishi mumkin.';

  @override
  String get marksDeleteTitle => 'Bahoni o‘chirish?';

  @override
  String marksDeleteBody(String title) {
    return '«$title» butunlay o‘chiriladi.';
  }

  @override
  String get marksGradeTheClass => 'Sinfni baholash';

  @override
  String get marksOnePercentEach => 'Har bir o‘quvchiga bitta foizli baho';

  @override
  String get marksSaveMarks => 'Baholarni saqlash';

  @override
  String get marksSaveMark => 'Bahoni saqlash';

  @override
  String get marksAddMark => 'Baho qo‘shish';

  @override
  String get marksNothingYet => 'Hali hech narsa yo‘q';

  @override
  String get marksAddFirst => 'Bu o‘quvchiga birinchi bahoni qo‘shing.';

  @override
  String marksSavedCount(int count) {
    return '$count ta baho saqlandi';
  }

  @override
  String get marksGroupHasNoStudents => 'Bu guruhda hali o‘quvchilar yo‘q.';

  @override
  String get marksTitleHint => 'masalan, 3-mavzu testi';

  @override
  String marksAverageLine(String percent, String label) {
    return 'O‘rtacha $percent · $label';
  }

  @override
  String get marksNoMarksYetShort => 'Hali baholar yo‘q';

  @override
  String get marksSummaryStudents => 'O‘quvchilar';

  @override
  String get marksSummaryMarks => 'Baholar';

  @override
  String get attendanceTitle => 'Davomat';

  @override
  String get attendanceEmpty => 'Davomat yozuvlari yo‘q';

  @override
  String get attendanceNoGroup => 'Guruh hali biriktirilmagan';

  @override
  String get attendanceMark => 'Davomatni belgilash';

  @override
  String get attendanceDailyTracking => 'Kunlik o‘quvchi hisobi';

  @override
  String get attendanceSaved => 'Davomat muvaffaqiyatli saqlandi';

  @override
  String get attendanceNoGroups => 'Guruhlar topilmadi';

  @override
  String get attendancePresent => 'B — Bor';

  @override
  String get attendanceLate => 'K — Kechikdi';

  @override
  String get attendanceAbsent => 'Y — Yo‘q';

  @override
  String get attendanceExcused => 'S — Sababli';

  @override
  String get attendancePresentShort => 'B';

  @override
  String get attendanceLateShort => 'K';

  @override
  String get attendanceAbsentShort => 'Y';

  @override
  String get attendanceExcusedShort => 'S';

  @override
  String get attendanceTrend => 'Davomat dinamikasi';

  @override
  String get attendanceOverall => 'Umumiy taqsimot';

  @override
  String get analyticsThisWeek => 'Shu hafta';

  @override
  String get analyticsLastWeek => 'O‘tgan hafta';

  @override
  String analyticsTotalMarks(int count) {
    return 'Jami baholar: $count';
  }

  @override
  String get notificationsTitle => 'Bildirishnomalar';

  @override
  String get notificationsEmpty => 'Hammasi o‘qilgan!';

  @override
  String get notificationsEmptySubtitle => 'Yangi bildirishnomalar yo‘q.';

  @override
  String get notificationsNone => 'Bildirishnomalar yo‘q';

  @override
  String get notifKindAssignment => 'Yangi uy vazifasi';

  @override
  String get notifKindAnnouncement => 'E’lon';

  @override
  String get notifKindGraded => 'Ish baholandi';

  @override
  String get notifKindSubmission => 'Yangi topshiriq';

  @override
  String get notifKindChat => 'Chat xabari';

  @override
  String get notifKindSystem => 'Yangilanish';

  @override
  String get notificationsOpen => 'Ochish';

  @override
  String get taskTitle => 'Vazifa';

  @override
  String get taskYourAnswer => 'Javobingiz';

  @override
  String get taskMarkCompleted => 'Bajarildi deb belgilash';

  @override
  String get taskAttachment => 'Ilova';

  @override
  String get taskAttachmentHint => 'Javobingizga rasm yoki hujjat qo‘shing.';

  @override
  String get taskAttachmentHintReady =>
      'Ochish uchun bosing · o‘chirish uchun axlat qutisi.';

  @override
  String get taskImage => 'Rasm';

  @override
  String get taskImageSubtitle => 'Galereya fotosurati';

  @override
  String get taskFile => 'Fayl';

  @override
  String get taskFileSubtitle => 'PDF yoki hujjat';

  @override
  String get taskReplaceImage => 'Rasm bilan almashtirish';

  @override
  String get taskReplaceFile => 'Faylni almashtirish';

  @override
  String get taskVoice => 'Ovozli yozuv';

  @override
  String get taskVoiceHint =>
      'Ixtiyoriy og‘zaki javob — yozing, tinglang, so‘ng saqlang.';

  @override
  String get taskViewPdf => 'PDFni ko‘rish';

  @override
  String get taskOpenLink => 'Havolani ochish';

  @override
  String get taskSubmitted => 'Yuborildi';

  @override
  String get taskSaved => 'Saqlandi';

  @override
  String taskUploadFailed(String error) {
    return 'Yuklash muvaffaqiyatsiz: $error';
  }

  @override
  String taskVoiceUploadFailed(String error) {
    return 'Ovozni yuklab bo‘lmadi: $error';
  }

  @override
  String taskCouldNotSave(String error) {
    return 'Saqlab bo‘lmadi: $error';
  }

  @override
  String get voiceTapToRecord => 'Javobingizni yozish uchun mikrofonni bosing';

  @override
  String get voiceRecording => 'Yozilmoqda…';

  @override
  String get voiceNote => 'Ovozli eslatma';

  @override
  String get voiceTapPlay => 'Tinglash uchun ijro etishni bosing';

  @override
  String get voiceRerecord => 'Qayta yozish';

  @override
  String get voiceStudentAnswer => 'O‘quvchining ovozli javobi';

  @override
  String get voiceMicPermission => 'Yozish uchun mikrofon ruxsati kerak.';

  @override
  String voiceCouldNotStart(String error) {
    return 'Yozuvni boshlab bo‘lmadi: $error';
  }

  @override
  String voiceCouldNotSave(String error) {
    return 'Yozuvni saqlab bo‘lmadi: $error';
  }

  @override
  String voiceCouldNotPlay(String error) {
    return 'Ovozni ijro etib bo‘lmadi: $error';
  }

  @override
  String get attachmentCouldNotOpen => 'Bu faylni ochib bo‘lmadi.';

  @override
  String get attachmentImage => 'Rasm ilovasi';

  @override
  String get attachmentFile => 'Fayl ilovasi';

  @override
  String get attachmentPdf => 'PDF hujjat';

  @override
  String get attachmentTapPreview => 'Ko‘rish uchun bosing';

  @override
  String get attachmentTapOpen => 'Ochish uchun bosing';

  @override
  String get pdfDefaultTitle => 'PDF';

  @override
  String get teacherWorkspace => 'O‘qituvchi ish maydoni';

  @override
  String get teacherQuickActions => 'Tezkor amallar';

  @override
  String get teacherCreateItems => 'Yangi elementlar yaratish';

  @override
  String get teacherNewAssignment => 'Yangi topshiriq';

  @override
  String get teacherNewAnnouncement => 'Yangi e’lon';

  @override
  String get teacherSubmissions => 'Ishlar';

  @override
  String get teacherNoSubmissions => 'Hali ishlar yo‘q';

  @override
  String get teacherNoSubmissionsSubtitle =>
      'O‘quvchi ishlari baholash uchun shu yerda ko‘rinadi.';

  @override
  String get teacherGradebook => 'Jurnal';

  @override
  String get teacherGradeClass => 'Sinfni baholash';

  @override
  String get teacherNoGroups => 'Hali guruhlar yo‘q';

  @override
  String get teacherNoGroupsSubtitle =>
      'Administratordan guruh biriktirishini so‘rang.';

  @override
  String get teacherActiveGroups => 'FAOL GURUHLAR';

  @override
  String get teacherSubject => 'FAN';

  @override
  String get teacherDailyTasks => 'Kunlik vazifalar';

  @override
  String get teacherNeedsAttention => 'Diqqatingizni talab qiladiganlar';

  @override
  String get teacherReviewSubmissions => 'Ishlarni tekshirish';

  @override
  String get teacherCheckAssignments => 'O‘quvchi topshiriqlarini tekshirish';

  @override
  String get teacherRecordMarks => 'Foizli baholar qo‘yish';

  @override
  String get teacherPerformanceAnalytics => 'Natijalar tahlili';

  @override
  String get teacherTrackProgress => 'Guruh jarayonini kuzatish';

  @override
  String get teacherOpenAttachment => 'Ilovani ochish';

  @override
  String get teacherScoreHelper => 'Uy vazifasi bahosini jurnalga qo‘shadi';

  @override
  String get teacherScoreRange => 'Ball 0 dan 100 gacha bo‘lishi kerak.';

  @override
  String get teacherNoWrittenAnswer => 'Yozma javob yo‘q.';

  @override
  String get teacherReviewSubmission => 'Ishni tekshirish';

  @override
  String get teacherHomeworkPackTasks => 'Uy vazifasi to‘plami vazifalari';

  @override
  String get teacherAddTask => 'Vazifa qo‘shish';

  @override
  String get teacherEditTask => 'Vazifani tahrirlash';

  @override
  String get teacherDeleteTask => 'Vazifani o‘chirish?';

  @override
  String get teacherTasksContent => 'Vazifalar mazmuni';

  @override
  String get teacherManagePack => 'Bu to‘plamdagi elementlarni boshqaring';

  @override
  String get teacherTaskTitleHint => 'masalan, O‘qish mashqi';

  @override
  String get teacherLinkHint => 'https://...';

  @override
  String get teacherAttachmentHint => 'Rasm yoki fayl havolasi...';

  @override
  String get teacherNoData => 'Ma’lumot yo‘q';

  @override
  String get teacherMarkDistribution => 'Baholar taqsimoti';

  @override
  String get teacherStudentsByAverage => 'O‘quvchilar o‘rtacha ball bo‘yicha';

  @override
  String get teacherNoMarksTrends =>
      'Tendensiyalarni ko‘rish uchun jurnalga baho qo‘shing.';

  @override
  String get teacherTargetGroup => 'Maqsadli guruh';

  @override
  String get adminWorkspace => 'Platformani boshqarish';

  @override
  String get adminUsers => 'Foydalanuvchilar';

  @override
  String get adminGroups => 'Guruhlar';

  @override
  String get adminAnalytics => 'Tahlil';

  @override
  String get adminTeachers => 'O‘QITUVCHILAR';

  @override
  String get adminStudents => 'O‘QUVCHILAR';

  @override
  String get adminGroupsLabel => 'GURUHLAR';

  @override
  String get adminMarksLabel => 'BAHOLAR';

  @override
  String get adminActivityInsights => 'Faoliyat tahlili';

  @override
  String get adminCurrentMetrics => 'Joriy ko‘rsatkichlar';

  @override
  String get adminCreateUser => 'Yangi foydalanuvchi';

  @override
  String get adminCreateUserButton => 'Foydalanuvchi yaratish';

  @override
  String get adminUserCreated => 'Foydalanuvchi muvaffaqiyatli yaratildi';

  @override
  String get adminResetPassword => 'Parolni tiklash';

  @override
  String adminResetPasswordTitle(String username) {
    return 'Parolni tiklash · $username';
  }

  @override
  String get adminCreateGroup => 'Yangi guruh';

  @override
  String get adminCreateGroupButton => 'Guruh yaratish';

  @override
  String get adminGroupTitleHint => 'masalan, 4-guruh';

  @override
  String get adminGroupTitleExists =>
      'Bu o‘qituvchida shu nomdagi guruh allaqachon bor';

  @override
  String get adminAssignStudent => 'O‘quvchini biriktirish';

  @override
  String get adminActivityDistribution => 'Faoliyat taqsimoti';

  @override
  String get adminGlobalMetrics => 'Global platforma ko‘rsatkichlari';

  @override
  String get adminActivityLog => 'Admin faoliyat jurnali';

  @override
  String get adminActivityLogSubtitle =>
      'Tizim voqealari va audit yozuvlari shu yerda paydo bo‘ladi.';

  @override
  String adminTeacherLine(String name) {
    return 'O‘qituvchi: $name';
  }

  @override
  String adminRoleLine(String role, String username) {
    return '$role · $username';
  }

  @override
  String get adminDisable => 'O‘chirish';

  @override
  String get adminEnable => 'Yoqish';

  @override
  String get adminPassword => 'Parol';

  @override
  String get adminFullName => 'To‘liq ism';

  @override
  String get adminRole => 'Rol';

  @override
  String get adminSphere => 'Soha';

  @override
  String get percentExcellent => 'A’lo';

  @override
  String get percentGood => 'Yaxshi';

  @override
  String get percentNeedsWork => 'Yaxshilash kerak';

  @override
  String get percentAtRisk => 'Xavf ostida';

  @override
  String get emptyStateDefault => 'Hali hech narsa yo‘q';

  @override
  String get setupRequiredTitle => 'Sozlash kerak';

  @override
  String get setupRequiredBody =>
      'Supabase sozlanmagan. .env fayliga SUPABASE_URL va SUPABASE_ANON_KEY qo‘shing.';

  @override
  String get setupOption1 => '1-variant — mahalliy .env fayli';

  @override
  String get setupOption2 => '2-variant — dart-define';

  @override
  String get attendanceAllPresent => 'Hammasi B';

  @override
  String get attendanceAllAbsent => 'Hammasi Y';

  @override
  String get attendanceAllLate => 'Hammasi K';

  @override
  String get attendanceAllExcused => 'Hammasi S';

  @override
  String get attendancePresentWord => 'Bor';

  @override
  String get attendanceAbsentWord => 'Yo‘q';

  @override
  String get attendanceLateWord => 'Kechikdi';

  @override
  String get attendanceExcusedWord => 'Sababli';

  @override
  String get attendanceWeekdayMon => 'Du';

  @override
  String get attendanceWeekdayTue => 'Se';

  @override
  String get attendanceWeekdayWed => 'Ch';

  @override
  String get attendanceWeekdayThu => 'Pa';

  @override
  String get attendanceWeekdayFri => 'Ju';

  @override
  String get attendancePercentLabel => 'Foiz';

  @override
  String get attendanceNoLesson => 'Dars yo‘q';

  @override
  String get attendanceHistory => 'Davomat tarixi';

  @override
  String get attendanceSelectStudent => 'O‘quvchi';

  @override
  String get attendanceAllStudents => 'Barcha o‘quvchilar';

  @override
  String get attendanceTapToCycle => 'Statusni o‘zgartirish uchun kunga bosing';

  @override
  String get attendanceUpdated => 'Davomat yangilandi';

  @override
  String get attendanceCalendarEmpty => 'Bu oyda davomat yo‘q';

  @override
  String get attendanceFutureNotAllowed =>
      'Kelajakdagi kun uchun davomat belgilab bo‘lmaydi';

  @override
  String get attendanceWeekendNotAllowed =>
      'Davomat faqat ish kunlari (du–ju) uchun belgilanadi';

  @override
  String get chartBandExcellent => '85–100%';

  @override
  String get chartBandGood => '70–84%';

  @override
  String get chartBandNeedsWork => '50–69%';

  @override
  String get chartBandAtRisk => '50% dan past';

  @override
  String get marksWeight => 'Og‘irlik';

  @override
  String get marksCategory => 'Turkum';

  @override
  String get marksDate => 'Sana';

  @override
  String get marksCommentOptional => 'Izoh (ixtiyoriy)';

  @override
  String get marksNewMark => 'Yangi baho';

  @override
  String get marksEditMark => 'Bahoni tahrirlash';

  @override
  String get marksFromSubmission => 'Tekshirilgan ishdan';

  @override
  String get marksNeedTitle => 'Baholanadigan element uchun sarlavha kiriting.';

  @override
  String get marksWeightPositive => 'Og‘irlik noldan katta bo‘lishi kerak.';

  @override
  String get marksNeedAtLeastOne => 'Kamida bitta o‘quvchiga baho kiriting.';

  @override
  String get marksLeaveBlankSkip =>
      'O‘quvchini o‘tkazib yuborish uchun maydonni bo‘sh qoldiring.';

  @override
  String get marksFromSubmissionDelete =>
      'Bu baho tekshirilgan ishdan. Uni o‘chirish uchun «Ishlar» bo‘limida ballni tozalang.';

  @override
  String get marksFromSubmissionEdit =>
      'Bu baho tekshirilgan ishga bog‘langan. Bu yerda tahrirlash keyingi tekshiruvda qayta yoziladi.';

  @override
  String get categoryHomework => 'Uy vazifasi';

  @override
  String get categoryClasswork => 'Sinf ishi';

  @override
  String get categoryQuiz => 'Viktorina';

  @override
  String get categoryTest => 'Test';

  @override
  String get categoryExam => 'Imtihon';

  @override
  String get categoryProject => 'Loyiha';

  @override
  String get categoryOral => 'Og‘zaki';

  @override
  String get categoryOther => 'Boshqa';

  @override
  String get teacherReferenceLinkOptional => 'Havola (ixtiyoriy)';

  @override
  String get teacherAttachmentUrlOptional => 'Ilova URL (ixtiyoriy)';

  @override
  String get teacherNoTasksYet =>
      'Hali vazifalar yo‘q. Boshlash uchun «Vazifa qo‘shish»ni bosing.';

  @override
  String get teacherTemplates => 'Shablonlar';

  @override
  String get teacherTemplatesEmpty => 'Hali shablonlar yo‘q';

  @override
  String get teacherTemplatesEmptySubtitle =>
      'Qayta ishlatish uchun topshiriqni shablon sifatida saqlang.';

  @override
  String get teacherSaveAsTemplate => 'Shablon sifatida saqlash';

  @override
  String get teacherTemplateSaved => 'Shablon saqlandi';

  @override
  String get teacherUseTemplate => 'Shablondan foydalanish';

  @override
  String get teacherFromTemplate => 'Shablondan';

  @override
  String get teacherDeleteTemplate => 'Shablonni o‘chirish?';

  @override
  String teacherDeleteTemplateBody(String title) {
    return '«$title» o‘chiriladi.';
  }

  @override
  String get teacherDuplicateAssignment => 'Nusxa olish';

  @override
  String get teacherDuplicateTitle => 'Topshiriqdan nusxa';

  @override
  String get teacherDuplicated => 'Topshiriq nusxalandi';

  @override
  String get assignmentEdit => 'Topshiriqni tahrirlash';

  @override
  String get assignmentDeleteTitle => 'Topshiriq o‘chirilsinmi?';

  @override
  String get assignmentDeleteBody =>
      'Topshiriq, vazifalar va o‘quvchi topshiriqlari butunlay o‘chiriladi.';

  @override
  String get assignmentDeleted => 'Topshiriq o‘chirildi';

  @override
  String get assignmentTypeHintStatic =>
      'Bitta ish. O‘quvchi bir marta topshiradi — qo‘shimcha vazifalar yo‘q.';

  @override
  String get assignmentTypeHintPack =>
      'Bir nechta vazifali to‘plam. Keyin bandlarni qo‘shasiz.';

  @override
  String get teacherCreateFromTemplate => 'Shablondan yaratish';

  @override
  String teacherTasksCopied(int count) {
    return '$count ta vazifa kiritiladi';
  }

  @override
  String get teacherRecentFeedback => 'Fikrni qayta ishlatish';

  @override
  String get teacherApplyFeedbackToOthers =>
      'Shu vazifa bo‘yicha boshqa kutayotganlarga ham qo‘llash';

  @override
  String teacherFeedbackAppliedCount(int count) {
    return 'Fikr yana $count ta topshiriqqa qo‘llandi';
  }

  @override
  String get teacherSharedComment => 'Umumiy izoh (ixtiyoriy)';

  @override
  String get teacherSharedCommentHint =>
      'Saqlanadigan har bir bahoga bir xil izoh';

  @override
  String get adminPlatformOverview => 'Platforma umumiy ko‘rinishi';

  @override
  String get adminAssignTeacher => 'O‘qituvchini biriktirish';

  @override
  String get adminSelectStudent => 'O‘quvchini tanlash';

  @override
  String get adminInitialGroupOptional => 'Boshlang‘ich guruh (ixtiyoriy)';

  @override
  String get adminChartTasks => 'Vazifalar';

  @override
  String get adminChartGroups => 'Guruhlar';

  @override
  String get adminChartStaff => 'Xodimlar';

  @override
  String get adminChartAssignments => 'Topshiriqlar';

  @override
  String get adminChartMarks => 'Baholar';

  @override
  String get adminChartStudents => 'O‘quvchilar';

  @override
  String get adminAcademicYears => 'O‘quv yillari';

  @override
  String get adminAcademicYearsSubtitle =>
      'Baholar jurnali uchun yillar va semestrlar';

  @override
  String get adminAcademicYearsTitle => 'O‘quv kalendari';

  @override
  String get adminCreateNextYear => 'Keyingi yilni yaratish';

  @override
  String adminYearCreated(String label) {
    return '$label yaratildi';
  }

  @override
  String get adminSetCurrentYear => 'Joriy qilish';

  @override
  String get adminCurrentYearBadge => 'Joriy';

  @override
  String get adminYearSemesters => 'To‘rt semestr · avg → iyn';

  @override
  String adminSemesterRange(int semester, String start, String end) {
    return '$semester-semestr · $start – $end';
  }

  @override
  String get adminEditTerm => 'Muddatni tahrirlash';

  @override
  String adminEditTermTitle(int semester) {
    return '$semester-semestr';
  }

  @override
  String get adminTermStartsOn => 'Boshlanishi';

  @override
  String get adminTermEndsOn => 'Tugashi';

  @override
  String get adminTermDatesInvalid =>
      'Tugash sanasi boshlanish sanasidan oldin bo‘lmasligi kerak';

  @override
  String get adminTermUpdated => 'Semestr sanalari yangilandi';

  @override
  String get adminDeleteYear => 'Yilni o‘chirish';

  @override
  String adminDeleteYearTitle(String label) {
    return '$label ni o‘chirasizmi?';
  }

  @override
  String adminDeleteYearBody(String label) {
    return 'Yil va to‘rt semestr kalendardan o‘chiriladi. Baholar o‘chirilmaydi. Tasdiqlash uchun pastda $label ni yozing.';
  }

  @override
  String adminDeleteYearConfirmHint(String label) {
    return 'Tasdiqlash uchun $label ni yozing';
  }

  @override
  String get adminDeleteYearCurrentBlocked =>
      'Avval boshqa yilni joriy qiling, keyin buni o‘chiring.';

  @override
  String adminYearDeleted(String label) {
    return '$label o‘chirildi';
  }

  @override
  String get adminNoAcademicYears => 'Hali o‘quv yillari yo‘q';

  @override
  String get adminAcademicYearsHint =>
      'Tayyor bo‘lganda keyingi o‘quv yilini yarating. O‘qituvchilar va o‘quvchilar jurnalda semestrni tanlaydi. Sanalarni o‘zgartirish uchun semestrni bosing.';

  @override
  String get adminCredentialPrintTitle => 'Login qog‘ozlari';

  @override
  String get adminCredentialPrintSubtitle =>
      'Bazadan unique loginlar, sahifada 3 ta karta';

  @override
  String get adminCredentialPasteLabel => 'Foydalanuvchilar';

  @override
  String get adminCredentialPasteHint =>
      'username|password|full name\n@james|Abc123xyz|James English|teacher\n@john_jones|Pass456|John Jones';

  @override
  String get adminCredentialPerPage => 'Sahifadagi kartalar';

  @override
  String get adminCredentialTwo => '2';

  @override
  String get adminCredentialThree => '3';

  @override
  String get adminCredentialExportPdf => 'PDF eksport';

  @override
  String get adminCredentialSlipTitle => 'MU Study login';

  @override
  String get adminCredentialSlipHint =>
      'Bu qog‘ozni o‘zingizda saqlang. Birinchi kirishdan keyin parolni o‘zgartiring.';

  @override
  String get adminCredentialNeedUsers => 'Chop etish uchun foydalanuvchi yo‘q';

  @override
  String get adminCredentialNeedSql =>
      'Supabase SQL Editor’da sql/admin_login_slips.sql ni ishga tushiring, keyin qayta eksport qiling.';

  @override
  String get adminCredentialConfidential =>
      'Maxfiy. Bu ma’lumotlar faqat belgilangan o‘quvchi uchun.';

  @override
  String get adminFirstName => 'Ism';

  @override
  String get adminLastName => 'Familiya';

  @override
  String get adminCredentialStudents => 'O‘quvchilar';

  @override
  String get adminCredentialTeachers => 'O‘qituvchilar';

  @override
  String get adminCredentialAllGroups => 'Barcha guruhlar';

  @override
  String get sphereMath => 'Matematika';

  @override
  String get sphereEnglish => 'Ingliz tili';

  @override
  String get dailyMotivation1 => 'Bugun oldinga siljish uchun ajoyib kun.';

  @override
  String get dailyMotivation2 =>
      'To‘xtagan joyingizdan davom etishga tayyormisiz?';

  @override
  String get dailyMotivation3 => 'Bugun maqsadlaringizni zabt etaylik.';

  @override
  String get dailyMotivation4 => 'Izchillik — mahorat kaliti.';
}
