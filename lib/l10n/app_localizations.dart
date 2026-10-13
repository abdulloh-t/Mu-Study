import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MU Study'**
  String get appName;

  /// No description provided for @shellMuStudy.
  ///
  /// In en, this message translates to:
  /// **'MU Study'**
  String get shellMuStudy;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Profile.'**
  String get languageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageUzbek.
  ///
  /// In en, this message translates to:
  /// **'Uzbek'**
  String get languageUzbek;

  /// No description provided for @languageEnglishNative.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishNative;

  /// No description provided for @languageRussianNative.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussianNative;

  /// No description provided for @languageUzbekNative.
  ///
  /// In en, this message translates to:
  /// **'O‘zbekcha'**
  String get languageUzbekNative;

  /// No description provided for @languageContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get languageContinue;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @languageHint.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languageHint;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your MU Study workspace'**
  String get loginSubtitle;

  /// No description provided for @loginUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginUsername;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignIn;

  /// No description provided for @loginMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter both username and password'**
  String get loginMissingFields;

  /// No description provided for @loginIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password'**
  String get loginIncorrect;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Check your connection and try again.'**
  String get loginFailed;

  /// No description provided for @loginConfigError.
  ///
  /// In en, this message translates to:
  /// **'Invalid configuration. Contact support.'**
  String get loginConfigError;

  /// No description provided for @loginConfigMissing.
  ///
  /// In en, this message translates to:
  /// **'Configuration missing. Check your .env file.'**
  String get loginConfigMissing;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'Account disabled. Contact admin.'**
  String get accountDisabled;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get navAssignments;

  /// No description provided for @navMarks.
  ///
  /// In en, this message translates to:
  /// **'Marks'**
  String get navMarks;

  /// No description provided for @navAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get navAttendance;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get navUsers;

  /// No description provided for @navGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get navGroups;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navGradebook.
  ///
  /// In en, this message translates to:
  /// **'Gradebook'**
  String get navGradebook;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get navFocus;

  /// No description provided for @focusTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusTitle;

  /// No description provided for @focusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet study time for one assignment at a time.'**
  String get focusSubtitle;

  /// No description provided for @focusTodaysFocus.
  ///
  /// In en, this message translates to:
  /// **'Today’s focus'**
  String get focusTodaysFocus;

  /// No description provided for @focusTodaysFocusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to three open assignments — any due date'**
  String get focusTodaysFocusSubtitle;

  /// No description provided for @focusAlsoDue.
  ///
  /// In en, this message translates to:
  /// **'More homework'**
  String get focusAlsoDue;

  /// No description provided for @focusContinueHomework.
  ///
  /// In en, this message translates to:
  /// **'Continue homework'**
  String get focusContinueHomework;

  /// No description provided for @focusOpenAssignment.
  ///
  /// In en, this message translates to:
  /// **'Open assignment'**
  String get focusOpenAssignment;

  /// No description provided for @focusEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No homework yet'**
  String get focusEmptyTitle;

  /// No description provided for @focusEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'When your teacher posts an assignment, you can start a focus session here.'**
  String get focusEmptySubtitle;

  /// No description provided for @focusChooseMode.
  ///
  /// In en, this message translates to:
  /// **'How do you want to focus?'**
  String get focusChooseMode;

  /// No description provided for @focusModePomodoro.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get focusModePomodoro;

  /// No description provided for @focusModePomodoroHint.
  ///
  /// In en, this message translates to:
  /// **'25 minutes, then a break'**
  String get focusModePomodoroHint;

  /// No description provided for @focusModeFree.
  ///
  /// In en, this message translates to:
  /// **'Free session'**
  String get focusModeFree;

  /// No description provided for @focusModeFreeHint.
  ///
  /// In en, this message translates to:
  /// **'Count up until you stop'**
  String get focusModeFreeHint;

  /// No description provided for @focusDoNotDisturb.
  ///
  /// In en, this message translates to:
  /// **'Chat muted'**
  String get focusDoNotDisturb;

  /// No description provided for @focusChatMuteHint.
  ///
  /// In en, this message translates to:
  /// **'While a session is active, chat badges stay quiet so you can focus. Notifications still arrive in the background.'**
  String get focusChatMuteHint;

  /// No description provided for @focusPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get focusPause;

  /// No description provided for @focusResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get focusResume;

  /// No description provided for @focusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get focusPaused;

  /// No description provided for @focusEndSession.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get focusEndSession;

  /// No description provided for @focusSessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get focusSessionComplete;

  /// No description provided for @focusSessionCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nice work. Here’s a quick recap.'**
  String get focusSessionCompleteSubtitle;

  /// No description provided for @focusTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time’s up!'**
  String get focusTimeUp;

  /// No description provided for @focusTimeUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Pomodoro block finished. Take a short break, then keep going.'**
  String get focusTimeUpSubtitle;

  /// No description provided for @focusMinutesFocused.
  ///
  /// In en, this message translates to:
  /// **'{duration} focused'**
  String focusMinutesFocused(String duration);

  /// No description provided for @focusOptionalNote.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get focusOptionalNote;

  /// No description provided for @focusOptionalNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Stuck on task #3'**
  String get focusOptionalNoteHint;

  /// No description provided for @focusSaveAndOpen.
  ///
  /// In en, this message translates to:
  /// **'Save & open assignment'**
  String get focusSaveAndOpen;

  /// No description provided for @focusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get focusDone;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @chatSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search groups or teachers'**
  String get chatSearchHint;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No chat rooms yet'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join a group to start messaging your class.'**
  String get chatEmptySubtitle;

  /// No description provided for @chatNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chatNoMessagesYet;

  /// No description provided for @chatMessageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get chatMessageDeleted;

  /// No description provided for @chatPreviewImage.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get chatPreviewImage;

  /// No description provided for @chatPreviewVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get chatPreviewVideo;

  /// No description provided for @chatVideoPlaybackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get chatVideoPlaybackSpeed;

  /// No description provided for @chatVideoSpeedNormal.
  ///
  /// In en, this message translates to:
  /// **'1x'**
  String get chatVideoSpeedNormal;

  /// No description provided for @chatVideoSpeedValue.
  ///
  /// In en, this message translates to:
  /// **'{speed}x'**
  String chatVideoSpeedValue(double speed);

  /// No description provided for @chatVideoRewind10.
  ///
  /// In en, this message translates to:
  /// **'-10s'**
  String get chatVideoRewind10;

  /// No description provided for @chatVideoForward10.
  ///
  /// In en, this message translates to:
  /// **'+10s'**
  String get chatVideoForward10;

  /// No description provided for @chatVideoCouldNotPlay.
  ///
  /// In en, this message translates to:
  /// **'Could not play this video'**
  String get chatVideoCouldNotPlay;

  /// No description provided for @chatPreviewVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get chatPreviewVoice;

  /// No description provided for @chatPreviewFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get chatPreviewFile;

  /// No description provided for @chatOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get chatOpenFile;

  /// No description provided for @chatOpenFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open this file.'**
  String get chatOpenFileFailed;

  /// No description provided for @chatYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chatYou;

  /// No description provided for @chatTeacherMembers.
  ///
  /// In en, this message translates to:
  /// **'{teacher} · {count} members'**
  String chatTeacherMembers(String teacher, int count);

  /// No description provided for @chatOnlineCount.
  ///
  /// In en, this message translates to:
  /// **'{count} online'**
  String chatOnlineCount(int count);

  /// No description provided for @chatReact.
  ///
  /// In en, this message translates to:
  /// **'React'**
  String get chatReact;

  /// No description provided for @chatCopyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get chatCopyText;

  /// No description provided for @chatCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get chatCopied;

  /// No description provided for @chatReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get chatReply;

  /// No description provided for @chatReplyTo.
  ///
  /// In en, this message translates to:
  /// **'In reply to {name}'**
  String chatReplyTo(String name);

  /// No description provided for @chatReplyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted message'**
  String get chatReplyDeleted;

  /// No description provided for @chatReplyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Original message isn’t available'**
  String get chatReplyNotFound;

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message…'**
  String get chatMessageHint;

  /// No description provided for @chatAttachImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get chatAttachImage;

  /// No description provided for @chatAttachVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get chatAttachVideo;

  /// No description provided for @chatAttachFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get chatAttachFile;

  /// No description provided for @chatTyping.
  ///
  /// In en, this message translates to:
  /// **'{names} typing…'**
  String chatTyping(String names);

  /// No description provided for @chatRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording {time}'**
  String chatRecording(String time);

  /// No description provided for @chatUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading {name}…'**
  String chatUploading(String name);

  /// No description provided for @chatSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send: {error}'**
  String chatSendFailed(String error);

  /// No description provided for @chatMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice messages.'**
  String get chatMicDenied;

  /// No description provided for @chatEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get chatEditTitle;

  /// No description provided for @chatDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete message?'**
  String get chatDeleteTitle;

  /// No description provided for @chatDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the message for everyone in the room.'**
  String get chatDeleteBody;

  /// No description provided for @chatDeleteSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} messages?'**
  String chatDeleteSelectedTitle(int count);

  /// No description provided for @chatDeleteSelectedBody.
  ///
  /// In en, this message translates to:
  /// **'Selected messages will be removed for everyone in the room.'**
  String get chatDeleteSelectedBody;

  /// No description provided for @chatSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String chatSelectedCount(int count);

  /// No description provided for @chatSelectMessages.
  ///
  /// In en, this message translates to:
  /// **'Select messages'**
  String get chatSelectMessages;

  /// No description provided for @chatSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get chatSelect;

  /// No description provided for @commonSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get commonSelectAll;

  /// No description provided for @chatEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get chatEdited;

  /// No description provided for @chatDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatDateToday;

  /// No description provided for @chatDateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatDateYesterday;

  /// No description provided for @chatRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'admin'**
  String get chatRoleAdmin;

  /// No description provided for @chatRoleTeacher.
  ///
  /// In en, this message translates to:
  /// **'teacher'**
  String get chatRoleTeacher;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @commonErrorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String commonErrorWithDetails(String error);

  /// No description provided for @commonCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String commonCouldNotSave(String error);

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// No description provided for @commonSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get commonSaveDraft;

  /// No description provided for @commonOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get commonOpen;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get commonAssign;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get commonLoadMore;

  /// No description provided for @commonExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get commonExport;

  /// No description provided for @commonExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export: {error}'**
  String commonExportFailed(String error);

  /// No description provided for @marksTermAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get marksTermAll;

  /// No description provided for @marksTermSemester.
  ///
  /// In en, this message translates to:
  /// **'{yearRange} · Semester {semester}'**
  String marksTermSemester(String yearRange, int semester);

  /// No description provided for @marksExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get marksExportCsv;

  /// No description provided for @marksExportDone.
  ///
  /// In en, this message translates to:
  /// **'Marks exported'**
  String get marksExportDone;

  /// No description provided for @commonTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get commonTeacher;

  /// No description provided for @commonStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get commonStudent;

  /// No description provided for @commonAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get commonAdmin;

  /// No description provided for @commonWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get commonWorkspace;

  /// No description provided for @commonNoDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get commonNoDueDate;

  /// No description provided for @commonDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String commonDueDate(String date);

  /// No description provided for @homeworkDueThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Due this week'**
  String get homeworkDueThisWeek;

  /// No description provided for @homeworkDueThisWeekSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overdue and upcoming deadlines'**
  String get homeworkDueThisWeekSubtitle;

  /// No description provided for @homeworkNoDueThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Nothing due this week'**
  String get homeworkNoDueThisWeek;

  /// No description provided for @homeworkNoDueThisWeekSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You’re clear until next week’s deadlines.'**
  String get homeworkNoDueThisWeekSubtitle;

  /// No description provided for @homeworkOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue · {date}'**
  String homeworkOverdue(String date);

  /// No description provided for @homeworkDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get homeworkDueToday;

  /// No description provided for @homeworkDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get homeworkDueTomorrow;

  /// No description provided for @homeworkDueInDays.
  ///
  /// In en, this message translates to:
  /// **'Due in {days} days'**
  String homeworkDueInDays(int days);

  /// No description provided for @homeworkLateBadge.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get homeworkLateBadge;

  /// No description provided for @commonProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get commonProgress;

  /// No description provided for @commonSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get commonSubject;

  /// No description provided for @commonType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get commonType;

  /// No description provided for @commonTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get commonTitle;

  /// No description provided for @commonDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get commonDescription;

  /// No description provided for @commonGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get commonGroup;

  /// No description provided for @commonMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get commonMessage;

  /// No description provided for @commonScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get commonScore;

  /// No description provided for @commonFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get commonFeedback;

  /// No description provided for @commonStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get commonStudents;

  /// No description provided for @commonCannotUndo.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get commonCannotUndo;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullName;

  /// No description provided for @profileNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get profileNotSignedIn;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get profileAccountSettings;

  /// No description provided for @profileSignOutAdmin.
  ///
  /// In en, this message translates to:
  /// **'Sign out of Admin Console'**
  String get profileSignOutAdmin;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get profileStyle;

  /// No description provided for @profileStyleModern.
  ///
  /// In en, this message translates to:
  /// **'Modern Professional'**
  String get profileStyleModern;

  /// No description provided for @profileStyleNature.
  ///
  /// In en, this message translates to:
  /// **'Nature Paper'**
  String get profileStyleNature;

  /// No description provided for @profileStyleSoftNeu.
  ///
  /// In en, this message translates to:
  /// **'Neumorphism'**
  String get profileStyleSoftNeu;

  /// No description provided for @profileStyleMonochrome.
  ///
  /// In en, this message translates to:
  /// **'Monochrome Workspace'**
  String get profileStyleMonochrome;

  /// No description provided for @profileEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get profileEditName;

  /// No description provided for @profileNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get profileNameUpdated;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated'**
  String get profilePhotoUpdated;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profileCurrentPassword;

  /// No description provided for @profileNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get profileNewPassword;

  /// No description provided for @profileConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get profileConfirmPassword;

  /// No description provided for @profilePasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get profilePasswordChanged;

  /// No description provided for @profilePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get profilePasswordMismatch;

  /// No description provided for @profilePasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get profilePasswordTooShort;

  /// No description provided for @profilePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Ask an admin if you forget your password.'**
  String get profilePasswordHint;

  /// No description provided for @profileShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get profileShortcuts;

  /// No description provided for @profileYourGroups.
  ///
  /// In en, this message translates to:
  /// **'Your groups'**
  String get profileYourGroups;

  /// No description provided for @profileNoGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups assigned'**
  String get profileNoGroups;

  /// No description provided for @profileGroupsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} groups'**
  String profileGroupsCount(int count);

  /// No description provided for @profileAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Term average'**
  String get profileAverageLabel;

  /// No description provided for @profileAttendanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get profileAttendanceLabel;

  /// No description provided for @profileShareProgress.
  ///
  /// In en, this message translates to:
  /// **'Share progress report'**
  String get profileShareProgress;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cached data'**
  String get profileClearCache;

  /// No description provided for @profileClearCacheWarn1Title.
  ///
  /// In en, this message translates to:
  /// **'Clear cached data?'**
  String get profileClearCacheWarn1Title;

  /// No description provided for @profileClearCacheWarn1Body.
  ///
  /// In en, this message translates to:
  /// **'This deletes offline chat messages and downloaded images, videos, voice notes, and files. You will need an internet connection to load them again.'**
  String get profileClearCacheWarn1Body;

  /// No description provided for @profileClearCacheWarn2Title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get profileClearCacheWarn2Title;

  /// No description provided for @profileClearCacheWarn2Body.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Cached chat media will be removed from this device.'**
  String get profileClearCacheWarn2Body;

  /// No description provided for @profileClearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get profileClearCacheConfirm;

  /// No description provided for @profileClearCacheDone.
  ///
  /// In en, this message translates to:
  /// **'Cached data cleared'**
  String get profileClearCacheDone;

  /// No description provided for @profileAppVersion.
  ///
  /// In en, this message translates to:
  /// **'MU Study · v{version}'**
  String profileAppVersion(String version);

  /// No description provided for @profileSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get profileSubject;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greetingEvening;

  /// No description provided for @greetingWithName.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @greetingLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Morning, User'**
  String get greetingLoadingTitle;

  /// No description provided for @greetingLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Loading your personalized greeting...'**
  String get greetingLoadingSubtitle;

  /// No description provided for @studentHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your learning space'**
  String get studentHomeSubtitle;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @continueLearningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get continueLearningSubtitle;

  /// No description provided for @everythingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Everything is completed.'**
  String get everythingCompleted;

  /// No description provided for @caughtUpToday.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up for today.'**
  String get caughtUpToday;

  /// No description provided for @homeworkPack.
  ///
  /// In en, this message translates to:
  /// **'Homework Pack'**
  String get homeworkPack;

  /// No description provided for @staticTask.
  ///
  /// In en, this message translates to:
  /// **'Static Task'**
  String get staticTask;

  /// No description provided for @staticAssignment.
  ///
  /// In en, this message translates to:
  /// **'Static'**
  String get staticAssignment;

  /// No description provided for @upcomingAssignments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Assignments'**
  String get upcomingAssignments;

  /// No description provided for @stayOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Stay on track'**
  String get stayOnTrack;

  /// No description provided for @loadingAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Loading announcements...'**
  String get loadingAnnouncements;

  /// No description provided for @notificationsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsCardTitle;

  /// No description provided for @unreadAlerts.
  ///
  /// In en, this message translates to:
  /// **'You have {count} new alerts'**
  String unreadAlerts(int count);

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'You are up to date'**
  String get upToDate;

  /// No description provided for @announcementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcementsTitle;

  /// No description provided for @announcementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From your teachers'**
  String get announcementsSubtitle;

  /// No description provided for @announcementsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No announcements'**
  String get announcementsEmpty;

  /// No description provided for @announcementsEmptyTeacher.
  ///
  /// In en, this message translates to:
  /// **'Share important updates with your students.'**
  String get announcementsEmptyTeacher;

  /// No description provided for @announcementsEmptyAdmin.
  ///
  /// In en, this message translates to:
  /// **'Platform-wide announcements will appear here.'**
  String get announcementsEmptyAdmin;

  /// No description provided for @announcementsReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get announcementsReadMore;

  /// No description provided for @announcementsShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get announcementsShowLess;

  /// No description provided for @announcementsViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all ({count})'**
  String announcementsViewAll(int count);

  /// No description provided for @announcementsAll.
  ///
  /// In en, this message translates to:
  /// **'All Announcements'**
  String get announcementsAll;

  /// No description provided for @announcementsNew.
  ///
  /// In en, this message translates to:
  /// **'New Announcement'**
  String get announcementsNew;

  /// No description provided for @announcementsPost.
  ///
  /// In en, this message translates to:
  /// **'Post Announcement'**
  String get announcementsPost;

  /// No description provided for @announcementsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Announcement'**
  String get announcementsEdit;

  /// No description provided for @announcementsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete announcement?'**
  String get announcementsDeleteTitle;

  /// No description provided for @announcementsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed for everyone in the group.'**
  String get announcementsDeleteBody;

  /// No description provided for @announcementsByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get announcementsByAdmin;

  /// No description provided for @announcementsShareUpdates.
  ///
  /// In en, this message translates to:
  /// **'Share updates with your groups'**
  String get announcementsShareUpdates;

  /// No description provided for @assignmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assignmentsTitle;

  /// No description provided for @assignmentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No assignments'**
  String get assignmentsEmpty;

  /// No description provided for @assignmentsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up!'**
  String get assignmentsEmptySubtitle;

  /// No description provided for @assignmentsEmptyTeacher.
  ///
  /// In en, this message translates to:
  /// **'Create your first assignment to get started.'**
  String get assignmentsEmptyTeacher;

  /// No description provided for @assignmentsLearningPath.
  ///
  /// In en, this message translates to:
  /// **'Learning Path'**
  String get assignmentsLearningPath;

  /// No description provided for @assignmentsActive.
  ///
  /// In en, this message translates to:
  /// **'Active assignments'**
  String get assignmentsActive;

  /// No description provided for @assignmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Assignment Details'**
  String get assignmentDetails;

  /// No description provided for @assignmentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Assignment not found'**
  String get assignmentNotFound;

  /// No description provided for @assignmentTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get assignmentTasks;

  /// No description provided for @assignmentTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete all to finish pack'**
  String get assignmentTasksSubtitle;

  /// No description provided for @assignmentNew.
  ///
  /// In en, this message translates to:
  /// **'New Assignment'**
  String get assignmentNew;

  /// No description provided for @assignmentManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Assignments'**
  String get assignmentManage;

  /// No description provided for @assignmentManageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create static or homework packs'**
  String get assignmentManageSubtitle;

  /// No description provided for @marksTitle.
  ///
  /// In en, this message translates to:
  /// **'My Marks'**
  String get marksTitle;

  /// No description provided for @marksOverallAverage.
  ///
  /// In en, this message translates to:
  /// **'Overall average'**
  String get marksOverallAverage;

  /// No description provided for @marksNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No marks recorded yet.'**
  String get marksNoneYet;

  /// No description provided for @marksBasedOn.
  ///
  /// In en, this message translates to:
  /// **'{label} · based on {count} marks.'**
  String marksBasedOn(String label, int count);

  /// No description provided for @marksByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get marksByCategory;

  /// No description provided for @marksWhereStrongest.
  ///
  /// In en, this message translates to:
  /// **'Where you are strongest'**
  String get marksWhereStrongest;

  /// No description provided for @marksAll.
  ///
  /// In en, this message translates to:
  /// **'All marks'**
  String get marksAll;

  /// No description provided for @marksNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get marksNewestFirst;

  /// No description provided for @marksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No marks yet'**
  String get marksEmptyTitle;

  /// No description provided for @marksEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your teacher\'s marks will appear here.'**
  String get marksEmptySubtitle;

  /// No description provided for @progressReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress report'**
  String get progressReportTitle;

  /// No description provided for @progressReportShare.
  ///
  /// In en, this message translates to:
  /// **'Share progress'**
  String get progressReportShare;

  /// No description provided for @progressReportSharing.
  ///
  /// In en, this message translates to:
  /// **'Preparing report…'**
  String get progressReportSharing;

  /// No description provided for @progressReportDone.
  ///
  /// In en, this message translates to:
  /// **'Progress report ready to share'**
  String get progressReportDone;

  /// No description provided for @progressReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share progress: {error}'**
  String progressReportFailed(String error);

  /// No description provided for @progressReportNeedGroup.
  ///
  /// In en, this message translates to:
  /// **'Join a group to share a progress report.'**
  String get progressReportNeedGroup;

  /// No description provided for @progressReportAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get progressReportAttendance;

  /// No description provided for @progressReportAttendanceRate.
  ///
  /// In en, this message translates to:
  /// **'Attendance rate'**
  String get progressReportAttendanceRate;

  /// No description provided for @progressReportNoAttendance.
  ///
  /// In en, this message translates to:
  /// **'No attendance recorded for this term.'**
  String get progressReportNoAttendance;

  /// No description provided for @progressReportSessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get progressReportSessions;

  /// No description provided for @progressReportMarksCounted.
  ///
  /// In en, this message translates to:
  /// **'marks'**
  String get progressReportMarksCounted;

  /// No description provided for @progressReportRecentMarks.
  ///
  /// In en, this message translates to:
  /// **'Recent marks'**
  String get progressReportRecentMarks;

  /// No description provided for @progressReportGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated {date}'**
  String progressReportGeneratedOn(String date);

  /// No description provided for @marksNoRecorded.
  ///
  /// In en, this message translates to:
  /// **'No marks recorded'**
  String get marksNoRecorded;

  /// No description provided for @marksNoRecordedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use \"Grade class\" to enter marks in one pass.'**
  String get marksNoRecordedSubtitle;

  /// No description provided for @marksRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent marks'**
  String get marksRecent;

  /// No description provided for @marksRecentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Latest entries across the group'**
  String get marksRecentSubtitle;

  /// No description provided for @marksStudentsHeader.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get marksStudentsHeader;

  /// No description provided for @marksStudentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weighted average of all marks'**
  String get marksStudentsSubtitle;

  /// No description provided for @marksNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students in this group'**
  String get marksNoStudents;

  /// No description provided for @marksNoStudentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An admin can assign students to your group.'**
  String get marksNoStudentsSubtitle;

  /// No description provided for @marksDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete mark?'**
  String get marksDeleteTitle;

  /// No description provided for @marksDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed permanently.'**
  String marksDeleteBody(String title);

  /// No description provided for @marksGradeTheClass.
  ///
  /// In en, this message translates to:
  /// **'Grade the class'**
  String get marksGradeTheClass;

  /// No description provided for @marksOnePercentEach.
  ///
  /// In en, this message translates to:
  /// **'One percent mark per student'**
  String get marksOnePercentEach;

  /// No description provided for @marksSaveMarks.
  ///
  /// In en, this message translates to:
  /// **'Save marks'**
  String get marksSaveMarks;

  /// No description provided for @marksSaveMark.
  ///
  /// In en, this message translates to:
  /// **'Save mark'**
  String get marksSaveMark;

  /// No description provided for @marksAddMark.
  ///
  /// In en, this message translates to:
  /// **'Add mark'**
  String get marksAddMark;

  /// No description provided for @marksNothingYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet'**
  String get marksNothingYet;

  /// No description provided for @marksAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add the first mark for this student.'**
  String get marksAddFirst;

  /// No description provided for @marksSavedCount.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} marks'**
  String marksSavedCount(int count);

  /// No description provided for @marksGroupHasNoStudents.
  ///
  /// In en, this message translates to:
  /// **'This group has no students yet.'**
  String get marksGroupHasNoStudents;

  /// No description provided for @marksTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Unit 3 test'**
  String get marksTitleHint;

  /// No description provided for @marksAverageLine.
  ///
  /// In en, this message translates to:
  /// **'Average {percent} · {label}'**
  String marksAverageLine(String percent, String label);

  /// No description provided for @marksNoMarksYetShort.
  ///
  /// In en, this message translates to:
  /// **'No marks yet'**
  String get marksNoMarksYetShort;

  /// No description provided for @marksSummaryStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get marksSummaryStudents;

  /// No description provided for @marksSummaryMarks.
  ///
  /// In en, this message translates to:
  /// **'Marks'**
  String get marksSummaryMarks;

  /// No description provided for @attendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendanceTitle;

  /// No description provided for @attendanceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No attendance records'**
  String get attendanceEmpty;

  /// No description provided for @attendanceNoGroup.
  ///
  /// In en, this message translates to:
  /// **'No group assigned yet'**
  String get attendanceNoGroup;

  /// No description provided for @attendanceMark.
  ///
  /// In en, this message translates to:
  /// **'Mark Attendance'**
  String get attendanceMark;

  /// No description provided for @attendanceDailyTracking.
  ///
  /// In en, this message translates to:
  /// **'Daily student tracking'**
  String get attendanceDailyTracking;

  /// No description provided for @attendanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Attendance saved successfully'**
  String get attendanceSaved;

  /// No description provided for @attendanceNoGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups found'**
  String get attendanceNoGroups;

  /// No description provided for @attendancePresent.
  ///
  /// In en, this message translates to:
  /// **'P — Present'**
  String get attendancePresent;

  /// No description provided for @attendanceLate.
  ///
  /// In en, this message translates to:
  /// **'L — Late'**
  String get attendanceLate;

  /// No description provided for @attendanceAbsent.
  ///
  /// In en, this message translates to:
  /// **'A — Absent'**
  String get attendanceAbsent;

  /// No description provided for @attendanceExcused.
  ///
  /// In en, this message translates to:
  /// **'E — Excused'**
  String get attendanceExcused;

  /// No description provided for @attendancePresentShort.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get attendancePresentShort;

  /// No description provided for @attendanceLateShort.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get attendanceLateShort;

  /// No description provided for @attendanceAbsentShort.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get attendanceAbsentShort;

  /// No description provided for @attendanceExcusedShort.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get attendanceExcusedShort;

  /// No description provided for @attendanceTrend.
  ///
  /// In en, this message translates to:
  /// **'Attendance Trend'**
  String get attendanceTrend;

  /// No description provided for @attendanceOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall distribution'**
  String get attendanceOverall;

  /// No description provided for @analyticsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get analyticsThisWeek;

  /// No description provided for @analyticsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get analyticsLastWeek;

  /// No description provided for @analyticsTotalMarks.
  ///
  /// In en, this message translates to:
  /// **'Total Marks: {count}'**
  String analyticsTotalMarks(int count);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No new notifications.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsNone.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsNone;

  /// No description provided for @notifKindAssignment.
  ///
  /// In en, this message translates to:
  /// **'New homework'**
  String get notifKindAssignment;

  /// No description provided for @notifKindAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get notifKindAnnouncement;

  /// No description provided for @notifKindGraded.
  ///
  /// In en, this message translates to:
  /// **'Work graded'**
  String get notifKindGraded;

  /// No description provided for @notifKindSubmission.
  ///
  /// In en, this message translates to:
  /// **'New submission'**
  String get notifKindSubmission;

  /// No description provided for @notifKindChat.
  ///
  /// In en, this message translates to:
  /// **'Chat message'**
  String get notifKindChat;

  /// No description provided for @notifKindSystem.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get notifKindSystem;

  /// No description provided for @notificationsOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get notificationsOpen;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskTitle;

  /// No description provided for @taskYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get taskYourAnswer;

  /// No description provided for @taskMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get taskMarkCompleted;

  /// No description provided for @taskAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get taskAttachment;

  /// No description provided for @taskAttachmentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a photo or document to your answer.'**
  String get taskAttachmentHint;

  /// No description provided for @taskAttachmentHintReady.
  ///
  /// In en, this message translates to:
  /// **'Tap to open · trash to remove.'**
  String get taskAttachmentHintReady;

  /// No description provided for @taskImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get taskImage;

  /// No description provided for @taskImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery photo'**
  String get taskImageSubtitle;

  /// No description provided for @taskFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get taskFile;

  /// No description provided for @taskFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PDF or document'**
  String get taskFileSubtitle;

  /// No description provided for @taskReplaceImage.
  ///
  /// In en, this message translates to:
  /// **'Replace with image'**
  String get taskReplaceImage;

  /// No description provided for @taskReplaceFile.
  ///
  /// In en, this message translates to:
  /// **'Replace file'**
  String get taskReplaceFile;

  /// No description provided for @taskVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice record'**
  String get taskVoice;

  /// No description provided for @taskVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Optional spoken answer — record, play back, then save.'**
  String get taskVoiceHint;

  /// No description provided for @taskViewPdf.
  ///
  /// In en, this message translates to:
  /// **'View PDF'**
  String get taskViewPdf;

  /// No description provided for @taskOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get taskOpenLink;

  /// No description provided for @taskSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get taskSubmitted;

  /// No description provided for @taskSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get taskSaved;

  /// No description provided for @taskUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String taskUploadFailed(String error);

  /// No description provided for @taskVoiceUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Voice upload failed: {error}'**
  String taskVoiceUploadFailed(String error);

  /// No description provided for @taskCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String taskCouldNotSave(String error);

  /// No description provided for @voiceTapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic to record your answer'**
  String get voiceTapToRecord;

  /// No description provided for @voiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get voiceRecording;

  /// No description provided for @voiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get voiceNote;

  /// No description provided for @voiceTapPlay.
  ///
  /// In en, this message translates to:
  /// **'Tap play to listen'**
  String get voiceTapPlay;

  /// No description provided for @voiceRerecord.
  ///
  /// In en, this message translates to:
  /// **'Re-record'**
  String get voiceRerecord;

  /// No description provided for @voiceStudentAnswer.
  ///
  /// In en, this message translates to:
  /// **'Student voice answer'**
  String get voiceStudentAnswer;

  /// No description provided for @voiceMicPermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record.'**
  String get voiceMicPermission;

  /// No description provided for @voiceCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Could not start recording: {error}'**
  String voiceCouldNotStart(String error);

  /// No description provided for @voiceCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save recording: {error}'**
  String voiceCouldNotSave(String error);

  /// No description provided for @voiceCouldNotPlay.
  ///
  /// In en, this message translates to:
  /// **'Could not play voice note: {error}'**
  String voiceCouldNotPlay(String error);

  /// No description provided for @attachmentCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open this file.'**
  String get attachmentCouldNotOpen;

  /// No description provided for @attachmentImage.
  ///
  /// In en, this message translates to:
  /// **'Image attachment'**
  String get attachmentImage;

  /// No description provided for @attachmentFile.
  ///
  /// In en, this message translates to:
  /// **'File attachment'**
  String get attachmentFile;

  /// No description provided for @attachmentPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF document'**
  String get attachmentPdf;

  /// No description provided for @attachmentTapPreview.
  ///
  /// In en, this message translates to:
  /// **'Tap to preview'**
  String get attachmentTapPreview;

  /// No description provided for @attachmentTapOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get attachmentTapOpen;

  /// No description provided for @pdfDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfDefaultTitle;

  /// No description provided for @teacherWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Teacher Workspace'**
  String get teacherWorkspace;

  /// No description provided for @teacherQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get teacherQuickActions;

  /// No description provided for @teacherCreateItems.
  ///
  /// In en, this message translates to:
  /// **'Create new items'**
  String get teacherCreateItems;

  /// No description provided for @teacherNewAssignment.
  ///
  /// In en, this message translates to:
  /// **'New Assignment'**
  String get teacherNewAssignment;

  /// No description provided for @teacherNewAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'New Announcement'**
  String get teacherNewAnnouncement;

  /// No description provided for @teacherSubmissions.
  ///
  /// In en, this message translates to:
  /// **'Submissions'**
  String get teacherSubmissions;

  /// No description provided for @teacherNoSubmissions.
  ///
  /// In en, this message translates to:
  /// **'No submissions yet'**
  String get teacherNoSubmissions;

  /// No description provided for @teacherNoSubmissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Student work will show up here for grading.'**
  String get teacherNoSubmissionsSubtitle;

  /// No description provided for @teacherGradebook.
  ///
  /// In en, this message translates to:
  /// **'Gradebook'**
  String get teacherGradebook;

  /// No description provided for @teacherGradeClass.
  ///
  /// In en, this message translates to:
  /// **'Grade class'**
  String get teacherGradeClass;

  /// No description provided for @teacherNoGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get teacherNoGroups;

  /// No description provided for @teacherNoGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask an admin to assign you a group.'**
  String get teacherNoGroupsSubtitle;

  /// No description provided for @teacherActiveGroups.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE GROUPS'**
  String get teacherActiveGroups;

  /// No description provided for @teacherSubject.
  ///
  /// In en, this message translates to:
  /// **'SUBJECT'**
  String get teacherSubject;

  /// No description provided for @teacherDailyTasks.
  ///
  /// In en, this message translates to:
  /// **'Daily Tasks'**
  String get teacherDailyTasks;

  /// No description provided for @teacherNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'What needs your attention'**
  String get teacherNeedsAttention;

  /// No description provided for @teacherReviewSubmissions.
  ///
  /// In en, this message translates to:
  /// **'Review Submissions'**
  String get teacherReviewSubmissions;

  /// No description provided for @teacherCheckAssignments.
  ///
  /// In en, this message translates to:
  /// **'Check student assignments'**
  String get teacherCheckAssignments;

  /// No description provided for @teacherRecordMarks.
  ///
  /// In en, this message translates to:
  /// **'Record marks in percent'**
  String get teacherRecordMarks;

  /// No description provided for @teacherPerformanceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Performance Analytics'**
  String get teacherPerformanceAnalytics;

  /// No description provided for @teacherTrackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track group progress'**
  String get teacherTrackProgress;

  /// No description provided for @teacherOpenAttachment.
  ///
  /// In en, this message translates to:
  /// **'Open attachment'**
  String get teacherOpenAttachment;

  /// No description provided for @teacherScoreHelper.
  ///
  /// In en, this message translates to:
  /// **'Adds a homework mark to the gradebook'**
  String get teacherScoreHelper;

  /// No description provided for @teacherScoreRange.
  ///
  /// In en, this message translates to:
  /// **'Score must be between 0 and 100.'**
  String get teacherScoreRange;

  /// No description provided for @teacherNoWrittenAnswer.
  ///
  /// In en, this message translates to:
  /// **'No written answer.'**
  String get teacherNoWrittenAnswer;

  /// No description provided for @teacherReviewSubmission.
  ///
  /// In en, this message translates to:
  /// **'Review submission'**
  String get teacherReviewSubmission;

  /// No description provided for @teacherHomeworkPackTasks.
  ///
  /// In en, this message translates to:
  /// **'Homework Pack Tasks'**
  String get teacherHomeworkPackTasks;

  /// No description provided for @teacherAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get teacherAddTask;

  /// No description provided for @teacherEditTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get teacherEditTask;

  /// No description provided for @teacherDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task?'**
  String get teacherDeleteTask;

  /// No description provided for @teacherTasksContent.
  ///
  /// In en, this message translates to:
  /// **'Tasks Content'**
  String get teacherTasksContent;

  /// No description provided for @teacherManagePack.
  ///
  /// In en, this message translates to:
  /// **'Manage items in this pack'**
  String get teacherManagePack;

  /// No description provided for @teacherTaskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Reading Exercise'**
  String get teacherTaskTitleHint;

  /// No description provided for @teacherLinkHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get teacherLinkHint;

  /// No description provided for @teacherAttachmentHint.
  ///
  /// In en, this message translates to:
  /// **'Image or file link...'**
  String get teacherAttachmentHint;

  /// No description provided for @teacherNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get teacherNoData;

  /// No description provided for @teacherMarkDistribution.
  ///
  /// In en, this message translates to:
  /// **'Mark Distribution'**
  String get teacherMarkDistribution;

  /// No description provided for @teacherStudentsByAverage.
  ///
  /// In en, this message translates to:
  /// **'Students grouped by average'**
  String get teacherStudentsByAverage;

  /// No description provided for @teacherNoMarksTrends.
  ///
  /// In en, this message translates to:
  /// **'Add marks in the gradebook to see trends.'**
  String get teacherNoMarksTrends;

  /// No description provided for @teacherTargetGroup.
  ///
  /// In en, this message translates to:
  /// **'Target Group'**
  String get teacherTargetGroup;

  /// No description provided for @adminWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace Control'**
  String get adminWorkspace;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get adminUsers;

  /// No description provided for @adminGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get adminGroups;

  /// No description provided for @adminAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get adminAnalytics;

  /// No description provided for @adminTeachers.
  ///
  /// In en, this message translates to:
  /// **'TEACHERS'**
  String get adminTeachers;

  /// No description provided for @adminStudents.
  ///
  /// In en, this message translates to:
  /// **'STUDENTS'**
  String get adminStudents;

  /// No description provided for @adminGroupsLabel.
  ///
  /// In en, this message translates to:
  /// **'GROUPS'**
  String get adminGroupsLabel;

  /// No description provided for @adminMarksLabel.
  ///
  /// In en, this message translates to:
  /// **'MARKS'**
  String get adminMarksLabel;

  /// No description provided for @adminActivityInsights.
  ///
  /// In en, this message translates to:
  /// **'Activity Insights'**
  String get adminActivityInsights;

  /// No description provided for @adminCurrentMetrics.
  ///
  /// In en, this message translates to:
  /// **'Current metrics'**
  String get adminCurrentMetrics;

  /// No description provided for @adminCreateUser.
  ///
  /// In en, this message translates to:
  /// **'Create New User'**
  String get adminCreateUser;

  /// No description provided for @adminCreateUserButton.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get adminCreateUserButton;

  /// No description provided for @adminUserCreated.
  ///
  /// In en, this message translates to:
  /// **'User created successfully'**
  String get adminUserCreated;

  /// No description provided for @adminResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get adminResetPassword;

  /// No description provided for @adminResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password · {username}'**
  String adminResetPasswordTitle(String username);

  /// No description provided for @adminCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create New Group'**
  String get adminCreateGroup;

  /// No description provided for @adminCreateGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get adminCreateGroupButton;

  /// No description provided for @adminGroupTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Group 4'**
  String get adminGroupTitleHint;

  /// No description provided for @adminGroupTitleExists.
  ///
  /// In en, this message translates to:
  /// **'This teacher already has a group with that name'**
  String get adminGroupTitleExists;

  /// No description provided for @adminAssignStudent.
  ///
  /// In en, this message translates to:
  /// **'Assign Student'**
  String get adminAssignStudent;

  /// No description provided for @adminActivityDistribution.
  ///
  /// In en, this message translates to:
  /// **'Activity Distribution'**
  String get adminActivityDistribution;

  /// No description provided for @adminGlobalMetrics.
  ///
  /// In en, this message translates to:
  /// **'Global platform metrics'**
  String get adminGlobalMetrics;

  /// No description provided for @adminActivityLog.
  ///
  /// In en, this message translates to:
  /// **'Admin Activity Log'**
  String get adminActivityLog;

  /// No description provided for @adminActivityLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System-wide events and audit logs appear here.'**
  String get adminActivityLogSubtitle;

  /// No description provided for @adminTeacherLine.
  ///
  /// In en, this message translates to:
  /// **'Teacher: {name}'**
  String adminTeacherLine(String name);

  /// No description provided for @adminRoleLine.
  ///
  /// In en, this message translates to:
  /// **'{role} · {username}'**
  String adminRoleLine(String role, String username);

  /// No description provided for @adminDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get adminDisable;

  /// No description provided for @adminEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get adminEnable;

  /// No description provided for @adminPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminPassword;

  /// No description provided for @adminFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get adminFullName;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminRole;

  /// No description provided for @adminSphere.
  ///
  /// In en, this message translates to:
  /// **'Sphere'**
  String get adminSphere;

  /// No description provided for @percentExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get percentExcellent;

  /// No description provided for @percentGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get percentGood;

  /// No description provided for @percentNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'Needs work'**
  String get percentNeedsWork;

  /// No description provided for @percentAtRisk.
  ///
  /// In en, this message translates to:
  /// **'At risk'**
  String get percentAtRisk;

  /// No description provided for @emptyStateDefault.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateDefault;

  /// No description provided for @setupRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup required'**
  String get setupRequiredTitle;

  /// No description provided for @setupRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY to your .env file.'**
  String get setupRequiredBody;

  /// No description provided for @setupOption1.
  ///
  /// In en, this message translates to:
  /// **'Option 1 — local .env file'**
  String get setupOption1;

  /// No description provided for @setupOption2.
  ///
  /// In en, this message translates to:
  /// **'Option 2 — dart-define'**
  String get setupOption2;

  /// No description provided for @attendanceAllPresent.
  ///
  /// In en, this message translates to:
  /// **'All P'**
  String get attendanceAllPresent;

  /// No description provided for @attendanceAllAbsent.
  ///
  /// In en, this message translates to:
  /// **'All A'**
  String get attendanceAllAbsent;

  /// No description provided for @attendanceAllLate.
  ///
  /// In en, this message translates to:
  /// **'All L'**
  String get attendanceAllLate;

  /// No description provided for @attendanceAllExcused.
  ///
  /// In en, this message translates to:
  /// **'All E'**
  String get attendanceAllExcused;

  /// No description provided for @attendancePresentWord.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get attendancePresentWord;

  /// No description provided for @attendanceAbsentWord.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get attendanceAbsentWord;

  /// No description provided for @attendanceLateWord.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceLateWord;

  /// No description provided for @attendanceExcusedWord.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get attendanceExcusedWord;

  /// No description provided for @attendanceWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get attendanceWeekdayMon;

  /// No description provided for @attendanceWeekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get attendanceWeekdayTue;

  /// No description provided for @attendanceWeekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get attendanceWeekdayWed;

  /// No description provided for @attendanceWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get attendanceWeekdayThu;

  /// No description provided for @attendanceWeekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get attendanceWeekdayFri;

  /// No description provided for @attendancePercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get attendancePercentLabel;

  /// No description provided for @attendanceNoLesson.
  ///
  /// In en, this message translates to:
  /// **'No lesson'**
  String get attendanceNoLesson;

  /// No description provided for @attendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance history'**
  String get attendanceHistory;

  /// No description provided for @attendanceSelectStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get attendanceSelectStudent;

  /// No description provided for @attendanceAllStudents.
  ///
  /// In en, this message translates to:
  /// **'All students'**
  String get attendanceAllStudents;

  /// No description provided for @attendanceTapToCycle.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to change status'**
  String get attendanceTapToCycle;

  /// No description provided for @attendanceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Attendance updated'**
  String get attendanceUpdated;

  /// No description provided for @attendanceCalendarEmpty.
  ///
  /// In en, this message translates to:
  /// **'No attendance in this month'**
  String get attendanceCalendarEmpty;

  /// No description provided for @attendanceFutureNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You can’t mark attendance for a future day'**
  String get attendanceFutureNotAllowed;

  /// No description provided for @attendanceWeekendNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Attendance can only be marked on weekdays (Mon–Fri)'**
  String get attendanceWeekendNotAllowed;

  /// No description provided for @chartBandExcellent.
  ///
  /// In en, this message translates to:
  /// **'85–100%'**
  String get chartBandExcellent;

  /// No description provided for @chartBandGood.
  ///
  /// In en, this message translates to:
  /// **'70–84%'**
  String get chartBandGood;

  /// No description provided for @chartBandNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'50–69%'**
  String get chartBandNeedsWork;

  /// No description provided for @chartBandAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Below 50%'**
  String get chartBandAtRisk;

  /// No description provided for @marksWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get marksWeight;

  /// No description provided for @marksCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get marksCategory;

  /// No description provided for @marksDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get marksDate;

  /// No description provided for @marksCommentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get marksCommentOptional;

  /// No description provided for @marksNewMark.
  ///
  /// In en, this message translates to:
  /// **'New mark'**
  String get marksNewMark;

  /// No description provided for @marksEditMark.
  ///
  /// In en, this message translates to:
  /// **'Edit mark'**
  String get marksEditMark;

  /// No description provided for @marksFromSubmission.
  ///
  /// In en, this message translates to:
  /// **'From a graded submission'**
  String get marksFromSubmission;

  /// No description provided for @marksNeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Give the graded item a title.'**
  String get marksNeedTitle;

  /// No description provided for @marksWeightPositive.
  ///
  /// In en, this message translates to:
  /// **'Weight must be greater than zero.'**
  String get marksWeightPositive;

  /// No description provided for @marksNeedAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Enter a mark for at least one student.'**
  String get marksNeedAtLeastOne;

  /// No description provided for @marksLeaveBlankSkip.
  ///
  /// In en, this message translates to:
  /// **'Leave a field blank to skip that student.'**
  String get marksLeaveBlankSkip;

  /// No description provided for @marksFromSubmissionDelete.
  ///
  /// In en, this message translates to:
  /// **'This mark comes from a graded submission. Clear the score in Submissions to remove it.'**
  String get marksFromSubmissionDelete;

  /// No description provided for @marksFromSubmissionEdit.
  ///
  /// In en, this message translates to:
  /// **'This mark mirrors a graded submission. Editing it here will be overwritten the next time the submission is re-graded.'**
  String get marksFromSubmissionEdit;

  /// No description provided for @categoryHomework.
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get categoryHomework;

  /// No description provided for @categoryClasswork.
  ///
  /// In en, this message translates to:
  /// **'Classwork'**
  String get categoryClasswork;

  /// No description provided for @categoryQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get categoryQuiz;

  /// No description provided for @categoryTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get categoryTest;

  /// No description provided for @categoryExam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get categoryExam;

  /// No description provided for @categoryProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get categoryProject;

  /// No description provided for @categoryOral.
  ///
  /// In en, this message translates to:
  /// **'Oral'**
  String get categoryOral;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @teacherReferenceLinkOptional.
  ///
  /// In en, this message translates to:
  /// **'Reference Link (optional)'**
  String get teacherReferenceLinkOptional;

  /// No description provided for @teacherAttachmentUrlOptional.
  ///
  /// In en, this message translates to:
  /// **'Attachment URL (optional)'**
  String get teacherAttachmentUrlOptional;

  /// No description provided for @teacherNoTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks added yet. Click \"Add Task\" to get started.'**
  String get teacherNoTasksYet;

  /// No description provided for @teacherTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get teacherTemplates;

  /// No description provided for @teacherTemplatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get teacherTemplatesEmpty;

  /// No description provided for @teacherTemplatesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save an assignment as a template to reuse it later.'**
  String get teacherTemplatesEmptySubtitle;

  /// No description provided for @teacherSaveAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get teacherSaveAsTemplate;

  /// No description provided for @teacherTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get teacherTemplateSaved;

  /// No description provided for @teacherUseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use template'**
  String get teacherUseTemplate;

  /// No description provided for @teacherFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'From template'**
  String get teacherFromTemplate;

  /// No description provided for @teacherDeleteTemplate.
  ///
  /// In en, this message translates to:
  /// **'Delete template?'**
  String get teacherDeleteTemplate;

  /// No description provided for @teacherDeleteTemplateBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed.'**
  String teacherDeleteTemplateBody(String title);

  /// No description provided for @teacherDuplicateAssignment.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get teacherDuplicateAssignment;

  /// No description provided for @teacherDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate assignment'**
  String get teacherDuplicateTitle;

  /// No description provided for @teacherDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Assignment duplicated'**
  String get teacherDuplicated;

  /// No description provided for @assignmentEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit assignment'**
  String get assignmentEdit;

  /// No description provided for @assignmentDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete assignment?'**
  String get assignmentDeleteTitle;

  /// No description provided for @assignmentDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the assignment, its tasks, and student submissions.'**
  String get assignmentDeleteBody;

  /// No description provided for @assignmentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Assignment deleted'**
  String get assignmentDeleted;

  /// No description provided for @assignmentTypeHintStatic.
  ///
  /// In en, this message translates to:
  /// **'A single piece of work. Students submit once — no extra tasks.'**
  String get assignmentTypeHintStatic;

  /// No description provided for @assignmentTypeHintPack.
  ///
  /// In en, this message translates to:
  /// **'A pack of multiple tasks (workbook-style). You’ll add items next.'**
  String get assignmentTypeHintPack;

  /// No description provided for @teacherCreateFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Create from template'**
  String get teacherCreateFromTemplate;

  /// No description provided for @teacherTasksCopied.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks included'**
  String teacherTasksCopied(int count);

  /// No description provided for @teacherRecentFeedback.
  ///
  /// In en, this message translates to:
  /// **'Reuse feedback'**
  String get teacherRecentFeedback;

  /// No description provided for @teacherApplyFeedbackToOthers.
  ///
  /// In en, this message translates to:
  /// **'Also apply to other pending for this task'**
  String get teacherApplyFeedbackToOthers;

  /// No description provided for @teacherFeedbackAppliedCount.
  ///
  /// In en, this message translates to:
  /// **'Feedback applied to {count} other submissions'**
  String teacherFeedbackAppliedCount(int count);

  /// No description provided for @teacherSharedComment.
  ///
  /// In en, this message translates to:
  /// **'Shared comment (optional)'**
  String get teacherSharedComment;

  /// No description provided for @teacherSharedCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Same note on every mark you save'**
  String get teacherSharedCommentHint;

  /// No description provided for @adminPlatformOverview.
  ///
  /// In en, this message translates to:
  /// **'Platform Overview'**
  String get adminPlatformOverview;

  /// No description provided for @adminAssignTeacher.
  ///
  /// In en, this message translates to:
  /// **'Assign Teacher'**
  String get adminAssignTeacher;

  /// No description provided for @adminSelectStudent.
  ///
  /// In en, this message translates to:
  /// **'Select Student'**
  String get adminSelectStudent;

  /// No description provided for @adminInitialGroupOptional.
  ///
  /// In en, this message translates to:
  /// **'Initial Group (Optional)'**
  String get adminInitialGroupOptional;

  /// No description provided for @adminChartTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get adminChartTasks;

  /// No description provided for @adminChartGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get adminChartGroups;

  /// No description provided for @adminChartStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get adminChartStaff;

  /// No description provided for @adminChartAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get adminChartAssignments;

  /// No description provided for @adminChartMarks.
  ///
  /// In en, this message translates to:
  /// **'Marks'**
  String get adminChartMarks;

  /// No description provided for @adminChartStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get adminChartStudents;

  /// No description provided for @adminAcademicYears.
  ///
  /// In en, this message translates to:
  /// **'Academic years'**
  String get adminAcademicYears;

  /// No description provided for @adminAcademicYearsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'School years and semesters for the gradebook'**
  String get adminAcademicYearsSubtitle;

  /// No description provided for @adminAcademicYearsTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic calendar'**
  String get adminAcademicYearsTitle;

  /// No description provided for @adminCreateNextYear.
  ///
  /// In en, this message translates to:
  /// **'Create next year'**
  String get adminCreateNextYear;

  /// No description provided for @adminYearCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {label}'**
  String adminYearCreated(String label);

  /// No description provided for @adminSetCurrentYear.
  ///
  /// In en, this message translates to:
  /// **'Set as current'**
  String get adminSetCurrentYear;

  /// No description provided for @adminCurrentYearBadge.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get adminCurrentYearBadge;

  /// No description provided for @adminYearSemesters.
  ///
  /// In en, this message translates to:
  /// **'Four semesters · Aug → Jun'**
  String get adminYearSemesters;

  /// No description provided for @adminSemesterRange.
  ///
  /// In en, this message translates to:
  /// **'Semester {semester} · {start} – {end}'**
  String adminSemesterRange(int semester, String start, String end);

  /// No description provided for @adminEditTerm.
  ///
  /// In en, this message translates to:
  /// **'Edit term'**
  String get adminEditTerm;

  /// No description provided for @adminEditTermTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit semester {semester}'**
  String adminEditTermTitle(int semester);

  /// No description provided for @adminTermStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Starts on'**
  String get adminTermStartsOn;

  /// No description provided for @adminTermEndsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends on'**
  String get adminTermEndsOn;

  /// No description provided for @adminTermDatesInvalid.
  ///
  /// In en, this message translates to:
  /// **'End date must be on or after the start date'**
  String get adminTermDatesInvalid;

  /// No description provided for @adminTermUpdated.
  ///
  /// In en, this message translates to:
  /// **'Term dates updated'**
  String get adminTermUpdated;

  /// No description provided for @adminDeleteYear.
  ///
  /// In en, this message translates to:
  /// **'Delete year'**
  String get adminDeleteYear;

  /// No description provided for @adminDeleteYearTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {label}?'**
  String adminDeleteYearTitle(String label);

  /// No description provided for @adminDeleteYearBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the year and its four terms from the calendar. Marks are not deleted. To confirm, type {label} below.'**
  String adminDeleteYearBody(String label);

  /// No description provided for @adminDeleteYearConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Type {label} to confirm'**
  String adminDeleteYearConfirmHint(String label);

  /// No description provided for @adminDeleteYearCurrentBlocked.
  ///
  /// In en, this message translates to:
  /// **'Set another year as current before deleting this one.'**
  String get adminDeleteYearCurrentBlocked;

  /// No description provided for @adminYearDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {label}'**
  String adminYearDeleted(String label);

  /// No description provided for @adminNoAcademicYears.
  ///
  /// In en, this message translates to:
  /// **'No academic years yet'**
  String get adminNoAcademicYears;

  /// No description provided for @adminAcademicYearsHint.
  ///
  /// In en, this message translates to:
  /// **'Create the next school year when you are ready. Teachers and students pick semesters in the gradebook. Tap a term to edit its dates.'**
  String get adminAcademicYearsHint;

  /// No description provided for @adminCredentialPrintTitle.
  ///
  /// In en, this message translates to:
  /// **'Print login slips'**
  String get adminCredentialPrintTitle;

  /// No description provided for @adminCredentialPrintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unique usernames and passwords from the database, 3 slips per page'**
  String get adminCredentialPrintSubtitle;

  /// No description provided for @adminCredentialPasteLabel.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminCredentialPasteLabel;

  /// No description provided for @adminCredentialPasteHint.
  ///
  /// In en, this message translates to:
  /// **'username|password|full name\n@james|Abc123xyz|James English|teacher\n@john_jones|Pass456|John Jones'**
  String get adminCredentialPasteHint;

  /// No description provided for @adminCredentialPerPage.
  ///
  /// In en, this message translates to:
  /// **'Slips per page'**
  String get adminCredentialPerPage;

  /// No description provided for @adminCredentialTwo.
  ///
  /// In en, this message translates to:
  /// **'2'**
  String get adminCredentialTwo;

  /// No description provided for @adminCredentialThree.
  ///
  /// In en, this message translates to:
  /// **'3'**
  String get adminCredentialThree;

  /// No description provided for @adminCredentialExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get adminCredentialExportPdf;

  /// No description provided for @adminCredentialSlipTitle.
  ///
  /// In en, this message translates to:
  /// **'Your MU Study login'**
  String get adminCredentialSlipTitle;

  /// No description provided for @adminCredentialSlipHint.
  ///
  /// In en, this message translates to:
  /// **'Keep this paper private. Change your password after first sign-in.'**
  String get adminCredentialSlipHint;

  /// No description provided for @adminCredentialNeedUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found to print'**
  String get adminCredentialNeedUsers;

  /// No description provided for @adminCredentialNeedSql.
  ///
  /// In en, this message translates to:
  /// **'Run sql/admin_login_slips.sql in the Supabase SQL Editor, then export again.'**
  String get adminCredentialNeedSql;

  /// No description provided for @adminCredentialConfidential.
  ///
  /// In en, this message translates to:
  /// **'Private and confidential. These credentials are intended only for the assigned student.'**
  String get adminCredentialConfidential;

  /// No description provided for @adminFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get adminFirstName;

  /// No description provided for @adminLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get adminLastName;

  /// No description provided for @adminCredentialStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get adminCredentialStudents;

  /// No description provided for @adminCredentialTeachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get adminCredentialTeachers;

  /// No description provided for @adminCredentialAllGroups.
  ///
  /// In en, this message translates to:
  /// **'All groups'**
  String get adminCredentialAllGroups;

  /// No description provided for @sphereMath.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get sphereMath;

  /// No description provided for @sphereEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get sphereEnglish;

  /// No description provided for @dailyMotivation1.
  ///
  /// In en, this message translates to:
  /// **'Today is a great day to make progress.'**
  String get dailyMotivation1;

  /// No description provided for @dailyMotivation2.
  ///
  /// In en, this message translates to:
  /// **'Ready to continue where you left off?'**
  String get dailyMotivation2;

  /// No description provided for @dailyMotivation3.
  ///
  /// In en, this message translates to:
  /// **'Let\'s conquer your goals today.'**
  String get dailyMotivation3;

  /// No description provided for @dailyMotivation4.
  ///
  /// In en, this message translates to:
  /// **'Consistency is the key to mastery.'**
  String get dailyMotivation4;
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
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
