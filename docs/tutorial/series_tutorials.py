"""Tutorials 1–30: easiest to hardest, written against the real MU Study app."""

from __future__ import annotations

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
from series_kit import learned, meta_box, mistakes, quiz, video_list


def _tier(styles, title, blurb):
    s = [h1(styles, title)]
    s.append(p(styles, blurb))
    s.append(PageBreak())
    return s


def all_tutorials(styles):
    story = []
    story += _tier(
        styles,
        "Tier 1 — Fundamentals",
        "No Flutter coding yet. You learn the product, the database vocabulary, the Supabase "
        "dashboard, and how secrets stay out of Git. If you cannot explain who creates accounts "
        "and why students must not see each other’s marks, do not start Tutorial 5.",
    )
    story += t01(styles)
    story += t02(styles)
    story += t03(styles)
    story += t04(styles)
    story += _tier(
        styles,
        "Tier 2 — Flutter basics",
        "You create the project shape, learn Dart, build widgets, and wire go_router the way "
        "MU Study does: splash, login, language gate, then a role shell.",
    )
    story += t05(styles)
    story += t06(styles)
    story += t07(styles)
    story += t08(styles)
    story += t09(styles)
    story += _tier(
        styles,
        "Tier 3 — State management",
        "Riverpod is how MU Study holds session, lists, and streams. Models are how JSON from "
        "PostgREST becomes typed Dart. Master both before writing repositories.",
    )
    story += t10(styles)
    story += t11(styles)
    story += _tier(
        styles,
        "Tier 4 — Database and backend",
        "SQL, Auth, Flutter queries, and RLS. This tier is the difference between a demo and a "
        "school product.",
    )
    story += t12(styles)
    story += t13(styles)
    story += t14(styles)
    story += t15(styles)
    story += _tier(
        styles,
        "Tier 5 — Advanced platform features",
        "Storage, Realtime, localization, theming, and the real notification system (not FCM).",
    )
    story += t16(styles)
    story += t17(styles)
    story += t18(styles)
    story += t19(styles)
    story += t20(styles)
    story += _tier(
        styles,
        "Tier 6 — Complete features",
        "You assemble end-to-end product flows. Each tutorial names the real screens, providers, "
        "tables, and RPCs.",
    )
    story += t21(styles)
    story += t22(styles)
    story += t23(styles)
    story += t24(styles)
    story += t25(styles)
    story += _tier(
        styles,
        "Tier 7 — Going deep",
        "Reusable widgets, tests, performance, errors, and shipping a release artifact.",
    )
    story += t26(styles)
    story += t27(styles)
    story += t28(styles)
    story += t29(styles)
    story += t30(styles)
    return story


def t01(styles):
    s = [h1(styles, "Tutorial 1 — Understanding the MU Study project")]
    s.append(meta_box(styles, 1, "Understanding MU Study", "★ easiest", "20–30 minutes", "None"))
    s.extend(video_list(styles, ["flutter_what", "supabase_what"]))
    s.append(h2(styles, "What MU Study is"))
    s.append(
        p(
            styles,
            "MU Study is a school management and study platform built for Math and English "
            "teachers and their students. It is not a public social network. There is no "
            "self-registration button. An administrator creates every username and password. "
            "Parents are not a first-class role in the current schema — a parent who needs access "
            "would be given a student or admin account by policy, not a parent table.",
        )
    )
    s.append(
        p(
            styles,
            "The client is a Flutter app that runs on Android, iOS, and Web. Phones use a bottom "
            "navigation bar. Wider layouts use a navigation rail. A permanent desktop-only sidebar "
            "is intentionally omitted (see README). The look is Material 3 with a chocolate/sand "
            "default plus three additional visual styles.",
        )
    )
    s.append(h2(styles, "Who uses it"))
    s.append(
        simple_table(
            styles,
            ["Role", "Database", "What they do in the app"],
            [
                ["Student", "profiles + students + group_students", "Homework, marks, attendance view, chat, focus timer, notifications"],
                ["Teacher", "profiles + teachers (sphere)", "Own groups, assignments, gradebook, take attendance, announcements, chat"],
                ["Admin", "profiles.role = admin", "Users, groups, academic years, school announcements, credential slips, mass generator"],
            ],
            [1.1 * inch, 2.2 * inch, 3.2 * inch],
        )
    )
    s.append(
        p(
            styles,
            "A teacher’s sphere is required: <b>math</b> or <b>english</b> (Postgres enum "
            "sphere_type). Admins do not auto-create groups when they add a teacher. They type "
            "exact group titles later.",
        )
    )
    s.append(h2(styles, "What you can do (feature map)"))
    s.extend(
        bullets(
            styles,
            [
                "Sign in with username + password (behind the scenes: synthetic email + Supabase Auth).",
                "Pick English, Russian, or Uzbek once; the choice is stored on the profile.",
                "Students: dashboard announcements, assignments (static vs homework pack), task submit (text/file/voice), marks, attendance calendar, group chat, focus mode, inbox.",
                "Teachers: create assignments and tasks, review submissions, gradebook, attendance grid, analytics charts, group announcements, chat.",
                "Admins: create/disable users, create groups and memberships, academic years/terms, print login slips, optional mass data generator.",
            ],
        )
    )
    s.append(h2(styles, "Technology stack at a glance"))
    s.append(
        simple_table(
            styles,
            ["Layer", "Choice in this repo", "Why"],
            [
                ["UI", "Flutter 3 / Dart ^3.11.5", "One codebase for Android, iOS, Web"],
                ["State", "flutter_riverpod", "Typed providers, no BuildContext lookup"],
                ["Routes", "go_router", "Path URLs + redirect on auth/language"],
                ["Backend", "Supabase", "Auth + Postgres + Storage + Realtime hosted together"],
                ["Database", "PostgreSQL 17", "RLS, enums, triggers, views"],
                ["Files", "Supabase Storage", "Avatars public; work and chat private"],
                ["Live updates", "Supabase Realtime", "Chat + notifications without polling"],
                ["i18n", "gen-l10n ARB", "en / ru / uz"],
            ],
            [1.2 * inch, 2.2 * inch, 3.1 * inch],
        )
    )
    s.append(h2(styles, "Architecture overview"))
    s.append(
        code_block(
            styles,
            "Mental model",
            "Phone / browser\n"
            "  Flutter widgets (screens + components)\n"
            "    Riverpod providers (auth, lists, streams)\n"
            "      supabase_flutter client\n"
            "        HTTPS → Supabase project\n"
            "          Auth  |  PostgREST (tables/RPC)  |  Storage  |  Realtime\n"
            "            PostgreSQL with RLS + triggers\n",
        )
    )
    s.append(
        p(
            styles,
            "Security is not “hide the admin button in Flutter.” A student who crafts an HTTP "
            "request still hits RLS. If a student can SELECT another student’s marks in the SQL "
            "Editor while logged in as that student JWT, the product is broken — even if the UI "
            "never showed a button.",
        )
    )
    s.append(h2(styles, "Screens you will tour"))
    s.append(
        p(
            styles,
            "On a working instance you will see Splash → Login → Language (first time) → a role "
            "home. Student home shows announcements. Teacher home shows group shortcuts. Admin "
            "home shows platform counts. Chat is a shared pair of screens under /student/chat, "
            "/teacher/chat, /admin/chat.",
        )
    )
    s.append(
        task(
            styles,
            "1.1 Screenshot tour",
            "1) Open a running MU Study build (this repo: make run, or the web target).\n"
            "2) Log in as each role you have (student, teacher, admin).\n"
            "3) Capture: login, language (if shown), dashboard, assignments, marks, chat list, profile.\n"
            "4) On each screenshot, write which table the visible titles/dates come from "
            "(announcements, assignments, marks, chat_room_summaries, profiles).\n"
            "5) Store the images in a private notes folder — not in git if they show real names.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Hand your screenshots to a classmate (or your future self tomorrow). They should be "
            "able to say: three roles, no public Register button, chat is per group, marks exist "
            "as a separate screen from assignments. If they think anyone can sign up, you labeled "
            "the product wrong — re-read this tutorial.",
        )
    )
    s.extend(
        mistakes(
            styles,
            [
                ("Treating MU Study like Instagram", "There is no public feed of all students. Data is scoped by group membership and RLS."),
                ("Assuming email login", "The field says Username. Email is an implementation detail of Auth."),
                ("Assuming Arabic or FCM", "This product ships EN/RU/UZ and in-app notifications."),
            ],
        )
    )
    s.extend(learned(styles, [
        "MU Study is a closed school platform with admin-created accounts.",
        "Three roles sit on one Flutter client with different shells.",
        "Supabase is the backend; Flutter never talks to Postgres with a raw password.",
    ]))
    s.extend(
        quiz(
            styles,
            [
                ("Who creates student accounts?", "An admin, via Admin → Users / admin_create_user. Not the student."),
                ("Name the three locales.", "en, ru, uz."),
                ("What is a teacher sphere?", "math or english — required when creating a teacher."),
            ],
        )
    )
    s.append(PageBreak())
    return s


