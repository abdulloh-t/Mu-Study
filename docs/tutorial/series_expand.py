"""Extra textbook volume: annotated listings, journals, screen manuals, interviews."""

from __future__ import annotations

import ast
import re
from pathlib import Path

from reportlab.lib.units import inch
from reportlab.platypus import PageBreak

from pdf_helpers import bullets, callout, checkpoint, h1, h2, h3, numbered, p, simple_table, task, warn
from series_kit import EXPORT, LIB, ROOT, TEST, code_chunks, dart_files, file_purpose

SCREENS = [
    ("SplashScreen", "/splash", "lib/screens/auth/splash_screen.dart", "all", "Brand pause while session restores."),
    ("SetupRequiredScreen", "(no route)", "lib/screens/auth/setup_required_screen.dart", "misconfig", "Shown when Env.isConfigured is false."),
    ("LoginScreen", "/login", "lib/screens/auth/login_screen.dart", "guest", "Username + password → AuthRepository."),
    ("LanguageSelectionScreen", "/language", "lib/screens/auth/language_selection_screen.dart", "authed", "Forces EN/RU/UZ before any shell."),
    ("StudentDashboardScreen", "/student/dashboard", "lib/screens/student/home/student_dashboard_screen.dart", "student", "Home + expandable announcements."),
    ("StudentAssignmentsScreen", "/student/assignments", "lib/screens/student/homework/student_assignments_screen.dart", "student", "Static vs pack list."),
    ("StudentTaskSubmitScreen", "/student/tasks/:taskId", "lib/screens/student/homework/student_task_submit_screen.dart", "student", "Text / file / voice submit."),
    ("StudentFocusScreen", "/student/focus", "lib/screens/student/focus/student_focus_screen.dart", "student", "Pomodoro or free timer (local)."),
    ("StudentMarksScreen", "/student/marks", "lib/screens/student/marks/student_marks_screen.dart", "student", "Own marks and averages."),
    ("StudentAttendanceScreen", "/student/attendance", "lib/screens/student/attendance/student_attendance_screen.dart", "student", "Calendar of statuses."),
    ("StudentNotificationsScreen", "/student/notifications", "lib/screens/student/notifications/student_notifications_screen.dart", "student", "Inbox."),
    ("StudentProfileScreen", "/student/profile", "lib/screens/student/profile/student_profile_screen.dart", "student", "Wrapper → AppProfileScreen."),
    ("TeacherDashboardScreen", "/teacher/dashboard", "lib/screens/teacher/dashboard/teacher_dashboard_screen.dart", "teacher", "Shortcuts and group context."),
    ("TeacherAssignmentsScreen", "/teacher/assignments", "lib/screens/teacher/assignments/teacher_assignments_screen.dart", "teacher", "Create/list assignments."),
    ("TeacherHomeworkPackScreen", "/teacher/assignments/:id", "lib/screens/teacher/homework/teacher_homework_pack_screen.dart", "teacher", "Tasks and pack progress."),
    ("TeacherSubmissionsScreen", "/teacher/submissions", "lib/screens/teacher/homework/teacher_submissions_screen.dart", "teacher", "Review queue."),
    ("TeacherAttendanceScreen", "/teacher/attendance", "lib/screens/teacher/attendance/teacher_attendance_screen.dart", "teacher", "Roll grid + ensure_lesson_session."),
    ("TeacherMarksScreen", "/teacher/marks", "lib/screens/teacher/marks/teacher_marks_screen.dart", "teacher", "Gradebook."),
    ("TeacherAnalyticsScreen", "/teacher/analytics", "lib/screens/teacher/analytics/teacher_analytics_screen.dart", "teacher", "Charts from aggregates."),
    ("TeacherAnnouncementsScreen", "/teacher/announcements", "lib/screens/teacher/announcements/teacher_announcements_screen.dart", "teacher", "Group posts."),
    ("TeacherNotificationsScreen", "/teacher/notifications", "lib/screens/teacher/notifications/teacher_notifications_screen.dart", "teacher", "Reuses inbox UI."),
    ("TeacherProfileScreen", "/teacher/profile", "lib/screens/teacher/profile/teacher_profile_screen.dart", "teacher", "Wrapper → AppProfileScreen."),
    ("AdminDashboardScreen", "/admin/dashboard", "lib/screens/admin/dashboard/admin_dashboard_screen.dart", "admin", "Platform counts."),
    ("AdminUsersScreen", "/admin/users", "lib/screens/admin/users/admin_users_screen.dart", "admin", "admin_create_user + disable."),
    ("AdminGroupsScreen", "/admin/groups", "lib/screens/admin/groups/admin_groups_screen.dart", "admin", "Groups + membership; chat trigger."),
    ("AdminAnalyticsScreen", "/admin/analytics", "lib/screens/admin/analytics/admin_analytics_screen.dart", "admin", "School-wide charts."),
    ("AdminAcademicYearsScreen", "/admin/academic-years", "lib/screens/admin/academic_years/admin_academic_years_screen.dart", "admin", "Years and four terms."),
    ("AdminAnnouncementsScreen", "/admin/announcements", "lib/screens/admin/announcements/admin_announcements_screen.dart", "admin", "Admin posts."),
    ("AdminNotificationsScreen", "/admin/notifications", "lib/screens/admin/notifications/admin_notifications_screen.dart", "admin", "Placeholder / empty."),
    ("AdminCredentialPrintScreen", "/admin/credential-print", "lib/screens/admin/credentials/admin_credential_print_screen.dart", "admin", "Printable login slips PDF."),
    ("AdminMassDataGeneratorScreen", "/admin/mass-generator", "lib/screens/admin/data_generator/admin_mass_data_generator_screen.dart", "admin", "admin_mass_generate_school_data."),
    ("AdminProfileScreen", "/admin/profile", "lib/screens/admin/profile/admin_profile_screen.dart", "admin", "Wrapper → AppProfileScreen."),
    ("ChatListScreen", "/*/chat", "lib/screens/chat/list/chat_list_screen.dart", "all roles", "Rooms + unread."),
    ("ChatRoomScreen", "/*/chat/:roomId", "lib/screens/chat/room/chat_room_screen.dart", "all roles", "Messages, media, reactions."),
    ("AppProfileScreen", "via wrappers", "lib/screens/profile/app_profile_screen.dart", "all", "Theme, language, password, logout."),
]


