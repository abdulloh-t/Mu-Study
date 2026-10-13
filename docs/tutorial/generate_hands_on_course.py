#!/usr/bin/env python3
"""
MU Study Hands-On Reconstruction Course PDF (v3).

Main body = Learn → Build → Test lessons for features, screens, providers.
Appendices = complete SQL + complete Dart + ARB (reference, not primary teaching).
"""

from __future__ import annotations

import re
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (
    KeepTogether,
    PageBreak,
    Paragraph,
    Preformatted,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
EXPORT = HERE / "export"
LIB = ROOT / "lib"
ASSETS = ROOT / "assets"
OUT = ROOT / "tutorials.pdf"

BRAND = colors.HexColor("#5C3D2E")
ACCENT = colors.HexColor("#C4A484")
CODE_BG = colors.HexColor("#F4F1EC")
MUTED = colors.HexColor("#6B5E55")
TASK = colors.HexColor("#E8F0FE")
WARN = colors.HexColor("#FFF4E5")
OK = colors.HexColor("#EEF6F0")
CHK = colors.HexColor("#F3E8FF")


def S():
    b = getSampleStyleSheet()
    return {
        "Title": ParagraphStyle("t", parent=b["Title"], fontSize=24, textColor=BRAND, alignment=TA_CENTER, spaceAfter=8),
        "Sub": ParagraphStyle("s", parent=b["Normal"], fontSize=11, textColor=MUTED, alignment=TA_CENTER, spaceAfter=6),
        "H1": ParagraphStyle("h1", parent=b["Heading1"], fontSize=15, textColor=BRAND, spaceBefore=14, spaceAfter=7, keepWithNext=1),
        "H2": ParagraphStyle("h2", parent=b["Heading2"], fontSize=12, textColor=BRAND, spaceBefore=10, spaceAfter=5, keepWithNext=1),
        "H3": ParagraphStyle("h3", parent=b["Heading3"], fontSize=10.5, textColor=colors.HexColor("#3E2C23"), spaceBefore=7, spaceAfter=3, keepWithNext=1),
        "Body": ParagraphStyle("b", parent=b["Normal"], fontSize=9, leading=12, alignment=TA_JUSTIFY, spaceAfter=5),
        "Bullet": ParagraphStyle("bu", parent=b["Normal"], fontSize=8.5, leading=11, leftIndent=10, spaceAfter=2),
        "Code": ParagraphStyle("c", parent=b["Code"], fontName="Courier", fontSize=6.5, leading=8.2, backColor=CODE_BG),
        "Path": ParagraphStyle("p", parent=b["Normal"], fontName="Courier-Bold", fontSize=7.5, textColor=BRAND, spaceBefore=5, spaceAfter=1),
        "Box": ParagraphStyle("x", parent=b["Normal"], fontSize=8.5, leading=11),
        "TOC": ParagraphStyle("toc", parent=b["Normal"], fontSize=8.5, leading=11),
        "TH": ParagraphStyle("th", parent=b["Normal"], fontSize=7, textColor=colors.white, fontName="Helvetica-Bold"),
        "TC": ParagraphStyle("tc", parent=b["Normal"], fontSize=7, leading=9),
        "Small": ParagraphStyle("sm", parent=b["Normal"], fontSize=7.5, textColor=MUTED, spaceAfter=3),
    }


def footer(c, doc):
    c.saveState()
    c.setStrokeColor(ACCENT)
    c.line(0.6 * inch, A4[1] - 0.48 * inch, A4[0] - 0.6 * inch, A4[1] - 0.48 * inch)
    c.setFont("Helvetica", 7)
    c.setFillColor(MUTED)
    c.drawString(0.6 * inch, A4[1] - 0.38 * inch, "MU Study — Hands-On Reconstruction Course")
    c.line(0.6 * inch, 0.48 * inch, A4[0] - 0.6 * inch, 0.48 * inch)
    c.drawCentredString(A4[0] / 2, 0.3 * inch, f"Page {doc.page}")
    c.restoreState()


def P(st, t, k="Body"):
    return Paragraph(str(t).replace("\n", "<br/>"), st[k])


def box(st, title, body, bg):
    inner = [Paragraph(f"<b>{title}</b>", st["Box"]), Paragraph(body.replace("\n", "<br/>"), st["Box"])]
    t = Table([[inner]], colWidths=[6.7 * inch])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), bg),
        ("BOX", (0, 0), (-1, -1), 0.4, ACCENT),
        ("LEFTPADDING", (0, 0), (-1, -1), 7),
        ("RIGHTPADDING", (0, 0), (-1, -1), 7),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]))
    return KeepTogether([Spacer(1, 3), t, Spacer(1, 3)])


def code_blocks(st, path, text):
    parts = []
    if path:
        parts.append(Paragraph(path, st["Path"]))
    body = text.replace("\t", "  ")
    chunks, cur, n = [], [], 0
    for line in body.splitlines(True):
        if n + len(line) > 14000 and cur:
            chunks.append("".join(cur))
            cur, n = [line], len(line)
        else:
            cur.append(line)
            n += len(line)
    if cur:
        chunks.append("".join(cur))
    for i, ch in enumerate(chunks):
        if i:
            parts.append(Paragraph(f"{path} — continued ({i+1}/{len(chunks)})", st["Path"]))
        parts.append(Preformatted(ch, st["Code"], maxLineLength=102))
    return parts


def tbl(st, headers, rows, widths=None):
    data = [[Paragraph(h, st["TH"]) for h in headers]]
    for r in rows:
        data.append([Paragraph(str(c), st["TC"]) for c in r])
    t = Table(data, colWidths=widths, repeatRows=1)
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), BRAND),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, CODE_BG]),
        ("GRID", (0, 0), (-1, -1), 0.25, ACCENT),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 2),
        ("RIGHTPADDING", (0, 0), (-1, -1), 2),
        ("TOPPADDING", (0, 0), (-1, -1), 2),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 2),
    ]))
    return t


def bullets(st, items):
    return [Paragraph(f"• {i}", st["Bullet"]) for i in items]


def numbered(st, items):
    return [Paragraph(f"{n}. {i}", st["Bullet"]) for n, i in enumerate(items, 1)]


def loop(st, learn, understand, build, task, verify, debug="", challenge="", checkpoint=""):
    out = []
    out.append(Paragraph("Learn → Build → Test loop", st["H3"]))
    out.append(box(st, "LEARN", learn, OK))
    out.append(box(st, "UNDERSTAND", understand, OK))
    out.append(box(st, "BUILD", build, TASK))
    out.append(box(st, "TASK", task, TASK))
    out.append(box(st, "VERIFY", verify, CHK))
    if debug:
        out.append(box(st, "DEBUG", debug, WARN))
    if challenge:
        out.append(box(st, "MINI CHALLENGE", challenge, TASK))
    if checkpoint:
        out.append(box(st, "CHECKPOINT", checkpoint, CHK))
    return out


# ---------------------------------------------------------------------------
# Screen / provider metadata for auto lessons
# ---------------------------------------------------------------------------