def t02(styles):
    s = [h1(styles, "Tutorial 2 — Database concepts for MU Study")]
    s.append(meta_box(styles, 2, "Database concepts", "★ easiest", "30–40 minutes", "Tutorial 1"))
    s.extend(video_list(styles, ["db_crash", "sql_fcc", "pg_amigos"]))
    s.append(h2(styles, "What a database is"))
    s.append(
        p(
            styles,
            "A database is organized storage with rules. A spreadsheet can hold names, but it "
            "will not stop two students from sharing the same impossible grade or stop a deleted "
            "group from leaving orphan attendance rows. PostgreSQL enforces primary keys, foreign "
            "keys, checks, and — in this project — row-level security.",
        )
    )
    s.append(h2(styles, "Tables, rows, columns — using students and groups"))
    s.append(
        p(
            styles,
            "A <b>table</b> is a named collection of rows with the same columns. A <b>row</b> is "
            "one student, one group, one mark. A <b>column</b> is one field (id, title, sphere). "
            "MU Study’s students table does not store the display name. The name lives on "
            "profiles. students.profile_id points at profiles.id. That is a foreign key.",
        )
    )
    s.append(
        code_block(
            styles,
            "Conceptual (IDs are UUIDs in the real app)",
            "profiles\n"
            "id (PK=auth.users.id) | username | full_name | role\n"
            "aaa...                | ali      | Ali Karimov| student\n"
            "bbb...                | sara     | Sara Lee   | student\n"
            "ccc...                | ms_ng    | N. Green   | teacher\n"
            "\n"
            "students                 teachers\n"
            "id (PK) | profile_id(FK)   id (PK) | profile_id(FK) | sphere\n"
            "s1      | aaa...           t1      | ccc...         | math\n"
            "\n"
            "groups\n"
            "id (PK) | teacher_id (FK→teachers.id) | title\n"
            "g1      | t1                          | Algebra A\n"
            "\n"
            "group_students\n"
            "id | group_id (FK) | student_id (FK)\n"
            "1  | g1            | s1\n",
        )
    )
    s.append(
        p(
            styles,
            "Notice students.id is not the same as profiles.id. Chat sender_id is a profile id "
            "(auth.uid()). Attendance.student_id is students.id. Mixing those UUIDs is the #1 "
            "join bug in this codebase. Always ask: “is this a profile id or a student row id?”",
        )
    )
    s.append(h2(styles, "Primary keys and foreign keys"))
    s.append(
        p(
            styles,
            "A primary key uniquely identifies a row. MU Study uses UUID keys generated by "
            "gen_random_uuid(), except profiles.id which is the Auth user id (no default — you "
            "insert the same UUID you put into auth.users). A foreign key says “this column must "
            "point at a real row.” ON DELETE CASCADE means deleting a group deletes its "
            "assignments, memberships, and chat room. That is intentional: a group is a container.",
        )
    )
    s.append(h2(styles, "Data types you will see"))
    s.append(
        simple_table(
            styles,
            ["Type", "Example column", "Meaning"],
            [
                ["uuid", "assignments.id", "128-bit identifier"],
                ["text", "groups.title", "Unlimited string"],
                ["timestamptz", "assignments.due_date", "Instant with time zone"],
                ["date", "attendance.date", "Calendar day"],
                ["boolean", "profiles.is_disabled", "true/false"],
                ["numeric", "marks.percentage", "Decimal 0–100"],
                ["jsonb", "announcements.image_urls", "JSON array of URLs"],
                ["user_role", "profiles.role", "enum student|teacher|admin"],
                ["sphere_type", "teachers.sphere", "enum math|english"],
            ],
            [1.3 * inch, 2.1 * inch, 3.1 * inch],
        )
    )
    s.append(h2(styles, "Schema overview — why ~20 tables"))
    s.append(
        simple_table(
            styles,
            ["Table", "Purpose"],
            [
                ["profiles", "Login identity, role, prefs, avatar"],
                ["teachers / students", "Role-specific rows (sphere; student memberships)"],
                ["groups / group_students", "Class sections and roster"],
                ["assignments / tasks / submissions / assignment_templates", "Work and answers"],
                ["lesson_sessions / attendance", "Roll call per day"],
                ["marks", "Gradebook (weighted percentage)"],
                ["announcements / notifications", "Posts and per-user inbox"],
                ["academic_years / academic_terms", "School calendar (semesters 1–4)"],
                ["chat_rooms / chat_messages / message_reads / message_reactions", "Group chat"],
            ],
            [2.6 * inch, 3.9 * inch],
        )
    )
    s.append(
        p(
            styles,
            "Views are stored queries, not tables: chat_room_summaries, student_mark_averages, "
            "student_group_mark_averages. The Flutter chat list reads the summaries view, then "
            "merges unread counts from the chat_unread_counts RPC.",
        )
    )
    s.append(
        task(
            styles,
            "2.1 Data modeling",
            "On paper, draw: auth.users 1—1 profiles 1—0..1 teachers|students. "
            "teachers 1—* groups *—* students via group_students. "
            "groups 1—1 chat_rooms. groups 1—* assignments 1—* tasks 1—* submissions.\n"
            "Label every FK column name exactly (profile_id, teacher_id, student_id, group_id).\n"
            "Circle the two different IDs for a student (profiles.id vs students.id).",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Without this book, list eight table names and one FK each. If you wrote "
            "students.group_id, you invented a column — MU Study uses group_students instead. "
            "Correct your diagram.",
        )
    )
    s.extend(
        mistakes(
            styles,
            [
                ("Putting group_id on students", "A student can be in many groups. Use group_students."),
                ("Using integer IDs in examples as if they were real", "Production IDs are UUIDs."),
                ("Forgetting CASCADE", "Deleting a teacher deletes their groups if FK is CASCADE — know the blast radius."),
            ],
        )
    )
    s.extend(learned(styles, [
        "Tables/rows/columns, PK/FK, enums, views.",
        "Student identity is two UUIDs; do not mix them.",
        "The 20-table map matches the live schema, not a blog example.",
    ]))
    s.extend(
        quiz(
            styles,
            [
                ("What table links a student to a group?", "group_students."),
                ("Where is the teacher’s subject stored?", "teachers.sphere (sphere_type)."),
                ("Is focus mode a table?", "No. SharedPreferences only."),
            ],
        )
    )
    s.append(PageBreak())
    return s


def t03(styles):
    s = [h1(styles, "Tutorial 3 — Supabase project setup")]
    s.append(meta_box(styles, 3, "Supabase setup", "★★ very easy", "15–25 minutes", "Tutorial 1; a browser; an email"))
    s.extend(video_list(styles, ["supabase_setup", "supabase_full"]))
    s.append(h2(styles, "Create the project"))
    s.extend(
        numbered(
            styles,
            [
                "Go to supabase.com and sign in.",
                "New project. Name it something like mu_study_dev. Pick the closest region. "
                "Set a database password and store it in a private notes file — not in the Flutter repo.",
                "Wait until the project is healthy (a few minutes).",
                "Settings → Data API (or API): copy Project URL https://YOURREF.supabase.co.",
                "Copy the anon / publishable key (starts with eyJ or sb_publishable_). Never copy service_role into the app.",
                "Open Table Editor (empty until you run SQL). Open SQL Editor for Tutorial 12+.",
            ],
        )
    )
    s.append(
        warn(
            styles,
            "Keys",
            "anon/publishable = client. service_role = god mode. If service_role leaks, rotate it "
            "immediately. The Flutter Env class even rejects keys that start with sb_secret_.",
        )
    )
    s.append(h2(styles, "What you will run later"))
    s.append(
        p(
            styles,
            "This tutorial does not apply the full schema yet (that is safer after you understand "
            "SQL). When you are ready, paste docs/tutorial/COMPLETE_BACKEND.sql in the SQL Editor "
            "top to bottom, then first_admin_bootstrap.sql with YOUR_STRONG_PASSWORD.",
        )
    )
    s.append(
        code_block(
            styles,
            "SQL Editor smoke test (now)",
            "SELECT current_timestamp AS now, current_database() AS db;",
        )
    )
    s.append(
        task(
            styles,
            "3.1 Supabase exploration",
            "Create the project. Screenshot: Settings page showing Project URL (blur the key if you share the image). "
            "Run SELECT current_timestamp; in SQL Editor and screenshot the result. "
            "Write down region and project ref in private notes.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "A friend should be able to open your (blurred) URL screenshot and see a supabase.co "
            "host. Your SQL screenshot must show a timestamp, not an error. If Table Editor already "
            "shows 20 tables, you ran the schema early — that is fine, but still keep the smoke query.",
        )
    )
    s.extend(mistakes(styles, [
        ("Putting service_role in .env used by Flutter", "Env.sanitize should empty it; if you bypass that, any user of the APK is a DBA."),
        ("Using the hosted demo project as production", "nmmdvdprczukaskxxdrs in Env is a development default. Create your own for learning."),
    ]))
    s.extend(learned(styles, [
        "Project URL + anon key are the only client secrets.",
        "SQL Editor is your source of truth for schema work.",
    ]))
    s.extend(quiz(styles, [
        ("Which key goes in Flutter?", "anon / publishable, never service_role."),
        ("What does SELECT current_timestamp prove?", "The database is reachable and you can run SQL."),
    ]))
    s.append(PageBreak())
    return s


def t04(styles):
    s = [h1(styles, "Tutorial 4 — Environment variables and configuration")]
    s.append(meta_box(styles, 4, "Environment variables", "★★ very easy", "20 minutes", "Tutorial 3"))
    s.extend(video_list(styles, ["env_fireship", "dotenv"]))
    s.append(h2(styles, "Why .env exists"))
    s.append(
        p(
            styles,
            "Source code is copied, forked, and pushed. Secrets must not ride along. MU Study "
            "loads SUPABASE_URL and SUPABASE_ANON_KEY (or SUPABASE_PUBLISHABLE_KEY) from a "
            ".env file via flutter_dotenv, or from --dart-define-from-file=.env at run time.",
        )
    )
    s.append(
        code_block(
            styles,
            ".env (local only — already in .gitignore)",
            "SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co\n"
            "SUPABASE_ANON_KEY=eyJ_your_anon_or_publishable_key\n",
        )
    )
    s.append(h2(styles, "How Flutter loads it in this repo"))
    s.append(
        p(
            styles,
            "lib/core/constants/env.dart is the whole story. Env.load() first checks "
            "String.fromEnvironment (dart-define). If SUPABASE_ANON_KEY is empty, it tries "
            "dotenv.load(fileName: '.env'). Then _sanitizeKey() rejects placeholders, "
            "your_ prefixes, paste_your, sb_secret_, and keys that do not start with eyJ or "
            "sb_publishable_. If the key is rejected, Env.isConfigured is false and main.dart "
            "shows SetupRequiredScreen instead of initializing Supabase.",
        )
    )
    s.append(
        p(
            styles,
            "pubspec.yaml lists .env under flutter assets so dotenv can load it on devices. "
            "That means a release APK can contain the anon key — which is expected for a public "
            "client key — but it must never contain service_role. Prefer CI dart-defines for "
            "production builds so you are not editing a committed asset.",
        )
    )
    s.append(
        code_block(
            styles,
            "Run (README)",
            "flutter pub get\n"
            "flutter run --dart-define-from-file=.env\n",
        )
    )
    s.append(
        task(
            styles,
            "4.1 Create .env",
            "1) In the project root, create .env with YOUR URL and anon key (placeholders shown above).\n"
            "2) Confirm .gitignore contains .env (it does in this repo).\n"
            "3) Run flutter run --dart-define-from-file=.env (or make run if your Makefile injects env).\n"
            "4) You must not stay on SetupRequiredScreen if the key is valid.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Run: git check-ignore -v .env  — it must report .gitignore. "
            "Run the app with an empty key: SetupRequiredScreen appears. "
            "Restore the key: splash/login appears. That A/B test proves Env, not luck.",
        )
    )
    s.extend(mistakes(styles, [
        ("Committing .env", "Rotate the anon key if it hit a remote."),
        ("Whitespace or quotes around the key", "trim() helps, but quotes can still break JWT parse."),
        ("Using the service role because “login failed”", "Login failures are almost never fixed by god keys. Fix RPC grants and passwords."),
    ]))
    s.extend(learned(styles, [
        "Env.isConfigured gates the entire app.",
        ".env is gitignored; dart-define is the clean run path.",
    ]))
    s.extend(quiz(styles, [
        ("What screen appears when the key is sanitized to empty?", "SetupRequiredScreen."),
        ("Name two accepted key prefixes.", "eyJ and sb_publishable_."),
    ]))
    s.append(PageBreak())
    return s