INTERESTING = re.compile(
    r"\.(from|rpc|select|insert|update|delete|upsert|eq|channel|onPostgresChanges|watch|read|invalidate|go\(|push\(|upload|download|createSignedUrl)\b"
    r"|class |enum |typedef |extends |implements |Provider|Notifier|Consumer",
    re.I,
)


def _safe_parse(text: str):
    try:
        return ast.parse(text)
    except SyntaxError:
        return None


def _decls(tree: ast.AST):
    out = []
    for node in getattr(tree, "body", []):
        if isinstance(node, ast.ClassDef):
            out.append(("class", node.name, node.lineno, [n.name for n in node.body if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef))][:12]))
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            out.append(("function", node.name, node.lineno, []))
        elif isinstance(node, ast.Assign):
            for t in node.targets:
                if isinstance(t, ast.Name) and t.id.endswith("Provider"):
                    out.append(("provider", t.id, node.lineno, []))
    return out


def annotated_source(styles):
    s = [h1(styles, "Annotated source — line lessons for every Dart file")]
    s.append(
        p(
            styles,
            "The source atlas printed raw files. This chapter slows down: every class and provider "
            "is named, and every line that talks to Supabase, Riverpod, or the router is explained "
            "in plain English. Use it when a tutorial says “open this file” and you do not know "
            "which line matters.",
        )
    )
    s.append(PageBreak())
    for fp in dart_files():
        rel = fp.relative_to(ROOT).as_posix()
        text = fp.read_text(encoding="utf-8")
        lines = text.splitlines()
        s.append(h2(styles, f"Line lesson — {rel}"))
        s.append(p(styles, file_purpose(rel)))
        tree = _safe_parse(text)
        decls = _decls(tree) if tree else []
        if decls:
            rows = []
            for kind, name, ln, methods in decls:
                extra = ", ".join(methods) if methods else "—"
                rows.append([kind, name, str(ln), extra])
            s.append(simple_table(styles, ["Kind", "Name", "Line", "Members"], rows, [1.0 * inch, 2.2 * inch, 0.7 * inch, 2.6 * inch]))
        else:
            s.append(p(styles, "No top-level class/provider parsed (the file may be a barrel export or use syntax the lesson parser skips). Read it as glue code."))

        hits = []
        for i, line in enumerate(lines, 1):
            raw = line.strip()
            if not raw or raw.startswith("//") or raw.startswith("import "):
                continue
            if INTERESTING.search(raw):
                hits.append((i, raw[:140]))
        s.append(h3(styles, "Why these lines exist"))
        if not hits:
            s.append(
                p(
                    styles,
                    "This file is mostly layout, colors, or pure functions. That is still product code: "
                    "a theme token file is how Nature Paper stays consistent. Read it top to bottom once, "
                    "then return when a screen imports it.",
                )
            )
        for i, raw in hits:
            why = _why_line(raw)
            s.append(p(styles, f"<b>L{i}.</b> <font face='Courier' size='8'>{_esc(raw)}</font>"))
            s.append(p(styles, why, "Small"))
        s.append(
            task(
                styles,
                f"Predict a break in {rel}",
                "Name one line above. Describe the user-visible bug if you delete it. "
                "Then restore it in your mind — do not actually break a working tree unless you are on a branch.",
            )
        )
        s.append(PageBreak())
    return s