SCREENS = [
    ("SplashScreen", "/splash", "auth/splash_screen.dart", "all", "Branded splash then navigates to /boot", "—", "Session not required"),
    ("SetupRequiredScreen", "(standalone)", "auth/setup_required_screen.dart", "all", "Shown when Env.isConfigured is false", "Env", "No Supabase init"),
    ("LoginScreen", "/login", "auth/login_screen.dart", "guest", "Username/password login", "authRepositoryProvider", "RPC get_auth_email_by_username"),
    ("LanguageSelectionScreen", "/language", "auth/language_selection_screen.dart", "authed", "First-run EN/RU/UZ", "localeProvider, currentProfileProvider", "profiles.preferred_language"),
    ("StudentDashboardScreen", "/student/dashboard", "student/home/student_dashboard_screen.dart", "student", "Home + announcements", "announcementsProvider", "announcements"),
    ("StudentAssignmentsScreen", "/student/assignments", "student/homework/student_assignments_screen.dart", "student", "Assignment list + detail class", "assignmentsProvider", "assignments"),
    ("StudentTaskSubmitScreen", "/student/tasks/:taskId", "student/homework/student_task_submit_screen.dart", "student", "Submit text/file/voice", "tasks/submissions", "submissions + storage"),
    ("StudentFocusScreen", "/student/focus", "student/focus/student_focus_screen.dart", "student", "Pomodoro/free focus", "focusSessionProvider", "SharedPreferences only"),
    ("StudentMarksScreen", "/student/marks", "student/marks/student_marks_screen.dart", "student", "Own marks & averages", "myMarksProvider", "marks + views"),
    ("StudentAttendanceScreen", "/student/attendance", "student/attendance/student_attendance_screen.dart", "student", "Attendance calendar", "attendance*", "attendance"),
    ("StudentNotificationsScreen", "/student/notifications", "student/notifications/student_notifications_screen.dart", "student", "Inbox", "notificationsProvider", "notifications realtime"),
    ("StudentProfileScreen", "/student/profile", "student/profile/student_profile_screen.dart", "student", "Wrapper → AppProfileScreen", "profile providers", "profiles"),
    ("TeacherDashboardScreen", "/teacher/dashboard", "teacher/dashboard/teacher_dashboard_screen.dart", "teacher", "Stats + shortcuts", "myGroupsProvider", "groups"),
    ("TeacherAssignmentsScreen", "/teacher/assignments", "teacher/assignments/teacher_assignments_screen.dart", "teacher", "Create/list assignments", "assignmentsProvider", "assignments/templates"),
    ("TeacherHomeworkPackScreen", "/teacher/assignments/:id", "teacher/homework/teacher_homework_pack_screen.dart", "teacher", "Pack tasks & progress", "tasksProvider", "tasks"),
    ("TeacherSubmissionsScreen", "/teacher/submissions", "teacher/homework/teacher_submissions_screen.dart", "teacher", "Review submissions", "teacherSubmissionsProvider", "submissions"),
    ("TeacherAttendanceScreen", "/teacher/attendance", "teacher/attendance/teacher_attendance_screen.dart", "teacher", "Take attendance", "attendance* + ensure_lesson_session", "lesson_sessions"),
    ("TeacherMarksScreen", "/teacher/marks", "teacher/marks/teacher_marks_screen.dart", "teacher", "Gradebook", "groupMarksProvider", "marks"),
    ("TeacherAnalyticsScreen", "/teacher/analytics", "teacher/analytics/teacher_analytics_screen.dart", "teacher", "Charts", "marks/attendance aggregates", "views"),
    ("TeacherAnnouncementsScreen", "/teacher/announcements", "teacher/announcements/teacher_announcements_screen.dart", "teacher", "Group announcements", "announcementsProvider", "announcements"),
    ("TeacherNotificationsScreen", "/teacher/notifications", "teacher/notifications/teacher_notifications_screen.dart", "teacher", "Reuses student inbox UI", "notificationsProvider", "notifications"),
    ("TeacherProfileScreen", "/teacher/profile", "teacher/profile/teacher_profile_screen.dart", "teacher", "Wrapper → AppProfileScreen", "profile", "profiles"),
    ("AdminDashboardScreen", "/admin/dashboard", "admin/dashboard/admin_dashboard_screen.dart", "admin", "Platform stats", "adminPlatformStatsProvider", "counts"),
    ("AdminUsersScreen", "/admin/users", "admin/users/admin_users_screen.dart", "admin", "Create/disable users", "allProfilesProvider + admin_create_user", "profiles/auth"),
    ("AdminGroupsScreen", "/admin/groups", "admin/groups/admin_groups_screen.dart", "admin", "Groups CRUD", "adminGroupsProvider", "groups + trigger chat_rooms"),
    ("AdminAnalyticsScreen", "/admin/analytics", "admin/analytics/admin_analytics_screen.dart", "admin", "Admin charts", "admin stats", "multiple"),
    ("AdminAcademicYearsScreen", "/admin/academic-years", "admin/academic_years/admin_academic_years_screen.dart", "admin", "Years & terms", "academic RPCs", "academic_*"),
    ("AdminAnnouncementsScreen", "/admin/announcements", "admin/announcements/admin_announcements_screen.dart", "admin", "School announcements", "adminAnnouncementsProvider", "announcements"),
    ("AdminNotificationsScreen", "/admin/notifications", "admin/notifications/admin_notifications_screen.dart", "admin", "Placeholder empty state", "—", "—"),
    ("AdminCredentialPrintScreen", "/admin/credential-print", "admin/credentials/admin_credential_print_screen.dart", "admin", "Print login slips PDF", "credential helpers / RPCs", "login_credentials optional"),
    ("AdminMassDataGeneratorScreen", "/admin/mass-generator", "admin/data_generator/admin_mass_data_generator_screen.dart", "admin", "Mass seed RPC", "admin_mass_generate_school_data", "many tables"),
    ("AdminProfileScreen", "/admin/profile", "admin/profile/admin_profile_screen.dart", "admin", "Wrapper → AppProfileScreen", "profile", "profiles"),
    ("ChatListScreen", "/*/chat", "chat/list/chat_list_screen.dart", "all roles", "Room list with unread", "chatRoomsProvider", "chat_room_summaries + RPC"),
    ("ChatRoomScreen", "/*/chat/:roomId", "chat/room/chat_room_screen.dart", "all roles", "Messaging UI", "chatMessagesProvider", "chat_messages realtime/storage"),
    ("AppProfileScreen", "via wrappers", "profile/app_profile_screen.dart", "all", "Theme/style/language/password/logout", "theme/locale/profile", "profiles + avatars"),
]

PROVIDERS = [
    ("authStateProvider", "auth/auth_provider.dart", "Stream&lt;AuthState&gt;", "Supabase auth stream for router refresh"),
    ("authRepositoryProvider", "auth/auth_provider.dart", "AuthRepository", "Username→email RPC, signIn, changePassword, signOut"),
    ("currentProfileProvider", "auth/auth_provider.dart", "Profile?", "Loads profiles row; offline cache fallback"),
    ("teacherProfileProvider", "auth/auth_provider.dart", "TeacherProfile?", "teachers by profile_id"),
    ("studentProfileProvider", "auth/auth_provider.dart", "StudentProfile?", "students by profile_id"),
    ("localeProvider", "settings/locale_provider.dart", "Locale", "EN/RU/UZ + profile persistence"),
    ("themeModeProvider", "settings/theme_provider.dart", "ThemeMode", "light/dark/system"),
    ("appStyleProvider", "settings/theme_provider.dart", "AppStyle", "4 visual styles"),
    ("myGroupsProvider", "groups/group_providers.dart", "List&lt;StudyGroup&gt;", "Teacher-owned or student membership"),
    ("activeGroupIdProvider", "groups/group_providers.dart", "String?", "Selected group context"),
    ("groupMembersProvider", "groups/group_providers.dart", "List&lt;GroupMember&gt;", "group_students join profiles"),
    ("assignmentsProvider", "homework/assignment_providers.dart", "paged Assignments", "assignments filtered by role/group"),
    ("assignmentDetailProvider", "homework/assignment_providers.dart", "Assignment", "single row"),
    ("tasksProvider", "homework/assignment_providers.dart", "List&lt;TaskItem&gt;", "tasks by assignment_id"),
    ("teacherSubmissionsProvider", "homework/teacher_submissions_provider.dart", "submissions", "pending review for teacher groups"),
    ("groupMarksProvider / myMarksProvider", "marks/marks_providers.dart", "marks pages", "CRUD marks; averages"),
    ("attendance providers", "attendance/attendance_providers.dart", "records/stats", "ensure_lesson_session + upsert"),
    ("chatRoomsProvider", "chat/chat_providers.dart", "room summaries", "view + unread RPC + realtime"),
    ("chatMessagesProvider", "chat/chat_providers.dart", "ChatMessagesNotifier", "messages, media, reactions, reads"),
    ("unreadChatCountProvider", "chat/chat_providers.dart", "int", "Shell badge"),
    ("notificationsProvider", "notifications/notification_providers.dart", "inbox", "realtime notifications"),
    ("announcementsProvider", "notifications/notification_providers.dart", "announcements", "group feed"),
    ("focusSessionProvider", "focus/focus_session_provider.dart", "session state", "local prefs timer"),
    ("focusChatMutedProvider", "focus/focus_session_provider.dart", "bool", "hides chat badge"),
    ("admin* providers", "admin/admin_providers.dart", "stats/users/groups", "admin dashboards"),
]


