import 'package:mu_study/l10n/app_localizations.dart';

String navLabel(AppLocalizations l10n, String key) {
  return switch (key) {
    'navDashboard' => l10n.navDashboard,
    'navAssignments' => l10n.navAssignments,
    'navMarks' => l10n.navMarks,
    'navAttendance' => l10n.navAttendance,
    'navNotifications' => l10n.navNotifications,
    'navProfile' => l10n.navProfile,
    'navUsers' => l10n.navUsers,
    'navGroups' => l10n.navGroups,
    'navAnalytics' => l10n.navAnalytics,
    'navGradebook' => l10n.navGradebook,
    'navChat' => l10n.navChat,
    'navFocus' => l10n.navFocus,
    _ => key,
  };
}