def t05(styles):
    s = [h1(styles, "Tutorial 5 — Flutter project structure")]
    s.append(meta_box(styles, 5, "Project structure", "★★ very easy", "25 minutes", "Flutter SDK; Tutorial 1"))
    s.extend(video_list(styles, ["flutter_struct", "flutter_begin"]))
    s.append(h2(styles, "What flutter create gives you"))
    s.append(
        p(
            styles,
            "flutter create --org com.example --project-name mu_study . produces android/, ios/, "
            "web/, lib/main.dart, and pubspec.yaml. MU Study’s applicationId is com.example.mu_study "
            "and the iOS bundle is com.example.muStudy. You will not write Kotlin/Swift for features; "
            "you will add microphone/photo permissions for chat voice and images.",
        )
    )
    s.append(
        code_block(
            styles,
            "Actual lib/ layout",
            "lib/\n"
            "  main.dart\n"
            "  core/          constants, theme, router, services, utils\n"
            "  models/        enums + domain classes\n"
            "  providers/     Riverpod (auth, homework, chat, …)\n"
            "  screens/       auth, student, teacher, admin, chat, profile\n"
            "  components/    shell, cards, attachments, charts\n"
            "  l10n/          ARB + generated localizations\n"
            "  supabase/      supabase_client.dart one-liner\n",
        )
    )
    s.append(
        p(
            styles,
            "pubspec.yaml is the manifest: SDK constraint, dependencies, assets (images, lottie, "
            ".env), and generate: true for l10n. After editing it, flutter pub get. After editing "
            "ARB files, flutter gen-l10n (or the next flutter run).",
        )
    )
    s.append(
        task(
            styles,
            "5.1 Walk the tree",
            "From the repo root: list lib/ directories. Open pubspec.yaml and count dependencies. "
            "Open android/app/src/main/AndroidManifest.xml and find INTERNET and RECORD_AUDIO. "
            "Open ios/Runner/Info.plist and find microphone / photo usage strings. "
            "Run flutter pub get and confirm no errors.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Write a 10-line tree of lib/ from memory. If you invented lib/services/ as a top-level "
            "folder, look again — services live under lib/core/services/ and screens call providers.",
        )
    )
    s.extend(mistakes(styles, [
        ("Editing files under .dart_tool or build/", "Those are generated. Your code is lib/."),
        ("Forgetting generate: true", "AppLocalizations will not exist."),
    ]))
    s.extend(learned(styles, ["lib/ is the product. pubspec is the bill of materials."]))
    s.extend(quiz(styles, [
        ("Where is go_router configured?", "lib/core/router/app_router.dart"),
        ("Where is the Supabase client accessor?", "lib/supabase/supabase_client.dart"),
    ]))
    s.append(PageBreak())
    return s


def t06(styles):
    s = [h1(styles, "Tutorial 6 — Dart basics")]
    s.append(meta_box(styles, 6, "Dart basics", "★★ very easy", "45 minutes", "Tutorial 5"))
    s.extend(video_list(styles, ["dart_fireship", "dart_null"]))
    s.append(h2(styles, "Types you will use daily"))
    s.append(
        code_block(
            styles,
            "dart",
            "final String username = 'ali';\n"
            "const int pageSize = 20;\n"
            "bool isDisabled = false;\n"
            "String? avatarUrl; // null until uploaded\n"
            "final roles = <String>['student', 'teacher', 'admin'];\n"
            "final row = <String, dynamic>{'full_name': 'Ali', 'role': 'student'};\n",
        )
    )
    s.append(
        p(
            styles,
            "final is assign-once. const is compile-time. var exists but this codebase prefers "
            "explicit types on public APIs. dynamic appears in JSON maps from Supabase — you "
            "immediately cast into models.",
        )
    )
    s.append(h2(styles, "Functions and named parameters"))
    s.append(
        code_block(
            styles,
            "Like AuthRepository.changePassword",
            "Future<void> changePassword({\n"
            "  required String username,\n"
            "  required String currentPassword,\n"
            "  required String newPassword,\n"
            "}) async {\n"
            "  // …\n"
            "}\n",
        )
    )
    s.append(h2(styles, "Classes — Profile is the teaching example"))
    s.append(
        p(
            styles,
            "lib/models/profile.dart is a plain class: constructor, fields, fromJson, toJson. "
            "JSON keys are snake_case. There is no Freezed code generation in the models folder "
            "even though freezed is in pubspec (available, not used for Profile). Learn both "
            "styles; ship what the repo actually compiles.",
        )
    )
    s.append(
        code_block(
            styles,
            "Null safety in login",
            "final email = await resolveAuthEmail(username);\n"
            "if (email == null) {\n"
            "  throw const AuthException('Incorrect username or password');\n"
            "}\n"
            "await supabase.auth.signInWithPassword(email: email, password: password);\n",
        )
    )
    s.append(
        task(
            styles,
            "6.1 Dart exercises (file: test or dartpad)",
            "1) Class User { name, email, role } with a role string.\n"
            "2) Function studentsOnly(List<User>) → only role == 'student'.\n"
            "3) Function printUsers(Map<String, User>) prints username → role.\n"
            "4) Give email a String? if it can be missing; do not use ! unless you just checked null.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Write a tiny test or main() that fails if studentsOnly keeps a teacher. Run it. "
            "If you only “looked at the code,” you did not verify.",
        )
    )
    s.extend(mistakes(styles, [
        ("Using user.role! everywhere", "If role is non-nullable, do not add ?. If it is nullable, handle both cases."),
        ("Parsing JSON without fromJson", "You will typo fullName vs full_name."),
    ]))
    s.extend(learned(styles, ["final/const, named args, null-aware login path, model classes."]))
    s.extend(quiz(styles, [
        ("Why is email String? from the RPC?", "Disabled or unknown usernames return null."),
        ("What does Profile.fromJson read for the name?", "json['full_name']."),
    ]))
    s.append(PageBreak())
    return s


def t07(styles):
    s = [h1(styles, "Tutorial 7 — Flutter widgets and layouts")]
    s.append(meta_box(styles, 7, "Widgets & layouts", "★★★ easy", "45 minutes", "Tutorial 6"))
    s.extend(video_list(styles, ["widgets_ninja", "layout_official", "material"]))
    s.append(
        p(
            styles,
            "Everything on screen is a widget. LoginScreen is a ConsumerStatefulWidget: it owns "
            "TextEditingControllers and a loading flag. The visual tree is Scaffold → decorations "
            "→ fields → PrimaryButton. Read lib/screens/auth/login_screen.dart after you can "
            "build a boring Column yourself.",
        )
    )
    s.append(
        code_block(
            styles,
            "Minimum login-shaped UI (practice, not the production file)",
            "Scaffold(\n"
            "  appBar: AppBar(title: const Text('MU Study')),\n"
            "  body: Padding(\n"
            "    padding: const EdgeInsets.all(24),\n"
            "    child: Column(\n"
            "      children: [\n"
            "        TextField(decoration: InputDecoration(labelText: 'Username')),\n"
            "        TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password')),\n"
            "        ElevatedButton(onPressed: () {}, child: Text('Sign in')),\n"
            "      ],\n"
            "    ),\n"
            "  ),\n"
            ");\n",
        )
    )
    s.append(
        p(
            styles,
            "Production login uses localized labels (context.l10n.loginUsername), AppLogo, "
            "paper décor for Nature Paper style, and maps errors to loginIncorrect / "
            "loginConfigError. There is no “Forgot password?” for students — admins reset "
            "passwords (admin_reset_password). Do not add a fake forgot-password that emails "
            "mustudy.internal addresses.",
        )
    )
    s.append(
        task(
            styles,
            "7.1 Build a practice login UI",
            "In a scratch file or a temporary route, build username + password + sign-in button "
            "with spacing. Then open the real LoginScreen and list five widgets it uses that yours "
            "does not (logo, l10n, PrimaryButton, error text, loading).",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "flutter run shows your practice UI. A screenshot with empty AppBar title means you "
            "skipped MaterialApp or localization — wrap with MaterialApp for the exercise.",
        )
    )
    s.extend(mistakes(styles, [
        ("Unbounded ListView inside Column", "Use Expanded or ListView as the body."),
        ("Hard-coded English on production screens", "Use ARB keys; Tutorial 18."),
    ]))
    s.extend(learned(styles, ["Scaffold, fields, buttons, why production login is richer."]))
    s.extend(quiz(styles, [
        ("Who resets a forgotten password today?", "An admin, not a public email flow."),
    ]))
    s.append(PageBreak())
    return s


def t08(styles):
    s = [h1(styles, "Tutorial 8 — Stateful vs Stateless widgets")]
    s.append(meta_box(styles, 8, "Stateful vs Stateless", "★★★ easy", "30 minutes", "Tutorial 7"))
    s.extend(video_list(styles, ["stateful", "state_fireship"]))
    s.append(
        p(
            styles,
            "StatelessWidget is a function of its constructor arguments. Greeting(name: 'Ali') "
            "never changes unless the parent passes a new name. StatefulWidget owns a State "
            "object. LoginScreen’s _loading and _error live there. setState schedules a rebuild.",
        )
    )
    s.append(
        p(
            styles,
            "MU Study uses State for controllers and ephemeral UI (forms, sheets). Shared data "
            "(profile, assignments, chat) lives in Riverpod so two screens stay in sync. If you "
            "put the assignment list in a State object on one screen, the dashboard will not see "
            "updates. That is why Tutorial 10 exists.",
        )
    )
    s.append(
        code_block(
            styles,
            "Ephemeral vs app state",
            "// Ephemeral — State is correct\n"
            "bool _obscure = true;\n"
            "\n"
            "// App state — Riverpod is correct\n"
            "final currentProfileProvider = FutureProvider<Profile?>(...);\n",
        )
    )
    s.append(
        task(
            styles,
            "8.1 Mini todo widget",
            "StatefulWidget with List<String> todos, TextField, add button, ListView. "
            "Then write two sentences: why this todo list should NOT be how MU Study stores "
            "assignments (no RLS, no teacher, no persistence).",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Adding a todo updates the list without a full app restart. Hot reload may reset "
            "State — that is expected. If add does nothing, you forgot setState.",
        )
    )
    s.extend(mistakes(styles, [
        ("Calling setState after dispose", "Guard with if (!mounted) return; after awaits — LoginScreen does this."),
    ]))
    s.extend(learned(styles, ["State is for local UI. Riverpod is for shared/async data."]))
    s.extend(quiz(styles, [
        ("Is currentProfileProvider a State field?", "No. It is a FutureProvider."),
    ]))
    s.append(PageBreak())
    return s