def _esc(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )


def _why_line(raw: str) -> str:
    r = raw.lower()
    if ".rpc(" in r:
        return "Remote procedure call. Authorization and writes that are too complex for a single RLS policy often live here (login email, admin create user, unread counts)."
    if ".from(" in r:
        return "PostgREST table access. RLS still applies. The string is the Postgres table or view name."
    if ".select(" in r:
        return "Read columns. Narrow the select when the row is wide; '*' is acceptable for small domain rows."
    if ".insert(" in r:
        return "Creates a row. Failures are usually unique violations or WITH CHECK policy failures."
    if ".update(" in r:
        return "Mutates matching rows. Silent zero rows usually means SELECT policy is missing for UPDATE."
    if ".delete(" in r:
        return "Removes matching rows. CASCADE on FKs may delete children — know the blast radius."
    if ".upsert(" in r:
        return "Insert-or-update. Submissions and attendance use this so retrying is safe."
    if ".eq(" in r:
        return "Equality filter. This is the WHERE clause. Wrong UUID type (profile vs student id) yields empty lists."
    if "onpostgreschanges" in r or ".channel(" in r:
        return "Realtime subscription. Dispose the channel on provider dispose or you leak events across logins."
    if "ref.watch(" in r:
        return "Rebuild this widget/provider when the dependency changes. Do not put watch in a click handler."
    if "ref.read(" in r:
        return "One-shot access, typical in onPressed. Login uses read(authRepositoryProvider)."
    if "invalidate(" in r:
        return "Drop cached AsyncValue so the next watch refetches (after login or a mutation)."
    if "context.go(" in r or ".go(" in r:
        return "Replace the navigation stack location. Login uses /boot so redirect can settle."
    if "context.push(" in r or ".push(" in r:
        return "Push a route the user can pop (assignment detail, chat room)."
    if "upload" in r:
        return "Storage write. Path folders must satisfy bucket policies."
    if "download" in r or "createsignedurl" in r:
        return "Storage read. Private buckets need a signed URL; avatars may use getPublicUrl."
    if raw.strip().startswith("class "):
        return "Type definition. If this is a widget, find build(). If this is a repository, find the supabase calls."
    if raw.strip().startswith("enum "):
        return "Closed set of values. Keep it aligned with the Postgres enum or the fromString helper."
    if "provider" in r:
        return "Riverpod binding. Name it after the value it exposes."
    if "consumer" in r:
        return "Widget that can watch providers. Required for profile/theme/locale."
    return "Product logic on this line. Read the surrounding ten lines if the token is unfamiliar."


