"""Deep-dive chapters appended to the MU Study tutorial PDF."""

from reportlab.lib.units import inch
from reportlab.platypus import PageBreak

from pdf_helpers import (
    bullets,
    callout,
    checkpoint,
    code_block,
    h1,
    h2,
    h3,
    numbered,
    p,
    simple_table,
    task,
    warn,
)


def deep_dive_chapters(styles):
    story = []
    story += _view_and_triggers(styles)
    story += _rls_full(styles)
    story += _functions_full(styles)
    story += _auth_ui(styles)
    story += _router_deep(styles)
    story += _chat_impl(styles)
    story += _platform_perms(styles)
    story += _makefile_ci(styles)
    story += _screen_catalog(styles)
    story += _seed_admin(styles)
    return story


def _view_and_triggers(styles):
    s = [h1(styles, "Appendix C — chat_room_summaries View (Exact)")]
    s.append(
        p(
            styles,
            "Create this view exactly. member_count = count(group_students)+1 (teacher).",
        )
    )
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE OR REPLACE VIEW public.chat_room_summaries AS\n"
            "SELECT cr.id, cr.group_id, cr.created_at,\n"
            "  g.title AS group_title,\n"
            "  tp.full_name AS teacher_name,\n"
            "  ((SELECT count(*)::int FROM group_students gs WHERE gs.group_id = g.id) + 1)\n"
            "    AS member_count,\n"
            "  lm.id AS last_message_id,\n"
            "  lm.message_type AS last_message_type,\n"
            "  lm.text_content AS last_message_text,\n"
            "  lm.media_url AS last_message_media_url,\n"
            "  lm.created_at AS last_message_at,\n"
            "  lm.is_deleted AS last_message_deleted,\n"
            "  lm.sender_id AS last_message_sender_id,\n"
            "  sp.full_name AS last_message_sender_name\n"
            "FROM chat_rooms cr\n"
            "JOIN groups g ON g.id = cr.group_id\n"
            "JOIN teachers t ON t.id = g.teacher_id\n"
            "JOIN profiles tp ON tp.id = t.profile_id\n"
            "LEFT JOIN LATERAL (\n"
            "  SELECT m.* FROM chat_messages m\n"
            "  WHERE m.room_id = cr.id\n"
            "  ORDER BY m.created_at DESC LIMIT 1\n"
            ") lm ON true\n"
            "LEFT JOIN profiles sp ON sp.id = lm.sender_id;",
        )
    )
    s.append(h2(styles, "Triggers to install (names from live DB)"))
    s.append(
        simple_table(
            styles,
            ["Table", "Trigger", "Function"],
            [
                ["groups", "tr_groups_create_chat_room", "ensure_chat_room_for_group()"],
                ["announcements", "announcement_created_notify", "trg_announcement_notify()"],
                ["assignments", "assignment_created_notify", "trg_assignment_notify()"],
                ["attendance", "tr_attendance_sync_session", "attendance_sync_session()"],
                ["chat_messages", "tr_chat_message_notify", "trg_chat_message_notify()"],
                ["chat_messages", "tr_chat_messages_reply_same_room", "chat_messages_reply_same_room()"],
                ["chat_messages", "tr_chat_messages_updated_at", "touch_chat_message_updated_at()"],
                ["marks", "tr_mark_notify", "trg_mark_notify()"],
                ["marks", "tr_marks_touch", "touch_updated_at()"],
                ["submissions", "tr_submission_mark", "sync_submission_mark()"],
                ["submissions", "tr_submission_notify", "trg_submission_notify()"],
            ],
            [1.5 * inch, 2.5 * inch, 2.5 * inch],
        )
    )
    s.append(
        callout(
            styles,
            "How to recover missing function bodies",
            "In SQL Editor: SELECT pg_get_functiondef(oid) FROM pg_proc WHERE proname = 'trg_assignment_notify'; "
            "On a fresh project, implement notify helpers using notify_user(p_user_id, title, body, kind, action_path, ref_id).",
        )
    )
    s.append(PageBreak())
    return s