FEATURES = [
    {
        "name": "Authentication & session",
        "story": "Guest opens Login → enters username+password → RPC resolves synthetic email → signInWithPassword → profile load → language/disabled/role gates → dashboard.",
        "arch": "LoginScreen → AuthRepository → rpc(get_auth_email_by_username) → auth.signInWithPassword → authStateProvider → currentProfileProvider → go_router redirect",
        "db": "profiles (auth_email, role, is_disabled, preferred_*); auth.users; auth.identities; RPC get_auth_email_by_username",
        "files": ["lib/providers/auth/auth_provider.dart", "lib/screens/auth/login_screen.dart", "lib/core/router/app_router.dart", "lib/models/profile.dart"],
        "queries": ".rpc('get_auth_email_by_username'); auth.signInWithPassword; .from('profiles').select().eq('id', uid)",
        "task": "Log in as first admin. Log out. Kill app and relaunch — session should restore to role home (after language set).",
        "verify": "Wrong password shows localized loginIncorrect. Disabled profile cannot resolve email (RPC filters is_disabled).",
        "challenge": "Explain why the client must not invent email locally.",
    },
    {
        "name": "Language selection & localization",
        "story": "New user without preferred_language is forced to /language → picks EN/RU/UZ → saved to SharedPreferences + profiles.preferred_language → router allows home.",
        "arch": "LanguageSelectionScreen → LocaleController → profiles.update + prefs → MaterialApp.locale",
        "db": "profiles.preferred_language CHECK IN (en,ru,uz)",
        "files": ["lib/screens/auth/language_selection_screen.dart", "lib/providers/settings/locale_provider.dart", "lib/l10n/app_*.arb"],
        "queries": ".from('profiles').update({preferred_language})",
        "task": "Switch language in profile settings; restart app; UI stays in that language.",
        "verify": "flutter gen-l10n succeeds; context.l10n.appName resolves.",
        "challenge": "Add a harmless new ARB key in all three languages and display it on profile.",
    },
    {
        "name": "Themes & styles",
        "story": "User picks light/dark/system and one of four styles (modern, naturePaper, softNeumorphism, monochromeWorkspace). Persisted locally and on profile.",
        "arch": "AppProfileScreen → ThemeModeController/AppStyleController → AppTheme → backdrops",
        "db": "profiles.preferred_theme, preferred_style (CHECKs)",
        "files": ["lib/core/theme/*", "lib/providers/settings/theme_provider.dart", "lib/screens/profile/*"],
        "queries": "profiles update preferred_theme/style",
        "task": "Switch to Nature Paper dark; verify backdrop and colors change instantly (themeAnimationDuration zero).",
        "verify": "preferred_style column matches AppStyle.name.",
        "challenge": "Name which ThemeExtension carries accent/ink tokens.",
    },
    {
        "name": "Admin users",
        "story": "Admin opens Users → creates username/password/full name/role(/sphere) → RPC admin_create_user inserts Auth+profile+teacher/student.",
        "arch": "AdminUsersScreen → supabase.rpc('admin_create_user') → SECURITY DEFINER inserts",
        "db": "admin_create_user; profiles; teachers/students; optional login_credentials",
        "files": ["lib/screens/admin/users/admin_users_screen.dart", "export/fn_admin_create_user.sql"],
        "queries": "rpc admin_create_user; select profiles paged",
        "task": "Create teacher sphere=math and a student. Confirm teachers/students rows exist.",
        "verify": "Non-admin calling RPC raises Not authorized. Teacher without sphere raises Sphere required.",
        "challenge": "Disable a user and confirm login fails.",
    },
    {
        "name": "Groups & membership",
        "story": "Admin creates group title under a teacher → trigger creates chat_rooms → members added in group_students → students/teachers see myGroups.",
        "arch": "AdminGroupsScreen → insert groups → trigger ensure_chat_room_for_group → group_students upsert",
        "db": "groups unique(teacher_id,title); group_students unique(group_id,student_id); chat_rooms 1:1 group",
        "files": ["lib/screens/admin/groups/admin_groups_screen.dart", "lib/providers/groups/group_providers.dart"],
        "queries": ".from('groups'); .from('group_students').select('..., students(profiles(...))')",
        "task": "Create 'Algebra A', add student, open Chat list — room appears.",
        "verify": "Duplicate title for same teacher fails unique index.",
        "challenge": "Explain member_count in chat_room_summaries (+1 teacher).",
    },
    {
        "name": "Assignments & homework packs",
        "story": "Teacher creates static or homework_pack assignment for active group → adds ordered tasks → students see list → open pack tasks.",
        "arch": "TeacherAssignmentsScreen → insert assignments/tasks → AssignmentsNotifier pages → StudentAssignmentsScreen",
        "db": "assignments.type enum; tasks.sort_order; RLS teacher manage / member select",
        "files": ["lib/providers/homework/assignment_providers.dart", "lib/screens/teacher/assignments/teacher_assignments_screen.dart", "lib/screens/student/homework/student_assignments_screen.dart"],
        "queries": ".from('assignments').select().eq('group_id', ...); .from('tasks').eq('assignment_id', ...).order('sort_order')",
        "task": "Create homework_pack with 2 tasks. Student sees both.",
        "verify": "trg_assignment_notify inserts notifications for group students.",
        "challenge": "Save an assignment_templates JSON draft and reuse it.",
    },
    {
        "name": "Submissions (text/file/voice)",
        "story": "Student opens task → types answer and/or uploads file/records voice → upsert submissions → teacher reviews score/feedback → trigger may sync mark + notify.",
        "arch": "StudentTaskSubmitScreen → storage submissions bucket → submissions upsert → TeacherSubmissionsScreen update",
        "db": "submissions unique(task_id,student_id); voice_url; status enum; sync_submission_mark trigger",
        "files": ["lib/screens/student/homework/student_task_submit_screen.dart", "lib/providers/homework/teacher_submissions_provider.dart", "lib/components/attachments/*"],
        "queries": "storage.from('submissions').upload; .from('submissions').upsert; update score/feedback",
        "task": "Submit text+voice; teacher set score 88; confirm mark row if trigger fires.",
        "verify": "Path includes studentId/taskId; signed URL works.",
        "challenge": "Resubmit same task — unique constraint upserts not duplicates.",
    },
    {
        "name": "Marks & weighted averages",
        "story": "Teacher gradebook adds marks with category/percentage/weight → student sees list + average from view round(sum(p*w)/sum(w),2).",
        "arch": "TeacherMarksScreen sheets → marks insert/update/delete → myMarksProvider / views",
        "db": "marks checks 0–100 & weight>0; student_mark_averages; student_group_mark_averages",
        "files": ["lib/providers/marks/marks_providers.dart", "lib/screens/teacher/marks/*", "lib/screens/student/marks/student_marks_screen.dart"],
        "queries": ".from('marks').insert/update/delete; select averages views",
        "task": "Add quiz 90 weight 1 and project 70 weight 2; verify average = (90+140)/3 = 76.67.",
        "verify": "Student B cannot read Student A marks (RLS).",
        "challenge": "Export CSV via marks_csv_export helper.",
    },
    {
        "name": "Attendance & lesson sessions",
        "story": "Teacher picks date → ensure_lesson_session(group,date) → upsert attendance rows → student calendar/stats. Future dates rejected.",
        "arch": "TeacherAttendanceScreen → rpc ensure_lesson_session → attendance upsert → StudentAttendanceScreen",
        "db": "lesson_sessions unique(group,date); attendance unique constraints; attendance_sync_session trigger",
        "files": ["lib/providers/attendance/attendance_providers.dart", "lib/screens/teacher/attendance/teacher_attendance_screen.dart"],
        "queries": "rpc ensure_lesson_session; .from('attendance').upsert",
        "task": "Mark present/late today; reopen day — values persist.",
        "verify": "Future date RPC raises check_violation.",
        "challenge": "Explain weekend handling in UI (not DB).",
    },
    {
        "name": "Announcements",
        "story": "Teacher/admin posts title+description for a group → trigger notifies members → dashboards show expandable cards.",
        "arch": "Announcements screens → insert announcements → trg_announcement_notify → notifications",
        "db": "announcements.teacher_id nullable for admin; image_urls/file_urls jsonb",
        "files": ["lib/screens/teacher/announcements/*", "lib/screens/admin/announcements/*", "lib/screens/student/home/widgets/*"],
        "queries": ".from('announcements').insert/select",
        "task": "Post announcement; student dashboard shows it; notification row exists.",
        "verify": "Other group does not see it (RLS).",
        "challenge": "Why admin can omit teacher_id.",
    },
    {
        "name": "Notifications & realtime",
        "story": "Server triggers insert notifications → client stream/realtime updates inbox → mark read → optional action_path navigation.",
        "arch": "triggers → notifications → notificationsProvider channel → UI",
        "db": "notifications; realtime publication; policies own-only",
        "files": ["lib/providers/notifications/notification_providers.dart", "lib/screens/*/notifications/*"],
        "queries": ".from('notifications'); .channel.onPostgresChanges",
        "task": "Create assignment while student inbox open — notification appears without refresh.",
        "verify": "Student cannot select another user's notifications.",
        "challenge": "Map kind/action_path for assignment notify function.",
    },
    {
        "name": "Chat (rooms, media, reactions, selection)",
        "story": "User opens chat list → room → reverse list → send text/media → long-press Overlay menu Reply/Copy/Edit/Select/Delete → reactions via RPC → unread via RPC. Own-only select/delete in UI.",
        "arch": "ChatList/Room → chat providers → chat_room_summaries/messages/storage/realtime/rpc",
        "db": "chat_*; message_reads; message_reactions; buckets chat-*; can_access_chat_room",
        "files": ["lib/providers/chat/chat_providers.dart", "lib/screens/chat/**", "lib/screens/chat/room/widgets/message_bubble.dart"],
        "queries": "from chat_room_summaries; rpc chat_unread_counts; storage upload path roomId/uid/stamp_file; rpc toggle_message_reaction",
        "task": "Send image; react; reply; select only own; soft-delete own.",
        "verify": "Other's message menu has no Delete/Select; selection mode has no empty circles on others; list padding clears shell nav.",
        "challenge": "Why Overlay.insert instead of showGeneralDialog.",
    },
    {
        "name": "Focus mode",
        "story": "Student starts Pomodoro/free timer → ambient UI → chat badge muted → summary on complete. No database.",
        "arch": "StudentFocusScreen → FocusSessionController → SharedPreferences",
        "db": "None (local focus_session_v1)",
        "files": ["lib/providers/focus/focus_session_provider.dart", "lib/screens/student/focus/**"],
        "queries": "none",
        "task": "Start session; confirm chat badge muted; kill app; restore if persisted.",
        "verify": "No Supabase traffic required.",
        "challenge": "Change Pomodoro minutes in code and verify.",
    },
    {
        "name": "Academic years & terms",
        "story": "Admin creates next year with 4 terms → set current → edit term dates via RPCs → marks UX can filter by term windows.",
        "arch": "AdminAcademicYearsScreen → admin_* academic RPCs",
        "db": "academic_years one is_current; academic_terms unique(year,semester)",
        "files": ["lib/screens/admin/academic_years/admin_academic_years_screen.dart", "export/fn_admin_*.sql"],
        "queries": "rpc admin_create_next_academic_year / set_current / update_term / delete",
        "task": "Create year; set current; edit semester 1 dates.",
        "verify": "Only one is_current row (partial unique index).",
        "challenge": "Read academic_semester_bounds defaults.",
    },
    {
        "name": "Credential slips & mass generator",
        "story": "Admin prints PDF login slips (optional login_credentials) and/or mass-generates demo school data via RPC.",
        "arch": "CredentialPrintScreen / MassGenerator → RPCs + Syncfusion PDF",
        "db": "optional login_credentials; admin_mass_generate_school_data; admin_reset_password",
        "files": ["lib/screens/admin/credentials/*", "lib/screens/admin/data_generator/*", "lib/core/admin/*"],
        "queries": "rpc admin_list_login_slips / admin_mass_generate_school_data / admin_reset_password",
        "task": "Generate a slips PDF for students (if login_credentials SQL applied).",
        "verify": "No service_role key in app.",
        "challenge": "Explain plaintext password storage risk on login_credentials.",
    },
    {
        "name": "Avatars & profile settings",
        "story": "User uploads avatar to public avatars bucket path {profileId}/avatar.jpg → updates profiles.avatar_url → settings change password/theme/language.",
        "arch": "AppProfileScreen → storage avatars → profiles.update",
        "db": "avatars public bucket; profiles.avatar_url",
        "files": ["lib/screens/profile/app_profile_screen.dart", "lib/components/brand/app_logo.dart"],
        "queries": "storage.from('avatars').upload; getPublicUrl; profiles.update",
        "task": "Upload avatar; confirm public URL loads in chat header.",
        "verify": "Policy allows public SELECT on avatars.",
        "challenge": "Change password via AuthRepository.changePassword flow.",
    },
]