def t09(styles):
    s = [h1(styles, "Tutorial 9 — Navigation with GoRouter")]
    s.append(meta_box(styles, 9, "GoRouter", "★★★ easy", "40 minutes", "Tutorial 8"))
    s.extend(video_list(styles, ["gorouter", "nav_fireship"]))
    s.append(
        p(
            styles,
            "lib/core/router/app_router.dart defines routerProvider. GoRouter starts at /splash. "
            "_RouterNotifier listens to authStateProvider and currentProfileProvider and calls "
            "notifyListeners so redirect re-runs. That is how login “just works” without a "
            "manual context.go in every success path (login still goes to /boot to settle).",
        )
    )
    s.append(h2(styles, "Redirect rules (actual)"))
    s.extend(
        numbered(
            styles,
            [
                "If location is /splash, do not redirect (splash decides).",
                "If no session → /login (unless already there).",
                "If profile is still loading (first load) → /boot.",
                "If profile is null → /login.",
                "If profile.isDisabled → /account-disabled.",
                "If preferred_language is empty → /language.",
                "If on /login, /boot, or /language after all gates pass → role home "
                "(/student/dashboard, /teacher/dashboard, /admin/dashboard).",
                "Otherwise null (allow the navigation).",
            ],
        )
    )
    s.append(
        p(
            styles,
            "Each role is a ShellRoute with destinations. Student includes Focus. Teacher includes "
            "gradebook and attendance. Admin includes users and groups. Chat is parameterized: "
            "ChatListScreen(basePath: '/teacher/chat') so one widget serves three shells.",
        )
    )
    s.append(
        code_block(
            styles,
            "Path parameters (homework)",
            "/student/tasks/:taskId  → StudentTaskSubmitScreen\n"
            "/teacher/assignments/:id → TeacherHomeworkPackScreen\n"
            "/*/chat/:roomId         → ChatRoomScreen\n",
        )
    )
    s.append(
        task(
            styles,
            "9.1 Trace one navigation",
            "On paper, start at /splash with no session. Write every location until student home "
            "for a user who has never chosen a language. Then repeat for a disabled teacher. "
            "Open app_router.dart and confirm your trace.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Log in as a new user (no preferred_language). You must hit LanguageSelectionScreen "
            "before any dashboard. Log in as a disabled profile (set is_disabled true in SQL). "
            "You must see account disabled copy, not a dashboard.",
        )
    )
    s.extend(mistakes(styles, [
        ("Redirecting /splash to /login immediately", "You skip the brand splash and may race auth restore."),
        ("Checking role only in the widget", "Deep links would still open teacher URLs. Redirect is the gate."),
    ]))
    s.extend(learned(styles, ["refreshListenable + redirect is the session backbone."]))
    s.extend(quiz(styles, [
        ("What path is the language gate?", "/language"),
        ("Why /boot exists?", "Hold UI while the first profile Future loads without tearing down a shell."),
    ]))
    s.append(PageBreak())
    return s


def t10(styles):
    s = [h1(styles, "Tutorial 10 — Riverpod basics")]
    s.append(meta_box(styles, 10, "Riverpod", "★★★ easy", "50 minutes", "Tutorial 9"))
    s.extend(video_list(styles, ["riverpod_fireship", "riverpod_codepur", "riverpod_docs", "riverpod_course"]))
    s.append(
        p(
            styles,
            "main.dart wraps the app in ProviderScope. Widgets that need data extend "
            "ConsumerWidget or ConsumerStatefulWidget and call ref.watch / ref.read. "
            "watch rebuilds when the value changes. read is for clicks (login, increment).",
        )
    )
    s.append(h2(styles, "Provider types in this repo"))
    s.append(
        simple_table(
            styles,
            ["Type", "Example", "Use"],
            [
                ["Provider", "authRepositoryProvider", "Construct a service once"],
                ["StreamProvider", "authStateProvider", "Supabase onAuthStateChange"],
                ["FutureProvider", "currentProfileProvider", "One-shot fetch with loading/error"],
                ["FutureProvider.family", "announcementsProvider", "Parameterized by groupId"],
                ["StreamProvider (inbox)", "notificationsProvider", "Yield list, then re-yield on Realtime"],
                ["Notifier / StateNotifier", "chat messages, paging lists", "Mutable collections + methods"],
                ["State-like controllers", "themeModeProvider, localeProvider", "User preferences"],
            ],
            [1.6 * inch, 2.2 * inch, 2.7 * inch],
        )
    )
    s.append(
        code_block(
            styles,
            "Watching in a widget",
            "final profile = ref.watch(currentProfileProvider);\n"
            "return profile.when(\n"
            "  loading: () => const CircularProgressIndicator(),\n"
            "  error: (e, _) => Text('Error: $e'),\n"
            "  data: (p) => Text(p?.fullName ?? ''),\n"
            ");\n",
        )
    )
    s.append(
        p(
            styles,
            "ref.invalidate(currentProfileProvider) after login forces a refetch. "
            "ref.refresh is similar and returns the new future. Use invalidate when you already "
            "navigated away and only need the next watch to reload.",
        )
    )
    s.append(
        task(
            styles,
            "10.1 / 10.2 Practice providers",
            "10.1 Build a counter with StateProvider<int> and two buttons in a scratch app.\n"
            "10.2 Build a FutureProvider that returns a fake Profile after a 1s delay. Show "
            "loading, error (throw once), and data. Add a retry that invalidates the provider.\n"
            "Then open auth_provider.dart and match each real provider to a type in the table.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Your counter updates without setState in the widget (the provider owns the int). "
            "Your FutureProvider demo shows all three AsyncValue branches. If you only used "
            "setState, redo 10.1.",
        )
    )
    s.extend(mistakes(styles, [
        ("watch inside onPressed", "Use read for events. watch belongs in build."),
        ("Forgetting ProviderScope", "Providers throw. main.dart already adds it."),
    ]))
    s.extend(learned(styles, ["watch vs read, AsyncValue.when, invalidate after login."]))
    s.extend(quiz(styles, [
        ("Which provider drives router refresh?", "authStateProvider (+ currentProfileProvider)."),
    ]))
    s.append(PageBreak())
    return s


def t11(styles):
    s = [h1(styles, "Tutorial 11 — Models and data classes")]
    s.append(meta_box(styles, 11, "Models", "★★★ easy", "35 minutes", "Tutorial 6"))
    s.extend(video_list(styles, ["freezed", "models"]))
    s.append(
        p(
            styles,
            "Models are the contract with PostgREST. lib/models/enums.dart maps Dart enums to "
            "database strings. homework_pack is the important mismatch: Dart uses homeworkPack, "
            "Postgres uses homework_pack. assignmentTypeFromString / assignmentTypeToDb exist "
            "so you never send 'homeworkPack' to SQL.",
        )
    )
    s.append(
        p(
            styles,
            "Freezed is in pubspec for future use and for people following generic tutorials. "
            "The shipped models are hand-written. That is easier to read in a textbook and avoids "
            "a build_runner step for every field change. If you introduce Freezed, you must run "
            "dart run build_runner build and commit the generated files your team agrees on.",
        )
    )
    s.append(
        code_block(
            styles,
            "Assignment.fromJson (real mapping)",
            "type: assignmentTypeFromString(json['type'] as String),\n"
            "dueDate: json['due_date'] != null\n"
            "    ? DateTime.parse(json['due_date'] as String)\n"
            "    : null,\n",
        )
    )
    s.append(
        task(
            styles,
            "11.1 Create / inspect MU Study models",
            "Open profile.dart, assignment.dart, attendance.dart, mark.dart, chat.dart, "
            "notification.dart. For each class, write the table name and the JSON keys. "
            "Write a Dart snippet that parses a fake assignments row map and prints title + type. "
            "Assert type == AssignmentType.homeworkPack when type is homework_pack.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Your snippet fails if you pass type: 'homeworkPack' (wrong) and succeeds for "
            "'homework_pack'. That single test prevents a silent insert bug.",
        )
    )
    s.extend(mistakes(styles, [
        ("Sending enum.toString()", "Gives AssignmentType.homeworkPack — invalid for Postgres."),
        ("Assuming marks live on submissions only", "marks is its own table; submission_id is optional/unique."),
    ]))
    s.extend(learned(styles, ["snake_case JSON, enum DB helpers, hand-written models."]))
    s.extend(quiz(styles, [
        ("What helper writes assignment type to the database?", "assignmentTypeToDb."),
    ]))
    s.append(PageBreak())
    return s