def _rls_full(styles):
    s = [h1(styles, "Appendix D — RLS Policies as SQL Templates")]
    s.append(
        p(
            styles,
            "Enable RLS on every table first. Then create policies. Examples for the hardest tables:",
        )
    )
    s.append(h3(styles, "chat_messages"))
    s.append(
        code_block(
            styles,
            "SQL",
            "ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;\n\n"
            "CREATE POLICY chat_messages_select ON public.chat_messages\n"
            "  FOR SELECT TO authenticated USING (can_access_chat_room(room_id));\n\n"
            "CREATE POLICY chat_messages_insert ON public.chat_messages\n"
            "  FOR INSERT TO authenticated\n"
            "  WITH CHECK (sender_id = auth.uid() AND can_access_chat_room(room_id));\n\n"
            "CREATE POLICY chat_messages_update ON public.chat_messages\n"
            "  FOR UPDATE TO authenticated\n"
            "  USING (is_admin() OR (sender_id = auth.uid() AND can_access_chat_room(room_id)))\n"
            "  WITH CHECK (is_admin() OR (sender_id = auth.uid() AND can_access_chat_room(room_id)));\n\n"
            "CREATE POLICY chat_messages_delete ON public.chat_messages\n"
            "  FOR DELETE TO authenticated\n"
            "  USING (is_admin() OR (sender_id = auth.uid() AND can_access_chat_room(room_id)));",
        )
    )
    s.append(h3(styles, "notifications"))
    s.append(
        code_block(
            styles,
            "SQL",
            "ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;\n"
            "CREATE POLICY notifications_own ON public.notifications\n"
            "  FOR ALL TO authenticated\n"
            "  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());",
        )
    )
    s.append(h3(styles, "marks"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE POLICY marks_select ON public.marks FOR SELECT TO authenticated USING (\n"
            "  EXISTS (SELECT 1 FROM students s WHERE s.id = marks.student_id AND s.profile_id = auth.uid())\n"
            "  OR is_teacher_of_group(group_id) OR is_admin()\n"
            ");\n"
            "CREATE POLICY marks_teacher_manage ON public.marks FOR ALL TO authenticated\n"
            "  USING (is_teacher_of_group(group_id) OR is_admin())\n"
            "  WITH CHECK (is_teacher_of_group(group_id) OR is_admin());",
        )
    )
    s.append(
        warn(
            styles,
            "profiles SELECT is multi-policy",
            "Postgres ORs multiple permissive SELECT policies. You need profiles_select, "
            "profiles_select_groupmates, AND profiles_select_chat_message_senders so classmates "
            "and chat senders are visible.",
        )
    )
    s.append(PageBreak())
    return s


def _functions_full(styles):
    s = [h1(styles, "Appendix E — Full Critical Function Bodies")]
    s.append(h2(styles, "can_access_chat_room"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE OR REPLACE FUNCTION public.can_access_chat_room(rid uuid)\n"
            "RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public' AS $$\n"
            "  SELECT public.is_admin()\n"
            "    OR EXISTS (\n"
            "      SELECT 1 FROM public.chat_rooms cr\n"
            "      WHERE cr.id = rid AND (\n"
            "        public.is_teacher_of_group(cr.group_id)\n"
            "        OR public.is_student_in_group(cr.group_id)\n"
            "      )\n"
            "    );\n"
            "$$;",
        )
    )
    s.append(h2(styles, "chat_unread_counts"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE OR REPLACE FUNCTION public.chat_unread_counts()\n"
            "RETURNS TABLE(room_id uuid, unread_count bigint)\n"
            "LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public' AS $$\n"
            "  SELECT m.room_id, COUNT(*)::BIGINT\n"
            "  FROM public.chat_messages m\n"
            "  WHERE m.is_deleted = FALSE\n"
            "    AND m.sender_id <> auth.uid()\n"
            "    AND public.can_access_chat_room(m.room_id)\n"
            "    AND NOT EXISTS (\n"
            "      SELECT 1 FROM public.message_reads r\n"
            "      WHERE r.message_id = m.id AND r.user_id = auth.uid()\n"
            "    )\n"
            "  GROUP BY m.room_id;\n"
            "$$;",
        )
    )
    s.append(h2(styles, "ensure_lesson_session"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE OR REPLACE FUNCTION public.ensure_lesson_session(p_group_id uuid, p_session_date date)\n"
            "RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$\n"
            "DECLARE sid UUID;\n"
            "BEGIN\n"
            "  IF p_session_date > CURRENT_DATE THEN\n"
            "    RAISE EXCEPTION 'Cannot create a lesson session for a future date'\n"
            "      USING ERRCODE = 'check_violation';\n"
            "  END IF;\n"
            "  INSERT INTO public.lesson_sessions (group_id, session_date)\n"
            "  VALUES (p_group_id, p_session_date)\n"
            "  ON CONFLICT (group_id, session_date)\n"
            "  DO UPDATE SET group_id = EXCLUDED.group_id\n"
            "  RETURNING id INTO sid;\n"
            "  RETURN sid;\n"
            "END; $$;",
        )
    )
    s.append(h2(styles, "admin_reset_password"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE OR REPLACE FUNCTION public.admin_reset_password(p_user_id uuid, p_password text)\n"
            "RETURNS void LANGUAGE plpgsql SECURITY DEFINER\n"
            "SET search_path TO 'auth', 'public', 'extensions' AS $$\n"
            "BEGIN\n"
            "  IF NOT public.is_admin() THEN RAISE EXCEPTION 'Not authorized'; END IF;\n"
            "  UPDATE auth.users\n"
            "  SET encrypted_password = extensions.crypt(p_password, extensions.gen_salt('bf')),\n"
            "      updated_at = NOW()\n"
            "  WHERE id = p_user_id;\n"
            "END; $$;",
        )
    )
    s.append(
        task(
            styles,
            "Install critical RPCs",
            "Paste all Appendix E functions, plus is_admin family and get_auth_email_by_username. "
            "GRANT EXECUTE to authenticated (and anon for get_auth_email_by_username).",
        )
    )
    s.append(PageBreak())
    return s


def _auth_ui(styles):
    s = [h1(styles, "Appendix F — Login Screen Implementation Notes")]
    s.append(
        p(
            styles,
            "File: lib/screens/auth/login_screen.dart. ConsumerStatefulWidget with username and "
            "password controllers. Validates non-empty → AuthRepository.signIn → invalidate "
            "currentProfileProvider → context.go('/boot'). Maps AuthException to localized "
            "loginIncorrect; PostgrestException about JWT/key → loginConfigError.",
        )
    )
    s.append(
        code_block(
            styles,
            "lib/screens/auth/login_screen.dart — _login core",
            "await ref.read(authRepositoryProvider)\n"
            "    .signIn(_usernameController.text.trim(), _passwordController.text);\n"
            "ref.invalidate(currentProfileProvider);\n"
            "if (!mounted) return;\n"
            "context.go('/boot');",
        )
    )
    s.append(
        p(
            styles,
            "UI: branded card with AppLogo, PrimaryButton, optional paper décor. Show loading "
            "on button. Never log passwords. Debug mode may show raw errors; release uses generic strings.",
        )
    )
    s.append(PageBreak())
    return s


def _router_deep(styles):
    s = [h1(styles, "Appendix G — Router Redirect Logic (Exact Behavior)")]
    s.append(
        code_block(
            styles,
            "lib/core/router/app_router.dart — redirect summary",
            "if loc == '/splash': allow\n"
            "if no session: force /login\n"
            "if profile loading without previous value: /boot (except /language)\n"
            "if profile null: /login\n"
            "if isDisabled: /account-disabled\n"
            "if !hasChosenLanguage: /language\n"
            "if on /login|/boot|/language: go role home\n"
            "else: stay",
        )
    )
    s.append(
        callout(
            styles,
            "Why not always /boot on refresh",
            "Comment in source: refreshing profile after language change must keep previous value "
            "to avoid tearing down the shell mid-gesture (semantics asserts).",
        )
    )
    s.append(
        p(
            styles,
            "Shell destinations use fade CustomTransitionPage for tabs; nested :id routes use "
            "default Material transition. ChatListScreen(basePath: '/student/chat') etc.",
        )
    )
    s.append(PageBreak())
    return s


def _chat_impl(styles):
    s = [h1(styles, "Appendix H — Chat Implementation Deep Dive")]
    s.append(h2(styles, "Sending media"))
    s.extend(
        numbered(
            styles,
            [
                "Pick file via image_picker/file_picker/record",
                "Choose bucket by ChatMessageType: chat-images|videos|voices|files",
                "Path: {roomId}/{profileId}/{timestamp}_{filename}",
                "storage.from(bucket).upload binary with upsert",
                "createSignedUrl(~10 years) store as media_url",
                "insert chat_messages row",
            ],
        )
    )
    s.append(h2(styles, "Long-press menu"))
    s.extend(
        bullets(
            styles,
            [
                "Use Overlay.insert — NOT showGeneralDialog — to avoid unfocus/list jump under composer",
                "Items: Reply, Copy text, Edit (own text), Select (own), Delete (own, red)",
                "Reactions bar above menu when onReact provided",
                "bottomReserve ≈ MediaQuery.padding.bottom + viewInsets.bottom + 108",
            ],
        )
    )
    s.append(h2(styles, "Selection mode"))
    s.extend(
        bullets(
            styles,
            [
                "Only selectable when sender_id == myId (canDelete)",
                "Do not render empty circles on others' messages",
                "Hide composer; ListView bottom padding = shellContentBottomPadding",
                "Bulk delete filters again server-side ownership before deleteMessages",
            ],
        )
    )
    s.append(
        checkpoint(
            styles,
            "Chat UX",
            "Long-press last message: menu appears; bubble does not slide under nav; "
            "other users' messages have no checkbox in select mode.",
        )
    )
    s.append(PageBreak())
    return s


def _platform_perms(styles):
    s = [h1(styles, "Appendix I — Platform Permissions")]
    s.append(h2(styles, "AndroidManifest.xml"))
    s.append(
        code_block(
            styles,
            "android/app/src/main/AndroidManifest.xml",
            "<uses-permission android:name=\"android.permission.INTERNET\"/>\n"
            "<uses-permission android:name=\"android.permission.RECORD_AUDIO\"/>\n"
            "<uses-permission android:name=\"android.permission.MODIFY_AUDIO_SETTINGS\"/>\n"
            "<!-- application android:label=\"MU Study\" -->",
        )
    )
    s.append(h2(styles, "iOS Info.plist"))
    s.append(
        code_block(
            styles,
            "ios/Runner/Info.plist keys",
            "NSMicrophoneUsageDescription = voice answers for homework\n"
            "NSPhotoLibraryUsageDescription = attach images to homework\n"
            "CFBundleDisplayName = MU Study",
        )
    )
    s.append(PageBreak())
    return s


def _makefile_ci(styles):
    s = [h1(styles, "Appendix J — Makefile & Local Commands")]
    s.append(
        code_block(
            styles,
            "Makefile",
            "run:\n\tflutter run\n"
            "clean:\n\tflutter clean\n"
            "get:\n\tflutter pub get\n"
            "ch:\n\tflutter run -d Chrome\n"
            "apk:\n\tflutter build apk --release\n"
            "\tcp build/app/outputs/flutter-apk/app-release.apk \\\n"
            "\t   build/app/outputs/flutter-apk/mu_study.apk",
        )
    )
    s.append(
        p(
            styles,
            "Recommended: flutter run --dart-define-from-file=.env so keys are not only in the asset bundle.",
        )
    )
    s.append(PageBreak())
    return s


def _screen_catalog(styles):
    s = [h1(styles, "Appendix K — Screen Catalog (Every Screen File)")]
    rows = [
        ["SplashScreen", "/splash", "Brand splash then /boot"],
        ["SetupRequiredScreen", "(no router)", "Missing Supabase key"],
        ["LoginScreen", "/login", "Username/password"],
        ["LanguageSelectionScreen", "/language", "en/ru/uz first run"],
        ["StudentDashboardScreen", "/student/dashboard", "Home + announcements"],
        ["StudentAssignmentsScreen", "/student/assignments", "List + detail"],
        ["StudentTaskSubmitScreen", "/student/tasks/:taskId", "Submit work"],
        ["StudentFocusScreen", "/student/focus", "Pomodoro/free"],
        ["StudentMarksScreen", "/student/marks", "Own marks"],
        ["StudentAttendanceScreen", "/student/attendance", "Calendar"],
        ["StudentNotificationsScreen", "/student/notifications", "Inbox"],
        ["StudentProfileScreen", "/student/profile", "AppProfileScreen"],
        ["TeacherDashboardScreen", "/teacher/dashboard", "Stats"],
        ["TeacherAssignmentsScreen", "/teacher/assignments", "CRUD + templates"],
        ["TeacherHomeworkPackScreen", "/teacher/assignments/:id", "Tasks progress"],
        ["TeacherSubmissionsScreen", "/teacher/submissions", "Review"],
        ["TeacherAttendanceScreen", "/teacher/attendance", "Take attendance"],
        ["TeacherMarksScreen", "/teacher/marks", "Gradebook"],
        ["TeacherAnalyticsScreen", "/teacher/analytics", "Charts"],
        ["TeacherAnnouncementsScreen", "/teacher/announcements", "Group posts"],
        ["AdminDashboardScreen", "/admin/dashboard", "Platform stats"],
        ["AdminUsersScreen", "/admin/users", "Create/disable users"],
        ["AdminGroupsScreen", "/admin/groups", "Groups CRUD"],
        ["AdminAnalyticsScreen", "/admin/analytics", "Admin charts"],
        ["AdminAcademicYearsScreen", "/admin/academic-years", "Years/terms"],
        ["AdminAnnouncementsScreen", "/admin/announcements", "Broadcasts"],
        ["AdminCredentialPrintScreen", "/admin/credential-print", "PDF slips"],
        ["AdminMassDataGeneratorScreen", "/admin/mass-generator", "Seed RPC"],
        ["ChatListScreen", "/*/chat", "Rooms"],
        ["ChatRoomScreen", "/*/chat/:roomId", "Messages"],
        ["AppProfileScreen", "/*/profile", "Shared settings"],
    ]
    s.append(simple_table(styles, ["Screen", "Route", "Purpose"], rows, [2.3 * inch, 2.0 * inch, 2.2 * inch]))
    s.append(PageBreak())
    return s


def _seed_admin(styles):
    s = [h1(styles, "Appendix L — Bootstrapping the First Admin")]
    s.append(
        p(
            styles,
            "Until one admin exists, admin_create_user cannot be called from the app. Use the "
            "SQL Editor (service role) to insert auth.users + auth.identities + profiles mirroring "
            "admin_create_user. Steps:",
        )
    )
    s.extend(
        numbered(
            styles,
            [
                "Choose username e.g. @admin and a strong password (store offline).",
                "Compute email: admin@mustudy.internal (strip @ from username then append domain).",
                "INSERT auth.users with extensions.crypt password, email_confirmed_at=now(), role authenticated.",
                "INSERT auth.identities provider=email provider_id=email.",
                "INSERT profiles (id, username, full_name, role='admin', auth_email).",
                "Sign in from the app with username @admin.",
                "Create teachers/students via Admin → Users thereafter.",
            ],
        )
    )
    s.append(
        warn(
            styles,
            "Do not leave demo passwords",
            "Any password123-style seed must be rotated before real users access the project.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Admin bootstrap",
            "You can log in as admin and open /admin/dashboard.",
        )
    )
    return s