def feature_lesson(st, f):
    s = [Paragraph(f"Rebuilding feature: {f['name']}", st["H1"])]
    s.append(Paragraph("A. What we are building", st["H2"]))
    s.append(P(st, f["story"]))
    s.append(Paragraph("B. User story / flow", st["H2"]))
    s.append(P(st, f["story"]))
    s.append(Paragraph("C. Architecture", st["H2"]))
    s.extend(code_blocks(st, "Architecture", f["arch"]))
    s.append(Paragraph("D. Database dependencies", st["H2"]))
    s.append(P(st, f["db"]))
    s.append(Paragraph("E. Flutter files to create", st["H2"]))
    s.extend(bullets(st, f["files"]))
    s.append(P(st, "Create each path and paste the COMPLETE file from the Screen/Provider lessons below or Appendix D. The lesson text teaches why; the file body is exact."))
    s.append(Paragraph("F–H. Queries & state", st["H2"]))
    s.append(P(st, f"<b>Key Supabase operations:</b> {f['queries']}"))
    s.append(Paragraph("R–U. Task / verify / challenge", st["H2"]))
    s.extend(loop(
        st,
        learn=f"Feature goal: {f['name']}.",
        understand=f["arch"],
        build="Implement listed files with complete source from later Screen/Provider lessons (or Appendix D reference).",
        task=f["task"],
        verify=f["verify"],
        challenge=f["challenge"],
        checkpoint=f"Feature '{f['name']}' works end-to-end on your rebuild.",
    ))
    s.append(PageBreak())
    return s


