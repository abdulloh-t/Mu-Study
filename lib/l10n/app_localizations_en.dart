// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MU Study';

  @override
  String get shellMuStudy => 'MU Study';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageSubtitle => 'You can change this anytime in Profile.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageUzbek => 'Uzbek';

  @override
  String get languageEnglishNative => 'English';

  @override
  String get languageRussianNative => 'Русский';

  @override
  String get languageUzbekNative => 'O‘zbekcha';

  @override
  String get languageContinue => 'Continue';

  @override
  String get languageSection => 'Language';

  @override
  String get languageHint => 'App language';

  @override
  String get loginWelcome => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to your MU Study workspace';

  @override
  String get loginUsername => 'Username';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginMissingFields => 'Please enter both username and password';

  @override
  String get loginIncorrect => 'Incorrect username or password';

  @override
  String get loginFailed =>
      'Sign in failed. Check your connection and try again.';

  @override
  String get loginConfigError => 'Invalid configuration. Contact support.';

  @override
  String get loginConfigMissing =>
      'Configuration missing. Check your .env file.';

  @override
  String get accountDisabled => 'Account disabled. Contact admin.';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navAssignments => 'Assignments';

  @override
  String get navMarks => 'Marks';

  @override
  String get navAttendance => 'Attendance';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get navUsers => 'Users';

  @override
  String get navGroups => 'Groups';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navGradebook => 'Gradebook';

  @override
  String get navChat => 'Chat';

  @override
  String get navFocus => 'Focus';

  @override
  String get focusTitle => 'Focus';

  @override
  String get focusSubtitle => 'Quiet study time for one assignment at a time.';

  @override
  String get focusTodaysFocus => 'Today’s focus';

  @override
  String get focusTodaysFocusSubtitle =>
      'Up to three open assignments — any due date';

  @override
  String get focusAlsoDue => 'More homework';

  @override
  String get focusContinueHomework => 'Continue homework';

  @override
  String get focusOpenAssignment => 'Open assignment';

  @override
  String get focusEmptyTitle => 'No homework yet';

  @override
  String get focusEmptySubtitle =>
      'When your teacher posts an assignment, you can start a focus session here.';

  @override
  String get focusChooseMode => 'How do you want to focus?';

  @override
  String get focusModePomodoro => 'Pomodoro';

  @override
  String get focusModePomodoroHint => '25 minutes, then a break';

  @override
  String get focusModeFree => 'Free session';

  @override
  String get focusModeFreeHint => 'Count up until you stop';

  @override
  String get focusDoNotDisturb => 'Chat muted';

  @override
  String get focusChatMuteHint =>
      'While a session is active, chat badges stay quiet so you can focus. Notifications still arrive in the background.';

  @override
  String get focusPause => 'Pause';

  @override
  String get focusResume => 'Resume';

  @override
  String get focusPaused => 'Paused';

  @override
  String get focusEndSession => 'End';

  @override
  String get focusSessionComplete => 'Session complete';

  @override
  String get focusSessionCompleteSubtitle => 'Nice work. Here’s a quick recap.';

  @override
  String get focusTimeUp => 'Time’s up!';

  @override
  String get focusTimeUpSubtitle =>
      'Your Pomodoro block finished. Take a short break, then keep going.';

  @override
  String focusMinutesFocused(String duration) {
    return '$duration focused';
  }

  @override
  String get focusOptionalNote => 'Optional note';

  @override
  String get focusOptionalNoteHint => 'e.g. Stuck on task #3';

  @override
  String get focusSaveAndOpen => 'Save & open assignment';

  @override
  String get focusDone => 'Done';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatSearchHint => 'Search groups or teachers';

  @override
  String get chatEmptyTitle => 'No chat rooms yet';

  @override
  String get chatEmptySubtitle => 'Join a group to start messaging your class.';

  @override
  String get chatNoMessagesYet => 'No messages yet';

  @override
  String get chatMessageDeleted => 'Message deleted';

  @override
  String get chatPreviewImage => 'Photo';

  @override
  String get chatPreviewVideo => 'Video';

  @override
  String get chatVideoPlaybackSpeed => 'Playback speed';

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
  String get chatVideoCouldNotPlay => 'Could not play this video';

  @override
  String get chatPreviewVoice => 'Voice message';

  @override
  String get chatPreviewFile => 'File';

  @override
  String get chatOpenFile => 'Tap to open';

  @override
  String get chatOpenFileFailed => 'Could not open this file.';

  @override
  String get chatYou => 'You';

  @override
  String chatTeacherMembers(String teacher, int count) {
    return '$teacher · $count members';
  }

  @override
  String chatOnlineCount(int count) {
    return '$count online';
  }

  @override
  String get chatReact => 'React';

  @override
  String get chatCopyText => 'Copy text';

  @override
  String get chatCopied => 'Copied';

  @override
  String get chatReply => 'Reply';

  @override
  String chatReplyTo(String name) {
    return 'In reply to $name';
  }

  @override
  String get chatReplyDeleted => 'Deleted message';

  @override
  String get chatReplyNotFound => 'Original message isn’t available';

  @override
  String get chatMessageHint => 'Message…';

  @override
  String get chatAttachImage => 'Image';

  @override
  String get chatAttachVideo => 'Video';

  @override
  String get chatAttachFile => 'File';

  @override
  String chatTyping(String names) {
    return '$names typing…';
  }

  @override
  String chatRecording(String time) {
    return 'Recording $time';
  }

  @override
  String chatUploading(String name) {
    return 'Uploading $name…';
  }

  @override
  String chatSendFailed(String error) {
    return 'Could not send: $error';
  }

  @override
  String get chatMicDenied =>
      'Microphone permission is required for voice messages.';

  @override
  String get chatEditTitle => 'Edit message';

  @override
  String get chatDeleteTitle => 'Delete message?';

  @override
  String get chatDeleteBody =>
      'This removes the message for everyone in the room.';

  @override
  String chatDeleteSelectedTitle(int count) {
    return 'Delete $count messages?';
  }

  @override
  String get chatDeleteSelectedBody =>
      'Selected messages will be removed for everyone in the room.';

  @override
  String chatSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get chatSelectMessages => 'Select messages';

  @override
  String get chatSelect => 'Select';

  @override
  String get commonSelectAll => 'Select all';

  @override
  String get chatEdited => 'edited';

  @override
  String get chatDateToday => 'Today';

  @override
  String get chatDateYesterday => 'Yesterday';

  @override
  String get chatRoleAdmin => 'admin';

  @override
  String get chatRoleTeacher => 'teacher';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonError => 'Something went wrong';

  @override
  String commonErrorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String commonCouldNotSave(String error) {
    return 'Could not save: $error';
  }

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get commonSaveDraft => 'Save draft';

  @override
  String get commonOpen => 'Open';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonAssign => 'Assign';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonLoadMore => 'Load more';

  @override
  String get commonExport => 'Export';

  @override
  String commonExportFailed(String error) {
    return 'Could not export: $error';
  }

  @override
  String get marksTermAll => 'All time';

  @override
  String marksTermSemester(String yearRange, int semester) {
    return '$yearRange · Semester $semester';
  }

  @override
  String get marksExportCsv => 'Export CSV';

  @override
  String get marksExportDone => 'Marks exported';

  @override
  String get commonTeacher => 'Teacher';

  @override
  String get commonStudent => 'Student';

  @override
  String get commonAdmin => 'Administrator';

  @override
  String get commonWorkspace => 'Workspace';

  @override
  String get commonNoDueDate => 'No due date';

  @override
  String commonDueDate(String date) {
    return 'Due $date';
  }

  @override
  String get homeworkDueThisWeek => 'Due this week';

  @override
  String get homeworkDueThisWeekSubtitle => 'Overdue and upcoming deadlines';

  @override
  String get homeworkNoDueThisWeek => 'Nothing due this week';

  @override
  String get homeworkNoDueThisWeekSubtitle =>
      'You’re clear until next week’s deadlines.';

  @override
  String homeworkOverdue(String date) {
    return 'Overdue · $date';
  }

  @override
  String get homeworkDueToday => 'Due today';

  @override
  String get homeworkDueTomorrow => 'Due tomorrow';

  @override
  String homeworkDueInDays(int days) {
    return 'Due in $days days';
  }

  @override
  String get homeworkLateBadge => 'Late';

  @override
  String get commonProgress => 'Progress';

  @override
  String get commonSubject => 'Subject';

  @override
  String get commonType => 'Type';

  @override
  String get commonTitle => 'Title';

  @override
  String get commonDescription => 'Description';

  @override
  String get commonGroup => 'Group';

  @override
  String get commonMessage => 'Message';

  @override
  String get commonScore => 'Score';

  @override
  String get commonFeedback => 'Feedback';

  @override
  String get commonStudents => 'Students';

  @override
  String get commonCannotUndo => 'This action cannot be undone.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileNotSignedIn => 'Not signed in';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileAccountSettings => 'Account Settings';

  @override
  String get profileSignOutAdmin => 'Sign out of Admin Console';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileStyle => 'Style';

  @override
  String get profileStyleModern => 'Modern Professional';

  @override
  String get profileStyleNature => 'Nature Paper';

  @override
  String get profileStyleSoftNeu => 'Neumorphism';

  @override
  String get profileStyleMonochrome => 'Monochrome Workspace';

  @override
  String get profileEditName => 'Edit name';

  @override
  String get profileNameUpdated => 'Name updated';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profilePhotoUpdated => 'Photo updated';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileCurrentPassword => 'Current password';

  @override
  String get profileNewPassword => 'New password';

  @override
  String get profileConfirmPassword => 'Confirm new password';

  @override
  String get profilePasswordChanged => 'Password updated';

  @override
  String get profilePasswordMismatch => 'New passwords do not match';

  @override
  String get profilePasswordTooShort => 'Use at least 8 characters';

  @override
  String get profilePasswordHint => 'Ask an admin if you forget your password.';

  @override
  String get profileShortcuts => 'Shortcuts';

  @override
  String get profileYourGroups => 'Your groups';

  @override
  String get profileNoGroups => 'No groups assigned';

  @override
  String profileGroupsCount(int count) {
    return '$count groups';
  }

  @override
  String get profileAverageLabel => 'Term average';

  @override
  String get profileAttendanceLabel => 'Attendance';

  @override
  String get profileShareProgress => 'Share progress report';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileClearCache => 'Clear cached data';

  @override
  String get profileClearCacheWarn1Title => 'Clear cached data?';

  @override
  String get profileClearCacheWarn1Body =>
      'This deletes offline chat messages and downloaded images, videos, voice notes, and files. You will need an internet connection to load them again.';

  @override
  String get profileClearCacheWarn2Title => 'Are you sure?';

  @override
  String get profileClearCacheWarn2Body =>
      'This cannot be undone. Cached chat media will be removed from this device.';

  @override
  String get profileClearCacheConfirm => 'Clear cache';

  @override
  String get profileClearCacheDone => 'Cached data cleared';

  @override
  String profileAppVersion(String version) {
    return 'MU Study · v$version';
  }

  @override
  String get profileSubject => 'Subject';

  @override
  String get greetingMorning => 'Good Morning';

  @override
  String get greetingAfternoon => 'Good Afternoon';

  @override
  String get greetingEvening => 'Good Evening';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get greetingLoadingTitle => 'Good Morning, User';

  @override
  String get greetingLoadingSubtitle => 'Loading your personalized greeting...';

  @override
  String get studentHomeSubtitle => 'Your learning space';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get continueLearningSubtitle => 'Pick up where you left off';

  @override
  String get everythingCompleted => 'Everything is completed.';

  @override
  String get caughtUpToday => 'You\'re all caught up for today.';

  @override
  String get homeworkPack => 'Homework Pack';

  @override
  String get staticTask => 'Static Task';

  @override
  String get staticAssignment => 'Static';

  @override
  String get upcomingAssignments => 'Upcoming Assignments';

  @override
  String get stayOnTrack => 'Stay on track';

  @override
  String get loadingAnnouncements => 'Loading announcements...';

  @override
  String get notificationsCardTitle => 'Notifications';

  @override
  String unreadAlerts(int count) {
    return 'You have $count new alerts';
  }

  @override
  String get upToDate => 'You are up to date';

  @override
  String get announcementsTitle => 'Announcements';

  @override
  String get announcementsSubtitle => 'From your teachers';

  @override
  String get announcementsEmpty => 'No announcements';

  @override
  String get announcementsEmptyTeacher =>
      'Share important updates with your students.';

  @override
  String get announcementsEmptyAdmin =>
      'Platform-wide announcements will appear here.';

  @override
  String get announcementsReadMore => 'Read more';

  @override
  String get announcementsShowLess => 'Show less';

  @override
  String announcementsViewAll(int count) {
    return 'View all ($count)';
  }

  @override
  String get announcementsAll => 'All Announcements';

  @override
  String get announcementsNew => 'New Announcement';

  @override
  String get announcementsPost => 'Post Announcement';

  @override
  String get announcementsEdit => 'Edit Announcement';

  @override
  String get announcementsDeleteTitle => 'Delete announcement?';

  @override
  String get announcementsDeleteBody =>
      'It will be removed for everyone in the group.';

  @override
  String get announcementsByAdmin => 'Administration';

  @override
  String get announcementsShareUpdates => 'Share updates with your groups';

  @override
  String get assignmentsTitle => 'Assignments';

  @override
  String get assignmentsEmpty => 'No assignments';

  @override
  String get assignmentsEmptySubtitle => 'You are all caught up!';

  @override
  String get assignmentsEmptyTeacher =>
      'Create your first assignment to get started.';

  @override
  String get assignmentsLearningPath => 'Learning Path';

  @override
  String get assignmentsActive => 'Active assignments';

  @override
  String get assignmentDetails => 'Assignment Details';

  @override
  String get assignmentNotFound => 'Assignment not found';

  @override
  String get assignmentTasks => 'Tasks';

  @override
  String get assignmentTasksSubtitle => 'Complete all to finish pack';

  @override
  String get assignmentNew => 'New Assignment';

  @override
  String get assignmentManage => 'Manage Assignments';

  @override
  String get assignmentManageSubtitle => 'Create static or homework packs';

  @override
  String get marksTitle => 'My Marks';

  @override
  String get marksOverallAverage => 'Overall average';

  @override
  String get marksNoneYet => 'No marks recorded yet.';

  @override
  String marksBasedOn(String label, int count) {
    return '$label · based on $count marks.';
  }

  @override
  String get marksByCategory => 'By category';

  @override
  String get marksWhereStrongest => 'Where you are strongest';

  @override
  String get marksAll => 'All marks';

  @override
  String get marksNewestFirst => 'Newest first';

  @override
  String get marksEmptyTitle => 'No marks yet';

  @override
  String get marksEmptySubtitle => 'Your teacher\'s marks will appear here.';

  @override
  String get progressReportTitle => 'Progress report';

  @override
  String get progressReportShare => 'Share progress';

  @override
  String get progressReportSharing => 'Preparing report…';

  @override
  String get progressReportDone => 'Progress report ready to share';

  @override
  String progressReportFailed(String error) {
    return 'Could not share progress: $error';
  }

  @override
  String get progressReportNeedGroup =>
      'Join a group to share a progress report.';

  @override
  String get progressReportAttendance => 'Attendance';

  @override
  String get progressReportAttendanceRate => 'Attendance rate';

  @override
  String get progressReportNoAttendance =>
      'No attendance recorded for this term.';

  @override
  String get progressReportSessions => 'sessions';

  @override
  String get progressReportMarksCounted => 'marks';

  @override
  String get progressReportRecentMarks => 'Recent marks';

  @override
  String progressReportGeneratedOn(String date) {
    return 'Generated $date';
  }

  @override
  String get marksNoRecorded => 'No marks recorded';

  @override
  String get marksNoRecordedSubtitle =>
      'Use \"Grade class\" to enter marks in one pass.';

  @override
  String get marksRecent => 'Recent marks';

  @override
  String get marksRecentSubtitle => 'Latest entries across the group';

  @override
  String get marksStudentsHeader => 'Students';

  @override
  String get marksStudentsSubtitle => 'Weighted average of all marks';

  @override
  String get marksNoStudents => 'No students in this group';

  @override
  String get marksNoStudentsSubtitle =>
      'An admin can assign students to your group.';

  @override
  String get marksDeleteTitle => 'Delete mark?';

  @override
  String marksDeleteBody(String title) {
    return '\"$title\" will be removed permanently.';
  }

  @override
  String get marksGradeTheClass => 'Grade the class';

  @override
  String get marksOnePercentEach => 'One percent mark per student';

  @override
  String get marksSaveMarks => 'Save marks';

  @override
  String get marksSaveMark => 'Save mark';

  @override
  String get marksAddMark => 'Add mark';

  @override
  String get marksNothingYet => 'Nothing recorded yet';

  @override
  String get marksAddFirst => 'Add the first mark for this student.';

  @override
  String marksSavedCount(int count) {
    return 'Saved $count marks';
  }

  @override
  String get marksGroupHasNoStudents => 'This group has no students yet.';

  @override
  String get marksTitleHint => 'e.g. Unit 3 test';

  @override
  String marksAverageLine(String percent, String label) {
    return 'Average $percent · $label';
  }

  @override
  String get marksNoMarksYetShort => 'No marks yet';

  @override
  String get marksSummaryStudents => 'Students';

  @override
  String get marksSummaryMarks => 'Marks';

  @override
  String get attendanceTitle => 'Attendance';

  @override
  String get attendanceEmpty => 'No attendance records';

  @override
  String get attendanceNoGroup => 'No group assigned yet';

  @override
  String get attendanceMark => 'Mark Attendance';

  @override
  String get attendanceDailyTracking => 'Daily student tracking';

  @override
  String get attendanceSaved => 'Attendance saved successfully';

  @override
  String get attendanceNoGroups => 'No groups found';

  @override
  String get attendancePresent => 'P — Present';

  @override
  String get attendanceLate => 'L — Late';

  @override
  String get attendanceAbsent => 'A — Absent';

  @override
  String get attendanceExcused => 'E — Excused';

  @override
  String get attendancePresentShort => 'P';

  @override
  String get attendanceLateShort => 'L';

  @override
  String get attendanceAbsentShort => 'A';

  @override
  String get attendanceExcusedShort => 'E';

  @override
  String get attendanceTrend => 'Attendance Trend';

  @override
  String get attendanceOverall => 'Overall distribution';

  @override
  String get analyticsThisWeek => 'This Week';

  @override
  String get analyticsLastWeek => 'Last Week';

  @override
  String analyticsTotalMarks(int count) {
    return 'Total Marks: $count';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'All caught up!';

  @override
  String get notificationsEmptySubtitle => 'No new notifications.';

  @override
  String get notificationsNone => 'No notifications';

  @override
  String get notifKindAssignment => 'New homework';

  @override
  String get notifKindAnnouncement => 'Announcement';

  @override
  String get notifKindGraded => 'Work graded';

  @override
  String get notifKindSubmission => 'New submission';

  @override
  String get notifKindChat => 'Chat message';

  @override
  String get notifKindSystem => 'Update';

  @override
  String get notificationsOpen => 'Open';

  @override
  String get taskTitle => 'Task';

  @override
  String get taskYourAnswer => 'Your answer';

  @override
  String get taskMarkCompleted => 'Mark completed';

  @override
  String get taskAttachment => 'Attachment';

  @override
  String get taskAttachmentHint => 'Add a photo or document to your answer.';

  @override
  String get taskAttachmentHintReady => 'Tap to open · trash to remove.';

  @override
  String get taskImage => 'Image';

  @override
  String get taskImageSubtitle => 'Gallery photo';

  @override
  String get taskFile => 'File';

  @override
  String get taskFileSubtitle => 'PDF or document';

  @override
  String get taskReplaceImage => 'Replace with image';

  @override
  String get taskReplaceFile => 'Replace file';

  @override
  String get taskVoice => 'Voice record';

  @override
  String get taskVoiceHint =>
      'Optional spoken answer — record, play back, then save.';

  @override
  String get taskViewPdf => 'View PDF';

  @override
  String get taskOpenLink => 'Open link';

  @override
  String get taskSubmitted => 'Submitted';

  @override
  String get taskSaved => 'Saved';

  @override
  String taskUploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String taskVoiceUploadFailed(String error) {
    return 'Voice upload failed: $error';
  }

  @override
  String taskCouldNotSave(String error) {
    return 'Could not save: $error';
  }

  @override
  String get voiceTapToRecord => 'Tap the mic to record your answer';

  @override
  String get voiceRecording => 'Recording…';

  @override
  String get voiceNote => 'Voice note';

  @override
  String get voiceTapPlay => 'Tap play to listen';

  @override
  String get voiceRerecord => 'Re-record';

  @override
  String get voiceStudentAnswer => 'Student voice answer';

  @override
  String get voiceMicPermission =>
      'Microphone permission is required to record.';

  @override
  String voiceCouldNotStart(String error) {
    return 'Could not start recording: $error';
  }

  @override
  String voiceCouldNotSave(String error) {
    return 'Could not save recording: $error';
  }

  @override
  String voiceCouldNotPlay(String error) {
    return 'Could not play voice note: $error';
  }

  @override
  String get attachmentCouldNotOpen => 'Could not open this file.';

  @override
  String get attachmentImage => 'Image attachment';

  @override
  String get attachmentFile => 'File attachment';

  @override
  String get attachmentPdf => 'PDF document';

  @override
  String get attachmentTapPreview => 'Tap to preview';

  @override
  String get attachmentTapOpen => 'Tap to open';

  @override
  String get pdfDefaultTitle => 'PDF';

  @override
  String get teacherWorkspace => 'Teacher Workspace';

  @override
  String get teacherQuickActions => 'Quick Actions';

  @override
  String get teacherCreateItems => 'Create new items';

  @override
  String get teacherNewAssignment => 'New Assignment';

  @override
  String get teacherNewAnnouncement => 'New Announcement';

  @override
  String get teacherSubmissions => 'Submissions';

  @override
  String get teacherNoSubmissions => 'No submissions yet';

  @override
  String get teacherNoSubmissionsSubtitle =>
      'Student work will show up here for grading.';

  @override
  String get teacherGradebook => 'Gradebook';

  @override
  String get teacherGradeClass => 'Grade class';

  @override
  String get teacherNoGroups => 'No groups yet';

  @override
  String get teacherNoGroupsSubtitle => 'Ask an admin to assign you a group.';

  @override
  String get teacherActiveGroups => 'ACTIVE GROUPS';

  @override
  String get teacherSubject => 'SUBJECT';

  @override
  String get teacherDailyTasks => 'Daily Tasks';

  @override
  String get teacherNeedsAttention => 'What needs your attention';

  @override
  String get teacherReviewSubmissions => 'Review Submissions';

  @override
  String get teacherCheckAssignments => 'Check student assignments';

  @override
  String get teacherRecordMarks => 'Record marks in percent';

  @override
  String get teacherPerformanceAnalytics => 'Performance Analytics';

  @override
  String get teacherTrackProgress => 'Track group progress';

  @override
  String get teacherOpenAttachment => 'Open attachment';

  @override
  String get teacherScoreHelper => 'Adds a homework mark to the gradebook';

  @override
  String get teacherScoreRange => 'Score must be between 0 and 100.';

  @override
  String get teacherNoWrittenAnswer => 'No written answer.';

  @override
  String get teacherReviewSubmission => 'Review submission';

  @override
  String get teacherHomeworkPackTasks => 'Homework Pack Tasks';

  @override
  String get teacherAddTask => 'Add Task';

  @override
  String get teacherEditTask => 'Edit Task';

  @override
  String get teacherDeleteTask => 'Delete Task?';

  @override
  String get teacherTasksContent => 'Tasks Content';

  @override
  String get teacherManagePack => 'Manage items in this pack';

  @override
  String get teacherTaskTitleHint => 'e.g. Reading Exercise';

  @override
  String get teacherLinkHint => 'https://...';

  @override
  String get teacherAttachmentHint => 'Image or file link...';

  @override
  String get teacherNoData => 'No data available';

  @override
  String get teacherMarkDistribution => 'Mark Distribution';

  @override
  String get teacherStudentsByAverage => 'Students grouped by average';

  @override
  String get teacherNoMarksTrends =>
      'Add marks in the gradebook to see trends.';

  @override
  String get teacherTargetGroup => 'Target Group';

  @override
  String get adminWorkspace => 'Workspace Control';

  @override
  String get adminUsers => 'User Management';

  @override
  String get adminGroups => 'Groups';

  @override
  String get adminAnalytics => 'Analytics';

  @override
  String get adminTeachers => 'TEACHERS';

  @override
  String get adminStudents => 'STUDENTS';

  @override
  String get adminGroupsLabel => 'GROUPS';

  @override
  String get adminMarksLabel => 'MARKS';

  @override
  String get adminActivityInsights => 'Activity Insights';

  @override
  String get adminCurrentMetrics => 'Current metrics';

  @override
  String get adminCreateUser => 'Create New User';

  @override
  String get adminCreateUserButton => 'Create User';

  @override
  String get adminUserCreated => 'User created successfully';

  @override
  String get adminResetPassword => 'Reset password';

  @override
  String adminResetPasswordTitle(String username) {
    return 'Reset Password · $username';
  }

  @override
  String get adminCreateGroup => 'Create New Group';

  @override
  String get adminCreateGroupButton => 'Create Group';

  @override
  String get adminGroupTitleHint => 'e.g. Group 4';

  @override
  String get adminGroupTitleExists =>
      'This teacher already has a group with that name';

  @override
  String get adminAssignStudent => 'Assign Student';

  @override
  String get adminActivityDistribution => 'Activity Distribution';

  @override
  String get adminGlobalMetrics => 'Global platform metrics';

  @override
  String get adminActivityLog => 'Admin Activity Log';

  @override
  String get adminActivityLogSubtitle =>
      'System-wide events and audit logs appear here.';

  @override
  String adminTeacherLine(String name) {
    return 'Teacher: $name';
  }

  @override
  String adminRoleLine(String role, String username) {
    return '$role · $username';
  }

  @override
  String get adminDisable => 'Disable';

  @override
  String get adminEnable => 'Enable';

  @override
  String get adminPassword => 'Password';

  @override
  String get adminFullName => 'Full name';

  @override
  String get adminRole => 'Role';

  @override
  String get adminSphere => 'Sphere';

  @override
  String get percentExcellent => 'Excellent';

  @override
  String get percentGood => 'Good';

  @override
  String get percentNeedsWork => 'Needs work';

  @override
  String get percentAtRisk => 'At risk';

  @override
  String get emptyStateDefault => 'Nothing here yet';

  @override
  String get setupRequiredTitle => 'Setup required';

  @override
  String get setupRequiredBody =>
      'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY to your .env file.';

  @override
  String get setupOption1 => 'Option 1 — local .env file';

  @override
  String get setupOption2 => 'Option 2 — dart-define';

  @override
  String get attendanceAllPresent => 'All P';

  @override
  String get attendanceAllAbsent => 'All A';

  @override
  String get attendanceAllLate => 'All L';

  @override
  String get attendanceAllExcused => 'All E';

  @override
  String get attendancePresentWord => 'Present';

  @override
  String get attendanceAbsentWord => 'Absent';

  @override
  String get attendanceLateWord => 'Late';

  @override
  String get attendanceExcusedWord => 'Excused';

  @override
  String get attendanceWeekdayMon => 'Mon';

  @override
  String get attendanceWeekdayTue => 'Tue';

  @override
  String get attendanceWeekdayWed => 'Wed';

  @override
  String get attendanceWeekdayThu => 'Thu';

  @override
  String get attendanceWeekdayFri => 'Fri';

  @override
  String get attendancePercentLabel => 'Rate';

  @override
  String get attendanceNoLesson => 'No lesson';

  @override
  String get attendanceHistory => 'Attendance history';

  @override
  String get attendanceSelectStudent => 'Student';

  @override
  String get attendanceAllStudents => 'All students';

  @override
  String get attendanceTapToCycle => 'Tap a day to change status';

  @override
  String get attendanceUpdated => 'Attendance updated';

  @override
  String get attendanceCalendarEmpty => 'No attendance in this month';

  @override
  String get attendanceFutureNotAllowed =>
      'You can’t mark attendance for a future day';

  @override
  String get attendanceWeekendNotAllowed =>
      'Attendance can only be marked on weekdays (Mon–Fri)';

  @override
  String get chartBandExcellent => '85–100%';

  @override
  String get chartBandGood => '70–84%';

  @override
  String get chartBandNeedsWork => '50–69%';

  @override
  String get chartBandAtRisk => 'Below 50%';

  @override
  String get marksWeight => 'Weight';

  @override
  String get marksCategory => 'Category';

  @override
  String get marksDate => 'Date';

  @override
  String get marksCommentOptional => 'Comment (optional)';

  @override
  String get marksNewMark => 'New mark';

  @override
  String get marksEditMark => 'Edit mark';

  @override
  String get marksFromSubmission => 'From a graded submission';

  @override
  String get marksNeedTitle => 'Give the graded item a title.';

  @override
  String get marksWeightPositive => 'Weight must be greater than zero.';

  @override
  String get marksNeedAtLeastOne => 'Enter a mark for at least one student.';

  @override
  String get marksLeaveBlankSkip => 'Leave a field blank to skip that student.';

  @override
  String get marksFromSubmissionDelete =>
      'This mark comes from a graded submission. Clear the score in Submissions to remove it.';

  @override
  String get marksFromSubmissionEdit =>
      'This mark mirrors a graded submission. Editing it here will be overwritten the next time the submission is re-graded.';

  @override
  String get categoryHomework => 'Homework';

  @override
  String get categoryClasswork => 'Classwork';

  @override
  String get categoryQuiz => 'Quiz';

  @override
  String get categoryTest => 'Test';

  @override
  String get categoryExam => 'Exam';

  @override
  String get categoryProject => 'Project';

  @override
  String get categoryOral => 'Oral';

  @override
  String get categoryOther => 'Other';

  @override
  String get teacherReferenceLinkOptional => 'Reference Link (optional)';

  @override
  String get teacherAttachmentUrlOptional => 'Attachment URL (optional)';

  @override
  String get teacherNoTasksYet =>
      'No tasks added yet. Click \"Add Task\" to get started.';

  @override
  String get teacherTemplates => 'Templates';

  @override
  String get teacherTemplatesEmpty => 'No templates yet';

  @override
  String get teacherTemplatesEmptySubtitle =>
      'Save an assignment as a template to reuse it later.';

  @override
  String get teacherSaveAsTemplate => 'Save as template';

  @override
  String get teacherTemplateSaved => 'Template saved';

  @override
  String get teacherUseTemplate => 'Use template';

  @override
  String get teacherFromTemplate => 'From template';

  @override
  String get teacherDeleteTemplate => 'Delete template?';

  @override
  String teacherDeleteTemplateBody(String title) {
    return '\"$title\" will be removed.';
  }

  @override
  String get teacherDuplicateAssignment => 'Duplicate';

  @override
  String get teacherDuplicateTitle => 'Duplicate assignment';

  @override
  String get teacherDuplicated => 'Assignment duplicated';

  @override
  String get assignmentEdit => 'Edit assignment';

  @override
  String get assignmentDeleteTitle => 'Delete assignment?';

  @override
  String get assignmentDeleteBody =>
      'This permanently removes the assignment, its tasks, and student submissions.';

  @override
  String get assignmentDeleted => 'Assignment deleted';

  @override
  String get assignmentTypeHintStatic =>
      'A single piece of work. Students submit once — no extra tasks.';

  @override
  String get assignmentTypeHintPack =>
      'A pack of multiple tasks (workbook-style). You’ll add items next.';

  @override
  String get teacherCreateFromTemplate => 'Create from template';

  @override
  String teacherTasksCopied(int count) {
    return '$count tasks included';
  }

  @override
  String get teacherRecentFeedback => 'Reuse feedback';

  @override
  String get teacherApplyFeedbackToOthers =>
      'Also apply to other pending for this task';

  @override
  String teacherFeedbackAppliedCount(int count) {
    return 'Feedback applied to $count other submissions';
  }

  @override
  String get teacherSharedComment => 'Shared comment (optional)';

  @override
  String get teacherSharedCommentHint => 'Same note on every mark you save';

  @override
  String get adminPlatformOverview => 'Platform Overview';

  @override
  String get adminAssignTeacher => 'Assign Teacher';

  @override
  String get adminSelectStudent => 'Select Student';

  @override
  String get adminInitialGroupOptional => 'Initial Group (Optional)';

  @override
  String get adminChartTasks => 'Tasks';

  @override
  String get adminChartGroups => 'Groups';

  @override
  String get adminChartStaff => 'Staff';

  @override
  String get adminChartAssignments => 'Assignments';

  @override
  String get adminChartMarks => 'Marks';

  @override
  String get adminChartStudents => 'Students';

  @override
  String get adminAcademicYears => 'Academic years';

  @override
  String get adminAcademicYearsSubtitle =>
      'School years and semesters for the gradebook';

  @override
  String get adminAcademicYearsTitle => 'Academic calendar';

  @override
  String get adminCreateNextYear => 'Create next year';

  @override
  String adminYearCreated(String label) {
    return 'Created $label';
  }

  @override
  String get adminSetCurrentYear => 'Set as current';

  @override
  String get adminCurrentYearBadge => 'Current';

  @override
  String get adminYearSemesters => 'Four semesters · Aug → Jun';

  @override
  String adminSemesterRange(int semester, String start, String end) {
    return 'Semester $semester · $start – $end';
  }

  @override
  String get adminEditTerm => 'Edit term';

  @override
  String adminEditTermTitle(int semester) {
    return 'Edit semester $semester';
  }

  @override
  String get adminTermStartsOn => 'Starts on';

  @override
  String get adminTermEndsOn => 'Ends on';

  @override
  String get adminTermDatesInvalid =>
      'End date must be on or after the start date';

  @override
  String get adminTermUpdated => 'Term dates updated';

  @override
  String get adminDeleteYear => 'Delete year';

  @override
  String adminDeleteYearTitle(String label) {
    return 'Delete $label?';
  }

  @override
  String adminDeleteYearBody(String label) {
    return 'This removes the year and its four terms from the calendar. Marks are not deleted. To confirm, type $label below.';
  }

  @override
  String adminDeleteYearConfirmHint(String label) {
    return 'Type $label to confirm';
  }

  @override
  String get adminDeleteYearCurrentBlocked =>
      'Set another year as current before deleting this one.';

  @override
  String adminYearDeleted(String label) {
    return 'Deleted $label';
  }

  @override
  String get adminNoAcademicYears => 'No academic years yet';

  @override
  String get adminAcademicYearsHint =>
      'Create the next school year when you are ready. Teachers and students pick semesters in the gradebook. Tap a term to edit its dates.';

  @override
  String get adminCredentialPrintTitle => 'Print login slips';

  @override
  String get adminCredentialPrintSubtitle =>
      'Unique usernames and passwords from the database, 3 slips per page';

  @override
  String get adminCredentialPasteLabel => 'Users';

  @override
  String get adminCredentialPasteHint =>
      'username|password|full name\n@james|Abc123xyz|James English|teacher\n@john_jones|Pass456|John Jones';

  @override
  String get adminCredentialPerPage => 'Slips per page';

  @override
  String get adminCredentialTwo => '2';

  @override
  String get adminCredentialThree => '3';

  @override
  String get adminCredentialExportPdf => 'Export PDF';

  @override
  String get adminCredentialSlipTitle => 'Your MU Study login';

  @override
  String get adminCredentialSlipHint =>
      'Keep this paper private. Change your password after first sign-in.';

  @override
  String get adminCredentialNeedUsers => 'No users found to print';

  @override
  String get adminCredentialNeedSql =>
      'Run sql/admin_login_slips.sql in the Supabase SQL Editor, then export again.';

  @override
  String get adminCredentialConfidential =>
      'Private and confidential. These credentials are intended only for the assigned student.';

  @override
  String get adminFirstName => 'First name';

  @override
  String get adminLastName => 'Last name';

  @override
  String get adminCredentialStudents => 'Students';

  @override
  String get adminCredentialTeachers => 'Teachers';

  @override
  String get adminCredentialAllGroups => 'All groups';

  @override
  String get sphereMath => 'Math';

  @override
  String get sphereEnglish => 'English';

  @override
  String get dailyMotivation1 => 'Today is a great day to make progress.';

  @override
  String get dailyMotivation2 => 'Ready to continue where you left off?';

  @override
  String get dailyMotivation3 => 'Let\'s conquer your goals today.';

  @override
  String get dailyMotivation4 => 'Consistency is the key to mastery.';
}
