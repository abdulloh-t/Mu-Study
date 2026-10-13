// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'MU Study';

  @override
  String get shellMuStudy => 'MU Study';

  @override
  String get languageTitle => 'Выберите язык';

  @override
  String get languageSubtitle =>
      'Вы можете изменить его в любое время в профиле.';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageUzbek => 'Узбекский';

  @override
  String get languageEnglishNative => 'English';

  @override
  String get languageRussianNative => 'Русский';

  @override
  String get languageUzbekNative => 'O‘zbekcha';

  @override
  String get languageContinue => 'Продолжить';

  @override
  String get languageSection => 'Язык';

  @override
  String get languageHint => 'Язык приложения';

  @override
  String get loginWelcome => 'С возвращением';

  @override
  String get loginSubtitle => 'Войдите в рабочее пространство MU Study';

  @override
  String get loginUsername => 'Имя пользователя';

  @override
  String get loginPassword => 'Пароль';

  @override
  String get loginSignIn => 'Войти';

  @override
  String get loginMissingFields => 'Введите имя пользователя и пароль';

  @override
  String get loginIncorrect => 'Неверное имя пользователя или пароль';

  @override
  String get loginFailed =>
      'Не удалось войти. Проверьте соединение и попробуйте снова.';

  @override
  String get loginConfigError => 'Ошибка конфигурации. Обратитесь в поддержку.';

  @override
  String get loginConfigMissing =>
      'Конфигурация отсутствует. Проверьте файл .env.';

  @override
  String get accountDisabled =>
      'Аккаунт отключён. Обратитесь к администратору.';

  @override
  String get navDashboard => 'Главная';

  @override
  String get navAssignments => 'Задания';

  @override
  String get navMarks => 'Оценки';

  @override
  String get navAttendance => 'Посещаемость';

  @override
  String get navNotifications => 'Уведомления';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navUsers => 'Пользователи';

  @override
  String get navGroups => 'Группы';

  @override
  String get navAnalytics => 'Аналитика';

  @override
  String get navGradebook => 'Журнал';

  @override
  String get navChat => 'Чат';

  @override
  String get navFocus => 'Фокус';

  @override
  String get focusTitle => 'Фокус';

  @override
  String get focusSubtitle => 'Спокойная учёба — одно задание за раз.';

  @override
  String get focusTodaysFocus => 'Фокус на сегодня';

  @override
  String get focusTodaysFocusSubtitle =>
      'До трёх открытых заданий — любой срок';

  @override
  String get focusAlsoDue => 'Ещё задания';

  @override
  String get focusContinueHomework => 'Продолжить домашнее';

  @override
  String get focusOpenAssignment => 'Открыть задание';

  @override
  String get focusEmptyTitle => 'Пока нет заданий';

  @override
  String get focusEmptySubtitle =>
      'Когда учитель опубликует задание, здесь можно начать фокус-сессию.';

  @override
  String get focusChooseMode => 'Как хотите сосредоточиться?';

  @override
  String get focusModePomodoro => 'Помодоро';

  @override
  String get focusModePomodoroHint => '25 минут, затем перерыв';

  @override
  String get focusModeFree => 'Свободная сессия';

  @override
  String get focusModeFreeHint => 'Счёт до остановки';

  @override
  String get focusDoNotDisturb => 'Чат приглушён';

  @override
  String get focusChatMuteHint =>
      'Пока сессия активна, значки чата скрыты. Уведомления всё равно приходят в фоне.';

  @override
  String get focusPause => 'Пауза';

  @override
  String get focusResume => 'Продолжить';

  @override
  String get focusPaused => 'Пауза';

  @override
  String get focusEndSession => 'Завершить';

  @override
  String get focusSessionComplete => 'Сессия завершена';

  @override
  String get focusSessionCompleteSubtitle => 'Отличная работа. Краткий итог:';

  @override
  String get focusTimeUp => 'Время вышло!';

  @override
  String get focusTimeUpSubtitle =>
      'Помидоро закончился. Сделайте короткий перерыв и продолжайте.';

  @override
  String focusMinutesFocused(String duration) {
    return 'В фокусе: $duration';
  }

  @override
  String get focusOptionalNote => 'Заметка (необязательно)';

  @override
  String get focusOptionalNoteHint => 'напр. Застрял на задании №3';

  @override
  String get focusSaveAndOpen => 'Сохранить и открыть задание';

  @override
  String get focusDone => 'Готово';

  @override
  String get chatTitle => 'Чат';

  @override
  String get chatSearchHint => 'Поиск групп или учителей';

  @override
  String get chatEmptyTitle => 'Пока нет чатов';

  @override
  String get chatEmptySubtitle => 'Вступите в группу, чтобы писать классу.';

  @override
  String get chatNoMessagesYet => 'Пока нет сообщений';

  @override
  String get chatMessageDeleted => 'Сообщение удалено';

  @override
  String get chatPreviewImage => 'Фото';

  @override
  String get chatPreviewVideo => 'Видео';

  @override
  String get chatVideoPlaybackSpeed => 'Скорость воспроизведения';

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
  String get chatVideoRewind10 => '-10с';

  @override
  String get chatVideoForward10 => '+10с';

  @override
  String get chatVideoCouldNotPlay => 'Не удалось воспроизвести видео';

  @override
  String get chatPreviewVoice => 'Голосовое сообщение';

  @override
  String get chatPreviewFile => 'Файл';

  @override
  String get chatOpenFile => 'Открыть';

  @override
  String get chatOpenFileFailed => 'Не удалось открыть файл.';

  @override
  String get chatYou => 'Вы';

  @override
  String chatTeacherMembers(String teacher, int count) {
    return '$teacher · $count участников';
  }

  @override
  String chatOnlineCount(int count) {
    return '$count в сети';
  }

  @override
  String get chatReact => 'Реакция';

  @override
  String get chatCopyText => 'Копировать текст';

  @override
  String get chatCopied => 'Скопировано';

  @override
  String get chatReply => 'Ответить';

  @override
  String chatReplyTo(String name) {
    return 'В ответ $name';
  }

  @override
  String get chatReplyDeleted => 'Удалённое сообщение';

  @override
  String get chatReplyNotFound => 'Исходное сообщение недоступно';

  @override
  String get chatMessageHint => 'Сообщение…';

  @override
  String get chatAttachImage => 'Фото';

  @override
  String get chatAttachVideo => 'Видео';

  @override
  String get chatAttachFile => 'Файл';

  @override
  String chatTyping(String names) {
    return '$names печатает…';
  }

  @override
  String chatRecording(String time) {
    return 'Запись $time';
  }

  @override
  String chatUploading(String name) {
    return 'Загрузка $name…';
  }

  @override
  String chatSendFailed(String error) {
    return 'Не удалось отправить: $error';
  }

  @override
  String get chatMicDenied =>
      'Для голосовых сообщений нужен доступ к микрофону.';

  @override
  String get chatEditTitle => 'Изменить сообщение';

  @override
  String get chatDeleteTitle => 'Удалить сообщение?';

  @override
  String get chatDeleteBody => 'Сообщение будет удалено для всех в комнате.';

  @override
  String chatDeleteSelectedTitle(int count) {
    return 'Удалить $count сообщ.?';
  }

  @override
  String get chatDeleteSelectedBody =>
      'Выбранные сообщения будут удалены для всех в комнате.';

  @override
  String chatSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get chatSelectMessages => 'Выбрать сообщения';

  @override
  String get chatSelect => 'Выбрать';

  @override
  String get commonSelectAll => 'Выбрать все';

  @override
  String get chatEdited => 'изм.';

  @override
  String get chatDateToday => 'Сегодня';

  @override
  String get chatDateYesterday => 'Вчера';

  @override
  String get chatRoleAdmin => 'админ';

  @override
  String get chatRoleTeacher => 'учитель';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSubmit => 'Отправить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonTryAgain => 'Попробовать снова';

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String get commonError => 'Что-то пошло не так';

  @override
  String commonErrorWithDetails(String error) {
    return 'Ошибка: $error';
  }

  @override
  String commonCouldNotSave(String error) {
    return 'Не удалось сохранить: $error';
  }

  @override
  String get commonSignOut => 'Выйти';

  @override
  String get commonSaveDraft => 'Сохранить черновик';

  @override
  String get commonOpen => 'Открыть';

  @override
  String get commonCreate => 'Создать';

  @override
  String get commonAssign => 'Назначить';

  @override
  String get commonReset => 'Сбросить';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonLoadMore => 'Загрузить ещё';

  @override
  String get commonExport => 'Экспорт';

  @override
  String commonExportFailed(String error) {
    return 'Не удалось экспортировать: $error';
  }

  @override
  String get marksTermAll => 'За всё время';

  @override
  String marksTermSemester(String yearRange, int semester) {
    return '$yearRange · Семестр $semester';
  }

  @override
  String get marksExportCsv => 'Экспорт CSV';

  @override
  String get marksExportDone => 'Оценки экспортированы';

  @override
  String get commonTeacher => 'Учитель';

  @override
  String get commonStudent => 'Ученик';

  @override
  String get commonAdmin => 'Администратор';

  @override
  String get commonWorkspace => 'Рабочее пространство';

  @override
  String get commonNoDueDate => 'Без срока';

  @override
  String commonDueDate(String date) {
    return 'Срок $date';
  }

  @override
  String get homeworkDueThisWeek => 'На этой неделе';

  @override
  String get homeworkDueThisWeekSubtitle => 'Просроченные и ближайшие сроки';

  @override
  String get homeworkNoDueThisWeek => 'На этой неделе ничего нет';

  @override
  String get homeworkNoDueThisWeekSubtitle =>
      'До дедлайнов следующей недели свободно.';

  @override
  String homeworkOverdue(String date) {
    return 'Просрочено · $date';
  }

  @override
  String get homeworkDueToday => 'Срок сегодня';

  @override
  String get homeworkDueTomorrow => 'Срок завтра';

  @override
  String homeworkDueInDays(int days) {
    return 'Через $days дн.';
  }

  @override
  String get homeworkLateBadge => 'Опоздание';

  @override
  String get commonProgress => 'Прогресс';

  @override
  String get commonSubject => 'Предмет';

  @override
  String get commonType => 'Тип';

  @override
  String get commonTitle => 'Название';

  @override
  String get commonDescription => 'Описание';

  @override
  String get commonGroup => 'Группа';

  @override
  String get commonMessage => 'Сообщение';

  @override
  String get commonScore => 'Оценка';

  @override
  String get commonFeedback => 'Отзыв';

  @override
  String get commonStudents => 'Ученики';

  @override
  String get commonCannotUndo => 'Это действие нельзя отменить.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileFullName => 'Полное имя';

  @override
  String get profileNotSignedIn => 'Вы не вошли';

  @override
  String get profileAccount => 'Аккаунт';

  @override
  String get profileAccountSettings => 'Настройки аккаунта';

  @override
  String get profileSignOutAdmin => 'Выйти из консоли администратора';

  @override
  String get profileSettings => 'Настройки';

  @override
  String get profileAppearance => 'Оформление';

  @override
  String get profileThemeLight => 'Светлая';

  @override
  String get profileThemeDark => 'Тёмная';

  @override
  String get profileThemeSystem => 'Системная';

  @override
  String get profileStyle => 'Стиль';

  @override
  String get profileStyleModern => 'Современный профессиональный';

  @override
  String get profileStyleNature => 'Природная бумага';

  @override
  String get profileStyleSoftNeu => 'Неоморфизм';

  @override
  String get profileStyleMonochrome => 'Монохромное пространство';

  @override
  String get profileEditName => 'Изменить имя';

  @override
  String get profileNameUpdated => 'Имя обновлено';

  @override
  String get profileChangePhoto => 'Сменить фото';

  @override
  String get profilePhotoUpdated => 'Фото обновлено';

  @override
  String get profileChangePassword => 'Сменить пароль';

  @override
  String get profileCurrentPassword => 'Текущий пароль';

  @override
  String get profileNewPassword => 'Новый пароль';

  @override
  String get profileConfirmPassword => 'Подтвердите новый пароль';

  @override
  String get profilePasswordChanged => 'Пароль обновлён';

  @override
  String get profilePasswordMismatch => 'Новые пароли не совпадают';

  @override
  String get profilePasswordTooShort => 'Не менее 8 символов';

  @override
  String get profilePasswordHint =>
      'Если забыли пароль — обратитесь к администратору.';

  @override
  String get profileShortcuts => 'Быстрый доступ';

  @override
  String get profileYourGroups => 'Ваши группы';

  @override
  String get profileNoGroups => 'Группы не назначены';

  @override
  String profileGroupsCount(int count) {
    return 'Групп: $count';
  }

  @override
  String get profileAverageLabel => 'Средний за период';

  @override
  String get profileAttendanceLabel => 'Посещаемость';

  @override
  String get profileShareProgress => 'Поделиться отчётом';

  @override
  String get profileNotifications => 'Уведомления';

  @override
  String get profileClearCache => 'Очистить кэш';

  @override
  String get profileClearCacheWarn1Title => 'Очистить кэш?';

  @override
  String get profileClearCacheWarn1Body =>
      'Будут удалены офлайн-сообщения чата и скачанные изображения, видео, голосовые и файлы. Для повторной загрузки понадобится интернет.';

  @override
  String get profileClearCacheWarn2Title => 'Вы уверены?';

  @override
  String get profileClearCacheWarn2Body =>
      'Это действие нельзя отменить. Кэш чата будет удалён с этого устройства.';

  @override
  String get profileClearCacheConfirm => 'Очистить кэш';

  @override
  String get profileClearCacheDone => 'Кэш очищен';

  @override
  String profileAppVersion(String version) {
    return 'MU Study · v$version';
  }

  @override
  String get profileSubject => 'Предмет';

  @override
  String get greetingMorning => 'Доброе утро';

  @override
  String get greetingAfternoon => 'Добрый день';

  @override
  String get greetingEvening => 'Добрый вечер';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get greetingLoadingTitle => 'Доброе утро, пользователь';

  @override
  String get greetingLoadingSubtitle => 'Загружаем ваше приветствие...';

  @override
  String get studentHomeSubtitle => 'Ваше учебное пространство';

  @override
  String get continueLearning => 'Продолжить обучение';

  @override
  String get continueLearningSubtitle =>
      'Продолжите с того места, где остановились';

  @override
  String get everythingCompleted => 'Всё выполнено.';

  @override
  String get caughtUpToday => 'На сегодня всё готово.';

  @override
  String get homeworkPack => 'Пакет домашнего задания';

  @override
  String get staticTask => 'Обычное задание';

  @override
  String get staticAssignment => 'Обычное';

  @override
  String get upcomingAssignments => 'Ближайшие задания';

  @override
  String get stayOnTrack => 'Не отставайте';

  @override
  String get loadingAnnouncements => 'Загрузка объявлений...';

  @override
  String get notificationsCardTitle => 'Уведомления';

  @override
  String unreadAlerts(int count) {
    return 'У вас $count новых уведомлений';
  }

  @override
  String get upToDate => 'У вас всё актуально';

  @override
  String get announcementsTitle => 'Объявления';

  @override
  String get announcementsSubtitle => 'От ваших учителей';

  @override
  String get announcementsEmpty => 'Нет объявлений';

  @override
  String get announcementsEmptyTeacher =>
      'Делитесь важными обновлениями с учениками.';

  @override
  String get announcementsEmptyAdmin =>
      'Объявления по всей платформе появятся здесь.';

  @override
  String get announcementsReadMore => 'Читать далее';

  @override
  String get announcementsShowLess => 'Свернуть';

  @override
  String announcementsViewAll(int count) {
    return 'Показать все ($count)';
  }

  @override
  String get announcementsAll => 'Все объявления';

  @override
  String get announcementsNew => 'Новое объявление';

  @override
  String get announcementsPost => 'Опубликовать объявление';

  @override
  String get announcementsEdit => 'Изменить объявление';

  @override
  String get announcementsDeleteTitle => 'Удалить объявление?';

  @override
  String get announcementsDeleteBody =>
      'Оно будет удалено у всех участников группы.';

  @override
  String get announcementsByAdmin => 'Администрация';

  @override
  String get announcementsShareUpdates => 'Делитесь обновлениями с группами';

  @override
  String get assignmentsTitle => 'Задания';

  @override
  String get assignmentsEmpty => 'Нет заданий';

  @override
  String get assignmentsEmptySubtitle => 'У вас всё выполнено!';

  @override
  String get assignmentsEmptyTeacher =>
      'Создайте первое задание, чтобы начать.';

  @override
  String get assignmentsLearningPath => 'Учебный путь';

  @override
  String get assignmentsActive => 'Активные задания';

  @override
  String get assignmentDetails => 'Детали задания';

  @override
  String get assignmentNotFound => 'Задание не найдено';

  @override
  String get assignmentTasks => 'Задачи';

  @override
  String get assignmentTasksSubtitle => 'Выполните все, чтобы завершить пакет';

  @override
  String get assignmentNew => 'Новое задание';

  @override
  String get assignmentManage => 'Управление заданиями';

  @override
  String get assignmentManageSubtitle =>
      'Создавайте обычные задания или пакеты';

  @override
  String get marksTitle => 'Мои оценки';

  @override
  String get marksOverallAverage => 'Общий средний балл';

  @override
  String get marksNoneYet => 'Оценок пока нет.';

  @override
  String marksBasedOn(String label, int count) {
    return '$label · на основе $count оценок.';
  }

  @override
  String get marksByCategory => 'По категориям';

  @override
  String get marksWhereStrongest => 'Где вы сильнее всего';

  @override
  String get marksAll => 'Все оценки';

  @override
  String get marksNewestFirst => 'Сначала новые';

  @override
  String get marksEmptyTitle => 'Оценок пока нет';

  @override
  String get marksEmptySubtitle => 'Оценки учителя появятся здесь.';

  @override
  String get progressReportTitle => 'Отчёт об успеваемости';

  @override
  String get progressReportShare => 'Поделиться успеваемостью';

  @override
  String get progressReportSharing => 'Готовим отчёт…';

  @override
  String get progressReportDone => 'Отчёт готов к отправке';

  @override
  String progressReportFailed(String error) {
    return 'Не удалось поделиться: $error';
  }

  @override
  String get progressReportNeedGroup =>
      'Вступите в группу, чтобы поделиться отчётом.';

  @override
  String get progressReportAttendance => 'Посещаемость';

  @override
  String get progressReportAttendanceRate => 'Посещаемость';

  @override
  String get progressReportNoAttendance =>
      'За этот период посещаемость не отмечена.';

  @override
  String get progressReportSessions => 'занятий';

  @override
  String get progressReportMarksCounted => 'оценок';

  @override
  String get progressReportRecentMarks => 'Недавние оценки';

  @override
  String progressReportGeneratedOn(String date) {
    return 'Сформировано $date';
  }

  @override
  String get marksNoRecorded => 'Оценок нет';

  @override
  String get marksNoRecordedSubtitle =>
      'Используйте «Оценить класс», чтобы выставить оценки сразу.';

  @override
  String get marksRecent => 'Недавние оценки';

  @override
  String get marksRecentSubtitle => 'Последние записи по группе';

  @override
  String get marksStudentsHeader => 'Ученики';

  @override
  String get marksStudentsSubtitle => 'Средневзвешенный балл всех оценок';

  @override
  String get marksNoStudents => 'В этой группе нет учеников';

  @override
  String get marksNoStudentsSubtitle =>
      'Администратор может назначить учеников в вашу группу.';

  @override
  String get marksDeleteTitle => 'Удалить оценку?';

  @override
  String marksDeleteBody(String title) {
    return '«$title» будет удалена навсегда.';
  }

  @override
  String get marksGradeTheClass => 'Оценить класс';

  @override
  String get marksOnePercentEach => 'Одна процентная оценка на ученика';

  @override
  String get marksSaveMarks => 'Сохранить оценки';

  @override
  String get marksSaveMark => 'Сохранить оценку';

  @override
  String get marksAddMark => 'Добавить оценку';

  @override
  String get marksNothingYet => 'Пока ничего нет';

  @override
  String get marksAddFirst => 'Добавьте первую оценку этому ученику.';

  @override
  String marksSavedCount(int count) {
    return 'Сохранено оценок: $count';
  }

  @override
  String get marksGroupHasNoStudents => 'В этой группе пока нет учеников.';

  @override
  String get marksTitleHint => 'например, Тест по теме 3';

  @override
  String marksAverageLine(String percent, String label) {
    return 'Средний $percent · $label';
  }

  @override
  String get marksNoMarksYetShort => 'Оценок пока нет';

  @override
  String get marksSummaryStudents => 'Ученики';

  @override
  String get marksSummaryMarks => 'Оценки';

  @override
  String get attendanceTitle => 'Посещаемость';

  @override
  String get attendanceEmpty => 'Нет записей посещаемости';

  @override
  String get attendanceNoGroup => 'Группа ещё не назначена';

  @override
  String get attendanceMark => 'Отметить посещаемость';

  @override
  String get attendanceDailyTracking => 'Ежедневный учёт учеников';

  @override
  String get attendanceSaved => 'Посещаемость успешно сохранена';

  @override
  String get attendanceNoGroups => 'Группы не найдены';

  @override
  String get attendancePresent => 'П — Присутствовал';

  @override
  String get attendanceLate => 'О — Опоздал';

  @override
  String get attendanceAbsent => 'Н — Отсутствовал';

  @override
  String get attendanceExcused => 'У — Уважительная';

  @override
  String get attendancePresentShort => 'П';

  @override
  String get attendanceLateShort => 'О';

  @override
  String get attendanceAbsentShort => 'Н';

  @override
  String get attendanceExcusedShort => 'У';

  @override
  String get attendanceTrend => 'Динамика посещаемости';

  @override
  String get attendanceOverall => 'Общее распределение';

  @override
  String get analyticsThisWeek => 'Эта неделя';

  @override
  String get analyticsLastWeek => 'Прошлая неделя';

  @override
  String analyticsTotalMarks(int count) {
    return 'Всего оценок: $count';
  }

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsEmpty => 'Всё прочитано!';

  @override
  String get notificationsEmptySubtitle => 'Новых уведомлений нет.';

  @override
  String get notificationsNone => 'Нет уведомлений';

  @override
  String get notifKindAssignment => 'Новое ДЗ';

  @override
  String get notifKindAnnouncement => 'Объявление';

  @override
  String get notifKindGraded => 'Работа оценена';

  @override
  String get notifKindSubmission => 'Новая сдача';

  @override
  String get notifKindChat => 'Сообщение в чате';

  @override
  String get notifKindSystem => 'Обновление';

  @override
  String get notificationsOpen => 'Открыть';

  @override
  String get taskTitle => 'Задание';

  @override
  String get taskYourAnswer => 'Ваш ответ';

  @override
  String get taskMarkCompleted => 'Отметить выполненным';

  @override
  String get taskAttachment => 'Вложение';

  @override
  String get taskAttachmentHint => 'Добавьте фото или документ к ответу.';

  @override
  String get taskAttachmentHintReady =>
      'Нажмите, чтобы открыть · корзина — удалить.';

  @override
  String get taskImage => 'Изображение';

  @override
  String get taskImageSubtitle => 'Фото из галереи';

  @override
  String get taskFile => 'Файл';

  @override
  String get taskFileSubtitle => 'PDF или документ';

  @override
  String get taskReplaceImage => 'Заменить изображением';

  @override
  String get taskReplaceFile => 'Заменить файл';

  @override
  String get taskVoice => 'Голосовая запись';

  @override
  String get taskVoiceHint =>
      'Необязательный устный ответ — запишите, прослушайте и сохраните.';

  @override
  String get taskViewPdf => 'Открыть PDF';

  @override
  String get taskOpenLink => 'Открыть ссылку';

  @override
  String get taskSubmitted => 'Отправлено';

  @override
  String get taskSaved => 'Сохранено';

  @override
  String taskUploadFailed(String error) {
    return 'Не удалось загрузить: $error';
  }

  @override
  String taskVoiceUploadFailed(String error) {
    return 'Не удалось загрузить голос: $error';
  }

  @override
  String taskCouldNotSave(String error) {
    return 'Не удалось сохранить: $error';
  }

  @override
  String get voiceTapToRecord => 'Нажмите на микрофон, чтобы записать ответ';

  @override
  String get voiceRecording => 'Запись…';

  @override
  String get voiceNote => 'Голосовая заметка';

  @override
  String get voiceTapPlay => 'Нажмите воспроизведение, чтобы прослушать';

  @override
  String get voiceRerecord => 'Перезаписать';

  @override
  String get voiceStudentAnswer => 'Голосовой ответ ученика';

  @override
  String get voiceMicPermission => 'Для записи нужен доступ к микрофону.';

  @override
  String voiceCouldNotStart(String error) {
    return 'Не удалось начать запись: $error';
  }

  @override
  String voiceCouldNotSave(String error) {
    return 'Не удалось сохранить запись: $error';
  }

  @override
  String voiceCouldNotPlay(String error) {
    return 'Не удалось воспроизвести: $error';
  }

  @override
  String get attachmentCouldNotOpen => 'Не удалось открыть этот файл.';

  @override
  String get attachmentImage => 'Изображение';

  @override
  String get attachmentFile => 'Файл';

  @override
  String get attachmentPdf => 'PDF-документ';

  @override
  String get attachmentTapPreview => 'Нажмите для просмотра';

  @override
  String get attachmentTapOpen => 'Нажмите, чтобы открыть';

  @override
  String get pdfDefaultTitle => 'PDF';

  @override
  String get teacherWorkspace => 'Рабочее пространство учителя';

  @override
  String get teacherQuickActions => 'Быстрые действия';

  @override
  String get teacherCreateItems => 'Создать новые элементы';

  @override
  String get teacherNewAssignment => 'Новое задание';

  @override
  String get teacherNewAnnouncement => 'Новое объявление';

  @override
  String get teacherSubmissions => 'Работы';

  @override
  String get teacherNoSubmissions => 'Работ пока нет';

  @override
  String get teacherNoSubmissionsSubtitle =>
      'Работы учеников появятся здесь для проверки.';

  @override
  String get teacherGradebook => 'Журнал';

  @override
  String get teacherGradeClass => 'Оценить класс';

  @override
  String get teacherNoGroups => 'Групп пока нет';

  @override
  String get teacherNoGroupsSubtitle =>
      'Попросите администратора назначить вам группу.';

  @override
  String get teacherActiveGroups => 'АКТИВНЫЕ ГРУППЫ';

  @override
  String get teacherSubject => 'ПРЕДМЕТ';

  @override
  String get teacherDailyTasks => 'Ежедневные задачи';

  @override
  String get teacherNeedsAttention => 'Что требует внимания';

  @override
  String get teacherReviewSubmissions => 'Проверить работы';

  @override
  String get teacherCheckAssignments => 'Проверить задания учеников';

  @override
  String get teacherRecordMarks => 'Выставить оценки в процентах';

  @override
  String get teacherPerformanceAnalytics => 'Аналитика успеваемости';

  @override
  String get teacherTrackProgress => 'Отслеживать прогресс группы';

  @override
  String get teacherOpenAttachment => 'Открыть вложение';

  @override
  String get teacherScoreHelper => 'Добавляет оценку за ДЗ в журнал';

  @override
  String get teacherScoreRange => 'Оценка должна быть от 0 до 100.';

  @override
  String get teacherNoWrittenAnswer => 'Письменного ответа нет.';

  @override
  String get teacherReviewSubmission => 'Проверить работу';

  @override
  String get teacherHomeworkPackTasks => 'Задачи пакета ДЗ';

  @override
  String get teacherAddTask => 'Добавить задачу';

  @override
  String get teacherEditTask => 'Изменить задачу';

  @override
  String get teacherDeleteTask => 'Удалить задачу?';

  @override
  String get teacherTasksContent => 'Содержание задач';

  @override
  String get teacherManagePack => 'Управляйте элементами этого пакета';

  @override
  String get teacherTaskTitleHint => 'например, Упражнение по чтению';

  @override
  String get teacherLinkHint => 'https://...';

  @override
  String get teacherAttachmentHint => 'Ссылка на изображение или файл...';

  @override
  String get teacherNoData => 'Нет данных';

  @override
  String get teacherMarkDistribution => 'Распределение оценок';

  @override
  String get teacherStudentsByAverage => 'Ученики по среднему баллу';

  @override
  String get teacherNoMarksTrends =>
      'Добавьте оценки в журнал, чтобы увидеть динамику.';

  @override
  String get teacherTargetGroup => 'Целевая группа';

  @override
  String get adminWorkspace => 'Управление платформой';

  @override
  String get adminUsers => 'Пользователи';

  @override
  String get adminGroups => 'Группы';

  @override
  String get adminAnalytics => 'Аналитика';

  @override
  String get adminTeachers => 'УЧИТЕЛЯ';

  @override
  String get adminStudents => 'УЧЕНИКИ';

  @override
  String get adminGroupsLabel => 'ГРУППЫ';

  @override
  String get adminMarksLabel => 'ОЦЕНКИ';

  @override
  String get adminActivityInsights => 'Аналитика активности';

  @override
  String get adminCurrentMetrics => 'Текущие показатели';

  @override
  String get adminCreateUser => 'Создать пользователя';

  @override
  String get adminCreateUserButton => 'Создать пользователя';

  @override
  String get adminUserCreated => 'Пользователь успешно создан';

  @override
  String get adminResetPassword => 'Сбросить пароль';

  @override
  String adminResetPasswordTitle(String username) {
    return 'Сброс пароля · $username';
  }

  @override
  String get adminCreateGroup => 'Создать группу';

  @override
  String get adminCreateGroupButton => 'Создать группу';

  @override
  String get adminGroupTitleHint => 'например, Группа 4';

  @override
  String get adminGroupTitleExists =>
      'У этого учителя уже есть группа с таким названием';

  @override
  String get adminAssignStudent => 'Назначить ученика';

  @override
  String get adminActivityDistribution => 'Распределение активности';

  @override
  String get adminGlobalMetrics => 'Глобальные показатели платформы';

  @override
  String get adminActivityLog => 'Журнал активности администратора';

  @override
  String get adminActivityLogSubtitle =>
      'Системные события и аудит появятся здесь.';

  @override
  String adminTeacherLine(String name) {
    return 'Учитель: $name';
  }

  @override
  String adminRoleLine(String role, String username) {
    return '$role · $username';
  }

  @override
  String get adminDisable => 'Отключить';

  @override
  String get adminEnable => 'Включить';

  @override
  String get adminPassword => 'Пароль';

  @override
  String get adminFullName => 'Полное имя';

  @override
  String get adminRole => 'Роль';

  @override
  String get adminSphere => 'Сфера';

  @override
  String get percentExcellent => 'Отлично';

  @override
  String get percentGood => 'Хорошо';

  @override
  String get percentNeedsWork => 'Нужно подтянуть';

  @override
  String get percentAtRisk => 'Под угрозой';

  @override
  String get emptyStateDefault => 'Пока ничего нет';

  @override
  String get setupRequiredTitle => 'Требуется настройка';

  @override
  String get setupRequiredBody =>
      'Supabase не настроен. Добавьте SUPABASE_URL и SUPABASE_ANON_KEY в файл .env.';

  @override
  String get setupOption1 => 'Вариант 1 — локальный файл .env';

  @override
  String get setupOption2 => 'Вариант 2 — dart-define';

  @override
  String get attendanceAllPresent => 'Все П';

  @override
  String get attendanceAllAbsent => 'Все Н';

  @override
  String get attendanceAllLate => 'Все О';

  @override
  String get attendanceAllExcused => 'Все У';

  @override
  String get attendancePresentWord => 'Присутствовал';

  @override
  String get attendanceAbsentWord => 'Отсутствовал';

  @override
  String get attendanceLateWord => 'Опоздал';

  @override
  String get attendanceExcusedWord => 'Уважительная';

  @override
  String get attendanceWeekdayMon => 'Пн';

  @override
  String get attendanceWeekdayTue => 'Вт';

  @override
  String get attendanceWeekdayWed => 'Ср';

  @override
  String get attendanceWeekdayThu => 'Чт';

  @override
  String get attendanceWeekdayFri => 'Пт';

  @override
  String get attendancePercentLabel => 'Доля';

  @override
  String get attendanceNoLesson => 'Нет урока';

  @override
  String get attendanceHistory => 'История посещаемости';

  @override
  String get attendanceSelectStudent => 'Ученик';

  @override
  String get attendanceAllStudents => 'Все ученики';

  @override
  String get attendanceTapToCycle => 'Нажмите на день, чтобы изменить статус';

  @override
  String get attendanceUpdated => 'Посещаемость обновлена';

  @override
  String get attendanceCalendarEmpty => 'Нет посещаемости в этом месяце';

  @override
  String get attendanceFutureNotAllowed =>
      'Нельзя отметить посещаемость на будущий день';

  @override
  String get attendanceWeekendNotAllowed =>
      'Посещаемость отмечается только в будни (пн–пт)';

  @override
  String get chartBandExcellent => '85–100%';

  @override
  String get chartBandGood => '70–84%';

  @override
  String get chartBandNeedsWork => '50–69%';

  @override
  String get chartBandAtRisk => 'Ниже 50%';

  @override
  String get marksWeight => 'Вес';

  @override
  String get marksCategory => 'Категория';

  @override
  String get marksDate => 'Дата';

  @override
  String get marksCommentOptional => 'Комментарий (необязательно)';

  @override
  String get marksNewMark => 'Новая оценка';

  @override
  String get marksEditMark => 'Изменить оценку';

  @override
  String get marksFromSubmission => 'Из проверенной работы';

  @override
  String get marksNeedTitle => 'Укажите название оцениваемого элемента.';

  @override
  String get marksWeightPositive => 'Вес должен быть больше нуля.';

  @override
  String get marksNeedAtLeastOne => 'Введите оценку хотя бы одному ученику.';

  @override
  String get marksLeaveBlankSkip =>
      'Оставьте поле пустым, чтобы пропустить ученика.';

  @override
  String get marksFromSubmissionDelete =>
      'Эта оценка из проверенной работы. Чтобы удалить её, очистите балл в разделе «Работы».';

  @override
  String get marksFromSubmissionEdit =>
      'Эта оценка связана с проверенной работой. Изменения здесь будут перезаписаны при повторной проверке.';

  @override
  String get categoryHomework => 'Домашнее задание';

  @override
  String get categoryClasswork => 'Классная работа';

  @override
  String get categoryQuiz => 'Квиз';

  @override
  String get categoryTest => 'Тест';

  @override
  String get categoryExam => 'Экзамен';

  @override
  String get categoryProject => 'Проект';

  @override
  String get categoryOral => 'Устно';

  @override
  String get categoryOther => 'Другое';

  @override
  String get teacherReferenceLinkOptional => 'Ссылка (необязательно)';

  @override
  String get teacherAttachmentUrlOptional => 'URL вложения (необязательно)';

  @override
  String get teacherNoTasksYet =>
      'Задач пока нет. Нажмите «Добавить задачу», чтобы начать.';

  @override
  String get teacherTemplates => 'Шаблоны';

  @override
  String get teacherTemplatesEmpty => 'Шаблонов пока нет';

  @override
  String get teacherTemplatesEmptySubtitle =>
      'Сохраните задание как шаблон, чтобы использовать снова.';

  @override
  String get teacherSaveAsTemplate => 'Сохранить как шаблон';

  @override
  String get teacherTemplateSaved => 'Шаблон сохранён';

  @override
  String get teacherUseTemplate => 'Использовать шаблон';

  @override
  String get teacherFromTemplate => 'Из шаблона';

  @override
  String get teacherDeleteTemplate => 'Удалить шаблон?';

  @override
  String teacherDeleteTemplateBody(String title) {
    return '«$title» будет удалён.';
  }

  @override
  String get teacherDuplicateAssignment => 'Дублировать';

  @override
  String get teacherDuplicateTitle => 'Дублировать задание';

  @override
  String get teacherDuplicated => 'Задание скопировано';

  @override
  String get assignmentEdit => 'Изменить задание';

  @override
  String get assignmentDeleteTitle => 'Удалить задание?';

  @override
  String get assignmentDeleteBody =>
      'Задание, задачи и работы учеников будут удалены безвозвратно.';

  @override
  String get assignmentDeleted => 'Задание удалено';

  @override
  String get assignmentTypeHintStatic =>
      'Одна работа. Ученик сдаёт один раз — без дополнительных задач.';

  @override
  String get assignmentTypeHintPack =>
      'Набор из нескольких задач. Дальше добавите пункты.';

  @override
  String get teacherCreateFromTemplate => 'Создать из шаблона';

  @override
  String teacherTasksCopied(int count) {
    return 'Задач: $count';
  }

  @override
  String get teacherRecentFeedback => 'Повторно использовать отзыв';

  @override
  String get teacherApplyFeedbackToOthers =>
      'Также применить к другим ожидающим по этой задаче';

  @override
  String teacherFeedbackAppliedCount(int count) {
    return 'Отзыв применён к $count другим работам';
  }

  @override
  String get teacherSharedComment => 'Общий комментарий (необязательно)';

  @override
  String get teacherSharedCommentHint =>
      'Одна и та же заметка ко всем сохраняемым оценкам';

  @override
  String get adminPlatformOverview => 'Обзор платформы';

  @override
  String get adminAssignTeacher => 'Назначить учителя';

  @override
  String get adminSelectStudent => 'Выбрать ученика';

  @override
  String get adminInitialGroupOptional => 'Начальная группа (необязательно)';

  @override
  String get adminChartTasks => 'Задачи';

  @override
  String get adminChartGroups => 'Группы';

  @override
  String get adminChartStaff => 'Сотрудники';

  @override
  String get adminChartAssignments => 'Задания';

  @override
  String get adminChartMarks => 'Оценки';

  @override
  String get adminChartStudents => 'Ученики';

  @override
  String get adminAcademicYears => 'Учебные годы';

  @override
  String get adminAcademicYearsSubtitle => 'Годы и семестры для журнала оценок';

  @override
  String get adminAcademicYearsTitle => 'Учебный календарь';

  @override
  String get adminCreateNextYear => 'Создать следующий год';

  @override
  String adminYearCreated(String label) {
    return 'Создан $label';
  }

  @override
  String get adminSetCurrentYear => 'Сделать текущим';

  @override
  String get adminCurrentYearBadge => 'Текущий';

  @override
  String get adminYearSemesters => 'Четыре семестра · авг → июн';

  @override
  String adminSemesterRange(int semester, String start, String end) {
    return 'Семестр $semester · $start – $end';
  }

  @override
  String get adminEditTerm => 'Изменить срок';

  @override
  String adminEditTermTitle(int semester) {
    return 'Семестр $semester';
  }

  @override
  String get adminTermStartsOn => 'Начало';

  @override
  String get adminTermEndsOn => 'Конец';

  @override
  String get adminTermDatesInvalid =>
      'Дата окончания должна быть не раньше даты начала';

  @override
  String get adminTermUpdated => 'Даты семестра обновлены';

  @override
  String get adminDeleteYear => 'Удалить год';

  @override
  String adminDeleteYearTitle(String label) {
    return 'Удалить $label?';
  }

  @override
  String adminDeleteYearBody(String label) {
    return 'Год и четыре семестра будут удалены из календаря. Оценки не удаляются. Для подтверждения введите $label ниже.';
  }

  @override
  String adminDeleteYearConfirmHint(String label) {
    return 'Введите $label для подтверждения';
  }

  @override
  String get adminDeleteYearCurrentBlocked =>
      'Сначала сделайте текущим другой год, затем удалите этот.';

  @override
  String adminYearDeleted(String label) {
    return 'Удалён $label';
  }

  @override
  String get adminNoAcademicYears => 'Учебных годов пока нет';

  @override
  String get adminAcademicYearsHint =>
      'Создайте следующий учебный год, когда будете готовы. Учителя и ученики выбирают семестры в журнале. Нажмите на семестр, чтобы изменить даты.';

  @override
  String get adminCredentialPrintTitle => 'Печать логинов';

  @override
  String get adminCredentialPrintSubtitle =>
      'Уникальные логины из базы, 3 карточки на странице';

  @override
  String get adminCredentialPasteLabel => 'Пользователи';

  @override
  String get adminCredentialPasteHint =>
      'username|password|full name\n@james|Abc123xyz|James English|teacher\n@john_jones|Pass456|John Jones';

  @override
  String get adminCredentialPerPage => 'Карточек на странице';

  @override
  String get adminCredentialTwo => '2';

  @override
  String get adminCredentialThree => '3';

  @override
  String get adminCredentialExportPdf => 'Экспорт PDF';

  @override
  String get adminCredentialSlipTitle => 'Ваш вход в MU Study';

  @override
  String get adminCredentialSlipHint =>
      'Храните этот листок при себе. Смените пароль после первого входа.';

  @override
  String get adminCredentialNeedUsers => 'Нет пользователей для печати';

  @override
  String get adminCredentialNeedSql =>
      'Выполните sql/admin_login_slips.sql в SQL Editor Supabase, затем экспортируйте снова.';

  @override
  String get adminCredentialConfidential =>
      'Конфиденциально. Эти данные только для назначенного ученика.';

  @override
  String get adminFirstName => 'Имя';

  @override
  String get adminLastName => 'Фамилия';

  @override
  String get adminCredentialStudents => 'Ученики';

  @override
  String get adminCredentialTeachers => 'Учителя';

  @override
  String get adminCredentialAllGroups => 'Все группы';

  @override
  String get sphereMath => 'Математика';

  @override
  String get sphereEnglish => 'Английский';

  @override
  String get dailyMotivation1 =>
      'Сегодня отличный день, чтобы продвинуться вперёд.';

  @override
  String get dailyMotivation2 =>
      'Готовы продолжить с того места, где остановились?';

  @override
  String get dailyMotivation3 => 'Давайте сегодня достигнем ваших целей.';

  @override
  String get dailyMotivation4 => 'Постоянство — ключ к мастерству.';
}