def screen_lesson(st, meta):
    name, route, rel, role, purpose, providers, db = meta
    path = f"lib/screens/{rel}"
    fp = ROOT / path
    s = [Paragraph(f"Rebuilding screen: {name}", st["H1"])]
    s.append(Paragraph("1–5. Purpose, route, role, entry", st["H2"]))
    s.append(tbl(st, ["Field", "Value"], [
        ["Purpose", purpose],
        ["Route", route],
        ["Role", role],
        ["File", path],
        ["Providers", providers],
        ["DB / Storage / Realtime", db],
    ], [1.5 * inch, 5.1 * inch]))
    s.append(Paragraph("6. How to think about this screen", st["H2"]))
    s.append(P(st,
        f"This screen is a ConsumerWidget/StatefulWidget under go_router. "
        f"It watches Riverpod providers, renders loading/error/data, and navigates with context.go/push. "
        f"Do not redesign it — reproduce the exact widget tree and callbacks from the source below."))
    s.append(Paragraph("7. Complete implementation", st["H2"]))
    if fp.exists():
        text = fp.read_text(encoding="utf-8")
        # Heuristic hierarchy hint
        hierarchy = []
        for m in re.finditer(r"\b(Scaffold|AppBar|ListView|Column|Row|Stack|BottomNavigationBar|FloatingActionButton|RefreshIndicator)\b", text):
            hierarchy.append(m.group(1))
        # unique preserve order
        seen = []
        for h in hierarchy:
            if h not in seen:
                seen.append(h)
        if seen:
            s.append(P(st, "Widget hierarchy keywords found in source: " + " → ".join(seen[:12])))
        s.extend(code_blocks(st, path, text))
    else:
        s.append(box(st, "MISSING FILE", path, WARN))
    s.append(Paragraph("8. Explanation of important parts", st["H2"]))
    s.append(P(st,
        "Read top-to-bottom: imports → providers watched → build method branches for loading/error/empty → "
        "interaction handlers (onPressed/onTap) that call notifiers or navigate. Match localization via context.l10n. "
        "Theme colors come from Theme.of(context) / AppColors / AppStyleTokens."))
    s.extend(loop(
        st,
        learn=f"Screen {name} serves: {purpose}",
        understand=f"Route {route} for role {role}; depends on {providers}.",
        build=f"Create {path} with the complete implementation above.",
        task=f"Navigate to {route} while logged in as an appropriate role and exercise primary actions.",
        verify=f"No red error screen; empty/loading states appear when data missing; DB side-effects match '{db}'.",
        debug="If blank: check redirect (role/language). If permission error: RLS/membership. If missing l10n: run flutter gen-l10n.",
        challenge=f"Point to the exact provider.watch/read call that loads primary data on {name}.",
        checkpoint=f"{name} reachable and functional.",
    ))
    s.append(PageBreak())
    return s


def provider_lesson(st, meta):
    name, rel, state, purpose = meta
    path = f"lib/providers/{rel}"
    fp = ROOT / path
    s = [Paragraph(f"Rebuilding provider: {name}", st["H1"])]
    s.append(tbl(st, ["Field", "Value"], [
        ["Provider", name],
        ["File", path],
        ["State", state],
        ["Purpose", purpose],
    ], [1.4 * inch, 5.2 * inch]))
    s.append(Paragraph("Why Riverpod here", st["H2"]))
    s.append(P(st,
        "Riverpod isolates async data, caching, and invalidation from widgets. Screens watch providers; "
        "mutations live in Notifiers/repositories so UI stays thin."))
    s.append(Paragraph("Complete implementation", st["H2"]))
    if fp.exists():
        s.extend(code_blocks(st, path, fp.read_text(encoding="utf-8")))
        # extract from( patterns
        text = fp.read_text(encoding="utf-8")
        ops = sorted(set(re.findall(r"\.(from|rpc)\('([^']+)'\)", text)))
        if ops:
            s.append(Paragraph("Supabase operations in this file", st["H2"]))
            s.extend(bullets(st, [f".{a}('{b}')" for a, b in ops]))
    else:
        s.append(box(st, "MISSING", path, WARN))
    s.extend(loop(
        st,
        learn=purpose,
        understand=f"State type conceptually: {state}. Consumers are screens that watch this provider.",
        build=f"Create {path} exactly as above.",
        task="Trigger a UI action that refreshes this provider; confirm loading then data.",
        verify="flutter analyze clean on the file; runtime shows expected rows under RLS.",
        debug="Empty data often means RLS or wrong group filter — query Table Editor as the same user via SQL with auth.uid() simulation notes.",
        challenge="List every .invalidate / ref.watch dependency related to this provider.",
        checkpoint=f"Provider {name} works.",
    ))
    s.append(PageBreak())
    return s


def title_toc(st):
    s = [Spacer(1, 1.1 * inch), Paragraph("MU Study", st["Title"])]
    s.append(Paragraph("Hands-On Reconstruction Course", st["Sub"]))
    s.append(Paragraph(
        "Learn → Build → Test → Verify<br/>"
        "Complete SQL & source remain in appendices as reference — the main body teaches you to construct the system.",
        st["Sub"],
    ))
    s.append(Spacer(1, 0.35 * inch))
    s.append(box(st, "Course contract",
                 "You start with an empty directory and a new Supabase project. "
                 "Each lesson explains WHY, shows HOW, gives the EXACT implementation, then a TASK and VERIFY. "
                 "Appendices are encyclopedias — not a substitute for doing the lessons.", OK))
    s.append(PageBreak())
    s.append(Paragraph("Table of Contents", st["H1"]))
    for e in [
        "Part I — Foundations & mental model",
        "Part II — Backend taught object-by-object",
        "Part III — Flutter foundation taught file-by-file",
        "Part IV — Authentication deep lesson + first admin",
        "Part V — Feature lessons (Learn/Build/Test)",
        "Part VI — Every screen lesson",
        "Part VII — Every provider lesson",
        "Part VIII — Query map, RLS teaching, Storage teaching",
        "Part IX — From Zero executable path",
        "Part X — Testing course, troubleshooting, deployment",
        "Part XI — Known limitations & scorecard",
        "Appendix A — COMPLETE_BACKEND.sql",
        "Appendix B — All function SQL files",
        "Appendix C — First admin + optional SQL",
        "Appendix D — Full Dart reference dump",
        "Appendix E — Full ARB files",
        "Appendix F — Asset inventory & categories",
        "Appendix G — Config files",
    ]:
        s.append(Paragraph(e, st["TOC"]))
    s.append(PageBreak())
    return s


def part_i(st):
    s = [Paragraph("Part I — Foundations & mental model", st["H1"])]
    s.append(P(st,
        "MU Study is a Flutter + Supabase school app for Math/English with roles student, teacher, admin. "
        "No public signup. Username login maps to synthetic emails via RPC."))
    s.append(Paragraph("Core data path", st["H2"]))
    s.extend(code_blocks(st, "Path",
        "User action → Widget → Riverpod → supabase.from/rpc/storage/channel\n"
        "→ PostgREST + RLS → Postgres/Storage → Realtime events → Provider → UI"))
    s.extend(loop(
        st,
        learn="You will rebuild frontend + backend, not only copy files blindly.",
        understand="Appendices hold exact bytes of SQL/Dart; lessons teach construction order and meaning.",
        build="Install Flutter SDK ^3.11.5 and create an empty notes file for passwords.",
        task="Run flutter doctor -v until your target device is ready.",
        verify="dart --version ≥ 3.11.5",
        checkpoint="Tooling ready.",
    ))
    s.append(PageBreak())
    return s


