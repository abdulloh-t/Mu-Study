import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/screens/admin/academic_years/admin_academic_years_screen.dart';
import 'package:mu_study/screens/admin/analytics/admin_analytics_screen.dart';
import 'package:mu_study/screens/admin/announcements/admin_announcements_screen.dart';
import 'package:mu_study/screens/admin/dashboard/admin_dashboard_screen.dart';
import 'package:mu_study/screens/admin/groups/admin_groups_screen.dart';
import 'package:mu_study/screens/admin/credentials/admin_credential_print_screen.dart';
import 'package:mu_study/screens/admin/data_generator/admin_mass_data_generator_screen.dart';
import 'package:mu_study/screens/admin/notifications/admin_notifications_screen.dart';
import 'package:mu_study/screens/admin/profile/admin_profile_screen.dart';
import 'package:mu_study/screens/admin/users/admin_users_screen.dart';
import 'package:mu_study/screens/auth/language_selection_screen.dart';
import 'package:mu_study/screens/auth/login_screen.dart';
import 'package:mu_study/screens/auth/splash_screen.dart';
import 'package:mu_study/screens/chat/list/chat_list_screen.dart';
import 'package:mu_study/screens/chat/room/chat_room_screen.dart';
import 'package:mu_study/screens/student/attendance/student_attendance_screen.dart';
import 'package:mu_study/screens/student/notifications/student_notifications_screen.dart';
import 'package:mu_study/screens/student/profile/student_profile_screen.dart';
import 'package:mu_study/screens/student/homework/student_assignments_screen.dart';
import 'package:mu_study/screens/student/home/student_dashboard_screen.dart';
import 'package:mu_study/screens/student/focus/student_focus_screen.dart';
import 'package:mu_study/screens/student/marks/student_marks_screen.dart';
import 'package:mu_study/screens/student/homework/student_task_submit_screen.dart';
import 'package:mu_study/screens/teacher/analytics/teacher_analytics_screen.dart';
import 'package:mu_study/screens/teacher/announcements/teacher_announcements_screen.dart';
import 'package:mu_study/screens/teacher/assignments/teacher_assignments_screen.dart';
import 'package:mu_study/screens/teacher/attendance/teacher_attendance_screen.dart';
import 'package:mu_study/screens/teacher/dashboard/teacher_dashboard_screen.dart';
import 'package:mu_study/screens/teacher/notifications/teacher_notifications_screen.dart';
import 'package:mu_study/screens/teacher/profile/teacher_profile_screen.dart';
import 'package:mu_study/screens/teacher/homework/teacher_homework_pack_screen.dart';
import 'package:mu_study/screens/teacher/marks/teacher_marks_screen.dart';
import 'package:mu_study/screens/teacher/homework/teacher_submissions_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/language',
        builder: (_, _) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/boot',
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/account-disabled',
        builder: (context, _) =>
            Scaffold(body: Center(child: Text(context.l10n.accountDisabled))),
      ),
      _studentShell(),
      _teacherShell(),
      _adminShell(),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, _) => notifyListeners());
    _ref.listen(currentProfileProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;
    if (loc == '/splash') return null;

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return loc == '/login' ? null : '/login';
    }

    final profileAsync = _ref.read(currentProfileProvider);

    // Only block on the *first* profile load. A refresh (e.g. after changing
    // language) still has the previous value — bouncing through /boot tears
    // down the shell mid-gesture and floods semantics.parentDataDirty asserts.
    if (!profileAsync.hasValue &&
        (profileAsync.isLoading || profileAsync.isRefreshing)) {
      if (loc == '/boot' || loc == '/language') return null;
      return '/boot';
    }

    final profile = profileAsync.valueOrNull;
    if (profile == null) {
      return loc == '/login' ? null : '/login';
    }
    if (profile.isDisabled) {
      return loc == '/account-disabled' ? null : '/account-disabled';
    }

    final home = switch (profile.role) {
      UserRole.student => '/student/dashboard',
      UserRole.teacher => '/teacher/dashboard',
      UserRole.admin => '/admin/dashboard',
    };

    if (!profile.hasChosenLanguage) {
      return loc == '/language' ? null : '/language';
    }

    if (loc == '/login' || loc == '/boot' || loc == '/language') {
      return home;
    }

    return null;
  }
}