def t12(styles):
    s = [h1(styles, "Tutorial 12 — SQL basics")]
    s.append(meta_box(styles, 12, "SQL basics", "★★★ easy", "50 minutes", "Tutorials 2 and 3"))
    s.extend(video_list(styles, ["sql_fcc", "pg_amigos", "sql_mosh"]))
    s.append(
        p(
            styles,
            "Open SQL Editor on your project. After COMPLETE_BACKEND.sql is applied, these "
            "queries match real names. Until then, run them mentally or on the development project.",
        )
    )
    s.append(
        code_block(
            styles,
            "Read / filter / join / aggregate",
            "-- All group titles for a teacher row\n"
            "SELECT id, title FROM groups WHERE teacher_id = '<teacher-uuid>';\n"
            "\n"
            "-- Students in a group with names\n"
            "SELECT p.username, p.full_name\n"
            "FROM group_students gs\n"
            "JOIN students s ON s.id = gs.student_id\n"
            "JOIN profiles p ON p.id = s.profile_id\n"
            "WHERE gs.group_id = '<group-uuid>'\n"
            "ORDER BY p.full_name;\n"
            "\n"
            "-- Assignments due after now\n"
            "SELECT title, due_date FROM assignments\n"
            "WHERE due_date > now()\n"
            "ORDER BY due_date;\n"
            "\n"
            "-- Submissions per assignment (via tasks)\n"
            "SELECT a.title, COUNT(sub.id) AS submitted\n"
            "FROM assignments a\n"
            "JOIN tasks t ON t.assignment_id = a.id\n"
            "LEFT JOIN submissions sub ON sub.task_id = t.id AND sub.status <> 'pending'\n"
            "GROUP BY a.id, a.title;\n"
            "\n"
            "-- Weighted average (same idea as student_mark_averages view)\n"
            "SELECT student_id,\n"
            "  ROUND(SUM(percentage * weight) / NULLIF(SUM(weight), 0), 2) AS avg\n"
            "FROM marks GROUP BY student_id;\n",
        )
    )
    s.append(
        warn(
            styles,
            "Writes",
            "INSERT/UPDATE/DELETE in the SQL Editor run as the postgres role and bypass RLS. "
            "That is fine for seeding. It is not how the app works. Never “test security” as postgres.",
        )
    )
    s.append(
        task(
            styles,
            "12.1 Write SQL",
            "1) Assignments due after today (query above).\n"
            "2) Marks for one student_id with group title (JOIN groups).\n"
            "3) COUNT submissions per assignment.\n"
            "Run them. Save the result screenshots privately.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Each query has a WHERE or GROUP BY you can explain. If COUNT(*) from marks as "
            "postgres returns rows a student JWT cannot see, that is expected — you are DBA here.",
        )
    )
    s.extend(mistakes(styles, [
        ("SELECT * FROM students expecting names", "Join profiles."),
        ("Filtering assignments with due_date > CURRENT_DATE and forgetting time", "due_date is timestamptz."),
    ]))
    s.extend(learned(styles, ["SELECT/JOIN/GROUP BY on real MU Study names."]))
    s.extend(quiz(styles, [
        ("Which view already averages marks?", "student_mark_averages and student_group_mark_averages."),
    ]))
    s.append(PageBreak())
    return s


def t13(styles):
    s = [h1(styles, "Tutorial 13 — Supabase authentication (the real login)")]
    s.append(meta_box(styles, 13, "Authentication", "★★★ easy", "45 minutes", "Tutorials 3 and 12"))
    s.extend(video_list(styles, ["supabase_auth", "flutter_auth", "jwt"]))
    s.append(h2(styles, "Flow"))
    s.append(
        code_block(
            styles,
            "Username login",
            "User types username + password\n"
            "  → AuthRepository.signIn\n"
            "  → rpc get_auth_email_by_username(p_username)\n"
            "  → NULL if missing or is_disabled\n"
            "  → signInWithPassword(email, password)\n"
            "  → JWT stored by supabase_flutter\n"
            "  → authStateProvider emits signedIn\n"
            "  → currentProfileProvider loads profiles row\n"
            "  → router redirect to language or role home\n",
        )
    )
    s.append(
        code_block(
            styles,
            "get_auth_email_by_username (exact idea)",
            "SELECT auth_email FROM public.profiles\n"
            "WHERE lower(username) = lower(trim(p_username))\n"
            "  AND is_disabled = FALSE\n"
            "LIMIT 1;\n",
        )
    )
    s.append(
        p(
            styles,
            "admin_create_user builds email as "
            "lower(trim(replace(username,'@',''))) || '@mustudy.internal'. "
            "Username @admin becomes admin@mustudy.internal. The first admin cannot call that RPC "
            "(nobody is admin yet). Use first_admin_bootstrap.sql once.",
        )
    )
    s.append(
        p(
            styles,
            "Do not create users in Authentication → Add user and forget profiles. The app will "
            "sign in then bounce to login because currentProfileProvider is null. Always create "
            "the pair: auth.users + identities + profiles + teachers/students.",
        )
    )
    s.append(
        task(
            styles,
            "13.1 / 13.2 First users",
            "13.1 After schema: run first_admin_bootstrap.sql with a password you invented. "
            "Verify: SELECT username, auth_email, role FROM profiles WHERE role = 'admin';\n"
            "13.2 Run the Flutter app, log in as @admin. You should reach language then admin dashboard.\n"
            "Then create a teacher (math) and a student from Admin → Users. Log in as each.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Wrong password → localized loginIncorrect, not a stack trace in release. "
            "Disabled user → RPC returns null → same incorrect message. "
            "SQL: SELECT auth.uid(); in a user session is not available in the dashboard the same "
            "way — instead confirm auth.users.email matches profiles.auth_email.",
        )
    )
    s.extend(mistakes(styles, [
        ("Inventing email in Dart", "Breaks if the scheme changes; leaks disabled usernames if you only skip is_disabled in the UI."),
        ("Unconfirmed email", "Bootstrap sets email_confirmed_at. Dashboard-created users may need confirm email disabled in Auth settings."),
    ]))
    s.extend(learned(styles, ["RPC → Auth → profile → router. First admin is a SQL bootstrap."]))
    s.extend(quiz(styles, [
        ("What email does username 'ms.green' become?", "ms.green@mustudy.internal (dots stay; @ is stripped if present)."),
    ]))
    s.append(PageBreak())
    return s


def t14(styles):
    s = [h1(styles, "Tutorial 14 — Supabase queries from Flutter")]
    s.append(meta_box(styles, 14, "Flutter queries", "★★★ easy", "45 minutes", "Tutorials 12–13"))
    s.extend(video_list(styles, ["sb_queries", "flutter_sb"]))
    s.append(
        p(
            styles,
            "lib/supabase/supabase_client.dart exports supabase. Providers call "
            "supabase.from('table').select() with filters. RLS silently filters rows — an “empty "
            "list” is often a policy or membership problem, not an empty school.",
        )
    )
    s.append(
        code_block(
            styles,
            "Patterns used in MU Study",
            "// Profile\n"
            "await supabase.from('profiles').select().eq('id', uid).maybeSingle();\n"
            "\n"
            "// Nested join (group members)\n"
            "from('group_students').select('..., students(profiles(...))');\n"
            "\n"
            "// RPC\n"
            "await supabase.rpc('get_auth_email_by_username', params: {'p_username': name});\n"
            "await supabase.rpc('ensure_lesson_session', params: {...});\n"
            "\n"
            "// Insert assignment\n"
            "await supabase.from('assignments').insert({...});\n",
        )
    )
    s.append(
        p(
            styles,
            "Ordering and limits: assignments and notifications use .order('created_at') and "
            ".limit(50) or paging helpers (PageResult). Do not download an entire marks table "
            "to the phone when a group filter exists.",
        )
    )
    s.append(
        task(
            styles,
            "14.1 Read the real repositories",
            "Open auth_provider.dart (profile fetch), group_providers.dart, "
            "assignment_providers.dart, marks_providers.dart. Write a table: method → .from/.rpc "
            "→ filters. You do not need a separate students_repository.dart — this app folds "
            "access into providers. If you create one for practice, keep it out of the production "
            "path until it matches RLS.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "As a student JWT (use the app, not the SQL Editor as postgres), open marks. You "
            "should see only your rows. As that student’s classmate, you should not see the first "
            "student’s marks. That is Tutorial 15, but you can already observe it.",
        )
    )
    s.extend(mistakes(styles, [
        ("Using .single() when 0 rows possible", "Use maybeSingle() like ProfileRepository."),
        (".select() without filter on a huge table", "Page and filter by group_id."),
    ]))
    s.extend(learned(styles, ["from/select/eq/rpc, empty list vs error, provider-as-repository."]))
    s.extend(quiz(styles, [
        ("Where is supabase defined?", "Supabase.instance.client via supabase_client.dart."),
    ]))
    s.append(PageBreak())
    return s


def t15(styles):
    s = [h1(styles, "Tutorial 15 — Row Level Security and permissions")]
    s.append(meta_box(styles, 15, "RLS", "★★★★ medium", "60 minutes", "Tutorials 12–14"))
    s.extend(video_list(styles, ["rls", "pg_rls"]))
    s.append(
        p(
            styles,
            "ALTER TABLE … ENABLE ROW LEVEL SECURITY is not optional. Without policies, "
            "authenticated users see zero rows (default deny). Policies are named SQL predicates. "
            "MU Study factors repeated checks into functions: is_admin(), is_teacher_of_group(id), "
            "is_student_in_group(id), can_access_chat_room(id), current_profile_role().",
        )
    )
    s.append(
        code_block(
            styles,
            "Mental policies (see export/rls_policies.sql for exact SQL)",
            "marks SELECT student: student_id = my students.id\n"
            "marks SELECT teacher: is_teacher_of_group(group_id)\n"
            "marks SELECT admin: is_admin()\n"
            "marks INSERT/UPDATE: teacher of group or admin\n"
            "notifications SELECT: user_id = auth.uid()\n"
            "chat_messages *: can_access_chat_room(room_id)\n",
        )
    )
    s.append(
        p(
            styles,
            "UPDATE needs a SELECT policy on the same rows. If teachers can UPDATE marks but "
            "cannot SELECT them, updates affect 0 rows with no drama. When debugging “save does "
            "nothing,” check SELECT policies first.",
        )
    )
    s.append(
        warn(
            styles,
            "Never authorize from user_metadata",
            "Supabase user_metadata is user-editable. Role lives in profiles.role. Helpers read "
            "that table (or related rows), not JWT user_metadata.",
        )
    )
    s.append(
        task(
            styles,
            "15.1 Prove RLS with two students",
            "Create student A and B in the same group. As teacher, insert two different marks. "
            "Log in as A — only A’s marks. Log in as B — only B’s. Log in as teacher — both. "
            "Optional: as A, try supabase.from('marks').select() in a debug print; count rows.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "A screenshot of two student accounts showing different mark lists, plus one SQL "
            "query as postgres showing both rows, is the proof. If both students see both rows, "
            "RLS is missing or you queried as service_role.",
        )
    )
    s.extend(mistakes(styles, [
        ("Testing RLS in SQL Editor as postgres", "You will always see everything. Use the app JWT."),
        ("Policy using submissions.group_id on marks", "marks has its own group_id. Copy-paste from blogs will not compile."),
    ]))
    s.extend(learned(styles, ["Default deny, helper functions, UPDATE needs SELECT."]))
    s.extend(quiz(styles, [
        ("Who can SELECT all profiles?", "Admins; others see self, groupmates, chat senders — see policies."),
    ]))
    s.append(PageBreak())
    return s