def part_ii(st):
    s = [Paragraph("Part II — Backend taught object-by-object", st["H1"])]
    s.append(P(st,
        "Create a new Supabase project. Enable Email auth. Copy Project URL + anon key as placeholders into .env later. "
        "Then apply SQL from Appendix A. Below: how to think about each layer before pasting."))
    s.append(Paragraph("Enums", st["H2"]))
    s.append(P(st, "Seven enums encode domain states (roles, spheres, assignment types, attendance, submission, chat message types, mark categories). Create them before tables that reference them."))
    s.append(Paragraph("Tables (purpose map)", st["H2"]))
    s.append(tbl(st, ["Table", "Purpose", "Written by", "Read by"], [
        ["profiles", "App user + prefs", "admin_create_user / self update", "everyone (RLS)"],
        ["teachers/students", "Role extensions", "admin_create_user", "role-scoped"],
        ["groups/group_students", "Classes & roster", "admin/teacher", "members"],
        ["assignments/tasks", "Work definition", "teacher", "group members"],
        ["submissions", "Student work", "student; teacher scores", "parties"],
        ["marks", "Gradebook", "teacher (+ trigger)", "student own / teacher"],
        ["lesson_sessions/attendance", "Roll call", "teacher", "members"],
        ["announcements/notifications", "Broadcasts & inbox", "teacher/admin/triggers", "targets"],
        ["chat_* / message_*", "Messaging", "members", "can_access_chat_room"],
        ["academic_*", "Calendar years", "admin RPCs", "authenticated select"],
    ], [1.5 * inch, 1.7 * inch, 1.6 * inch, 1.6 * inch]))
    s.append(Paragraph("Functions & triggers", st["H2"]))
    s.append(P(st,
        "Helpers (is_admin, is_teacher_of_group, …) power RLS. RPCs encapsulate auth user creation, unread counts, reactions, academic ops. "
        "Triggers auto-create chat rooms, notify users, sync marks, validate replies. Full bodies: Appendix B."))
    s.append(Paragraph("RLS teaching example", st["H2"]))
    s.append(P(st,
        "Policy chat_messages_insert WITH CHECK (sender_id = auth.uid() AND can_access_chat_room(room_id)) "
        "prevents spoofing another sender and prevents writing into rooms you do not belong to. "
        "Test: student A insert into student B's other-group room must fail."))
    s.extend(loop(
        st,
        learn="Backend is the source of truth for security.",
        understand="Paste Appendix A after understanding object purposes above.",
        build="Run COMPLETE_BACKEND.sql (split if needed: tables→views→functions→triggers→RLS→storage→realtime).",
        task="Confirm 20 base tables + 3 views in Table Editor; 8 storage buckets.",
        verify="SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.prokind='f'; expect 36.",
        debug="extension crypt errors → ensure extensions schema / pgcrypto.",
        checkpoint="Backend empty schema ready for first admin.",
    ))
    s.append(PageBreak())
    return s


def part_iii(st):
    s = [Paragraph("Part III — Flutter foundation taught", st["H1"])]
    s.extend(numbered(st, [
        "flutter create --org com.example --project-name mu_study mu_study",
        "Replace pubspec.yaml (Appendix G) → flutter pub get",
        "Add l10n.yaml + ARBs (Appendix E) → flutter gen-l10n",
        "Implement Env + supabase_client + main.dart (Provider lessons / Appendix D)",
        "Create folder tree matching lib/ screens, providers, models, components, core",
        "Copy assets per Appendix F categories",
        "Set Android/iOS permissions",
    ]))
    for rel in [
        "lib/core/constants/env.dart",
        "lib/supabase/supabase_client.dart",
        "lib/main.dart",
        "lib/models/enums.dart",
        "lib/models/profile.dart",
    ]:
        fp = ROOT / rel
        s.append(Paragraph(f"Build file: {rel}", st["H2"]))
        s.append(P(st, "Why: foundational bootstrap/domain types. Paste complete file, then explain to yourself each public symbol."))
        if fp.exists():
            s.extend(code_blocks(st, rel, fp.read_text(encoding="utf-8")))
    s.extend(loop(
        st,
        learn="Bootstrap order matters: Env before Supabase.initialize.",
        understand="SetupRequiredScreen is the failure mode for missing keys.",
        build="Run the app with invalid key → setup screen; with valid key → splash.",
        task="Confirm SetupRequiredScreen and splash paths.",
        verify="No crash on launch.",
        checkpoint="Flutter skeleton boots against your Supabase.",
    ))
    s.append(PageBreak())
    return s


def part_iv(st):
    s = [Paragraph("Part IV — Authentication deep lesson + first admin", st["H1"])]
    s.append(Paragraph("Chicken-and-egg", st["H2"]))
    s.append(P(st,
        "admin_create_user requires is_admin(), which reads profiles.role='admin'. "
        "Therefore the first admin cannot be created from the app. You insert auth.users + auth.identities + profiles manually once."))
    s.append(Paragraph("What each Auth table is", st["H2"]))
    s.extend(bullets(st, [
        "auth.users — Supabase Auth identity (email + bcrypt password)",
        "auth.identities — links provider 'email' to the user",
        "public.profiles — app profile keyed by same UUID; holds username, role, auth_email, prefs",
    ]))
    s.append(Paragraph("Exact first-admin SQL", st["H2"]))
    s.extend(code_blocks(st, "first_admin_bootstrap.sql", (EXPORT / "first_admin_bootstrap.sql").read_text()))
    s.append(Paragraph("Login pipeline", st["H2"]))
    s.extend(code_blocks(st, "pipeline",
        "username → get_auth_email_by_username → email\n"
        "→ signInWithPassword → session\n"
        "→ currentProfileProvider → profiles\n"
        "→ disabled? / language? / role home"))
    for rel in ["lib/providers/auth/auth_provider.dart", "lib/screens/auth/login_screen.dart", "lib/core/router/app_router.dart"]:
        s.append(Paragraph(rel, st["H2"]))
        s.extend(code_blocks(st, rel, (ROOT / rel).read_text(encoding="utf-8")))
    s.extend(loop(
        st,
        learn="Username login is email login underneath.",
        understand="RPC hides disabled users by returning null email.",
        build="Run first_admin_bootstrap.sql with YOUR_STRONG_PASSWORD; implement auth files above.",
        task="Login as @admin; set language; land on /admin/dashboard; logout; login again.",
        verify="SELECT auth_email FROM profiles WHERE username='@admin'; should be admin@mustudy.internal",
        debug="Invalid login: check RPC grants to anon; check email_confirmed_at; check password crypt.",
        challenge="Create second admin via Admin → Users after first login.",
        checkpoint="Auth loop works.",
    ))
    s.append(PageBreak())
    return s