def sql_line_lessons(styles):
    s = [h1(styles, "Annotated SQL — every statement in COMPLETE_BACKEND.sql")]
    s.append(
        p(
            styles,
            "SQL is not decoration. Each statement either creates a type, a table, a view, a function, "
            "a trigger, or a grant. This chapter walks the complete script so you can narrate it "
            "without scrolling blindly.",
        )
    )
    path = Path(__file__).resolve().parent / "COMPLETE_BACKEND.sql"
    if not path.exists():
        path = EXPORT / "COMPLETE_BACKEND.sql"
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    chunk = []
    start = 1
    s.append(PageBreak())

    def flush(a, b, body):
        if not body.strip():
            return []
        out = [h3(styles, f"COMPLETE_BACKEND.sql lines {a}–{b}")]
        out.extend(code_chunks(styles, f"COMPLETE_BACKEND.sql:{a}-{b}", body))
        head = body.lstrip()
        if head.startswith("CREATE TYPE"):
            out.append(p(styles, "Enum or composite type. Flutter models must use the same labels (homework_pack, not homeworkPack)."))
        elif head.startswith("CREATE TABLE"):
            out.append(p(styles, "Base table. After create, enable RLS and add policies or the API returns empty sets for authenticated users."))
        elif head.startswith("CREATE UNIQUE INDEX") or head.startswith("CREATE INDEX"):
            out.append(p(styles, "Index. Unique indexes are product rules (one group title per teacher; one current academic year)."))
        elif head.startswith("CREATE OR REPLACE VIEW"):
            out.append(p(styles, "View. Treat it as a stored SELECT. Chat list and mark averages depend on these."))
        elif head.startswith("CREATE OR REPLACE FUNCTION") or head.startswith("CREATE FUNCTION"):
            out.append(p(styles, "Function. Note LANGUAGE and SECURITY. DEFINER must check is_admin or membership."))
        elif head.startswith("CREATE TRIGGER") or "TRIGGER" in head[:80]:
            out.append(p(styles, "Trigger. Side effects (notify, touch updated_at, ensure chat room) happen here, not in Flutter."))
        elif head.startswith("ALTER TABLE") and "ROW LEVEL" in head:
            out.append(p(styles, "RLS on. Without policies this table is invisible to the app role."))
        elif head.startswith("CREATE POLICY"):
            out.append(p(styles, "Access rule. USING is for existing rows; WITH CHECK is for new/changed rows."))
        elif head.startswith("GRANT") or head.startswith("REVOKE"):
            out.append(p(styles, "Privilege. Demo seed functions must stay revoked from anon/authenticated on real schools."))
        elif head.startswith("--"):
            out.append(p(styles, "Section comment in the recovered script. Use it as a bookmark when applying SQL."))
        else:
            out.append(p(styles, "Supporting SQL (constraint, comment, or continuation). Keep it when you recreate the database."))
        out.append(
            checkpoint(
                styles,
                f"Explain lines {a}–{b}",
                "In one sentence: what object appears in Postgres after this chunk, and which Flutter file would break if you skipped it.",
            )
        )
        return out

    for i, line in enumerate(lines, 1):
        chunk.append(line)
        boundary = line.startswith("CREATE ") or line.startswith("ALTER TABLE") or line.startswith("CREATE POLICY") or line.startswith("GRANT ") or line.startswith("REVOKE ")
        if len(chunk) >= 18 or (boundary and len(chunk) > 4 and i != start):
            # if boundary at start of a new object, flush previous
            if boundary and len(chunk) > 1:
                prev = "\n".join(chunk[:-1])
                s.extend(flush(start, i - 1, prev))
                chunk = [line]
                start = i
            elif len(chunk) >= 22:
                body = "\n".join(chunk)
                s.extend(flush(start, i, body))
                chunk = []
                start = i + 1
    if chunk:
        s.extend(flush(start, start + len(chunk) - 1, "\n".join(chunk)))
    s.append(PageBreak())
    return s


def screen_manual(styles):
    s = [h1(styles, "Screen manual — every destination")]
    s.append(
        p(
            styles,
            "A reconstruction is finished only when each screen exists, routes, and talks to the "
            "correct provider. Work this list with the running app.",
        )
    )
    for name, path, rel, role, purpose in SCREENS:
        s.append(h2(styles, name))
        s.append(
            simple_table(
                styles,
                ["Field", "Value"],
                [
                    ["Route", path],
                    ["File", rel],
                    ["Role gate", role],
                    ["Purpose", purpose],
                ],
                [1.4 * inch, 5.1 * inch],
            )
        )
        fp = ROOT / rel
        if fp.exists():
            text = fp.read_text(encoding="utf-8")
            s.append(p(styles, f"Source length: {len(text.splitlines())} lines. Study build() first, then event handlers."))
            # excerpt first 80 lines as a teaching lead-in
            lead = "\n".join(text.splitlines()[:80])
            s.extend(code_chunks(styles, f"{rel} (opening)", lead))
            s.append(
                p(
                    styles,
                    "The opening shows imports — those are your dependency map. If you see "
                    "auth_provider, the screen is session-aware. If you see l10n_x, strings are translated. "
                    "If you see supabase_client directly, prefer moving that call into a provider when you rebuild.",
                )
            )
        s.extend(
            numbered(
                styles,
                [
                    f"Navigate to {path} as role {role}. If redirect sends you away, write which gate fired.",
                    "Name the provider(s) watched in build().",
                    "Perform the primary action (submit, save, send, create).",
                    "Confirm the Table Editor row or Storage object.",
                    "Repeat as a role that should be denied — you should bounce or see empty data.",
                ],
            )
        )
        s.append(
            task(
                styles,
                f"Manual QA — {name}",
                f"Screenshot {path}. Annotate one widget and the table behind it. File the screenshot in private notes.",
            )
        )
        s.append(PageBreak())
    return s


