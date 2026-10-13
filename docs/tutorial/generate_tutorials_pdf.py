#!/usr/bin/env python3
"""Generate tutorials.pdf — MU Study complete reconstruction textbook."""

from __future__ import annotations

import os
import sys
from pathlib import Path

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import inch
from reportlab.platypus import (
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)
from reportlab.lib import colors

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(HERE))

from pdf_styles import BRAND, MUTED, ACCENT, build_styles  # noqa: E402
from pdf_helpers import (  # noqa: E402
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
from deep_chapters import deep_dive_chapters  # noqa: E402
from column_catalog import column_catalog  # noqa: E402


OUT = ROOT / "tutorials.pdf"


def header_footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(ACCENT)
    canvas.setLineWidth(0.6)
    canvas.line(0.75 * inch, A4[1] - 0.55 * inch, A4[0] - 0.75 * inch, A4[1] - 0.55 * inch)
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(MUTED)
    canvas.drawString(0.75 * inch, A4[1] - 0.45 * inch, "MU Study — Complete Reconstruction Tutorial")
    canvas.line(0.75 * inch, 0.55 * inch, A4[0] - 0.75 * inch, 0.55 * inch)
    canvas.drawCentredString(A4[0] / 2, 0.35 * inch, f"Page {doc.page}")
    canvas.restoreState()


def title_page(styles):
    story = [Spacer(1, 1.6 * inch)]
    story.append(Paragraph("MU Study", styles["Title"]))
    story.append(Paragraph("Complete Project Reconstruction Tutorial", styles["Subtitle"]))
    story.append(Spacer(1, 0.3 * inch))
    story.append(
        Paragraph(
            "A from-scratch course to recreate the Flutter + Supabase school platform:<br/>"
            "architecture, PostgreSQL schema, RLS, Storage, Auth, Riverpod, go_router,<br/>"
            "role-based UI, chat, homework, attendance, marks, and deployment.",
            styles["Subtitle"],
        )
    )
    story.append(Spacer(1, 0.8 * inch))
    meta = [
        ["Project", "mu_study 1.0.0+1"],
        ["Stack", "Flutter · Dart ^3.11.5 · Riverpod · go_router · Supabase"],
        ["Roles", "Student · Teacher (math/english) · Admin"],
        ["Locales", "English · Russian · Uzbek"],
        ["Source of truth", "Live Supabase project + this repository"],
        ["Secrets policy", "Placeholders only — never paste real keys"],
    ]
    t = Table(meta, colWidths=[1.6 * inch, 4.6 * inch])
    t.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (0, -1), "Helvetica-Bold"),
                ("TEXTCOLOR", (0, 0), (0, -1), BRAND),
                ("FONTSIZE", (0, 0), (-1, -1), 10),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 6),
                ("LINEBELOW", (0, 0), (-1, -2), 0.3, ACCENT),
            ]
        )
    )
    story.append(t)
    story.append(Spacer(1, 1.2 * inch))
    story.append(
        Paragraph(
            "<i>Educational textbook generated from the inspected MU Study codebase and "
            "the live PostgreSQL/Supabase configuration. Recreate the application without "
            "copying the original tree blindly — follow each chapter in order.</i>",
            styles["Caption"],
        )
    )
    story.append(PageBreak())
    return story


def toc(styles):
    story = [h1(styles, "Table of Contents")]
    entries = [
        "1. How to Use This Tutorial",
        "2. What You Are Building",
        "3. Architecture Map",
        "4. Environment & Tooling Setup",
        "5. Create the Flutter Project From Zero",
        "6. Dependencies (Every Package)",
        "7. Project Structure",
        "8. Supabase Project Setup",
        "9. Database — Enums & Core Tables",
        "10. Database — School Domain Tables",
        "11. Database — Chat, Academic Years, Views",
        "12. Helper Functions & RPCs",
        "13. Row Level Security (RLS)",
        "14. Storage Buckets & Policies",
        "15. Realtime",
        "16. Environment Variables & Bootstrap",
        "17. Models & Enums",
        "18. Authentication End-to-End",
        "19. Routing & App Shell",
        "20. Theme, Locale, Shared UI",
        "21. Feature: Groups & Admin Users",
        "22. Feature: Assignments & Submissions",
        "23. Feature: Marks / Gradebook",
        "24. Feature: Attendance",
        "25. Feature: Chat (Telegram-style)",
        "26. Feature: Notifications & Announcements",
        "27. Feature: Focus Mode",
        "28. Feature: Academic Years & Credentials",
        "29. Security Chapter",
        "30. Troubleshooting",
        "31. Testing & Acceptance Checklist",
        "32. Deployment",
        "33. Final Reconstruction Challenge",
        "34. Database Verification Queries",
        "Appendix A — Complete Schema SQL Skeleton",
        "Appendix B — Limitations & Source Gaps",
        "Appendix C — chat_room_summaries View (Exact)",
        "Appendix D — RLS Policy SQL Templates",
        "Appendix E — Full Critical Function Bodies",
        "Appendix F — Login Screen Implementation",
        "Appendix G — Router Redirect Logic",
        "Appendix H — Chat Implementation Deep Dive",
        "Appendix I — Platform Permissions",
        "Appendix J — Makefile & Local Commands",
        "Appendix K — Screen Catalog",
        "Appendix L — Bootstrapping the First Admin",
        "Appendix M — Full Column Catalog (Every Table)",
    ]
    for e in entries:
        story.append(Paragraph(e, styles["TOCEntry"]))
    story.append(PageBreak())
    return story


def ch1(styles):
    s = [h1(styles, "1. How to Use This Tutorial")]
    s.append(
        p(
            styles,
            "This book teaches you to rebuild <b>MU Study</b> — a school management and "
            "study platform for Math and English teachers — from an empty directory and a "
            "brand-new Supabase project. It is not a high-level overview. Every major "
            "object (table column, RLS policy, route, provider) is named explicitly.",
        )
    )
    s.append(h2(styles, "Learning contract"))
    s.extend(
        bullets(
            styles,
            [
                "Work sequentially. Later chapters assume earlier checkpoints pass.",
                "Type SQL and Dart yourself. Do not paste secrets from any .env file.",
                "After each TASK box, verify the listed outcomes before continuing.",
                "When something fails, use Chapter 30 (Troubleshooting) before skipping ahead.",
                "The repository is the source of truth for behavior; this book documents that behavior.",
            ],
        )
    )
    s.append(h2(styles, "What “complete” means here"))
    s.append(
        p(
            styles,
            "A complete recreation includes: Flutter client with three role shells; "
            "username/password auth via synthetic emails; PostgreSQL enums/tables/views; "
            "SECURITY DEFINER RPCs; RLS; Storage buckets; Realtime on chat/notifications; "
            "EN/RU/UZ localization; four visual styles; homework packs; attendance sessions; "
            "gradebook; group chat with reactions/replies; admin mass tools.",
        )
    )
    s.append(
        warn(
            styles,
            "Missing migrations in the Git tree",
            "The README mentions supabase/migrations/ and seed_full.sql, but those files are "
            "NOT present in the checked-in repository. Schema details in this tutorial were "
            "recovered from the LIVE Supabase project (nmmdvdprczukaskxxdrs) plus Dart usage "
            "and the SQL fragments under sql/. Treat Appendix A as the rebuild script.",
        )
    )
    s.append(
        task(
            styles,
            "Orientation",
            "1) Skim the Table of Contents.\n"
            "2) Confirm you have a computer that can install Flutter and a free Supabase account.\n"
            "3) Create a notes file titled mu_study_rebuild_notes.md for passwords you invent "
            "(never commit it).",
        )
    )
    s.append(PageBreak())
    return s