def t16(styles):
    s = [h1(styles, "Tutorial 16 — File upload and Supabase Storage")]
    s.append(meta_box(styles, 16, "Storage", "★★★★ medium", "50 minutes", "Tutorial 14"))
    s.extend(video_list(styles, ["storage", "file_upload"]))
    s.append(
        p(
            styles,
            "Buckets in this product: avatars (public), submissions, assignments, announcements, "
            "chat-images, chat-videos, chat-voices, chat-files (private). Public avatars use "
            "getPublicUrl. Private objects use createSignedUrl after upload.",
        )
    )
    s.append(
        code_block(
            styles,
            "Path conventions",
            "avatars/{profileId}/avatar.jpg\n"
            "submissions/{studentId}/{taskId}/{filename}\n"
            "chat-images/{roomId}/{profileId}/{timestamp}_{filename}\n",
        )
    )
    s.append(
        p(
            styles,
            "Storage policies parse folder segments. Chat uploads require folder[1]=room the user "
            "can access and folder[2]=auth.uid(). A mismatch is 403, not a mysterious empty URL.",
        )
    )
    s.append(
        task(
            styles,
            "16.1 Submit a file as a student",
            "Create a homework_pack with one task. As student, open StudentTaskSubmitScreen, "
            "pick a small PDF or image, submit. In Storage, open submissions and find the object. "
            "In Table Editor, confirm submissions.file_url is a signed or stored URL. "
            "As another student, you must not download that object.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Teacher can open the file from the review UI. Second student cannot. If both can, "
            "the bucket is public or the policy is USING(true).",
        )
    )
    s.extend(mistakes(styles, [
        ("Uploading to avatars for homework", "Wrong bucket; URLs become world-readable."),
        ("Granting only INSERT on storage", "Upsert/replace needs INSERT+SELECT+UPDATE."),
    ]))
    s.extend(learned(styles, ["Bucket privacy, path folders, signed URLs."]))
    s.extend(quiz(styles, [
        ("Which bucket is public?", "avatars."),
    ]))
    s.append(PageBreak())
    return s


def t17(styles):
    s = [h1(styles, "Tutorial 17 — Realtime live updates")]
    s.append(meta_box(styles, 17, "Realtime", "★★★★ medium", "50 minutes", "Tutorial 14"))
    s.extend(video_list(styles, ["realtime", "chat"]))
    s.append(
        p(
            styles,
            "supabase_flutter v2 uses channel.onPostgresChanges, not the old .from().on() API "
            "you will still see in outdated blogs. notificationsProvider subscribes to "
            "public.notifications filtered by user_id. Chat providers subscribe to chat_messages, "
            "message_reads, and message_reactions. Tables must be in the supabase_realtime "
            "publication. message_reactions uses REPLICA IDENTITY FULL so updates/deletes emit payloads.",
        )
    )
    s.append(
        code_block(
            styles,
            "notificationsProvider (shape)",
            "channel('notifications-${profile.id}')\n"
            "  .onPostgresChanges(\n"
            "    event: PostgresChangeEvent.all,\n"
            "    schema: 'public',\n"
            "    table: 'notifications',\n"
            "    filter: PostgresChangeFilter(\n"
            "      type: PostgresChangeFilterType.eq,\n"
            "      column: 'user_id',\n"
            "      value: profile.id,\n"
            "    ),\n"
            "    callback: (_) => changes.add(null),\n"
            "  )\n"
            "  .subscribe();\n",
        )
    )
    s.append(
        p(
            styles,
            "The stream yields an initial load, then re-fetches on each change. That is simpler "
            "than applying diffs and matches a 50-row inbox. Chat may append incrementally — "
            "read chat_providers.dart for the exact strategy.",
        )
    )
    s.append(
        task(
            styles,
            "17.1 Two devices, one room",
            "Open the same group chat on two accounts (teacher + student). Send a text. "
            "The other device must show it without pulling to refresh. "
            "Insert a notification row for user A in SQL; A’s inbox badge must update.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "If only refresh-after-navigate works, Realtime is not subscribed or the table is "
            "not in the publication. Check Database → Publications → supabase_realtime.",
        )
    )
    s.extend(mistakes(styles, [
        ("Copying RealtimeListenTypes from old tutorials", "Use onPostgresChanges."),
        ("Forgetting ref.onDispose(removeChannel)", "Leaked channels; missed events after logout."),
    ]))
    s.extend(learned(styles, ["Channels, filters, publication, dispose."]))
    s.extend(quiz(styles, [
        ("Why REPLICA IDENTITY FULL on reactions?", "Realtime needs old row keys on UPDATE/DELETE."),
    ]))
    s.append(PageBreak())
    return s


def t18(styles):
    s = [h1(styles, "Tutorial 18 — Localization (English, Russian, Uzbek)")]
    s.append(meta_box(styles, 18, "Localization", "★★★★ medium", "45 minutes", "Tutorials 7 and 10"))
    s.extend(video_list(styles, ["l10n", "i18n"]))
    s.append(
        p(
            styles,
            "l10n.yaml points at lib/l10n, template app_en.arb, class AppLocalizations, "
            "nullable-getter: false. That last flag means AppLocalizations.of(context) is "
            "non-null if delegates are installed — the code uses context.l10n via l10n_x.dart.",
        )
    )
    s.append(
        p(
            styles,
            "Languages are English, Russian, and Uzbek — not Arabic. First-run "
            "LanguageSelectionScreen writes profiles.preferred_language and SharedPreferences. "
            "The router blocks dashboards until that column is set. Profile settings can change "
            "it later via localeProvider.",
        )
    )
    s.append(
        code_block(
            styles,
            "lib/l10n/app_en.arb (excerpt)",
            '"loginSignIn": "Sign in",\n'
            '"navFocus": "Focus",\n'
            '"chatTitle": "Chat",\n',
        )
    )
    s.append(
        task(
            styles,
            "18.1 Switch languages",
            "Log in, pick Russian, confirm dashboard strings change. Repeat Uzbek. "
            "Restart the app — language persists. Add a harmless ARB key to all three files, "
            "run flutter gen-l10n, display it on the profile screen, then remove it if you do "
            "not want to keep it.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "SQL: preferred_language is ru or uz. flutter gen-l10n exits 0. A missing key in "
            "app_uz.arb fails generation — that failure is the test that you must edit all three.",
        )
    )
    s.extend(mistakes(styles, [
        ("Hard-coding Arabic from a generic prompt", "Wrong product."),
        ("Only editing app_en.arb", "Other locales fall back or fail CI."),
    ]))
    s.extend(learned(styles, ["ARB trio, language gate, context.l10n."]))
    s.extend(quiz(styles, [
        ("Which file is the template?", "app_en.arb"),
    ]))
    s.append(PageBreak())
    return s


def t19(styles):
    s = [h1(styles, "Tutorial 19 — Theming and dark mode")]
    s.append(meta_box(styles, 19, "Theming", "★★★★ medium", "40 minutes", "Tutorials 7 and 10"))
    s.extend(video_list(styles, ["theme", "dark"]))
    s.append(
        p(
            styles,
            "AppStyle has four values: modern, naturePaper, softNeumorphism, monochromeWorkspace. "
            "themeMode is light, dark, or system. Both persist locally and on "
            "profiles.preferred_style / preferred_theme. main.dart overrides the controllers so "
            "a profile load applies the saved look. themeAnimationDuration is zero.",
        )
    )
    s.append(
        p(
            styles,
            "Nature Paper and Soft Neumorphism add backdrop widgets in MaterialApp.builder "
            "alongside ResponsiveBreakpoints. Tokens live in app_style_tokens.dart and per-style "
            "color files. Read AppTheme.light(style) / dark(style).",
        )
    )
    s.append(
        task(
            styles,
            "19.1 Toggle every combination",
            "On AppProfileScreen, walk 4 styles × 2 brightness modes (ignore system or set it). "
            "Confirm Nature Paper shows paper décor and Soft Neumorphism shows its backdrop. "
            "Restart — prefs survive. Change on device A, confirm profiles row updated, then "
            "login on device B (optional) to see server-followed style.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "preferred_style in SQL equals the enum name (naturePaper camelCase). If you stored "
            "nature_paper, tryParse fails and the UI falls back.",
        )
    )
    s.extend(mistakes(styles, [
        ("Animating theme between incompatible palettes", "The repo disables animation on purpose."),
    ]))
    s.extend(learned(styles, ["Four styles, themeMode, profile persistence."]))
    s.extend(quiz(styles, [
        ("Where are backdrops wrapped?", "MuStudyApp builder → NaturePaperBackdrop → SoftNeumorphismBackdrop."),
    ]))
    s.append(PageBreak())
    return s


def t20(styles):
    s = [h1(styles, "Tutorial 20 — Notifications (what MU Study actually ships)")]
    s.append(meta_box(styles, 20, "Notifications", "★★★★★ hard conceptually", "60 minutes", "Tutorials 13–14, 17"))
    s.extend(video_list(styles, ["realtime", "fcm", "push"]))
    s.append(
        warn(
            styles,
            "Firebase Cloud Messaging is not in this repository",
            "pubspec.yaml has no firebase_messaging. There is no FCM token column. Tutorial "
            "prompts that ask you to “send a test push from the Supabase dashboard” describe a "
            "different product. This tutorial teaches the real inbox, then sketches how FCM "
            "could be added later without pretending it already works.",
        )
    )
    s.append(h2(styles, "The real pipeline"))
    s.append(
        code_block(
            styles,
            "In-app notifications",
            "Teacher creates assignment\n"
            "  → trg_assignment_notify / notify_user()\n"
            "  → INSERT notifications (user_id, title, body, kind, action_path, ref_id)\n"
            "  → Realtime event\n"
            "  → notificationsProvider reloads\n"
            "  → unreadNotificationsCountProvider updates shell badge\n"
            "  → Student taps row → optional action_path via go_router\n",
        )
    )
    s.append(
        p(
            styles,
            "Similar triggers exist for announcements, submissions, marks, and chat messages "
            "(fn_trg_*.sql, fn_notify_user.sql, fn_notify_chat_message.sql). kind distinguishes "
            "system vs chat vs homework so the UI can icon and filter.",
        )
    )
    s.append(h2(styles, "If you add FCM later (design only)"))
    s.append(
        p(
            styles,
            "You would store a device token per profile, send from an Edge Function on "
            "notification INSERT, and handle onMessageOpenedApp to context.go(action_path). "
            "That is a new project with APNs/FCM keys. Do not block reconstruction of MU Study "
            "on store push certificates.",
        )
    )
    s.append(
        task(
            styles,
            "20.1 Prove in-app notifications",
            "As teacher, create an assignment for a group that has a student. "
            "As student, watch the inbox and badge update without refresh. "
            "Mark as read; unread count drops. Read fn_trg_assignment_notify.sql and write the "
            "INSERT column list in your notes.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Table Editor shows a notifications row with the student profile id. The student’s "
            "phone showed it live. No Firebase console was involved. That is a pass.",
        )
    )
    s.extend(mistakes(styles, [
        ("Installing firebase_messaging “because the prompt said so”", "Out of scope unless you explicitly start a push project."),
    ]))
    s.extend(learned(styles, ["Inbox table + triggers + Realtime. FCM is optional future work."]))
    s.extend(quiz(styles, [
        ("Who inserts homework notifications?", "A trigger after assignment insert, via notify helpers."),
    ]))
    s.append(PageBreak())
    return s