ShellRoute _studentShell() {
  const destinations = [
    ShellDestination(
      labelKey: 'navDashboard',
      icon: Icons.dashboard_outlined,
      path: '/student/dashboard',
    ),
    ShellDestination(
      labelKey: 'navAssignments',
      icon: Icons.assignment_outlined,
      path: '/student/assignments',
    ),
    ShellDestination(
      labelKey: 'navFocus',
      icon: Icons.self_improvement_outlined,
      path: '/student/focus',
    ),
    ShellDestination(
      labelKey: 'navMarks',
      icon: Icons.grade_outlined,
      path: '/student/marks',
    ),
    ShellDestination(
      labelKey: 'navChat',
      icon: Icons.chat_bubble_outline_rounded,
      path: '/student/chat',
      badge: ShellBadgeKind.chat,
    ),
    ShellDestination(
      labelKey: 'navAttendance',
      icon: Icons.event_available_outlined,
      path: '/student/attendance',
    ),
    ShellDestination(
      labelKey: 'navProfile',
      icon: Icons.person_outline,
      path: '/student/profile',
    ),
  ];

  return ShellRoute(
    builder: (context, state, child) => AppShell(
      role: UserRole.student,
      destinations: destinations,
      child: child,
    ),
    routes: [
      GoRoute(
        path: '/student/dashboard',
        pageBuilder: (_, s) => _fade(const StudentDashboardScreen(), s),
      ),
      GoRoute(
        path: '/student/assignments',
        pageBuilder: (_, s) => _fade(const StudentAssignmentsScreen(), s),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, s) => StudentAssignmentDetailScreen(
              assignmentId: s.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/student/tasks/:taskId',
        builder: (_, s) =>
            StudentTaskSubmitScreen(taskId: s.pathParameters['taskId']!),
      ),
      GoRoute(
        path: '/student/focus',
        pageBuilder: (_, s) => _fade(const StudentFocusScreen(), s),
      ),
      GoRoute(
        path: '/student/marks',
        pageBuilder: (_, s) => _fade(const StudentMarksScreen(), s),
      ),
      GoRoute(
        path: '/student/chat',
        pageBuilder: (_, s) =>
            _fade(const ChatListScreen(basePath: '/student/chat'), s),
        routes: [
          GoRoute(
            path: ':roomId',
            builder: (_, s) =>
                ChatRoomScreen(roomId: s.pathParameters['roomId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/student/attendance',
        pageBuilder: (_, s) => _fade(const StudentAttendanceScreen(), s),
      ),
      GoRoute(
        path: '/student/notifications',
        pageBuilder: (_, s) => _fade(const StudentNotificationsScreen(), s),
      ),
      GoRoute(
        path: '/student/profile',
        pageBuilder: (_, s) => _fade(const StudentProfileScreen(), s),
      ),
    ],
  );
}

ShellRoute _teacherShell() {
  const destinations = [
    ShellDestination(
      labelKey: 'navDashboard',
      icon: Icons.dashboard_outlined,
      path: '/teacher/dashboard',
    ),
    ShellDestination(
      labelKey: 'navAssignments',
      icon: Icons.assignment_outlined,
      path: '/teacher/assignments',
    ),
    ShellDestination(
      labelKey: 'navChat',
      icon: Icons.chat_bubble_outline_rounded,
      path: '/teacher/chat',
      badge: ShellBadgeKind.chat,
    ),
    ShellDestination(
      labelKey: 'navAttendance',
      icon: Icons.event_available_outlined,
      path: '/teacher/attendance',
    ),
    ShellDestination(
      labelKey: 'navGradebook',
      icon: Icons.grade_outlined,
      path: '/teacher/marks',
    ),
    ShellDestination(
      labelKey: 'navProfile',
      icon: Icons.person_outline,
      path: '/teacher/profile',
    ),
  ];

  return ShellRoute(
    builder: (context, state, child) => AppShell(
      role: UserRole.teacher,
      destinations: destinations,
      child: child,
    ),
    routes: [
      GoRoute(
        path: '/teacher/dashboard',
        pageBuilder: (_, s) => _fade(const TeacherDashboardScreen(), s),
      ),
      GoRoute(
        path: '/teacher/submissions',
        builder: (_, _) => const TeacherSubmissionsScreen(),
      ),
      GoRoute(
        path: '/teacher/assignments',
        pageBuilder: (_, s) => _fade(const TeacherAssignmentsScreen(), s),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, s) => TeacherHomeworkPackScreen(
              assignmentId: s.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/teacher/chat',
        pageBuilder: (_, s) =>
            _fade(const ChatListScreen(basePath: '/teacher/chat'), s),
        routes: [
          GoRoute(
            path: ':roomId',
            builder: (_, s) =>
                ChatRoomScreen(roomId: s.pathParameters['roomId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/teacher/attendance',
        pageBuilder: (_, s) => _fade(const TeacherAttendanceScreen(), s),
      ),
      GoRoute(
        path: '/teacher/marks',
        pageBuilder: (_, s) => _fade(const TeacherMarksScreen(), s),
      ),
      GoRoute(
        path: '/teacher/analytics',
        builder: (_, _) => const TeacherAnalyticsScreen(),
      ),
      GoRoute(
        path: '/teacher/announcements',
        pageBuilder: (_, s) => _fade(const TeacherAnnouncementsScreen(), s),
      ),
      GoRoute(
        path: '/teacher/notifications',
        pageBuilder: (_, s) => _fade(const TeacherNotificationsScreen(), s),
      ),
      GoRoute(
        path: '/teacher/profile',
        pageBuilder: (_, s) => _fade(const TeacherProfileScreen(), s),
      ),
    ],
  );
}

ShellRoute _adminShell() {
  const destinations = [
    ShellDestination(
      labelKey: 'navDashboard',
      icon: Icons.dashboard_outlined,
      path: '/admin/dashboard',
    ),
    ShellDestination(
      labelKey: 'navUsers',
      icon: Icons.people_outline,
      path: '/admin/users',
    ),
    ShellDestination(
      labelKey: 'navGroups',
      icon: Icons.groups_outlined,
      path: '/admin/groups',
    ),
    ShellDestination(
      labelKey: 'navChat',
      icon: Icons.chat_bubble_outline_rounded,
      path: '/admin/chat',
      badge: ShellBadgeKind.chat,
    ),
    ShellDestination(
      labelKey: 'navAnalytics',
      icon: Icons.insights_outlined,
      path: '/admin/analytics',
    ),
    ShellDestination(
      labelKey: 'navProfile',
      icon: Icons.person_outline,
      path: '/admin/profile',
    ),
  ];

  return ShellRoute(
    builder: (context, state, child) => AppShell(
      role: UserRole.admin,
      destinations: destinations,
      child: child,
    ),
    routes: [
      GoRoute(
        path: '/admin/dashboard',
        pageBuilder: (_, s) => _fade(const AdminDashboardScreen(), s),
      ),
      GoRoute(
        path: '/admin/users',
        pageBuilder: (_, s) => _fade(const AdminUsersScreen(), s),
      ),
      GoRoute(
        path: '/admin/groups',
        pageBuilder: (_, s) => _fade(const AdminGroupsScreen(), s),
      ),
      GoRoute(
        path: '/admin/chat',
        pageBuilder: (_, s) =>
            _fade(const ChatListScreen(basePath: '/admin/chat'), s),
        routes: [
          GoRoute(
            path: ':roomId',
            builder: (_, s) =>
                ChatRoomScreen(roomId: s.pathParameters['roomId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/analytics',
        pageBuilder: (_, s) => _fade(const AdminAnalyticsScreen(), s),
      ),
      GoRoute(
        path: '/admin/academic-years',
        pageBuilder: (_, s) => _fade(const AdminAcademicYearsScreen(), s),
      ),
      GoRoute(
        path: '/admin/announcements',
        pageBuilder: (_, s) => _fade(const AdminAnnouncementsScreen(), s),
      ),
      GoRoute(
        path: '/admin/notifications',
        pageBuilder: (_, s) => _fade(const AdminNotificationsScreen(), s),
      ),
      GoRoute(
        path: '/admin/profile',
        pageBuilder: (_, s) => _fade(const AdminProfileScreen(), s),
      ),
      GoRoute(
        path: '/admin/mass-generator',
        pageBuilder: (_, s) => _fade(
          const AdminMassDataGeneratorScreen(),
          s,
        ),
      ),
      GoRoute(
        path: '/admin/credential-print',
        pageBuilder: (_, s) =>
            _fade(const AdminCredentialPrintScreen(), s),
      ),
    ],
  );
}

CustomTransitionPage<void> _fade(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