def ch2(styles):
    s = [h1(styles, "2. What You Are Building")]
    s.append(
        p(
            styles,
            "MU Study is a multi-role school app. There is <b>no public registration</b>. "
            "An admin creates every account. Users log in with a <b>username + password</b>. "
            "Behind the scenes Supabase Auth still uses email/password, but emails are "
            "synthetic: <font face='Courier'>username@mustudy.internal</font>.",
        )
    )
    s.append(h2(styles, "Roles"))
    s.append(
        simple_table(
            styles,
            ["Role", "DB enum", "Primary capabilities"],
            [
                ["Student", "student", "Homework submit, marks, attendance view, chat, focus, notifications"],
                ["Teacher", "teacher", "Groups (own), assignments, gradebook, attendance take, announcements, chat"],
                ["Admin", "admin", "Users, groups, analytics, academic years, announcements, credential slips, mass generator"],
            ],
            [1.1 * inch, 1.1 * inch, 4.3 * inch],
        )
    )
    s.append(h2(styles, "Teacher spheres"))
    s.append(p(styles, "Teachers have a required sphere: <b>math</b> or <b>english</b> (Postgres enum sphere_type)."))
    s.append(h2(styles, "Platforms"))
    s.extend(
        bullets(
            styles,
            [
                "Android (applicationId com.example.mu_study) — INTERNET, RECORD_AUDIO",
                "iOS (bundle com.example.muStudy) — microphone + photo library usage strings",
                "Web (Chrome) — responsive shell; Makefile target make ch",
            ],
        )
    )
    s.append(h2(styles, "End-to-end data flow (actual)"))
    s.append(
        code_block(
            styles,
            "Conceptual path",
            "User taps UI\n"
            "  → Widget (screen/component)\n"
            "  → Riverpod provider / Notifier\n"
            "  → supabase.from(...) or supabase.rpc(...)\n"
            "  → PostgREST / Postgres (RLS enforced)\n"
            "  → Optional Storage signed/public URL\n"
            "  → Optional Realtime INSERT/UPDATE/DELETE\n"
            "  → Provider state updates\n"
            "  → Widget rebuilds",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Product understanding",
            "You can explain to a classmate: who creates accounts, how login maps username→email, "
            "and which three shells exist.",
        )
    )
    s.append(PageBreak())
    return s


def ch3(styles):
    s = [h1(styles, "3. Architecture Map")]
    s.append(h2(styles, "Frontend layers"))
    s.append(
        simple_table(
            styles,
            ["Layer", "Path", "Responsibility"],
            [
                ["Bootstrap", "lib/main.dart", "Env load, Supabase.initialize, ProviderScope, themes"],
                ["Env", "lib/core/constants/env.dart", "SUPABASE_URL + ANON/PUBLISHABLE key"],
                ["Router", "lib/core/router/app_router.dart", "go_router + auth redirects"],
                ["Shell", "lib/components/layouts/", "Role nav: bottom bar / rail / sidebar"],
                ["Screens", "lib/screens/{role}/", "Feature UI"],
                ["Providers", "lib/providers/", "Riverpod data + mutations"],
                ["Models", "lib/models/", "JSON ↔ Dart domain types"],
                ["Theme", "lib/core/theme/", "4 styles × light/dark"],
                ["l10n", "lib/l10n/", "ARB en/ru/uz"],
            ],
            [1.1 * inch, 2.2 * inch, 3.2 * inch],
        )
    )
    s.append(h2(styles, "Backend"))
    s.extend(
        bullets(
            styles,
            [
                "Supabase Auth (email provider) with internal emails",
                "PostgreSQL 17 public schema with RLS enabled on all app tables",
                "SECURITY DEFINER helpers: is_admin, is_teacher_of_group, is_student_in_group, can_access_chat_room, …",
                "Storage buckets: avatars (public), submissions, assignments, announcements, chat-* (private)",
                "Realtime on notifications, chat_messages, message_reads, message_reactions",
            ],
        )
    )
    s.append(h2(styles, "State management choice"))
    s.append(
        p(
            styles,
            "The project uses <b>flutter_riverpod</b> (not Bloc). Auth is a StreamProvider over "
            "onAuthStateChange. Lists often use AsyncNotifier with pagination. Chat rooms use "
            "streams combining summaries + unread RPC. Focus mode is local SharedPreferences "
            "(no DB table).",
        )
    )
    s.append(h2(styles, "Navigation choice"))
    s.append(
        p(
            styles,
            "go_router with a redirect notifier watching auth + profile. Nested ShellRoute "
            "per role. Chat list/room are shared screens parameterized by basePath "
            "(/student/chat, /teacher/chat, /admin/chat).",
        )
    )
    s.append(
        callout(
            styles,
            "Why username login needs an RPC",
            "Supabase Auth signInWithPassword requires an email. MU Study stores auth_email on "
            "profiles and exposes get_auth_email_by_username so the client never invents the "
            "email formula incorrectly for disabled users.",
        )
    )
    s.append(PageBreak())
    return s


def ch4(styles):
    s = [h1(styles, "4. Environment & Tooling Setup")]
    s.append(h2(styles, "Assumptions"))
    s.extend(
        bullets(
            styles,
            [
                "macOS, Windows, or Linux with admin rights to install SDKs",
                "Git installed",
                "Ability to create a project at https://supabase.com",
            ],
        )
    )
    s.append(h2(styles, "Install Flutter (match project SDK)"))
    s.append(p(styles, "pubspec.yaml requires <font face='Courier'>environment: sdk: ^3.11.5</font>. Install a current Flutter stable that ships Dart ≥ 3.11.5."))
    s.append(
        code_block(
            styles,
            "Verify",
            "flutter --version\n"
            "dart --version\n"
            "flutter doctor -v",
        )
    )
    s.append(
        p(
            styles,
            "Fix any blockers for the platforms you care about (Xcode for iOS, Android Studio / cmdline-tools for Android, Chrome for web).",
        )
    )
    s.append(h2(styles, "Other tools"))
    s.extend(
        numbered(
            styles,
            [
                "IDE: VS Code or Android Studio / IntelliJ with Flutter + Dart plugins (Cursor works).",
                "Optional: Supabase CLI for local workflows — not required if you use Dashboard SQL Editor.",
                "Optional: make — project Makefile wraps flutter run / pub get / apk.",
            ],
        )
    )
    s.append(
        task(
            styles,
            "Tooling ready",
            "Run flutter doctor until your target device shows no errors. Create an empty folder "
            "named mu_study_rebuild outside this repo for the recreation challenge later.",
        )
    )
    s.append(PageBreak())
    return s


def ch5(styles):
    s = [h1(styles, "5. Create the Flutter Project From Zero")]
    s.append(
        code_block(
            styles,
            "Terminal",
            "flutter create --org com.example --project-name mu_study mu_study\n"
            "cd mu_study",
        )
    )
    s.append(
        p(
            styles,
            "This yields android/, ios/, web/, lib/main.dart, pubspec.yaml, analysis_options.yaml, test/. "
            "You will replace most of lib/ and expand pubspec.yaml.",
        )
    )
    s.append(h2(styles, "Align package identity with the original"))
    s.extend(
        bullets(
            styles,
            [
                "Android applicationId: com.example.mu_study (android/app/build.gradle.kts)",
                "iOS product bundle identifier: com.example.muStudy",
                "Display name: MU Study (AndroidManifest label + iOS CFBundleDisplayName)",
            ],
        )
    )
    s.append(h2(styles, "Asset folders to create"))
    s.append(
        code_block(
            styles,
            "Shell",
            "mkdir -p assets/images/logo assets/images/nature-paper assets/lottie\n"
            "# Place logo.jpeg under assets/images/logo/\n"
            "# Nature-paper PNGs and Lottie JSONs are required for full UI parity",
        )
    )
    s.append(
        warn(
            styles,
            "Assets are large",
            "The original ships ~57 nature-paper PNGs and ~74 Lottie emoji animations. Without them, "
            "Nature Paper style and animated chat emoji degrade. Functionality still works with Material icons.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Empty app runs",
            "flutter run launches the counter demo on a device/emulator/Chrome.",
        )
    )
    s.append(PageBreak())
    return s