def part_viii(st):
    s = [Paragraph("Part VIII — Query map, RLS teaching, Storage teaching", st["H1"])]
    s.append(Paragraph("Important query traces (EXACT from providers)", st["H2"]))
    traces = [
        ["assignment_providers", "from('assignments').select", "group/role filter", "assignments_select RLS", "Assignment cards"],
        ["assignment_providers", "from('tasks').order(sort_order)", "assignment_id", "tasks_select", "Task list"],
        ["teacher_submissions", "from submissions/tasks/assignments", "teacher groups", "submissions_select", "Review queue"],
        ["marks_providers", "from('marks') CRUD", "group/student", "marks_* policies", "Gradebook"],
        ["attendance", "rpc ensure_lesson_session + upsert", "group+date", "attendance_teacher", "Roll grid"],
        ["chatRooms", "from chat_room_summaries + rpc chat_unread_counts", "membership", "view+RPC security definer", "Chat list"],
        ["chatMessages", "from chat_messages + storage + rpc toggle_message_reaction", "room_id", "chat_messages_* + storage policies", "Room UI"],
        ["notifications", "from notifications + channel", "user_id", "notifications_own", "Inbox"],
        ["auth", "rpc get_auth_email_by_username", "username", "SECURITY DEFINER", "Login"],
    ]
    s.append(tbl(st, ["Flutter", "Operation", "Filter", "RLS/Security", "UI"], traces,
                 [1.3 * inch, 1.7 * inch, 1.1 * inch, 1.3 * inch, 1.1 * inch]))
    s.append(Paragraph("Storage path teaching", st["H2"]))
    s.extend(code_blocks(st, "Chat upload path convention",
        "bucket = chat-images | chat-videos | chat-voices | chat-files\n"
        "object = '{roomId}/{profileId}/{timestamp}_{filename}'\n"
        "folder[1]=roomId → chat_storage_room_id(name)\n"
        "folder[2]=profileId must equal auth.uid() on insert"))
    s.append(P(st, "Avatars: public bucket avatars/{profileId}/avatar.jpg + getPublicUrl. "
                   "Submissions: private bucket path {studentId}/{taskId}/... + long-lived signed URL."))
    s.extend(loop(
        st,
        learn="Every UI fetch maps to a table/RPC and an RLS gate.",
        understand="Security definer RPCs carefully expose only intended rows.",
        build="After coding chat upload, attempt upload with wrong uid folder — must 403.",
        task="Trace one mark insert from UI to SQL in Table Editor.",
        verify="Row appears with expected FKs.",
        checkpoint="You can explain one full query trace without notes.",
    ))
    s.append(PageBreak())
    return s


def part_ix(st):
    s = [Paragraph("Part IX — From Zero executable path", st["H1"])]
    steps = [
        ("01", "Install Flutter", "flutter doctor -v", "Dart ≥ 3.11.5"),
        ("02", "Create app", "flutter create --org com.example --project-name mu_study mu_study", "Project runs counter demo"),
        ("03", "Dependencies", "Paste Appendix G pubspec → flutter pub get", "No resolution errors"),
        ("04", "Supabase project", "Create project; enable Email", "URL + anon key available"),
        ("05", "Database", "Run Appendix A COMPLETE_BACKEND.sql", "20 tables, 8 buckets"),
        ("06", "First admin", "Run Appendix C first_admin_bootstrap.sql", "Admin profile row"),
        ("07", "Env", "Create .env placeholders with YOUR keys", "Env.isConfigured true"),
        ("08", "Foundation files", "Part III files + models", "App reaches splash"),
        ("09", "Auth + router", "Part IV files", "Login to /admin/dashboard"),
        ("10", "Localization", "Appendix E ARBs → gen-l10n", "Language screen works"),
        ("11", "Shell + themes", "AppShell + theme providers", "Tabs render"),
        ("12", "Features", "Parts V–VII in order: groups→assignments→…→chat", "Checkpoints pass"),
        ("13", "Assets", "Appendix F copy Category C binaries", "Nature Paper/Lottie optional fidelity"),
        ("14", "Platform perms", "Manifest + Info.plist", "Mic/photo prompts"),
        ("15", "Test course", "Part X scripts", "Acceptance ticks"),
        ("16", "Build", "flutter build apk|web|ipa", "Artifact produced"),
    ]
    for num, title, action, expected in steps:
        s.append(Paragraph(f"STEP {num} — {title}", st["H3"]))
        s.append(P(st, f"<b>Action:</b> {action}"))
        s.append(P(st, f"<b>Expected:</b> {expected}"))
    s.append(PageBreak())
    return s


def part_x(st):
    s = [Paragraph("Part X — Testing, troubleshooting, deployment", st["H1"])]
    s.append(Paragraph("Procedural test template (use for each feature)", st["H2"]))
    s.extend(code_blocks(st, "Template",
        "PRECONDITIONS:\nSTEPS:\nEXPECTED UI:\nEXPECTED DB:\nFAILURE TEST:\nSECURITY TEST:"))
    s.append(Paragraph("Example — student submits homework", st["H2"]))
    s.extend(code_blocks(st, "Test",
        "PRECONDITIONS: student in group; homework_pack with task\n"
        "STEPS: login student → Assignments → task → text+submit\n"
        "EXPECTED UI: success; teacher sees submission\n"
        "EXPECTED DB: submissions.status=submitted; student_id/task_id match\n"
        "FAILURE: empty submit blocked by validation\n"
        "SECURITY: other student cannot read submission (RLS)"))
    s.append(Paragraph("Troubleshooting format", st["H2"]))
    s.append(tbl(st, ["Problem", "Why", "Diagnose", "Fix", "Verify"], [
        ["SetupRequiredScreen", "Key sanitized", "Print Env after load", "Use eyJ anon key", "Splash shows"],
        ["Login fails", "RPC/email/password", "SQL select auth_email", "Fix profile/password", "Session exists"],
        ["Empty lists", "RLS/membership", "Check group_students", "Add membership", "Rows appear"],
        ["Storage 403", "Path/policy", "Inspect object name folders", "Fix roomId/uid", "Upload 200"],
        ["Realtime silent", "Publication", "Check supabase_realtime", "Add tables", "Live insert"],
        ["Chat under nav", "extendBody", "Selection mode padding", "shellContentBottomPadding", "Timestamp visible"],
    ], [1.2 * inch, 1.1 * inch, 1.3 * inch, 1.4 * inch, 1.2 * inch]))
    s.append(Paragraph("Deployment (honest)", st["H2"]))
    s.append(P(st,
        "Repository supports Android (Makefile apk; currently debug signing in template), iOS (bundle com.example.muStudy), "
        "and Web (flutter build web). Exact hosting vendor is not prescribed in-repo — choose HTTPS host; set Supabase Auth Site URL. "
        "Never ship service_role. Prefer CI secrets over committing .env."))
    s.append(PageBreak())
    return s


def part_xi(st):
    s = [Paragraph("Part XI — Known limitations & scorecard", st["H1"])]
    s.append(Paragraph("100% reproducible from this PDF + official installs", st["H2"]))
    s.extend(bullets(st, [
        "Database schema, functions, triggers, RLS, storage policies, realtime membership",
        "Dart application logic (all lib sources provided)",
        "ARB localization keys",
        "pubspec/l10n/Makefile/manifests",
        "Auth/RBAC behavior",
    ]))
    s.append(Paragraph("Reproducible behavior, not byte-identical assets (Category C)", st["H2"]))
    s.extend(bullets(st, [
        "Nature-paper PNGs and Lottie JSON binaries — copy from an assets bundle / original assets/ tree",
        "logo.jpeg — replace with your own brand mark if needed",
        "Exact binary reproduction is not possible from text alone; app logic still runs with Material fallbacks",
    ]))
    s.append(Paragraph("Cannot invent", st["H2"]))
    s.extend(bullets(st, [
        "Your Supabase project password / anon key (you create them)",
        "A specific third-party hosting vendor (not fixed in repo)",
    ]))
    s.append(Paragraph("1000-point scorecard", st["H2"]))
    s.append(tbl(st, ["Area", "Pts"], [
        ["Environment", "25"], ["Project/deps", "50"], ["Architecture understanding", "50"],
        ["Database completeness", "100"], ["Functions/triggers", "100"], ["RLS understanding+SQL", "100"],
        ["Storage+Realtime", "75"], ["Auth+first admin", "75"], ["Routing/shell", "50"],
        ["Feature lessons completed", "150"], ["Screen lessons completed", "75"],
        ["Provider lessons completed", "50"], ["Tests+troubleshooting", "50"], ["Deployment hygiene", "25"],
        ["Total", "1000"],
    ], [5.2 * inch, 1.4 * inch]))
    s.append(Paragraph("Final reconstruction challenge", st["H2"]))
    s.append(P(st,
        "Without opening the original Git working tree, rebuild MU Study using only this PDF, official Flutter/Supabase docs, "
        "and an assets folder obtained separately. Grade yourself with the scorecard. Do not paste Appendix D as your first action — "
        "follow Parts I–IX, using appendices when a lesson says to paste a complete file."))
    s.append(PageBreak())
    return s