def t21(styles):
    s = [h1(styles, "Tutorial 21 — Authentication feature (complete)")]
    s.append(meta_box(styles, 21, "Complete auth", "★★★★ medium", "90 minutes", "Tutorials 10–15"))
    s.extend(video_list(styles, ["supabase_auth", "flutter_auth"]))
    s.append(
        p(
            styles,
            "Assemble SplashScreen, SetupRequiredScreen, LoginScreen, LanguageSelectionScreen, "
            "disabled account, AuthRepository, ProfileRepository, router redirect, cache fallback. "
            "Session persistence is supabase_flutter’s job (local storage). Profile JSON is also "
            "cached in CacheService for offline display.",
        )
    )
    s.append(
        code_block(
            styles,
            "Files to implement in order",
            "lib/core/constants/env.dart\n"
            "lib/supabase/supabase_client.dart\n"
            "lib/models/enums.dart\n"
            "lib/models/profile.dart\n"
            "lib/providers/auth/auth_provider.dart\n"
            "lib/core/router/app_router.dart\n"
            "lib/screens/auth/*.dart\n"
            "lib/main.dart\n",
        )
    )
    s.append(
        task(
            styles,
            "21.1 Full loop",
            "Cold start → splash → login → language → admin home → logout → login as student → "
            "student home. Kill the process, relaunch: session restores, language not asked again. "
            "Change password as a user who has current password (profile settings). "
            "Disable a user; they cannot resolve email.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Three accounts, three homes. SharedPreferences still has supabase session after "
            "relaunch (or you would see login). SQL is_disabled true blocks RPC.",
        )
    )
    s.extend(mistakes(styles, [
        ("Skipping /language", "Users with null preferred_language must not see role chrome."),
    ]))
    s.extend(learned(styles, ["The production auth loop, not a toy email form."]))
    s.extend(quiz(styles, [
        ("What does signOut clear besides Auth?", "App caches via clearAllAppCaches."),
    ]))
    s.append(PageBreak())
    return s


def t22(styles):
    s = [h1(styles, "Tutorial 22 — Assignments feature (complete)")]
    s.append(meta_box(styles, 22, "Assignments", "★★★★★ hard", "120 minutes", "Tutorials 10–16"))
    s.append(
        p(
            styles,
            "Teacher: TeacherAssignmentsScreen creates static or homework_pack rows for the "
            "active group. Packs open TeacherHomeworkPackScreen to add TaskItems (sort_order). "
            "Student: StudentAssignmentsScreen lists work. Packs open tasks; "
            "StudentTaskSubmitScreen upserts submissions (text, file_url, voice_url). "
            "TeacherSubmissionsScreen reviews. Marks may sync via fn_sync_submission_mark. "
            "trg_assignment_notify fans out inbox rows.",
        )
    )
    s.append(
        simple_table(
            styles,
            ["Actor", "Screen", "Table/RPC"],
            [
                ["Teacher", "TeacherAssignmentsScreen", "assignments insert"],
                ["Teacher", "TeacherHomeworkPackScreen", "tasks"],
                ["Student", "StudentTaskSubmitScreen", "submissions + storage"],
                ["Teacher", "TeacherSubmissionsScreen", "submissions update"],
                ["Either", "marks screens", "marks / views"],
            ],
            [1.2 * inch, 2.6 * inch, 2.7 * inch],
        )
    )
    s.append(
        task(
            styles,
            "22.1 End-to-end pack",
            "Teacher creates homework_pack “Fractions” with two tasks (one with a link). "
            "Student submits text on task 1 and a file on task 2. Teacher scores task 1. "
            "Student marks screen updates. Notification exists for the assignment create.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "UNIQUE (task_id, student_id) prevents a second submission row — upsert or error. "
            "SQL shows two tasks, two submissions, one mark. Classmate cannot open the file.",
        )
    )
    s.extend(mistakes(styles, [
        ("Treating static assignments as submit-able", "Product: static is display-only."),
    ]))
    s.extend(learned(styles, ["Pack vs static, task order, submission uniqueness, notify trigger."]))
    s.extend(quiz(styles, [
        ("Which enum value is stored for a pack?", "homework_pack"),
    ]))
    s.append(PageBreak())
    return s


def t23(styles):
    s = [h1(styles, "Tutorial 23 — Chat feature (complete)")]
    s.append(meta_box(styles, 23, "Chat", "★★★★★ hard", "120 minutes", "Tutorials 10–17"))
    s.append(
        p(
            styles,
            "Chat is group-scoped, not a free DM roster. ensure_chat_room_for_group creates "
            "chat_rooms when a group is inserted. ChatListScreen reads chat_room_summaries + "
            "chat_unread_counts. ChatRoomScreen sends text/voice/image/video/file, replies "
            "(same room check), reactions (toggle_message_reaction), and marks reads. "
            "Soft delete sets is_deleted. Content check constraint: text needs text_content; "
            "media types need media_url.",
        )
    )
    s.append(
        p(
            styles,
            "There is no separate 1-1 student–teacher table. A “direct” feel happens because a "
            "small group still shares one room. Typing indicators are not a first-class table "
            "in the recovered schema — if you add them, use a Realtime broadcast channel, not "
            "a row per keystroke.",
        )
    )
    s.append(
        task(
            styles,
            "23.1 Group chat fidelity",
            "Two members send text. One sends an image (chat-images path). One replies. Both "
            "toggle a reaction. Unread badge on the other user drops after they open the room. "
            "Delete a message — others see deleted state, not the old text.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "A third user not in the group cannot SELECT chat_messages for that room_id (RLS). "
            "Storage 403 if they guess the path. member_count = students + 1.",
        )
    )
    s.extend(mistakes(styles, [
        ("Creating chat_rooms in Flutter instead of the trigger", "You will get duplicates or miss rooms."),
    ]))
    s.extend(learned(styles, ["One room per group, media paths, unread RPC, reactions RPC."]))
    s.extend(quiz(styles, [
        ("What view feeds the chat list?", "chat_room_summaries"),
    ]))
    s.append(PageBreak())
    return s


def t24(styles):
    s = [h1(styles, "Tutorial 24 — Attendance feature (complete)")]
    s.append(meta_box(styles, 24, "Attendance", "★★★★ medium", "90 minutes", "Tutorials 10–15"))
    s.append(
        p(
            styles,
            "Teachers open TeacherAttendanceScreen, pick a group and date. "
            "ensure_lesson_session(group, date) returns/creates lesson_sessions. Attendance rows "
            "upsert status: present, absent, late, excused. Unique (group, student, date) and "
            "unique (session, student). Students see a calendar (AttendanceCalendarGrid). "
            "Analytics charts aggregate percentages. There is no parent-push integration; "
            "a parent-facing notification would be a new notifications.kind plus a product decision.",
        )
    )
    s.append(
        task(
            styles,
            "24.1 Roll call",
            "Mark a class mixed present/absent/late. Change one student to excused. "
            "SQL: one lesson_sessions row, N attendance rows. Student calendar matches. "
            "Teacher analytics shows a sane percentage.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Re-opening the same date does not create a second session (UNIQUE group_id, session_date). "
            "A teacher of another group cannot write this group’s attendance (RLS).",
        )
    )
    s.extend(mistakes(styles, [
        ("Inserting attendance without a session", "session_id is NOT NULL."),
    ]))
    s.extend(learned(styles, ["Session + status enum + student calendar."]))
    s.extend(quiz(styles, [
        ("Which RPC starts the day?", "ensure_lesson_session"),
    ]))
    s.append(PageBreak())
    return s


def t25(styles):
    s = [h1(styles, "Tutorial 25 — Announcements feature (complete)")]
    s.append(meta_box(styles, 25, "Announcements", "★★★ easy", "60 minutes", "Tutorials 10–16"))
    s.append(
        p(
            styles,
            "announcements belong to a group. teacher_id is nullable so an admin school-wide "
            "post can omit a teacher. image_urls and file_urls are jsonb arrays. "
            "TeacherAnnouncementsScreen and AdminAnnouncementsScreen insert rows and upload "
            "attachments to the announcements bucket. trg_announcement_notify inserts inbox "
            "rows. Student dashboard ExpandableAnnouncementCard reads announcementsProvider.",
        )
    )
    s.append(
        p(
            styles,
            "There is no announcements_reads table. “Read” is approximated by opening the card "
            "or by the related notification.is_read. If you need true per-student read receipts "
            "for announcements, that is a new table — do not overload message_reads.",
        )
    )
    s.append(
        task(
            styles,
            "25.1 Post and receive",
            "Teacher posts a title + description + one image. Students in that group see it on "
            "the dashboard and get a notification. Students in another group do not. "
            "Admin can post to a selected group from the admin announcements screen.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "SQL: announcements.group_id matches. notifications.kind/action_path point at the "
            "announcement. Storage object is not world-listable. Out-of-group student SELECT "
            "returns zero rows for that id.",
        )
    )
    s.extend(mistakes(styles, [
        ("Putting school-wide news in a random student’s group", "Admins still pick a group_id; plan which group is “all school” or post per group."),
    ]))
    s.extend(learned(styles, ["Group-scoped posts, jsonb URLs, notify trigger."]))
    s.extend(quiz(styles, [
        ("Can teacher_id be null?", "Yes — admin posts."),
    ]))
    s.append(PageBreak())
    return s