def ch6(styles):
    s = [h1(styles, "6. Dependencies (Every Package)")]
    s.append(p(styles, "Copy these constraints into pubspec.yaml (versions from the original project). Then run flutter pub get."))
    s.append(
        simple_table(
            styles,
            ["Package", "Constraint", "Purpose"],
            [
                ["supabase_flutter", "^2.9.1", "Auth, DB, Storage, Realtime client"],
                ["flutter_riverpod", "^2.6.1", "State management"],
                ["go_router", "^14.8.1", "Declarative routing + redirects"],
                ["flutter_dotenv", "^5.2.1", "Load .env asset"],
                ["shared_preferences", "^2.5.3", "Theme/locale/focus/cache"],
                ["responsive_framework", "^1.5.1", "Breakpoints wrapper"],
                ["google_fonts", "^6.2.1", "Plus Jakarta Sans"],
                ["intl", "^0.20.2", "Dates + l10n helpers"],
                ["cached_network_image", "^3.4.1", "Avatars/media cache"],
                ["flutter_cache_manager", "^3.4.2", "Custom cache"],
                ["file_picker / image_picker", "^8.3.7 / ^1.1.2", "Attachments"],
                ["record / audioplayers", "^6.2.1 / ^6.7.1", "Voice notes"],
                ["video_player", "^2.11.1", "Chat videos"],
                ["get_thumbnail_video", "^0.7.3", "Video thumbs"],
                ["lottie", "^3.3.3", "Animated emoji"],
                ["syncfusion_* pdf/charts/viewer", "^30.1.41", "PDF slips, charts, PDF view"],
                ["share_plus", "^11.0.0", "Share reports"],
                ["url_launcher", "^6.3.1", "Open links"],
                ["http / crypto / path / path_provider / cross_file / characters / package_info_plus", "various", "Networking, hashing, paths, app info"],
                ["shimmer / skeletonizer / flutter_animate", "UX", "Loading & motion"],
                ["freezed_annotation / json_annotation", "codegen", "Present; models mostly hand-written"],
            ],
            [2.2 * inch, 1.3 * inch, 3.0 * inch],
        )
    )
    s.append(h3(styles, "Dev dependencies"))
    s.append(p(styles, "flutter_lints ^6.0.0, build_runner, freezed, json_serializable."))
    s.append(h3(styles, "Override"))
    s.append(code_block(styles, "pubspec.yaml", "dependency_overrides:\n  audioplayers_darwin: 6.3.0"))
    s.append(h3(styles, "Flutter section"))
    s.append(
        code_block(
            styles,
            "pubspec.yaml",
            "flutter:\n"
            "  generate: true\n"
            "  uses-material-design: true\n"
            "  assets:\n"
            "    - assets/images/\n"
            "    - assets/images/logo/\n"
            "    - assets/images/nature-paper/\n"
            "    - assets/lottie/\n"
            "    - .env",
        )
    )
    s.append(h3(styles, "l10n.yaml"))
    s.append(
        code_block(
            styles,
            "l10n.yaml",
            "arb-dir: lib/l10n\n"
            "template-arb-file: app_en.arb\n"
            "output-localization-file: app_localizations.dart\n"
            "output-class: AppLocalizations",
        )
    )
    s.append(
        task(
            styles,
            "Dependencies",
            "Update pubspec.yaml, add empty ARB files with a few keys, run flutter pub get "
            "and flutter gen-l10n. Confirm no dependency resolution errors.",
        )
    )
    s.append(PageBreak())
    return s


def ch7(styles):
    s = [h1(styles, "7. Project Structure")]
    s.append(
        code_block(
            styles,
            "Target tree (lib/)",
            "lib/\n"
            "  main.dart\n"
            "  components/          # reusable UI (shell, buttons, chat, marks, …)\n"
            "  core/\n"
            "    constants/env.dart\n"
            "    router/app_router.dart\n"
            "    theme/             # styles × themes\n"
            "    services/          # cache, media helpers\n"
            "    locale/, chat/, marks/, homework/, admin/, progress/, focus/\n"
            "  l10n/                # app_en.arb, app_ru.arb, app_uz.arb + generated\n"
            "  models/              # enums + domain classes + models.dart barrel\n"
            "  providers/           # auth, groups, homework, marks, attendance, chat, …\n"
            "  screens/\n"
            "    auth/\n"
            "    student/|teacher/|admin/|chat/|profile/\n"
            "  supabase/supabase_client.dart\n"
            "  tools/generate_school_sql.dart  # optional offline SQL printer",
        )
    )
    s.append(
        p(
            styles,
            "Create empty directories first, then fill files chapter by chapter. Do not invent a "
            "features/ folder — the original organizes by role under screens/ and by domain under providers/.",
        )
    )
    s.append(PageBreak())
    return s


def ch8(styles):
    s = [h1(styles, "8. Supabase Project Setup")]
    s.extend(
        numbered(
            styles,
            [
                "Sign in at supabase.com → New project. Pick a region (original: ap-southeast-1).",
                "Save the database password in your private notes (not in git).",
                "Project Settings → API: copy Project URL and anon/public key.",
                "Authentication → Providers: enable Email. Disable public signup if you want parity "
                "(accounts are created via SECURITY DEFINER RPC inserting into auth.users).",
                "Authentication → URL Configuration: set Site URL to your web origin for production; "
                "for local Flutter mobile, default localhost is fine because login uses password grant.",
                "Database → Extensions: ensure pgcrypto (extensions.crypt / gen_salt) is available — "
                "Supabase usually provides schema extensions.",
                "Realtime: enable for tables listed in Chapter 15.",
            ],
        )
    )
    s.append(
        code_block(
            styles,
            ".env (PLACEHOLDERS ONLY)",
            "SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co\n"
            "SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.YOUR_ANON_JWT\n"
            "# or SUPABASE_PUBLISHABLE_KEY=sb_publishable_...",
        )
    )
    s.append(
        warn(
            styles,
            "Never commit service_role",
            "The Flutter client must use the anon/publishable key only. Service role keys bypass RLS "
            "and must stay server-side / Dashboard only.",
        )
    )
    s.append(
        task(
            styles,
            "Empty Supabase project",
            "Create the project, create .env with placeholders replaced by YOUR keys, keep .env "
            "out of public repos (.gitignore already ignores typical secrets — still double-check).",
        )
    )
    s.append(PageBreak())
    return s