def day_journal(styles):
    days = [
        (1, "Product walk", "Tutorial 1 screenshots. Write the three roles from memory."),
        (2, "ER diagram", "Tutorial 2. Circle profile id vs student id."),
        (3, "Supabase project", "Tutorial 3. URL + anon key in private notes."),
        (4, ".env + SetupRequired A/B", "Tutorial 4."),
        (5, "flutter create / tree", "Tutorial 5. pub get."),
        (6, "Dart drills", "Tutorial 6 tests."),
        (7, "Practice login UI", "Tutorial 7."),
        (8, "Todo State vs Riverpod note", "Tutorial 8."),
        (9, "Redirect trace on paper", "Tutorial 9."),
        (10, "Counter + FutureProvider lab", "Tutorial 10."),
        (11, "homework_pack mapping test", "Tutorial 11."),
        (12, "SQL joins in SQL Editor", "Tutorial 12."),
        (13, "First admin + login", "Tutorial 13."),
        (14, "Trace three .from() calls", "Tutorial 14."),
        (15, "Two-student marks RLS", "Tutorial 15."),
        (16, "Homework file upload", "Tutorial 16."),
        (17, "Two-device chat", "Tutorial 17."),
        (18, "RU + UZ switch", "Tutorial 18."),
        (19, "Four styles × dark", "Tutorial 19."),
        (20, "Assignment notify inbox", "Tutorial 20."),
        (21, "Full auth loop freeze-test", "Tutorial 21."),
        (22, "Pack create → submit → grade", "Tutorial 22."),
        (23, "Reactions + unread", "Tutorial 23."),
        (24, "Attendance unique session", "Tutorial 24."),
        (25, "Announcement + out-of-group deny", "Tutorial 25."),
        (26, "Component inventory", "Tutorial 26."),
        (27, "flutter test + one new unit test", "Tutorial 27."),
        (28, "Network tab on gradebook", "Tutorial 28."),
        (29, "Airplane mode marks", "Tutorial 29."),
        (30, "Release APK/web + password rotation plan", "Tutorial 30."),
    ]
    s = [h1(styles, "30-day rebuild journal")]
    s.append(
        p(
            styles,
            "If you work one day at a time, this journal is your calendar. Each day ends with a "
            "written proof (screenshot, SQL result, or test output). Days are not optional snacks — "
            "they are the same 30 tutorials in calendar form.",
        )
    )
    for n, title, work in days:
        s.append(h2(styles, f"Day {n:02d} — {title}"))
        s.append(p(styles, f"<b>Work:</b> {work}"))
        s.append(
            p(
                styles,
                "Morning: read the tutorial without touching the keyboard. Write three questions. "
                "Afternoon: do the TASK. Evening: run the CHECKPOINT and paste the proof into your "
                "private notes file. If the checkpoint fails, do not start the next day — use Appendix D.",
            )
        )
        s.append(
            p(
                styles,
                "Reflection prompts: What object did you create today (table, widget, provider)? "
                "What would a student see if you shipped only through today? What secret did you "
                "almost put in git?",
            )
        )
        s.append(
            checkpoint(
                styles,
                f"Day {n} done",
                "You have an artifact (file, query, screenshot) dated today. Tomorrow-you can "
                "reproduce the step from that artifact without this paragraph.",
            )
        )
        s.append(PageBreak())
    return s