def appendices(st):
    s = []
    s.append(Paragraph("Appendix A — COMPLETE_BACKEND.sql", st["H1"]))
    s.append(P(st, "Reference dump. Prefer learning Part II first."))
    s.extend(code_blocks(st, "COMPLETE_BACKEND.sql", (EXPORT / "COMPLETE_BACKEND.sql").read_text()))
    s.append(PageBreak())

    s.append(Paragraph("Appendix B — Function SQL files", st["H1"]))
    for f in sorted(EXPORT.glob("fn_*.sql")):
        s.append(Paragraph(f.name, st["H3"]))
        s.extend(code_blocks(st, f.name, f.read_text()))
    s.append(PageBreak())

    s.append(Paragraph("Appendix C — First admin + optional SQL", st["H1"]))
    for name in ["first_admin_bootstrap.sql", "optional_login_credentials.sql", "optional_fix_admin_create_user.sql", "rls_policies.sql"]:
        p = EXPORT / name
        if p.exists():
            s.append(Paragraph(name, st["H2"]))
            s.extend(code_blocks(st, name, p.read_text()))
    s.append(PageBreak())

    s.append(Paragraph("Appendix D — Full Dart reference dump", st["H1"]))
    s.append(P(st, "Encyclopedic reference of every lib/**/*.dart. Use when a lesson tells you to paste a complete file, "
                   "or to compare your rebuild. Prefer screen/provider lessons in Parts VI–VII for teaching order."))
    for fp in sorted(LIB.rglob("*.dart")):
        rel = fp.relative_to(ROOT).as_posix()
        s.extend(code_blocks(st, rel, fp.read_text(encoding="utf-8")))
    s.append(PageBreak())

    s.append(Paragraph("Appendix E — ARB localization", st["H1"]))
    for name in ["app_en.arb", "app_ru.arb", "app_uz.arb"]:
        s.extend(code_blocks(st, f"lib/l10n/{name}", (LIB / "l10n" / name).read_text(encoding="utf-8")))
    s.append(PageBreak())

    s.append(Paragraph("Appendix F — Asset inventory & categories", st["H1"]))
    rows = []
    for fp in sorted(ASSETS.rglob("*")):
        if not fp.is_file() or fp.name in {".DS_Store", ".gitkeep"}:
            continue
        rel = fp.relative_to(ROOT).as_posix()
        if "lottie" in rel:
            cat, purpose = "C", "Animated emoji Lottie"
        elif "nature-paper" in rel:
            cat, purpose = "C", "Nature Paper décor PNG"
        elif "logo" in rel:
            cat, purpose = "C", "Brand logo (replaceable)"
        else:
            cat, purpose = "C", "Asset"
        rows.append([rel, cat, purpose])
    for i in range(0, len(rows), 45):
        s.append(tbl(st, ["Path", "Cat", "Purpose"], rows[i:i+45], [4.4 * inch, 0.5 * inch, 1.7 * inch]))
    s.append(P(st, "Category C = original proprietary/binary; acquire by copying assets/ from a provided bundle. "
                   "Logic works without them; visual fidelity does not."))
    s.append(PageBreak())

    s.append(Paragraph("Appendix G — Config files", st["H1"]))
    for rel in ["pubspec.yaml", "l10n.yaml", "Makefile", "analysis_options.yaml",
                "android/app/src/main/AndroidManifest.xml", "ios/Runner/Info.plist"]:
        fp = ROOT / rel
        if fp.exists():
            s.extend(code_blocks(st, rel, fp.read_text(encoding="utf-8")))
    return s


def build():
    st = S()
    story = []
    story += title_toc(st)
    story += part_i(st)
    story += part_ii(st)
    story += part_iii(st)
    # Models taught before auth
    story.append(Paragraph("Part III-B — Models taught", st["H1"]))
    story.append(P(st, "Create these model files before providers. Each field maps to a DB column or join."))
    for rel in [
        "lib/models/enums.dart",
        "lib/models/profile.dart",
        "lib/models/assignment.dart",
        "lib/models/attendance.dart",
        "lib/models/mark.dart",
        "lib/models/chat.dart",
        "lib/models/notification.dart",
        "lib/models/models.dart",
    ]:
        fp = ROOT / rel
        story.append(Paragraph(f"Rebuilding model file: {rel}", st["H2"]))
        story.append(P(st,
            "Learn: domain types. Understand: fromJson snake_case ↔ Dart camelCase; enums need DB mapping helpers "
            "(e.g. homework_pack). Build: paste complete file. Task: instantiate from a sample JSON map in a dart snippet/test. "
            "Verify: flutter analyze clean."))
        if fp.exists():
            story.extend(code_blocks(st, rel, fp.read_text(encoding="utf-8")))
        story.extend(loop(
            st,
            learn=f"Model file {rel}",
            understand="JSON keys match PostgREST column names.",
            build=f"Create {rel}",
            task="Write a tiny unit assertion that fromJson round-trips critical fields (or run existing tests).",
            verify="analyze clean",
            challenge="Find assignmentTypeToDb and explain why it exists.",
            checkpoint=f"{rel} present",
        ))
    story.append(PageBreak())
    story += part_iv(st)

    story.append(Paragraph("Part V — Feature lessons", st["H1"]))
    story.append(P(st, f"There are {len(FEATURES)} major feature lessons. Each follows Learn→Build→Test."))
    story.append(PageBreak())
    for f in FEATURES:
        story += feature_lesson(st, f)

    story.append(Paragraph("Part VI — Every screen lesson", st["H1"]))
    story.append(P(st, f"{len(SCREENS)} screens. Each includes complete source + task/verify."))
    story.append(PageBreak())
    for meta in SCREENS:
        story += screen_lesson(st, meta)

    story.append(Paragraph("Part VII — Every provider lesson", st["H1"]))
    story.append(P(st, f"{len(PROVIDERS)} provider modules (some files host multiple providers)."))
    story.append(PageBreak())
    # unique files
    seen = set()
    for meta in PROVIDERS:
        key = meta[1]
        if key in seen:
            # still emit short lesson referencing same file
            story += provider_lesson(st, meta)
        else:
            seen.add(key)
            story += provider_lesson(st, meta)

    story += part_viii(st)
    story += part_ix(st)
    story += part_x(st)
    story += part_xi(st)
    print("Appending reference appendices...")
    story += appendices(st)

    doc = SimpleDocTemplate(
        str(OUT), pagesize=A4,
        leftMargin=0.6 * inch, rightMargin=0.6 * inch,
        topMargin=0.65 * inch, bottomMargin=0.65 * inch,
        title="MU Study Hands-On Reconstruction Course",
        author="MU Study Course Generator v3",
    )
    print(f"Building PDF ({len(story)} flowables)...")
    doc.build(story, onFirstPage=footer, onLaterPages=footer)
    print(f"Wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    build()