def ch9(styles):
    s = [h1(styles, "9. Database — Enums & Core Tables")]
    s.append(
        p(
            styles,
            "Run the following in the Supabase SQL Editor in order. These definitions match the "
            "live MU Study database (inspected August 2026).",
        )
    )
    s.append(h2(styles, "9.1 Enums"))
    s.append(
        code_block(
            styles,
            "SQL — enums",
            "CREATE TYPE public.user_role AS ENUM ('student', 'teacher', 'admin');\n"
            "CREATE TYPE public.sphere_type AS ENUM ('math', 'english');\n"
            "CREATE TYPE public.assignment_type AS ENUM ('static', 'homework_pack');\n"
            "CREATE TYPE public.attendance_status AS ENUM ('present', 'absent', 'late', 'excused');\n"
            "CREATE TYPE public.submission_status AS ENUM ('pending', 'submitted', 'reviewed');\n"
            "CREATE TYPE public.chat_message_type AS ENUM ('text', 'voice', 'image', 'video', 'file');\n"
            "CREATE TYPE public.mark_category AS ENUM (\n"
            "  'homework', 'classwork', 'quiz', 'test', 'exam', 'project', 'oral', 'other'\n"
            ");",
        )
    )
    s.append(h2(styles, "9.2 profiles"))
    s.append(
        p(
            styles,
            "Purpose: app user record keyed by auth.users.id. Holds role, synthetic auth_email, "
            "disable flag, and UI preferences.",
        )
    )
    s.append(
        code_block(
            styles,
            "SQL — profiles",
            "CREATE TABLE public.profiles (\n"
            "  id UUID PRIMARY KEY,  -- equals auth.users.id\n"
            "  username TEXT NOT NULL UNIQUE,\n"
            "  full_name TEXT NOT NULL DEFAULT '',\n"
            "  role public.user_role NOT NULL,\n"
            "  auth_email TEXT NOT NULL UNIQUE,\n"
            "  avatar_url TEXT,\n"
            "  is_disabled BOOLEAN NOT NULL DEFAULT false,\n"
            "  preferred_language TEXT,\n"
            "  preferred_theme TEXT,\n"
            "  preferred_style TEXT,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n"
            ");\n"
            "CREATE INDEX idx_profiles_username ON public.profiles (username);",
        )
    )
    s.append(
        callout(
            styles,
            "auth_email formula",
            "lower(trim(replace(username,'@',''))) || '@mustudy.internal' — implemented inside "
            "admin_create_user, not in a DB generated column.",
        )
    )
    s.append(h2(styles, "9.3 teachers & students"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE TABLE public.teachers (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,\n"
            "  sphere public.sphere_type NOT NULL,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n"
            ");\n\n"
            "CREATE TABLE public.students (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n"
            ");",
        )
    )
    s.append(
        p(
            styles,
            "Note the dual IDs: teachers.id / students.id are used as FKs from groups, marks, "
            "attendance, etc. profiles.id is the auth uid used as chat sender_id.",
        )
    )
    s.append(
        task(
            styles,
            "Core identity tables",
            "Create enums + profiles + teachers + students. Verify in Table Editor. Do not enable "
            "RLS yet until helper functions exist (Chapter 12–13).",
        )
    )
    s.append(PageBreak())
    return s


def ch10(styles):
    s = [h1(styles, "10. Database — School Domain Tables")]
    s.append(h2(styles, "groups & group_students"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE TABLE public.groups (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,\n"
            "  title TEXT NOT NULL,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n"
            ");\n"
            "CREATE UNIQUE INDEX groups_teacher_title_uidx ON public.groups (teacher_id, title);\n"
            "CREATE INDEX idx_groups_teacher ON public.groups (teacher_id);\n\n"
            "CREATE TABLE public.group_students (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,\n"
            "  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),\n"
            "  UNIQUE (group_id, student_id)\n"
            ");",
        )
    )
    s.append(
        warn(
            styles,
            "No auto Group 1/2/3",
            "Older admin_create_user versions auto-created three groups per teacher. The current "
            "function does NOT. Admins create exact titles from Admin → Groups.",
        )
    )
    s.append(h2(styles, "assignments, tasks, submissions"))
    s.append(
        code_block(
            styles,
            "SQL (abridged for page width — include every column)",
            "CREATE TABLE public.assignments (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,\n"
            "  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,\n"
            "  type public.assignment_type NOT NULL DEFAULT 'static',\n"
            "  title TEXT NOT NULL,\n"
            "  description TEXT NOT NULL DEFAULT '',\n"
            "  due_date TIMESTAMPTZ,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n"
            ");\n"
            "CREATE INDEX idx_assignments_group ON public.assignments (group_id);\n\n"
            "CREATE TABLE public.tasks (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  assignment_id UUID NOT NULL REFERENCES public.assignments(id) ON DELETE CASCADE,\n"
            "  title TEXT NOT NULL,\n"
            "  description TEXT NOT NULL DEFAULT '',\n"
            "  attachment_url TEXT,\n"
            "  link_url TEXT,\n"
            "  sort_order INT NOT NULL DEFAULT 0,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n"
            ");\n\n"
            "CREATE TABLE public.submissions (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,\n"
            "  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,\n"
            "  text_answer TEXT,\n"
            "  file_url TEXT,\n"
            "  voice_url TEXT,\n"
            "  status public.submission_status NOT NULL DEFAULT 'pending',\n"
            "  score NUMERIC,\n"
            "  feedback TEXT,\n"
            "  is_completed BOOLEAN NOT NULL DEFAULT false,\n"
            "  submitted_at TIMESTAMPTZ,\n"
            "  UNIQUE (task_id, student_id)\n"
            ");",
        )
    )
    s.append(h2(styles, "marks"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE TABLE public.marks (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,\n"
            "  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,\n"
            "  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,\n"
            "  submission_id UUID UNIQUE REFERENCES public.submissions(id) ON DELETE CASCADE,\n"
            "  title TEXT NOT NULL,\n"
            "  category public.mark_category NOT NULL DEFAULT 'other',\n"
            "  percentage NUMERIC NOT NULL,\n"
            "  weight NUMERIC NOT NULL DEFAULT 1,\n"
            "  comment TEXT NOT NULL DEFAULT '',\n"
            "  marked_on DATE NOT NULL DEFAULT CURRENT_DATE,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),\n"
            "  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()\n"
            ");\n"
            "CREATE INDEX idx_marks_group ON public.marks (group_id, marked_on DESC);\n"
            "CREATE INDEX idx_marks_student ON public.marks (student_id, marked_on DESC);",
        )
    )
    s.append(h2(styles, "lesson_sessions & attendance"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE TABLE public.lesson_sessions (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,\n"
            "  session_date DATE NOT NULL,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),\n"
            "  UNIQUE (group_id, session_date)\n"
            ");\n\n"
            "CREATE TABLE public.attendance (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,\n"
            "  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,\n"
            "  session_id UUID NOT NULL REFERENCES public.lesson_sessions(id) ON DELETE CASCADE,\n"
            "  status public.attendance_status NOT NULL,\n"
            "  date DATE NOT NULL,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),\n"
            "  UNIQUE (group_id, student_id, date),\n"
            "  UNIQUE (session_id, student_id)\n"
            ");",
        )
    )
    s.append(h2(styles, "announcements, notifications, assignment_templates"))
    s.append(
        p(
            styles,
            "announcements.teacher_id is NULLABLE so admins can author without a teachers row. "
            "image_urls/file_urls are jsonb arrays default []. notifications include kind, "
            "action_path, ref_id for deep links. assignment_templates.tasks is jsonb of task drafts.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "School tables exist",
            "Table Editor shows groups, group_students, assignments, tasks, submissions, marks, "
            "lesson_sessions, attendance, announcements, notifications, assignment_templates.",
        )
    )
    s.append(PageBreak())
    return s


def ch11(styles):
    s = [h1(styles, "11. Database — Chat, Academic Years, Views")]
    s.append(h2(styles, "chat_rooms, chat_messages, reads, reactions"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE TABLE public.chat_rooms (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  group_id UUID NOT NULL UNIQUE REFERENCES public.groups(id) ON DELETE CASCADE,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n"
            ");\n\n"
            "CREATE TABLE public.chat_messages (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,\n"
            "  sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,\n"
            "  message_type public.chat_message_type NOT NULL DEFAULT 'text',\n"
            "  text_content TEXT,\n"
            "  media_url TEXT,\n"
            "  is_deleted BOOLEAN NOT NULL DEFAULT false,\n"
            "  reply_to_message_id UUID REFERENCES public.chat_messages(id) ON DELETE SET NULL,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),\n"
            "  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()\n"
            ");\n"
            "CREATE INDEX idx_chat_messages_room_created ON public.chat_messages (room_id, created_at DESC);\n\n"
            "CREATE TABLE public.message_reads (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  message_id UUID NOT NULL REFERENCES public.chat_messages(id) ON DELETE CASCADE,\n"
            "  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,\n"
            "  read_at TIMESTAMPTZ NOT NULL DEFAULT now(),\n"
            "  UNIQUE (message_id, user_id)\n"
            ");\n\n"
            "CREATE TABLE public.message_reactions (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  message_id UUID NOT NULL REFERENCES public.chat_messages(id) ON DELETE CASCADE,\n"
            "  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,\n"
            "  emoji TEXT NOT NULL,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),\n"
            "  UNIQUE (message_id, user_id)\n"
            ");",
        )
    )
    s.append(
        p(
            styles,
            "Add a trigger ensure_chat_room_for_group AFTER INSERT ON groups to create the room "
            "automatically (name matches live DB). Soft-delete messages by setting is_deleted=true "
            "and clearing text/media (matches Flutter ChatMessagesNotifier.deleteMessages).",
        )
    )
    s.append(h2(styles, "chat_room_summaries view"))
    s.append(
        p(
            styles,
            "The Flutter client reads from view chat_room_summaries (not raw chat_rooms) to get "
            "group_title, teacher_name, member_count, and last message fields. Rebuild the view by "
            "joining chat_rooms → groups → teachers → profiles and a lateral last message. "
            "unread_count is NOT a view column — it comes from RPC chat_unread_counts().",
        )
    )
    s.append(h2(styles, "academic_years & academic_terms"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE TABLE public.academic_years (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  start_year INT NOT NULL UNIQUE,\n"
            "  label TEXT NOT NULL,\n"
            "  is_current BOOLEAN NOT NULL DEFAULT false,\n"
            "  created_by UUID,\n"
            "  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n"
            ");\n"
            "CREATE UNIQUE INDEX academic_years_one_current\n"
            "  ON public.academic_years ((true)) WHERE is_current;\n\n"
            "CREATE TABLE public.academic_terms (\n"
            "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n"
            "  academic_year_id UUID NOT NULL REFERENCES public.academic_years(id) ON DELETE CASCADE,\n"
            "  semester INT NOT NULL CHECK (semester BETWEEN 1 AND 4),\n"
            "  starts_on DATE NOT NULL,\n"
            "  ends_on DATE NOT NULL,\n"
            "  UNIQUE (academic_year_id, semester)\n"
            ");",
        )
    )
    s.append(h2(styles, "Mark average views"))
    s.append(
        p(
            styles,
            "Live DB also has views student_mark_averages and student_group_mark_averages "
            "(student_id, average_percent, marks_count, last_marked_on[, group_id]). Recreate as "
            "weighted averages over marks.percentage * marks.weight.",
        )
    )
    s.append(PageBreak())
    return s


def ch12(styles):
    s = [h1(styles, "12. Helper Functions & RPCs")]
    s.append(
        p(
            styles,
            "These SECURITY DEFINER functions are the authorization backbone. Create them "
            "<b>before</b> RLS policies that call them.",
        )
    )
    s.append(h2(styles, "Role helpers (exact live SQL)"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE OR REPLACE FUNCTION public.is_admin()\n"
            "RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public' AS $$\n"
            "  SELECT EXISTS (\n"
            "    SELECT 1 FROM public.profiles\n"
            "    WHERE id = auth.uid() AND role = 'admin' AND is_disabled = FALSE\n"
            "  );\n"
            "$$;\n\n"
            "CREATE OR REPLACE FUNCTION public.current_profile_role()\n"
            "RETURNS user_role LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public' AS $$\n"
            "  SELECT role FROM public.profiles WHERE id = auth.uid();\n"
            "$$;\n\n"
            "CREATE OR REPLACE FUNCTION public.is_teacher_of_group(gid uuid)\n"
            "RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public' AS $$\n"
            "  SELECT EXISTS (\n"
            "    SELECT 1 FROM public.groups g\n"
            "    JOIN public.teachers t ON t.id = g.teacher_id\n"
            "    WHERE g.id = gid AND t.profile_id = auth.uid()\n"
            "  );\n"
            "$$;\n\n"
            "CREATE OR REPLACE FUNCTION public.is_student_in_group(gid uuid)\n"
            "RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public' AS $$\n"
            "  SELECT EXISTS (\n"
            "    SELECT 1 FROM public.group_students gs\n"
            "    JOIN public.students s ON s.id = gs.student_id\n"
            "    WHERE gs.group_id = gid AND s.profile_id = auth.uid()\n"
            "  );\n"
            "$$;",
        )
    )
    s.append(h2(styles, "Login RPC"))
    s.append(
        code_block(
            styles,
            "SQL",
            "CREATE OR REPLACE FUNCTION public.get_auth_email_by_username(p_username text)\n"
            "RETURNS text LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public' AS $$\n"
            "  SELECT auth_email FROM public.profiles\n"
            "  WHERE lower(username) = lower(trim(p_username))\n"
            "    AND is_disabled = FALSE LIMIT 1;\n"
            "$$;\n"
            "GRANT EXECUTE ON FUNCTION public.get_auth_email_by_username(text) TO anon, authenticated;",
        )
    )
    s.append(h2(styles, "Chat helpers"))
    s.append(
        code_block(
            styles,
            "SQL — can_access_chat_room + chat_unread_counts + toggle_message_reaction",
            "-- See live definitions: can_access_chat_room(rid) = admin OR teacher/student of room's group\n"
            "-- chat_unread_counts(): messages not deleted, not mine, no message_reads row for me\n"
            "-- toggle_message_reaction(p_message_id, p_emoji): insert/update/delete one reaction per user",
        )
    )
    s.append(
        p(
            styles,
            "Paste the full function bodies from Chapter inspection / Appendix — the live "
            "toggle_message_reaction validates access, toggles off if same emoji, otherwise upserts.",
        )
    )
    s.append(h2(styles, "admin_create_user (current behavior)"))
    s.append(
        p(
            styles,
            "SECURITY DEFINER. Requires is_admin(). Creates auth.users + auth.identities + "
            "profiles (+ teachers/students). Email = username@mustudy.internal. Password hashed "
            "with extensions.crypt(..., gen_salt('bf')). Does NOT create default groups. "
            "GRANT EXECUTE TO authenticated.",
        )
    )
    s.append(h2(styles, "Other RPCs the Flutter app calls"))
    s.append(
        simple_table(
            styles,
            ["RPC", "Args", "Used for"],
            [
                ["admin_reset_password", "p_user_id, p_password", "Admin password reset / slips"],
                ["admin_mass_generate_school_data", "jsonb teachers/students/groups/assignments", "Mass generator screen"],
                ["admin_create_next_academic_year", "—", "Academic years UI"],
                ["admin_set_current_academic_year", "p_year_id", "Set current year"],
                ["admin_delete_academic_year", "p_year_id", "Delete year"],
                ["admin_update_academic_term", "p_term_id, dates", "Edit term window"],
                ["ensure_lesson_session", "p_group_id, p_session_date", "Before attendance upsert; rejects future dates"],
            ],
            [2.2 * inch, 2.0 * inch, 2.3 * inch],
        )
    )
    s.append(
        task(
            styles,
            "Helpers",
            "Create is_admin, current_profile_role, is_teacher_of_group, is_student_in_group, "
            "get_auth_email_by_username. Test get_auth_email_by_username from SQL with a seed profile.",
        )
    )
    s.append(PageBreak())
    return s


def ch13(styles):
    s = [h1(styles, "13. Row Level Security (RLS)")]
    s.append(
        p(
            styles,
            "Every public business table has RLS enabled. Below is the policy catalog from the "
            "live project. Recreate each policy by name.",
        )
    )
    s.append(h2(styles, "Pattern"))
    s.append(
        code_block(
            styles,
            "SQL pattern",
            "ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;\n"
            "CREATE POLICY groups_select ON public.groups FOR SELECT TO authenticated\n"
            "  USING (is_teacher_of_group(id) OR is_student_in_group(id) OR is_admin());\n"
            "CREATE POLICY groups_teacher_manage ON public.groups FOR ALL TO authenticated\n"
            "  USING (is_teacher_of_group(id) OR is_admin())\n"
            "  WITH CHECK (is_teacher_of_group(id) OR is_admin());",
        )
    )
    s.append(h2(styles, "Policy inventory (must match)"))
    policies = [
        ["profiles", "profiles_select / profiles_update_self / profiles_admin_all / groupmate + chat sender selects"],
        ["teachers/students", "select for self/admin/counterpart role; admin ALL"],
        ["groups/group_students", "select for members; manage teacher/admin"],
        ["assignments/tasks", "select members; teacher ALL via ownership"],
        ["submissions", "student ALL own; teacher UPDATE review; select parties"],
        ["marks", "select student own or teacher of group; teacher manage"],
        ["attendance/lesson_sessions", "select members; manage teacher/admin"],
        ["announcements", "select members; teacher/admin ALL"],
        ["notifications", "notifications_own ALL where user_id = auth.uid()"],
        ["chat_rooms", "select can_access_chat_room; insert admin/teacher of group"],
        ["chat_messages", "select access; insert sender=uid; update/delete own or admin"],
        ["message_reads/reactions", "scoped to room access + own user_id"],
        ["academic_*", "select true for authenticated; admin ALL"],
        ["assignment_templates", "teacher owns or admin"],
    ]
    s.append(simple_table(styles, ["Table", "Policies (summary)"], policies, [1.8 * inch, 4.7 * inch]))
    s.append(
        warn(
            styles,
            "Client delete vs RLS",
            "DB allows admin OR sender to UPDATE/DELETE chat_messages. The Flutter UI further "
            "restricts Delete/Select to the message owner only (own messages). Recreate both layers.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "RLS smoke test",
            "As student JWT, SELECT other group's assignments returns 0 rows. As teacher of group, rows appear.",
        )
    )
    s.append(PageBreak())
    return s


def ch14(styles):
    s = [h1(styles, "14. Storage Buckets & Policies")]
    s.append(
        simple_table(
            styles,
            ["Bucket", "Public?", "App usage"],
            [
                ["avatars", "YES", "{profileId}/avatar.jpg — getPublicUrl"],
                ["submissions", "NO", "{studentId}/{taskId}/… — signed URL ~10y"],
                ["assignments", "NO", "task attachments (authenticated)"],
                ["announcements", "NO", "announcement media"],
                ["chat-images", "NO", "{roomId}/{uid}/{stamp}_file"],
                ["chat-videos", "NO", "same path pattern"],
                ["chat-voices", "NO", "same"],
                ["chat-files", "NO", "same"],
            ],
            [1.4 * inch, 0.9 * inch, 4.2 * inch],
        )
    )
    s.append(h2(styles, "Create buckets"))
    s.append(
        code_block(
            styles,
            "SQL",
            "INSERT INTO storage.buckets (id, name, public) VALUES\n"
            " ('avatars','avatars', true),\n"
            " ('submissions','submissions', false),\n"
            " ('assignments','assignments', false),\n"
            " ('announcements','announcements', false),\n"
            " ('chat-images','chat-images', false),\n"
            " ('chat-videos','chat-videos', false),\n"
            " ('chat-voices','chat-voices', false),\n"
            " ('chat-files','chat-files', false)\n"
            "ON CONFLICT (id) DO NOTHING;",
        )
    )
    s.append(h2(styles, "Policy examples (live)"))
    s.append(
        code_block(
            styles,
            "Chat images insert",
            "-- authenticated INSERT when bucket_id='chat-images'\n"
            "-- AND can_access_chat_room(chat_storage_room_id(name))\n"
            "-- AND (storage.foldername(name))[2] = auth.uid()::text",
        )
    )
    s.append(
        p(
            styles,
            "avatars: ALL for authenticated on bucket + SELECT for public. "
            "submissions/assignments/announcements: ALL for authenticated on that bucket_id "
            "(simpler than chat path checks — tighten later if desired).",
        )
    )
    s.append(PageBreak())
    return s


def ch15(styles):
    s = [h1(styles, "15. Realtime")]
    s.append(
        p(
            styles,
            "In Supabase Dashboard → Database → Publications / Replication, add tables to "
            "supabase_realtime:",
        )
    )
    s.extend(
        bullets(
            styles,
            [
                "notifications — inbox live updates",
                "chat_messages — new/edited/soft-deleted messages",
                "message_reads — read receipts",
                "message_reactions — reaction bar (replica identity FULL was set in a migration)",
            ],
        )
    )
    s.append(
        p(
            styles,
            "Flutter chat provider subscribes with filters on room_id / message_id, merges into "
            "local list state, and unsubscribes on dispose. Always cancel channels when leaving "
            "ChatRoomScreen to avoid leaks.",
        )
    )
    s.append(PageBreak())
    return s


def ch16(styles):
    s = [h1(styles, "16. Environment Variables & Bootstrap")]
    s.append(h2(styles, "Env.load() rules"))
    s.extend(
        numbered(
            styles,
            [
                "Prefer --dart-define=SUPABASE_URL and SUPABASE_ANON_KEY if present.",
                "Else load asset .env via flutter_dotenv; accept SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY.",
                "Reject placeholders: empty, your_*, paste_your, sb_secret_*, keys not starting with eyJ or sb_publishable_.",
                "Default URL constant exists but empty key → SetupRequiredScreen.",
            ],
        )
    )
    s.append(
        code_block(
            styles,
            "lib/supabase/supabase_client.dart",
            "import 'package:supabase_flutter/supabase_flutter.dart';\n\n"
            "SupabaseClient get supabase => Supabase.instance.client;",
        )
    )
    s.append(
        code_block(
            styles,
            "lib/main.dart (critical sequence)",
            "WidgetsFlutterBinding.ensureInitialized();\n"
            "await Env.load();\n"
            "if (!Env.isConfigured) { runApp(const SetupRequiredScreen()); return; }\n"
            "await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);\n"
            "// load theme/style from SharedPreferences, then ProviderScope → MuStudyApp",
        )
    )
    s.append(
        task(
            styles,
            "Bootstrap",
            "Implement Env + SetupRequiredScreen + main.dart. Launch with empty key → setup UI. "
            "Launch with valid key → splash/login path.",
        )
    )
    s.append(PageBreak())
    return s


def ch17(styles):
    s = [h1(styles, "17. Models & Enums")]
    s.append(
        p(
            styles,
            "Create lib/models/enums.dart with UserRole, Sphere, AssignmentType (map homework_pack), "
            "AttendanceStatus, SubmissionStatus, ChatMessageType, MarkCategory. Create Profile, "
            "TeacherProfile, StudentProfile, StudyGroup, Assignment, TaskItem, Submission, Mark, "
            "AttendanceRecord, AppNotification, Announcement, ChatRoomSummary, ChatMessage, etc. "
            "Export via models.dart.",
        )
    )
    s.append(
        callout(
            styles,
            "AssignmentType DB mapping",
            "Dart homeworkPack ↔ DB 'homework_pack'; Dart staticAssignment ↔ DB 'static'. "
            "Use assignmentTypeToDb / assignmentTypeFromString exactly.",
        )
    )
    s.append(
        code_block(
            styles,
            "lib/models/profile.dart (fields)",
            "id, username, fullName, role, avatarUrl, isDisabled,\n"
            "preferredLanguage, preferredTheme, preferredStyle\n"
            "// hasChosenLanguage => preferredLanguage != null && not empty",
        )
    )
    s.append(PageBreak())
    return s


def ch18(styles):
    s = [h1(styles, "18. Authentication End-to-End")]
    s.append(h2(styles, "User flow"))
    s.extend(
        numbered(
            styles,
            [
                "Splash (~1.2s) → /boot",
                "No session → LoginScreen (username + password)",
                "AuthRepository.signIn → RPC get_auth_email_by_username → signInWithPassword",
                "currentProfileProvider loads profiles row",
                "If is_disabled → /account-disabled",
                "If preferred_language empty → LanguageSelectionScreen (en/ru/uz)",
                "Else role home dashboard",
            ],
        )
    )
    s.append(
        code_block(
            styles,
            "lib/providers/auth/auth_provider.dart — signIn",
            "Future<void> signIn(String username, String password) async {\n"
            "  final email = await resolveAuthEmail(username);\n"
            "  if (email == null) {\n"
            "    throw const AuthException('Incorrect username or password');\n"
            "  }\n"
            "  await supabase.auth.signInWithPassword(email: email, password: password);\n"
            "}",
        )
    )
    s.append(h2(styles, "Creating the first admin"))
    s.append(
        p(
            styles,
            "Chicken-and-egg: admin_create_user requires is_admin(). Bootstrap the first admin "
            "via Dashboard SQL inserting into auth.users / identities / profiles with role=admin "
            "(mirror admin_create_user body), or temporarily use service role in SQL Editor. "
            "After one admin exists, use the app.",
        )
    )
    s.append(
        task(
            styles,
            "Auth loop",
            "Seed one admin, one teacher (math), one student. Log in as each. Confirm redirects "
            "and language gate. Log out clears session + caches.",
        )
    )
    s.append(PageBreak())
    return s


def ch19(styles):
    s = [h1(styles, "19. Routing & App Shell")]
    s.append(h2(styles, "Route map (must implement)"))
    s.append(
        p(
            styles,
            "Public: /splash, /login, /language, /boot, /account-disabled. "
            "Student shell: /student/{dashboard,assignments,assignments/:id,tasks/:taskId,focus,marks,"
            "chat,chat/:roomId,attendance,notifications,profile}. "
            "Teacher: /teacher/{dashboard,assignments,assignments/:id,submissions,chat,chat/:roomId,"
            "attendance,marks,analytics,announcements,notifications,profile}. "
            "Admin: /admin/{dashboard,users,groups,chat,chat/:roomId,analytics,academic-years,"
            "announcements,notifications,profile,mass-generator,credential-print}.",
        )
    )
    s.append(h2(styles, "Shell responsive behavior"))
    s.extend(
        bullets(
            styles,
            [
                "<600: floating pill ShellNavBar, Scaffold.extendBody=true → pad lists with shellContentBottomPadding",
                "600–1099: NavigationRail",
                "≥1100: collapsible sidebar 260/80 with logo décor",
            ],
        )
    )
    s.append(
        callout(
            styles,
            "Chat badge",
            "unreadChatCountProvider on chat tab; muted while focusChatMutedProvider true during Focus session.",
        )
    )
    s.append(PageBreak())
    return s


def ch20(styles):
    s = [h1(styles, "20. Theme, Locale, Shared UI")]
    s.append(h2(styles, "AppStyle enum"))
    s.extend(bullets(styles, ["modern (default coffee/cream)", "naturePaper", "softNeumorphism", "monochromeWorkspace"]))
    s.append(
        p(
            styles,
            "Persist preferred_theme (light|dark|system) and preferred_style on profiles + SharedPreferences. "
            "Brand colors live in app_colors.dart (coffeeBrown, cream, mutedGold, dark surfaces). "
            "Typography: Plus Jakarta Sans via google_fonts.",
        )
    )
    s.append(h2(styles, "Localization"))
    s.append(
        p(
            styles,
            "Three ARB files with hundreds of keys. Access via context.l10n extension. "
            "nav_labels.dart / domain_labels.dart map keys and enums to localized strings.",
        )
    )
    s.append(PageBreak())
    return s


def feature_chapter(styles, num, title, goal, flow, db, ui, logic, tests, edges):
    s = [h1(styles, f"{num}. Feature: {title}")]
    s.append(h2(styles, "Goal"))
    s.append(p(styles, goal))
    s.append(h2(styles, "User flow"))
    s.extend(numbered(styles, flow))
    s.append(h2(styles, "Database"))
    s.append(p(styles, db))
    s.append(h2(styles, "UI / routes"))
    s.append(p(styles, ui))
    s.append(h2(styles, "Logic & state"))
    s.append(p(styles, logic))
    s.append(h2(styles, "Test steps"))
    s.extend(numbered(styles, tests))
    s.append(h2(styles, "Edge cases"))
    s.extend(bullets(styles, edges))
    s.append(
        task(
            styles,
            title,
            f"Implement {title} until all test steps pass. Document any SQL gaps you hit in your notes.",
        )
    )
    s.append(PageBreak())
    return s


def ch21(styles):
    return feature_chapter(
        styles,
        21,
        "Groups & Admin Users",
        "Admins create users and groups; teachers manage membership of their groups.",
        [
            "Admin → Users → create username/password/full name/role(/sphere)",
            "RPC admin_create_user inserts Auth + profiles + teacher/student row",
            "Admin → Groups → create title under a teacher; add students via group_students",
            "Trigger creates chat_rooms row for the group",
        ],
        "profiles, teachers, students, groups (unique teacher_id+title), group_students, chat_rooms.",
        "AdminUsersScreen, AdminGroupsScreen; teacher sees myGroupsProvider.",
        "allProfilesProvider pagination; prevent double-submit on create; admin_create_user errors surface in SnackBar.",
        [
            "Create teacher math + student",
            "Create group 'Algebra A' for teacher",
            "Add student; verify student myGroups includes it",
            "Duplicate title for same teacher fails unique index",
        ],
        [
            "Sphere null for teacher → RPC exception",
            "Non-admin calling admin_create_user → Not authorized",
            "Disabled user: get_auth_email_by_username returns null → login fails",
        ],
    )


def ch22(styles):
    return feature_chapter(
        styles,
        22,
        "Assignments & Submissions",
        "Teachers create static assignments or homework packs with tasks; students submit text/file/voice.",
        [
            "Teacher selects group → create assignment type/title/due",
            "For homework_pack add tasks (sort_order)",
            "Student opens assignment → task → submit to submissions bucket + row",
            "Teacher reviews → score/feedback → status reviewed; optional mark sync trigger",
        ],
        "assignments, tasks, submissions; Storage submissions; notify triggers.",
        "TeacherAssignmentsScreen, TeacherHomeworkPackScreen, TeacherSubmissionsScreen, StudentAssignmentsScreen, StudentTaskSubmitScreen.",
        "assignmentsProvider, tasksProvider, teacherSubmissionsProvider; voice via record package.",
        [
            "Create pack with 2 tasks",
            "Student submits file + voice",
            "Teacher scores; student sees feedback",
        ],
        ["Unique (task_id,student_id) upsert", "Offline: show error SnackBar", "Static assignment display-only for students"],
    )


def ch23(styles):
    return feature_chapter(
        styles,
        23,
        "Marks / Gradebook",
        "Teachers enter percentage marks by category/weight; students see averages.",
        [
            "Teacher Marks tab → pick group → add/edit/bulk marks",
            "Student Marks tab → list + category stats",
        ],
        "marks + average views; categories enum.",
        "TeacherMarksScreen + sheets; StudentMarksScreen; charts optional.",
        "groupMarksProvider, myMarksProvider, averages providers.",
        ["Add quiz 90% weight 1", "Verify student average", "CSV export if implemented"],
        ["RLS: student cannot read other students' marks", "submission_id unique when linked"],
    )


def ch24(styles):
    return feature_chapter(
        styles,
        24,
        "Attendance",
        "Teachers take per-session attendance; no future dates; weekends handled in UI.",
        [
            "Teacher picks date → ensure_lesson_session → upsert attendance rows",
            "Student views calendar/stats",
        ],
        "lesson_sessions, attendance unique constraints.",
        "TeacherAttendanceScreen, StudentAttendanceScreen, AttendanceCalendarGrid.",
        "todayAttendanceProvider, attendanceRangeProvider rejects invalid dates.",
        ["Mark present/late", "Retry same day updates", "Future date blocked by RPC"],
        ["Weekend selection UX", "Student only own group"],
    )


def ch25(styles):
    return feature_chapter(
        styles,
        25,
        "Chat (Telegram-style)",
        "Group chat with media, replies, reactions, soft delete, own-message select/delete, unread counts.",
        [
            "Open Chat list (role basePath)",
            "Enter room → reverse ListView messages",
            "Long-press → Overlay menu: Reply, Copy, Edit, Select, Delete (no translate/forward/pin)",
            "Select mode: checkboxes only on own messages; pad above shell nav",
            "React via toggle_message_reaction",
        ],
        "chat_rooms, chat_messages, message_reads, message_reactions, chat_room_summaries, chat_unread_counts; chat-* buckets.",
        "ChatListScreen, ChatRoomScreen, MessageBubble, media widgets.",
        "chatRoomsProvider stream; ChatMessagesNotifier send/edit/delete/upload; Overlay not showGeneralDialog (avoid list jump).",
        [
            "Send text/image",
            "Reply + react",
            "Long-press other message: no Delete/Select",
            "Long-press own: Delete works; selection circles only on mine",
        ],
        [
            "Soft delete clears content",
            "Unread excludes own + already-read",
            "Composer hidden in selection mode — list needs shellContentBottomPadding",
        ],
    )


def ch26(styles):
    return feature_chapter(
        styles,
        26,
        "Notifications & Announcements",
        "Server triggers insert notifications; clients stream inbox. Teachers/admins post announcements per group.",
        [
            "Create assignment → students notified",
            "Open Notifications → mark read",
            "Teacher posts announcement → group feed on dashboards",
        ],
        "notifications, announcements; triggers trg_*_notify.",
        "Student/Teacher notification screens; announcement screens; dashboard cards.",
        "notificationsProvider realtime; announcementsProvider.",
        ["Trigger assignment notify", "Realtime appears without refresh"],
        ["Admin notifications screen may be placeholder", "action_path deep link optional"],
    )


def ch27(styles):
    return feature_chapter(
        styles,
        27,
        "Focus Mode",
        "Local Pomodoro/free timer with ambient UI; mutes chat badge while active.",
        [
            "Student Focus → choose mode → start",
            "Complete → summary",
            "Chat badge muted during session",
        ],
        "None (SharedPreferences focus_session_v1).",
        "StudentFocusScreen + focus widgets.",
        "focusSessionProvider, focusChatMutedProvider.",
        ["Start 25m pomodoro", "Kill app and restore session if persisted"],
        ["No network required", "Does not write Supabase"],
    )


def ch28(styles):
    return feature_chapter(
        styles,
        28,
        "Academic Years & Credentials",
        "Admins manage year/terms; print login slips PDF (credentials may use login_credentials table + RPCs from sql/).",
        [
            "Admin Academic Years → create next year / set current / edit term dates",
            "Credential print → select users → generate PDF slips",
        ],
        "academic_years, academic_terms; optional login_credentials from sql/admin_login_slips.sql.",
        "AdminAcademicYearsScreen, AdminCredentialPrintScreen.",
        "RPCs admin_* academic; Syncfusion PDF for slips.",
        ["Create year with 4 terms", "Generate PDF without leaking service keys"],
        ["Only one is_current year", "login_credentials may be absent — slips can reset via admin_reset_password"],
    )


def ch29(styles):
    s = [h1(styles, "29. Security Chapter")]
    s.extend(
        bullets(
            styles,
            [
                "Anon key is public by design — security is RLS + Storage policies",
                "Never ship service_role in the Flutter app",
                "Username enumeration: get_auth_email_by_username returns null for missing/disabled — keep error messages generic",
                "Passwords: bcrypt via extensions.crypt in RPCs",
                "Chat storage paths bind folder[2] to auth.uid()",
                "is_disabled blocks login email resolution and profile self-update",
                "Validate uploads client-side; still enforce MIME/size in Storage when possible",
                "Credential slips storing plaintext passwords (login_credentials) are sensitive — admin-only RPC; treat as temporary print aid",
            ],
        )
    )
    s.append(PageBreak())
    return s


def ch30(styles):
    s = [h1(styles, "30. Troubleshooting")]
    rows = [
        ["SetupRequiredScreen always", "ANON key rejected by Env sanitizer", "Use eyJ… JWT anon key; not service_role"],
        ["Login fails always", "RPC missing / wrong email", "Deploy get_auth_email_by_username; check auth_email"],
        ["Empty lists but data in SQL", "RLS denying", "Check is_teacher_of_group membership; policies"],
        ["Storage 403", "Policy/path mismatch", "Ensure roomId/uid folders; can_access_chat_room"],
        ["Realtime silent", "Table not in publication", "Add table to supabase_realtime"],
        ["Duplicate groups", "Missing unique (teacher_id,title)", "Create groups_teacher_title_uidx"],
        ["iOS mic crash", "Missing usage string", "NSMicrophoneUsageDescription"],
        ["Chat last msg under nav", "extendBody without padding", "shellContentBottomPadding in selection mode"],
        ["gen_salt errors", "pgcrypto path", "Use extensions.crypt / extensions.gen_salt"],
        ["admin_create_user Not authorized", "Caller not admin", "Seed admin profile role"],
    ]
    s.append(simple_table(styles, ["Symptom", "Cause", "Fix"], rows, [2.0 * inch, 2.2 * inch, 2.3 * inch]))
    s.append(PageBreak())
    return s


def ch31(styles):
    s = [h1(styles, "31. Testing & Acceptance Checklist")]
    s.extend(
        bullets(
            styles,
            [
                "□ flutter analyze clean on lib/",
                "□ Login admin/teacher/student",
                "□ Language selection persists to profile",
                "□ Theme/style switch persists",
                "□ Create group + membership",
                "□ Homework pack submit + review",
                "□ Marks average correct",
                "□ Attendance no future date",
                "□ Chat realtime, reactions, own-only delete",
                "□ Notification appears on assignment create",
                "□ Focus mutes chat badge",
                "□ Avatar upload public URL",
                "□ Disabled user cannot login",
                "□ make apk or flutter build apk succeeds",
            ],
        )
    )
    s.append(PageBreak())
    return s


def ch32(styles):
    s = [h1(styles, "32. Deployment")]
    s.extend(
        numbered(
            styles,
            [
                "Production Supabase project; rotate keys if ever leaked",
                "Set Auth Site URL + redirect allow list for web",
                "Build with dart-define or production .env asset (prefer CI secrets)",
                "Android: replace debug signing with release keystore (original currently debug-signed)",
                "iOS: set unique bundle id + signing team; keep mic/photo strings",
                "Web: flutter build web — host on HTTPS",
                "Makefile apk target copies mu_study.apk",
                "Review Syncfusion license obligations for production",
            ],
        )
    )
    s.append(PageBreak())
    return s


def ch33(styles):
    s = [h1(styles, "33. Final Reconstruction Challenge")]
    s.append(
        p(
            styles,
            "From an empty directory and a new Supabase project, recreate MU Study without "
            "copying the original tree wholesale. Use this book as the primary guide.",
        )
    )
    s.append(
        simple_table(
            styles,
            ["Area", "Points"],
            [
                ["Project setup & dependencies", "5"],
                ["Database schema (tables/enums/indexes/FKs)", "15"],
                ["RLS + helper functions", "10"],
                ["Auth username login + redirects", "10"],
                ["Architecture (Riverpod + go_router + shell)", "10"],
                ["UI parity (roles, themes, l10n)", "15"],
                ["Features (homework, marks, attendance, chat, …)", "20"],
                ["Storage + Realtime", "10"],
                ["Testing evidence", "5"],
                ["Total", "100"],
            ],
            [5.0 * inch, 1.5 * inch],
        )
    )
    s.append(PageBreak())
    return s


def ch34(styles):
    s = [h1(styles, "34. Database Verification Queries")]
    s.append(
        code_block(
            styles,
            "SQL checks",
            "-- tables\n"
            "SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY 1;\n\n"
            "-- columns\n"
            "SELECT table_name, column_name, udt_name, is_nullable\n"
            "FROM information_schema.columns WHERE table_schema='public' ORDER BY 1,2;\n\n"
            "-- RLS enabled?\n"
            "SELECT relname, relrowsecurity FROM pg_class c\n"
            "JOIN pg_namespace n ON n.oid=c.relnamespace\n"
            "WHERE n.nspname='public' AND relkind='r';\n\n"
            "-- policies\n"
            "SELECT tablename, policyname, cmd FROM pg_policies WHERE schemaname='public';\n\n"
            "-- buckets\n"
            "SELECT id, name, public FROM storage.buckets ORDER BY name;\n\n"
            "-- enums\n"
            "SELECT t.typname, e.enumlabel FROM pg_type t\n"
            "JOIN pg_enum e ON e.enumtypid=t.oid\n"
            "JOIN pg_namespace n ON n.oid=t.typnamespace\n"
            "WHERE n.nspname='public' ORDER BY 1, e.enumsortorder;",
        )
    )
    s.append(PageBreak())
    return s


def appendix_a(styles):
    s = [h1(styles, "Appendix A — Schema Rebuild Order")]
    s.extend(
        numbered(
            styles,
            [
                "Enums",
                "profiles, teachers, students",
                "groups, group_students",
                "assignments, tasks, submissions",
                "marks + average views",
                "lesson_sessions, attendance",
                "announcements, notifications, assignment_templates",
                "chat_rooms, chat_messages, message_reads, message_reactions + summaries view",
                "academic_years, academic_terms",
                "Helper functions (is_admin, …)",
                "Triggers (chat room ensure, notify_*, touch_updated_at, attendance session sync, reply same room)",
                "RPCs (admin_*, ensure_lesson_session, chat_*, get_auth_email_by_username)",
                "ENABLE RLS + policies",
                "Storage buckets + policies",
                "Realtime publication",
                "Seed first admin",
                "GRANT EXECUTE on needed RPCs to authenticated/anon as appropriate",
            ],
        )
    )
    s.append(
        callout(
            styles,
            "Repo SQL extras",
            "Also apply sql/fix_admin_create_user_no_auto_groups.sql and optionally "
            "sql/admin_login_slips.sql for printable credentials.",
        )
    )
    s.append(PageBreak())
    return s


def appendix_b(styles):
    s = [h1(styles, "Appendix B — Limitations & Source Gaps")]
    s.extend(
        bullets(
            styles,
            [
                "supabase/migrations/*.sql and seed_full.sql are referenced in README but missing from the Git tree — schema recovered from live DB + Dart.",
                "fix-migrations.sql may be empty/absent locally.",
                "Full trigger/view SQL bodies for every notify_* and chat_room_summaries are large; reconstruct from Dashboard or pg_get_viewdef / pg_get_functiondef.",
                "Demo passwords mentioned historically must never be reused in production.",
                "Admin notifications screen is a placeholder empty state in the app.",
                "Focus feature is intentionally offline-only.",
                "This PDF teaches reconstruction; it cannot embed every ARB string and every Lottie file — copy assets from the original project when available.",
            ],
        )
    )
    s.append(
        p(
            styles,
            "If a detail cannot be determined from repository or live schema, stop and inspect "
            "with the verification queries rather than inventing columns.",
        )
    )
    return s


def build():
    styles = build_styles()
    story = []
    story += title_page(styles)
    story += toc(styles)
    for fn in [
        ch1,
        ch2,
        ch3,
        ch4,
        ch5,
        ch6,
        ch7,
        ch8,
        ch9,
        ch10,
        ch11,
        ch12,
        ch13,
        ch14,
        ch15,
        ch16,
        ch17,
        ch18,
        ch19,
        ch20,
        ch21,
        ch22,
        ch23,
        ch24,
        ch25,
        ch26,
        ch27,
        ch28,
        ch29,
        ch30,
        ch31,
        ch32,
        ch33,
        ch34,
        appendix_a,
        appendix_b,
    ]:
        story += fn(styles)

    story += deep_dive_chapters(styles)
    story += column_catalog(styles)

    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=A4,
        leftMargin=0.75 * inch,
        rightMargin=0.75 * inch,
        topMargin=0.75 * inch,
        bottomMargin=0.75 * inch,
        title="MU Study — Complete Reconstruction Tutorial",
        author="MU Study Tutorial Generator",
    )
    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
    print(f"Wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    build()