def interview_bank(styles):
    qa = [
        ("Why is profiles.id the Auth user id?",
         "RLS uses auth.uid(). If profile ids were random, every policy would need a join. Equality is simpler and harder to get wrong."),
        ("Why synthetic emails?",
         "Supabase Auth signInWithPassword requires an email. The school wants usernames. auth_email is the adapter. The RPC hides the adapter from attackers probing disabled accounts."),
        ("How do you prevent students from reading all marks?",
         "ENABLE ROW LEVEL SECURITY + SELECT policies that compare student_id to the caller’s students row (or teacher group membership, or is_admin). The Flutter list is not the control."),
        ("What is the difference between students.id and profiles.id?",
         "profiles.id is the login identity. students.id is the roster identity used on attendance, marks, submissions, group_students. Mixing them yields empty joins."),
        ("Why a junction table for group membership?",
         "A student can belong to more than one group (math and English). group_id on students cannot model that."),
        ("Why does creating a group create a chat room?",
         "Trigger ensure_chat_room_for_group keeps a 1:1 invariant. Flutter must not insert chat_rooms ad hoc."),
        ("How are unread counts computed?",
         "chat_unread_counts RPC, not a column on chat_rooms. Reads live in message_reads."),
        ("Why REPLICA IDENTITY FULL on reactions?",
         "Realtime UPDATE/DELETE payloads need old keys. Default replica identity may omit them."),
        ("Where is focus data?",
         "SharedPreferences. There is no focus table. Offline still works."),
        ("How do four visual styles work?",
         "AppStyle enum + AppTheme.light/dark(style) + optional backdrops. Persisted as preferred_style."),
        ("What happens if you skip first_admin_bootstrap?",
         "admin_create_user requires is_admin(). Chicken and egg. Bootstrap inserts the first admin like the RPC does."),
        ("Why revoke seed_demo_data from authenticated?",
         "Otherwise any logged-in student could flood the school with fake users."),
        ("How does language gating work?",
         "profiles.preferred_language null → router /language. After save, home opens."),
        ("Why Duration.zero on theme animation?",
         "Styles do not interpolate cleanly. Instant switch is a product choice."),
        ("What is a homework_pack?",
         "Assignment type with ordered tasks students submit. static is display-only."),
        ("How are voice notes stored?",
         "record package → file → Storage chat-voices or submissions voice_url."),
        ("How do credential slips work?",
         "Admin screen builds a PDF of usernames/passwords. Optional login_credentials table stores plaintext for reprint — treat as sensitive."),
        ("What is academic_years_one_current?",
         "Partial unique index ensuring only one is_current year."),
        ("Why maybeSingle on profile fetch?",
         "A signed-in Auth user might lack a profile (partial bootstrap). single() would throw."),
        ("How do you test RLS?",
         "Two real JWTs (two app logins), never the SQL Editor postgres role."),
        ("What does ShellRoute buy you?",
         "Persistent nav chrome while child routes change. One AppShell, three destination lists."),
        ("Why invalidate profile after login?",
         "The FutureProvider may have cached null from the guest session."),
        ("What is action_path on notifications?",
         "Deep link for go_router when the student taps the inbox row."),
        ("Why jsonb for announcement files?",
         "Variable-length list of URLs without a child table. Trade-off: harder to query individual files."),
        ("How is member_count defined?",
         "count(group_students)+1 for the teacher."),
        ("What breaks if you use user_metadata.role in RLS?",
         "Users can edit user_metadata. They would escalate to admin."),
        ("Why dart-define-from-file?",
         "Inject secrets at build/run without relying only on an asset .env."),
        ("What is _sanitizeKey?",
         "Rejects placeholders and service-role-shaped keys so the app fails closed."),
        ("How do you page assignments?",
         "PageResult + limit/offset or cursor in assignment providers + LoadMoreButton."),
        ("What is the blast radius of deleting a teacher?",
         "ON DELETE CASCADE on groups.teacher_id removes groups and, cascading, assignments, chat, etc. Know this before delete UI."),
        ("Why shared ChatRoomScreen?",
         "Behavior is identical; only basePath changes. Duplicating 1k lines three times is how bugs fork."),
        ("How do replies stay in-room?",
         "chat_messages_reply_same_room trigger/function rejects cross-room reply_to."),
        ("What is mark weight?",
         "Weighted average: sum(percentage*weight)/sum(weight). Views implement it."),
        ("Why four academic terms?",
         "CHECK semester 1–4. Bounds come from academic_semester_bounds."),
        ("How does mass generate work?",
         "admin_mass_generate_school_data SECURITY DEFINER after is_admin(). Dev/demo only on real schools."),
        ("What is Nature Paper?",
         "An AppStyle with backdrop PNGs and paper décor widgets."),
        ("How do you localize a new string?",
         "Add key to app_en.arb, app_ru.arb, app_uz.arb, flutter gen-l10n, use context.l10n."),
        ("Why no Forgot password?",
         "Internal emails are not mailboxes. Admin resets via RPC."),
        ("What is the web layout rule?",
         "Bottom bar on phones, rail on tablet/web widths. No permanent desktop-only sidebar."),
        ("How do you know Realtime is live?",
         "Second device updates without refresh; publication includes the table."),
        ("What is CacheService?",
         "SharedPreferences JSON for profile, assignments, notifications, dashboard when the network fails."),
        ("Why publishable key vs service role?",
         "Publishable is designed for clients with RLS. Service role bypasses RLS and is a breach if shipped."),
        ("How is a disabled user blocked?",
         "RPC filters is_disabled; router also sends /account-disabled if a profile loads as disabled."),
        ("What file is the router?",
         "lib/core/router/app_router.dart"),
        ("Name three SECURITY DEFINER functions",
         "get_auth_email_by_username, admin_create_user, is_admin (and many admin_* / notify helpers)."),
        ("What unique key is on submissions?",
         "(task_id, student_id)"),
        ("What unique key is on attendance?",
         "(group_id, student_id, date) and (session_id, student_id)"),
        ("How do charts get data?",
         "Aggregates from marks/attendance views or provider-side grouping into Syncfusion series."),
        ("What is go_router refreshListenable?",
         "_RouterNotifier that notifyListeners when auth or profile changes so redirect re-runs."),
        ("Why include .env in assets?",
         "dotenv load on devices that are not using dart-define. Still gitignore the file contents in source control."),
    ]
    s = [h1(styles, "Oral exam — 50 questions with answers")]
    s.append(p(styles, "Cover the answer. Speak for thirty seconds. Then read the book’s answer and grade yourself."))
    for i, (q, a) in enumerate(qa, 1):
        s.append(h3(styles, f"Question {i}"))
        s.append(p(styles, q))
        s.append(callout(styles, "Model answer", a))
        s.append(
            p(
                styles,
                "Follow-up you should also be able to answer: which file or SQL object proves this? "
                "If you cannot name one, you memorized a slogan, not the system.",
            )
        )
    s.append(PageBreak())
    return s