def t26(styles):
    s = [h1(styles, "Tutorial 26 — Custom widgets and components")]
    s.append(meta_box(styles, 26, "Custom widgets", "★★★★ medium", "60 minutes", "Tutorial 7"))
    s.append(
        p(
            styles,
            "lib/components/ is the widget library: AppShell, ShellNavBar, PremiumCard, "
            "EmptyState, PrimaryButton, GroupSelector, AttachmentPreview, VoiceNoteField, "
            "MarkAverageCard, AttendanceCalendarGrid, chat bubbles, PDF viewer sheet, "
            "analytics charts. Screens should compose these instead of restyling ListTile "
            "fifty times.",
        )
    )
    s.append(
        p(
            styles,
            "Good components take data + callbacks (Assignment-like cards take onTap). They do "
            "not call supabase themselves. If a card fetches, you cannot reuse it in a test "
            "without a fake backend.",
        )
    )
    s.append(
        task(
            styles,
            "26.1 Inventory and reuse",
            "List ten components and the screens that use them. "
            "Build a practice StudentProfileCard in a scratch file that only takes Profile. "
            "Then compare to ProfileHeroCard. Note what you missed (style tokens, l10n, avatar cache).",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Your practice card has no supabase import. flutter analyze on the scratch file is clean. "
            "You can point to AppShell as the reason student/teacher/admin feel like one product.",
        )
    )
    s.extend(mistakes(styles, [
        ("Copy-pasting MessageBubble into three role folders", "Chat is already shared."),
    ]))
    s.extend(learned(styles, ["Composition, props vs fetch, shared shell."]))
    s.extend(quiz(styles, [
        ("Where does bottom nav live?", "lib/components/layouts/ — AppShell + ShellNavBar."),
    ]))
    s.append(PageBreak())
    return s


def t27(styles):
    s = [h1(styles, "Tutorial 27 — Testing")]
    s.append(meta_box(styles, 27, "Testing", "★★★★★ hard", "90 minutes", "Tutorials 6 and 10"))
    s.extend(video_list(styles, ["testing"]))
    s.append(
        p(
            styles,
            "This repo already has test/widget_test.dart (SetupRequiredScreen), "
            "test/emoji_message_test.dart, and test/shell_layout_test.dart. They run without "
            "Supabase. That is the correct default: unit/widget tests mock or avoid the network. "
            "Integration tests that log in to a live project belong in a separate CI job with secrets.",
        )
    )
    s.append(
        code_block(
            styles,
            "test/widget_test.dart (real)",
            "testWidgets('Setup screen shows configuration hint', (tester) async {\n"
            "  await tester.pumpWidget(const SetupRequiredScreen());\n"
            "  expect(find.textContaining('Supabase is not configured'), findsOneWidget);\n"
            "});\n",
        )
    )
    s.append(
        p(
            styles,
            "For models, test assignmentTypeFromString('homework_pack') and fromJson with a "
            "fixture map. For AuthRepository, inject a fake supabase is hard — prefer testing "
            "pure functions (email normalization, error mapping) and a thin mock around rpc. "
            "Do not hit production with widget tests.",
        )
    )
    s.append(
        task(
            styles,
            "27.1 Write tests that belong in this repo",
            "1) Unit: assignmentTypeToDb / fromString round-trip.\n"
            "2) Unit: Profile.fromJson missing full_name becomes ''.\n"
            "3) Widget: SetupRequiredScreen (already exists — run it).\n"
            "4) Widget: a dummy login form you built in Tutorial 7 (optional).\n"
            "5) Manual integration checklist: login → dashboard → create assignment (teacher).\n"
            "Run: flutter test",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "flutter test exits 0. A new unit test fails when you break homework_pack mapping. "
            "CI should run flutter test on every PR.",
        )
    )
    s.extend(mistakes(styles, [
        ("Widget test that calls real signInWithPassword", "Flaky, slow, pollutes Auth users."),
    ]))
    s.extend(learned(styles, ["Test without network first. Manual checklist for RLS."]))
    s.extend(quiz(styles, [
        ("Why is SetupRequiredScreen easy to test?", "No Supabase init; it is a static widget."),
    ]))
    s.append(PageBreak())
    return s


def t28(styles):
    s = [h1(styles, "Tutorial 28 — Performance and optimization")]
    s.append(meta_box(styles, 28, "Performance", "★★★★★ hard", "60 minutes", "Tutorials 10 and 14"))
    s.extend(video_list(styles, ["perf"]))
    s.append(
        p(
            styles,
            "Riverpod already caches FutureProvider results until invalidate. "
            "Lists page (PageResult, LoadMoreButton). Images use cached_network_image and "
            "chat_media_cache_service. Selects should name columns when payloads are large "
            "(chat list uses a view instead of N+1 queries). Focus and theme reads hit "
            "SharedPreferences, not Postgres.",
        )
    )
    s.append(
        code_block(
            styles,
            "Habits",
            "- Filter by group_id / user_id in the query, not in Dart after download.\n"
            "- limit(50) on notifications (already).\n"
            "- Do not watch a high-churn stream in AppShell if only a badge integer is needed\n"
            "  (unreadNotificationsCountProvider derives from the list).\n"
            "- Chat video thumbnails are computed once (chat_video_thumbnail_service).\n",
        )
    )
    s.append(
        task(
            styles,
            "28.1 Measure one list",
            "Open teacher gradebook for a group with many marks. Note the select and whether "
            "it pages. If you add a student directory, implement page size 20 and a LoadMoreButton. "
            "Confirm DevTools rebuild counts do not rebuild the entire shell on each mark edit.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "Network tab (or Supabase logs) shows bounded payloads. Opening chat does not "
            "re-download all academic years. That is a pass.",
        )
    )
    s.extend(mistakes(styles, [
        ("select() * on chat_messages without room filter", "You will ship the whole school."),
    ]))
    s.extend(learned(styles, ["Cache, page, filter in SQL, isolate rebuilds."]))
    s.extend(quiz(styles, [
        ("Where is offline profile stored?", "CacheService / SharedPreferences via app_cache."),
    ]))
    s.append(PageBreak())
    return s


def t29(styles):
    s = [h1(styles, "Tutorial 29 — Error handling and user feedback")]
    s.append(meta_box(styles, 29, "Errors & feedback", "★★★★ medium", "50 minutes", "Tutorials 10 and 14"))
    s.append(
        p(
            styles,
            "LoginScreen maps AuthException → loginIncorrect, PostgrestException with jwt/key "
            "→ loginConfigError, other → loginFailed (debug shows the raw error). "
            "ProfileRepository catches fetch errors and falls back to cachedProfile. "
            "Lists should use AsyncValue.when with a retry that invalidates the provider. "
            "Skeletonizer/shimmer packages are in pubspec for loading chrome.",
        )
    )
    s.append(
        code_block(
            styles,
            "Pattern",
            "asyncValue.when(\n"
            "  loading: () => const Skeletonizer(child: PlaceholderList()),\n"
            "  error: (e, _) => EmptyState(\n"
            "    title: context.l10n.genericError,\n"
            "    action: () => ref.invalidate(assignmentsProvider),\n"
            "  ),\n"
            "  data: (items) => items.isEmpty ? EmptyState(...) : ListView(...),\n"
            ");\n",
        )
    )
    s.append(
        task(
            styles,
            "29.1 Break the network on purpose",
            "Airplane mode on a logged-in student. Open marks — cached or friendly error, not a "
            "red screen of death. Turn network on, tap retry. "
            "Wrong login password — no exception dump in release. "
            "Invalid anon key — SetupRequired or loginConfigError, not a hang.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "A non-developer testers’ notes: they always saw a sentence in their language and a "
            "next action (retry, contact admin). If they saw PostgrestException, you leaked internals.",
        )
    )
    s.extend(mistakes(styles, [
        ("catch (_) {}", "You hide RLS bugs. Log in debug, show l10n in release."),
    ]))
    s.extend(learned(styles, ["Typed errors, cache fallback, retry, empty vs error."]))
    s.extend(quiz(styles, [
        ("What does LoginScreen do after a successful sign-in?", "invalidate currentProfileProvider and context.go('/boot')."),
    ]))
    s.append(PageBreak())
    return s


def t30(styles):
    s = [h1(styles, "Tutorial 30 — Deployment to app stores and web")]
    s.append(meta_box(styles, 30, "Deployment", "★★★★★ hard", "120 minutes", "All previous tutorials"))
    s.extend(video_list(styles, ["deploy"]))
    s.append(
        p(
            styles,
            "Makefile apk target: flutter build apk --release then copies to mu_study.apk. "
            "Web: flutter build web (and make ch for Chrome debug). iOS: flutter build ipa "
            "requires Apple developer membership, signing, and bundle com.example.muStudy — "
            "change the bundle before a real store listing.",
        )
    )
    s.append(
        p(
            styles,
            "Store listing is an organizational process (screenshots, privacy policy, age "
            "ratings, data-safety forms). This book cannot create your Play Console or App "
            "Store Connect accounts. It can demand hygiene: no service_role, production "
            "Supabase project, Auth site URL allow-list, Syncfusion license if required, "
            "real passwords instead of password123, microphone/photo purpose strings that "
            "match what you actually record.",
        )
    )
    s.append(
        code_block(
            styles,
            "Release commands",
            "flutter test\n"
            "flutter build apk --release --dart-define-from-file=.env.production\n"
            "flutter build web --release --dart-define-from-file=.env.production\n"
            "flutter build ipa --release --dart-define-from-file=.env.production\n",
        )
    )
    s.append(
        task(
            styles,
            "30.1 Produce artifacts (local)",
            "1) flutter test passes.\n"
            "2) flutter build apk --release succeeds; install on a phone and log in against "
            "YOUR project.\n"
            "3) flutter build web succeeds; serve build/web and log in.\n"
            "4) Write a one-page launch checklist: rotate demo passwords, confirm RLS with "
            "two students, confirm Storage 403, confirm Auth redirect URLs.\n"
            "Uploading to stores is optional and account-specific — do not paste store keys here.",
        )
    )
    s.append(
        checkpoint(
            styles,
            "Independent verification",
            "The APK/web build logs in without SetupRequiredScreen. strings.xml / Info.plist "
            "usage descriptions exist. .env.production is not in git. A second student still "
            "cannot see the first student’s marks on the release build — RLS does not care about Debug.",
        )
    )
    s.extend(mistakes(styles, [
        ("Shipping the development project URL to the world with password123", "Read the README warning again."),
        ("Debug signing as a Play Store AAB", "Play requires a real upload keystore."),
    ]))
    s.extend(learned(styles, ["Release builds, secrets, store process vs engineering artifacts."]))
    s.extend(quiz(styles, [
        ("What Makefile target copies the APK?", "make apk"),
        ("Why dart-define-from-file on release?", "Inject URL/key without relying on a bundled .env you might forget to strip."),
    ]))
    s.append(
        callout(
            styles,
            "You finished the 30 tutorials",
            "The source atlas and SQL atlas after this page are the reconstruction encyclopedia. "
            "Use them when a lesson said “open file X” and you want the entire listing. "
            "Score yourself with Appendix K quizzes and the feature checkpoints — not with page count.",
        )
    )
    s.append(PageBreak())
    return s