def generated_l10n_dump(styles):
    s = [h1(styles, "Generated localization Dart (reference)")]
    s.append(
        p(
            styles,
            "These files are produced by flutter gen-l10n. Do not hand-edit. They are printed so "
            "you can see how an ARB key becomes a getter. If they are missing, run the generator.",
        )
    )
    for name in (
        "app_localizations.dart",
        "app_localizations_en.dart",
        "app_localizations_ru.dart",
        "app_localizations_uz.dart",
    ):
        fp = LIB / "l10n" / name
        if fp.exists():
            s.append(h2(styles, name))
            s.extend(code_chunks(styles, f"lib/l10n/{name}", fp.read_text(encoding="utf-8")))
            s.append(PageBreak())
    return s


def provider_manual(styles):
    files = sorted((LIB / "providers").rglob("*.dart"))
    s = [h1(styles, "Provider manual — every state module")]
    for fp in files:
        rel = fp.relative_to(ROOT).as_posix()
        text = fp.read_text(encoding="utf-8")
        s.append(h2(styles, rel))
        s.append(p(styles, file_purpose(rel)))
        names = re.findall(r"final (\w+Provider)", text)
        if names:
            s.append(p(styles, "Providers declared: " + ", ".join(dict.fromkeys(names)) + "."))
        s.extend(code_chunks(styles, rel, text))
        s.append(
            task(
                styles,
                f"Trace {rel}",
                "Write the table/RPC list. Write which screen watches each provider. "
                "Write what invalidate you must call after a successful mutation.",
            )
        )
        s.append(PageBreak())
    return s


def every_line_book(styles):
    s = [h1(styles, "Every-line Dart commentary")]
    s.append(
        p(
            styles,
            "This is the slowest chapter on purpose. Every non-trivial line of application Dart "
            "is printed with a one-sentence reason. Skip it while racing through tutorials; "
            "use it when a file feels like noise. Imports and lone braces are omitted.",
        )
    )
    s.append(PageBreak())
    skip_only = {"}", "{", "});", "];", "],", ");", ",", "[", "]", "(", ")"}
    for fp in dart_files():
        rel = fp.relative_to(ROOT).as_posix()
        lines = fp.read_text(encoding="utf-8").splitlines()
        s.append(h2(styles, f"Every line — {rel}"))
        s.append(p(styles, file_purpose(rel)))
        batch = []
        for i, line in enumerate(lines, 1):
            raw = line.strip()
            if not raw or raw in skip_only or raw.startswith("import ") or raw.startswith("export ") or raw.startswith("//"):
                continue
            if raw.startswith("part ") or raw.startswith("library "):
                continue
            why = _why_line(raw)
            batch.append(f"<b>L{i}</b> <font face='Courier' size='7'>{_esc(raw[:160])}</font><br/>{why}")
            if len(batch) == 4:
                s.append(p(styles, "<br/><br/>".join(batch), "Small"))
                batch = []
        if batch:
            s.append(p(styles, "<br/><br/>".join(batch), "Small"))
        s.append(
            checkpoint(
                styles,
                f"Closed {rel}",
                "Name the file’s public API in one breath. If you cannot, reread the class/provider table in the annotated chapter.",
            )
        )
        s.append(PageBreak())
    return s


def arb_key_lessons(styles):
    import json

    s = [h1(styles, "Every localization key (EN / RU / UZ)")]
    s.append(
        p(
            styles,
            "Each ARB key is a user-visible contract. If English exists and Uzbek does not, "
            "generation fails or falls back. Walk the keys and tick any screen you have not opened.",
        )
    )
    def load(name):
        raw = (LIB / "l10n" / name).read_text(encoding="utf-8")
        return json.loads(raw)

    try:
        en, ru, uz = load("app_en.arb"), load("app_ru.arb"), load("app_uz.arb")
    except Exception as e:
        s.append(warn(styles, "ARB parse", str(e)))
        s.append(PageBreak())
        return s

    keys = [k for k in en.keys() if not k.startswith("@")]
    s.append(p(styles, f"Key count in app_en.arb: {len(keys)}."))
    rows = []
    for k in keys:
        rows.append([
            k,
            str(en.get(k, ""))[:80],
            str(ru.get(k, "MISSING"))[:50],
            str(uz.get(k, "MISSING"))[:50],
        ])
        if len(rows) == 12:
            s.append(simple_table(styles, ["Key", "EN", "RU", "UZ"], rows, [1.5 * inch, 1.8 * inch, 1.6 * inch, 1.6 * inch]))
            s.append(
                p(
                    styles,
                    "Practice: pick one key from this block, find it in a screen with your editor, "
                    "and change the English string locally to prove the widget is wired. Then revert.",
                )
            )
            rows = []
    if rows:
        s.append(simple_table(styles, ["Key", "EN", "RU", "UZ"], rows, [1.5 * inch, 1.8 * inch, 1.6 * inch, 1.6 * inch]))
    missing_ru = [k for k in keys if k not in ru]
    missing_uz = [k for k in keys if k not in uz]
    s.append(h3(styles, "Missing translations"))
    s.append(p(styles, f"RU missing: {len(missing_ru)}. UZ missing: {len(missing_uz)}."))
    if missing_ru:
        s.extend(bullets(styles, missing_ru[:40]))
    if missing_uz:
        s.extend(bullets(styles, missing_uz[:40]))
    s.append(PageBreak())
    return s


def rls_english(styles):
    s = [h1(styles, "RLS policies in English")]
    path = EXPORT / "rls_policies.sql"
    if not path.exists():
        s.append(p(styles, "rls_policies.sql not found."))
        s.append(PageBreak())
        return s
    text = path.read_text(encoding="utf-8")
    parts = re.split(r"(?=CREATE POLICY)", text)
    s.append(p(styles, "Each policy is a sentence you should be able to say to a school principal."))
    for part in parts:
        if "CREATE POLICY" not in part:
            continue
        m = re.search(r'CREATE POLICY\s+"?([\w]+)"?\s+ON\s+([\w.]+)', part)
        name = m.group(1) if m else "policy"
        table = m.group(2) if m else "table"
        s.append(h3(styles, f"{name} on {table}"))
        s.extend(code_chunks(styles, name, part.strip()[:2500]))
        kind = "read" if "FOR SELECT" in part else "write" if "FOR INSERT" in part or "FOR UPDATE" in part or "FOR ALL" in part else "mixed"
        s.append(
            p(
                styles,
                f"This is a {kind} rule. Ask: who is auth.uid()? Does the function is_admin / "
                f"is_teacher_of_group / is_student_in_group / can_access_chat_room appear? "
                f"If the policy is USING(true), it is a red flag unless the table is harmless.",
            )
        )
        s.append(
            checkpoint(
                styles,
                f"Say {name} aloud",
                f"Complete: “A row in {table} may be {kind} when …”. If you need the SQL in front of you, you do not own the policy yet.",
            )
        )
    s.append(PageBreak())
    return s


def widget_catalog(styles):
    files = sorted((LIB / "components").rglob("*.dart"))
    s = [h1(styles, "Component catalog — every reusable widget file")]
    for fp in files:
        rel = fp.relative_to(ROOT).as_posix()
        text = fp.read_text(encoding="utf-8")
        s.append(h2(styles, rel))
        s.append(p(styles, file_purpose(rel)))
        classes = re.findall(r"class (\w+)", text)
        if classes:
            s.extend(bullets(styles, [f"Type {c}" for c in classes[:20]]))
        s.extend(code_chunks(styles, rel, text))
        s.append(
            warn(
                styles,
                "Reuse rule",
                "If this widget starts calling supabase, it is no longer a dumb component. "
                "Push I/O back to a provider so tests and other screens stay simple.",
            )
        )
        s.append(PageBreak())
    return s
