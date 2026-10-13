"""Shared helpers, video catalog, and source-atlas builders for the beginner series PDF."""

from __future__ import annotations

from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.platypus import KeepTogether, PageBreak, Paragraph, Preformatted, Spacer, Table, TableStyle

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
from pdf_styles import ACCENT, BRAND, CODE_BG, MUTED
from column_catalog import TABLES

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
EXPORT = HERE / "export"
LIB = ROOT / "lib"
ASSETS = ROOT / "assets"
TEST = ROOT / "test"

SKIP_DART_NAMES = {
    "app_localizations.dart",
    "app_localizations_en.dart",
    "app_localizations_ru.dart",
    "app_localizations_uz.dart",
}


VIDEOS = {
    "flutter_what": ("What is Flutter? — Flutter Official", "https://www.youtube.com/watch?v=fDkQWZDu6UU"),
    "supabase_what": ("What is Supabase? — Supabase Channel", "https://www.youtube.com/watch?v=WiwfiP2jtjY"),
    "db_crash": ("Database Basics — Crash Course", "https://www.youtube.com/watch?v=oCgc3fumTW0"),
    "sql_fcc": ("SQL for Beginners — freeCodeCamp", "https://www.youtube.com/watch?v=HXV3zeQKqGY"),
    "pg_amigos": ("PostgreSQL Tutorial — Amigoscode", "https://www.youtube.com/watch?v=qw--VYLpxG4"),
    "sql_mosh": ("SQL for Beginners — Programming with Mosh", "https://www.youtube.com/watch?v=7S_tz1z_5bA"),
    "supabase_setup": ("Supabase Setup & Tutorial — Official", "https://www.youtube.com/watch?v=I6nnp6kS3F8"),
    "supabase_full": ("Supabase Full Course — Codementor", "https://www.youtube.com/watch?v=rypsG5tqz8Q"),
    "env_fireship": ("Environment Variables — Fireship", "https://www.youtube.com/watch?v=HXZpY4sUmqQ"),
    "dotenv": ("flutter_dotenv package walkthrough", "https://pub.dev/packages/flutter_dotenv"),
    "flutter_struct": ("Flutter Project Structure — The Net Ninja", "https://www.youtube.com/watch?v=u3R2cCP_ynI"),
    "flutter_begin": ("Flutter for Beginners — Udacity", "https://www.youtube.com/watch?v=7nAMS3cAr3c"),
    "dart_fireship": ("Dart for Beginners — Fireship", "https://www.youtube.com/watch?v=Ej_Pcr4uC2Q"),
    "dart_null": ("Dart Null Safety — Dart Official", "https://www.youtube.com/watch?v=IqD_wjsDMKU"),
    "widgets_ninja": ("Flutter Widgets — The Net Ninja", "https://www.youtube.com/watch?v=u_rbIqnRDms"),
    "layout_official": ("Flutter Layout Tutorial — Flutter Official", "https://www.youtube.com/watch?v=_58-kTsPq9c"),
    "material": ("Material Design in Flutter — Google", "https://www.youtube.com/watch?v=DL0Ix1lnK4k"),
    "stateful": ("Stateful vs Stateless — Flutter Official", "https://www.youtube.com/watch?v=wE7khGHVkYY"),
    "state_fireship": ("Flutter State Management — Fireship", "https://www.youtube.com/watch?v=lTnXr8XO0Ys"),
    "gorouter": ("GoRouter — Flutter Official", "https://www.youtube.com/watch?v=Y9DLpnBckso"),
    "nav_fireship": ("Navigation in Flutter — Fireship", "https://www.youtube.com/watch?v=xYPCrZ5iHzQ"),
    "riverpod_fireship": ("Riverpod Tutorial — Fireship", "https://www.youtube.com/watch?v=9EDFCZ0SqEA"),
    "riverpod_codepur": ("Riverpod for State Management — Codepur", "https://www.youtube.com/watch?v=GxXSiSkJUvY"),
    "riverpod_docs": ("Riverpod Documentation", "https://riverpod.dev/"),
    "riverpod_course": ("Riverpod Complete Course — Tomic Riedel", "https://www.youtube.com/watch?v=W_nqHaYVHjE"),
    "freezed": ("Freezed Package — Codepur", "https://www.youtube.com/watch?v=PkJCU-Qm3QM"),
    "models": ("Dart Models & Serialization — Fireship", "https://www.youtube.com/watch?v=xXCG15nVP_8"),
    "supabase_auth": ("Supabase Auth — Official", "https://www.youtube.com/watch?v=6ow_jW7iS24"),
    "flutter_auth": ("Flutter Authentication — Fireship", "https://www.youtube.com/watch?v=yH3NQFr3k0s"),
    "sb_queries": ("Supabase Database Queries — Official", "https://www.youtube.com/watch?v=zVlc_O_oJgA"),
    "flutter_sb": ("Flutter + Supabase — Fireship", "https://www.youtube.com/watch?v=eKvj2P3sJVU"),
    "rls": ("Supabase RLS — Official", "https://www.youtube.com/watch?v=Ow_Utn9OIMQ"),
    "pg_rls": ("PostgreSQL Row-Level Security — Amigoscode", "https://www.youtube.com/watch?v=2IXAHGQJ0as"),
    "storage": ("Supabase Storage — Official", "https://www.youtube.com/watch?v=s7EwCRwxo5s"),
    "file_upload": ("File Upload in Flutter — Fireship", "https://www.youtube.com/watch?v=KLY_2vtuWsQ"),
    "realtime": ("Supabase Real-time — Official", "https://www.youtube.com/watch?v=lsKDFTL1YbQ"),
    "chat": ("Real-time Chat Flutter — Fireship", "https://www.youtube.com/watch?v=F7OX-pxjvPQ"),
    "l10n": ("Flutter Localization — Official", "https://www.youtube.com/watch?v=Zw3-fHMjVLw"),
    "i18n": ("i18n in Flutter — Fireship", "https://www.youtube.com/watch?v=QDmKQkeSLfI"),
    "theme": ("Flutter Theming — Official", "https://www.youtube.com/watch?v=oP3asNgo_Tw"),
    "dark": ("Dark Mode in Flutter — Fireship", "https://www.youtube.com/watch?v=h3bkKqFtaO4"),
    "fcm": ("Firebase Cloud Messaging — Flutter", "https://www.youtube.com/watch?v=aIRVqk9oE94"),
    "push": ("Push Notifications in Flutter — Fireship", "https://www.youtube.com/watch?v=7AtVo2H3g1s"),
    "testing": ("Flutter Testing — Official", "https://www.youtube.com/watch?v=X8uCMbpnb5s"),
    "perf": ("Flutter Performance — Official", "https://www.youtube.com/watch?v=pk05Vmtfl5g"),
    "deploy": ("Flutter Release Builds — Official", "https://www.youtube.com/watch?v=Yx1kSisJo4k"),
    "http": ("HTTP Crash Course — Traversy", "https://www.youtube.com/watch?v=iYM2zFP3Zn0"),
    "json": ("JSON Crash Course — Traversy", "https://www.youtube.com/watch?v=iiADhChRriM"),
    "jwt": ("JWT explained — Fireship", "https://www.youtube.com/watch?v=7Q17ubqLfaM"),
    "git": ("Git & GitHub — freeCodeCamp", "https://www.youtube.com/watch?v=RGOj5yH7evk"),
}


FOLDER_PURPOSE = {
    "lib": "Application Dart source. Everything a user sees starts here.",
    "lib/main.dart": "Process entry: load env, init Supabase, wrap ProviderScope, run MaterialApp.router.",
    "lib/core": "Cross-cutting platform code: theme, router, env, cache, utilities.",
    "lib/core/constants": "Compile-time and runtime configuration (Env).",
    "lib/core/router": "go_router route table and auth/language/disabled redirects.",
    "lib/core/theme": "Four visual styles × light/dark Material 3 themes.",
    "lib/core/services": "Caches, voice, chat media, SharedPreferences wrappers.",
    "lib/core/admin": "Credential slip PDF generation for printed login cards.",
    "lib/core/chat": "Emoji helpers and animated emoji registry.",
    "lib/core/focus": "Focus-mode audio/visual cues (local, not a database table).",
    "lib/core/homework": "Due-date helpers and assignment template JSON.",
    "lib/core/locale": "Supported locales EN/RU/UZ.",
    "lib/core/marks": "Academic term math and CSV export.",
    "lib/core/paging": "Generic page-result type for list pagination.",
    "lib/core/progress": "Student progress report model + PDF + share.",
    "lib/core/utils": "Responsive breakpoints and voice playback.",
    "lib/models": "JSON ↔ Dart domain types. Manual fromJson, not Freezed in this repo.",
    "lib/providers": "Riverpod providers: auth, lists, streams, mutations.",
    "lib/providers/auth": "Session stream, username login RPC, profile/teacher/student loaders.",
    "lib/providers/groups": "Teacher-owned and student-membership groups.",
    "lib/providers/homework": "Assignments, tasks, teacher submissions queue.",
    "lib/providers/marks": "Gradebook CRUD and student averages.",
    "lib/providers/attendance": "Lesson sessions + attendance upsert.",
    "lib/providers/chat": "Room summaries, unread RPC, messages, reactions.",
    "lib/providers/notifications": "Realtime inbox + announcements.",
    "lib/providers/focus": "Local Pomodoro/free timer persisted in SharedPreferences.",
    "lib/providers/settings": "Locale, theme mode, AppStyle.",
    "lib/providers/admin": "Users, groups, analytics, academic years, mass generator.",
    "lib/screens": "Full pages composed into go_router.",
    "lib/screens/auth": "Splash, login, language, setup-required, disabled account.",
    "lib/screens/student": "Student shell destinations: home, homework, focus, marks, attendance, chat, notifications, profile.",
    "lib/screens/teacher": "Teacher shell: dashboard, assignments, submissions, attendance, gradebook, analytics, announcements, chat.",
    "lib/screens/admin": "Admin shell: users, groups, years, announcements, credentials, mass data.",
    "lib/screens/chat": "Shared chat list + room used by all three roles.",
    "lib/screens/profile": "Shared profile (theme, language, password, logout).",
    "lib/components": "Reusable widgets: shell, cards, attachments, charts, chat bits.",
    "lib/l10n": "ARB translations and generated AppLocalizations.",
    "lib/supabase": "Thin accessor: supabase = Supabase.instance.client.",
    "test": "Widget/unit tests that run without a live Supabase project.",
}


def video_list(styles, keys):
    rows = []
    for k in keys:
        title, url = VIDEOS[k]
        rows.append([title, url])
    out = [h3(styles, "Video resources")]
    out.append(
        p(
            styles,
            "Watch at least one video before the task. Videos teach the general technology; "
            "this book teaches how MU Study uses that technology. Pause the video and map each "
            "concept onto a file in this repository.",
        )
    )
    out.append(simple_table(styles, ["Resource", "URL"], rows, [2.6 * inch, 3.9 * inch]))
    return out


def meta_box(styles, num, title, stars, minutes, prereq):
    rows = [
        ["Tutorial", f"{num} — {title}"],
        ["Difficulty", stars],
        ["Time", minutes],
        ["Prerequisites", prereq],
        ["Verify yourself", "Every TASK has an independent CHECKPOINT. Do not skip it."],
    ]
    return simple_table(styles, ["Field", "Value"], rows, [1.6 * inch, 4.9 * inch])


def quiz(styles, pairs):
    out = [h3(styles, "Self-check quiz (cover the answers)")]
    for i, (q, a) in enumerate(pairs, 1):
        out.append(p(styles, f"<b>Q{i}.</b> {q}"))
        out.append(callout(styles, f"Answer {i}", a))
    return out


def mistakes(styles, items):
    out = [h3(styles, "Common mistakes")]
    for title, body in items:
        out.append(warn(styles, title, body))
    return out


def learned(styles, items):
    out = [h3(styles, "What you just learned")]
    out.extend(bullets(styles, items))
    return out


def code_chunks(styles, path, text, max_chars=14000):
    parts = []
    if path:
        parts.append(Paragraph(path, styles["CodePath"]))
    body = text.replace("\t", "  ")
    chunks, cur, n = [], [], 0
    for line in body.splitlines(True):
        if n + len(line) > max_chars and cur:
            chunks.append("".join(cur))
            cur, n = [line], len(line)
        else:
            cur.append(line)
            n += len(line)
    if cur:
        chunks.append("".join(cur))
    for i, ch in enumerate(chunks):
        if i:
            parts.append(Paragraph(f"{path} — continued ({i + 1}/{len(chunks)})", styles["CodePath"]))
        parts.append(Preformatted(ch, styles["Code"], maxLineLength=96))
    return parts


def file_purpose(rel: str) -> str:
    posix = rel.replace("\\", "/")
    if posix in FOLDER_PURPOSE:
        return FOLDER_PURPOSE[posix]
    parent = str(Path(posix).parent)
    if parent in FOLDER_PURPOSE:
        name = Path(posix).stem.replace("_", " ")
        return f"{FOLDER_PURPOSE[parent]} This file ({name}) is one concrete piece of that layer."
    return (
        "Application source used by MU Study. Read the imports first, then the public types, "
        "then the widget build or provider body."
    )


def dart_files():
    files = []
    for fp in sorted(LIB.rglob("*.dart")):
        if fp.name in SKIP_DART_NAMES:
            continue
        files.append(fp)
    return files


def header_footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(ACCENT)
    canvas.setLineWidth(0.6)
    canvas.line(0.7 * inch, 11.15 * inch, 7.8 * inch, 11.15 * inch)
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(MUTED)
    canvas.drawString(0.7 * inch, 11.25 * inch, "MU Study — Beginner-to-Advanced Tutorial Series")
    canvas.line(0.7 * inch, 0.5 * inch, 7.8 * inch, 0.5 * inch)
    canvas.drawCentredString(4.25 * inch, 0.32 * inch, f"Page {doc.page}")
    canvas.restoreState()


def title_page(styles):
    story = [Spacer(1, 1.4 * inch)]
    story.append(Paragraph("MU Study", styles["Title"]))
    story.append(Paragraph("Complete Tutorial Series — Easiest to Hardest", styles["Subtitle"]))
    story.append(Spacer(1, 0.25 * inch))
    story.append(
        p(
            styles,
            "Thirty tutorials that teach every layer of the Flutter + Supabase school platform: "
            "product, database, auth, Riverpod, go_router, homework, marks, attendance, chat, "
            "notifications, themes, localization, testing, and release. Ordered from concepts "
            "that need no code to complete features that stitch the whole system together.",
            "Subtitle",
        )
    )
    story.append(Spacer(1, 0.5 * inch))
    meta = [
        ["Product", "School management + study platform (Math & English)"],
        ["Client", "Flutter · Dart ^3.11.5 · Riverpod · go_router"],
        ["Backend", "Supabase · PostgreSQL · Auth · Storage · Realtime"],
        ["Roles", "Student · Teacher (math/english) · Admin"],
        ["Locales", "English · Russian · Uzbek (not Arabic)"],
        ["Login", "Username + password (synthetic @mustudy.internal email)"],
        ["Registration", "None — admins create every account"],
        ["Secrets", "Placeholders only. Never paste a real anon key into notes you share."],
    ]
    t = Table(meta, colWidths=[1.5 * inch, 5.0 * inch])
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
    story.append(Spacer(1, 0.8 * inch))
    story.append(
        Paragraph(
            "<i>Generated from the inspected MU Study repository and the live PostgreSQL schema. "
            "Follow tutorials in order. Type the code. Verify every checkpoint independently.</i>",
            styles["Caption"],
        )
    )
    story.append(PageBreak())
    return story


def how_to_use(styles):
    s = [h1(styles, "How to use this book")]
    s.append(
        p(
            styles,
            "This is a reconstruction textbook, not a slide deck. Each tutorial has a Learn block, "
            "real MU Study files, a practical TASK, an independent verification CHECKPOINT, "
            "common mistakes, and video links. Later tutorials assume earlier checkpoints passed.",
        )
    )
    s.append(h2(styles, "Learning contract"))
    s.extend(
        numbered(
            styles,
            [
                "Work sequentially from Tutorial 1. Skipping fundamentals is the fastest way to get stuck on RLS.",
                "Type SQL and Dart yourself. Copy-paste only when a lesson says the file is a reference dump.",
                "Never commit .env. Never put the service_role key in Flutter. Never invent auth emails in the client.",
                "After each TASK, prove the CHECKPOINT without looking at the answer first.",
                "When something fails, use Appendix D (Troubleshooting) before changing random code.",
            ],
        )
    )
    s.append(h2(styles, "What “complete” means for MU Study"))
    s.append(
        p(
            styles,
            "A complete recreation includes: three role shells (student, teacher, admin); username "
            "login via get_auth_email_by_username; PostgreSQL enums, tables, views, SECURITY DEFINER "
            "RPCs, RLS, Storage buckets, Realtime on chat and notifications; EN/RU/UZ localization; "
            "four visual styles; homework packs with tasks; attendance sessions; weighted marks; "
            "group chat with replies and reactions; admin mass tools and printed credential slips.",
        )
    )
    s.append(
        warn(
            styles,
            "This book teaches the real app, not a simplified fantasy",
            "Some generic Flutter+Supabase tutorials use public email signup, Arabic localization, "
            "or Firebase Cloud Messaging. MU Study does none of those. Login is username-based. "
            "Languages are English, Russian, and Uzbek. Notifications are in-app rows plus Realtime, "
            "not FCM. Tutorial 20 explains that honestly and shows the real notification path.",
        )
    )
    s.append(
        callout(
            styles,
            "Independent verification",
            "A checkpoint is independent when you can prove it without the author’s machine: a SQL "
            "query result, a flutter analyze exit code, a screenshot of a named screen, or a second "
            "account that cannot see another student’s marks. “It looked fine” is not verification.",
        )
    )
    s.append(PageBreak())
    return s


def toc(styles):
    s = [h1(styles, "Table of contents")]
    entries = [
        ("How to use this book", "Start here"),
        ("Tier 1 — Fundamentals", "Tutorials 1–4 · no coding required at first"),
        ("  1. Understanding MU Study", "Product, roles, stack, architecture"),
        ("  2. Database concepts", "Tables, keys, types, 20-table map"),
        ("  3. Supabase project setup", "Account, keys, Table Editor, SQL Editor"),
        ("  4. Environment variables", ".env, dart-define, Env.sanitize"),
        ("Tier 2 — Flutter basics", "Tutorials 5–9"),
        ("  5. Flutter project structure", "lib/, pubspec, platforms"),
        ("  6. Dart basics", "Types, functions, classes, null safety"),
        ("  7. Widgets & layouts", "Material, Scaffold, forms"),
        ("  8. Stateful vs Stateless", "setState and when not to use it"),
        ("  9. Navigation with GoRouter", "Redirects, shells, path params"),
        ("Tier 3 — State management", "Tutorials 10–11"),
        ("  10. Riverpod basics", "Provider, Future, Stream, Notifier"),
        ("  11. Models & data classes", "fromJson, enums, why not Freezed here"),
        ("Tier 4 — Database & backend", "Tutorials 12–15"),
        ("  12. SQL basics", "SELECT through JOIN and aggregates"),
        ("  13. Supabase authentication", "Username → email RPC → JWT"),
        ("  14. Database queries from Flutter", "PostgREST, RPC, repositories"),
        ("  15. Row Level Security", "Policies, helpers, role matrix"),
        ("Tier 5 — Advanced platform", "Tutorials 16–20"),
        ("  16. File upload & Storage", "Buckets, paths, signed URLs"),
        ("  17. Realtime", "Chat and notification channels"),
        ("  18. Localization", "ARB EN/RU/UZ"),
        ("  19. Theming & dark mode", "Four styles × light/dark"),
        ("  20. Notifications (real system)", "Table + Realtime; FCM is future work"),
        ("Tier 6 — Complete features", "Tutorials 21–25"),
        ("  21. Authentication feature", "Splash → login → language → shell"),
        ("  22. Assignments feature", "Packs, tasks, submit, grade"),
        ("  23. Chat feature", "Rooms, media, reactions, unread"),
        ("  24. Attendance feature", "Sessions, statuses, reports"),
        ("  25. Announcements feature", "Group posts, attachments, notify"),
        ("Tier 7 — Going deep", "Tutorials 26–30"),
        ("  26. Custom widgets", "Shell, cards, bubbles, empty states"),
        ("  27. Testing", "Unit, widget, integration habits"),
        ("  28. Performance", "Cache, paging, image, query shape"),
        ("  29. Error handling", "AsyncValue, offline, user copy"),
        ("  30. Deployment", "APK, web, iOS, store hygiene"),
        ("Source atlas", "Every Dart file with purpose + full listing"),
        ("Annotated source", "Every interesting line explained"),
        ("SQL atlas + annotated SQL", "Functions and statement-by-statement"),
        ("Screen / provider / component manuals", "QA for every UI module"),
        ("30-day journal + oral exam", "Calendar and 50 spoken answers"),
        ("Every-line Dart commentary", "Non-trivial lines with a one-sentence why"),
        ("ARB key catalog", "EN / RU / UZ side by side"),
        ("RLS in English", "Every policy said as a sentence"),
        ("Appendix A — Complete backend SQL", "Run top to bottom on a new project"),
        ("Appendix B — Dependencies", "Every pubspec package explained"),
        ("Appendix C — Video index", "All links by topic"),
        ("Appendix D — Troubleshooting", "Errors you will actually hit"),
        ("Appendix E — Architecture diagrams", "Data, widgets, providers, schema"),
        ("Appendix F — Code style guide", "Names, files, comments"),
        ("Appendix G — Column catalog", "Every table, every column"),
        ("Appendix H — ARB catalogs", "EN / RU / UZ"),
        ("Appendix I — First admin bootstrap", "Create @admin safely"),
        ("Appendix J — Config files", "Makefile, l10n, manifests"),
        ("Appendix K — Glossary & quizzes", "Terms + extra practice"),
        ("Appendix L — Foundation essays", "HTTP, JSON, JWT, Git, Postgres types"),
    ]
    s.append(simple_table(styles, ["Section", "What you gain"], entries, [3.2 * inch, 3.3 * inch]))
    s.append(PageBreak())
    return s


def source_atlas(styles):
    s = [h1(styles, "Source atlas — every application Dart file")]
    s.append(
        p(
            styles,
            "This atlas is the reconstruction reference. For each file: why it exists, how to read it, "
            "the complete listing, and five questions you can answer without running the app. "
            "Generated localization files are omitted (run flutter gen-l10n instead).",
        )
    )
    files = dart_files()
    s.append(p(styles, f"File count in this atlas: <b>{len(files)}</b>."))
    s.append(PageBreak())

    for fp in files:
        rel = fp.relative_to(ROOT).as_posix()
        text = fp.read_text(encoding="utf-8")
        lines = text.count("\n") + (0 if text.endswith("\n") or not text else 1)
        imports = [ln.strip() for ln in text.splitlines() if ln.startswith("import ")]
        s.append(h2(styles, rel))
        s.append(p(styles, file_purpose(rel)))
        s.append(
            p(
                styles,
                f"Line count: {lines}. Import count: {len(imports)}. "
                "Read imports to learn dependencies, then scan for class / provider names, "
                "then read the first public method end-to-end.",
            )
        )
        if imports:
            shown = imports[:18]
            extra = len(imports) - len(shown)
            s.extend(bullets(styles, shown + ([f"… and {extra} more imports"] if extra else [])))
        s.append(
            callout(
                styles,
                "How to study this file",
                "1) Name the layer (screen / provider / model / widget / service).\n"
                "2) List the tables or RPCs it touches (search for .from( and .rpc().\n"
                "3) List the providers it watches or invalidates.\n"
                "4) Predict what breaks if this file is deleted.\n"
                "5) Only then read the listing below.",
            )
        )
        s.extend(code_chunks(styles, rel, text))
        s.append(h3(styles, "Comprehension"))
        s.extend(
            numbered(
                styles,
                [
                    f"What user role(s) can reach the behavior in {rel}?",
                    "Which database table or RPC would you inspect in Supabase to debug it?",
                    "Does it hold UI, state, or both? Why was that choice made?",
                    "What happens offline — cache, error, or empty?",
                    "Name one widget or provider that would break if this file’s public API changed.",
                ],
            )
        )
        s.append(PageBreak())
    return s


def sql_function_atlas(styles):
    s = [h1(styles, "SQL function atlas — every exported function")]
    s.append(
        p(
            styles,
            "Each file under docs/tutorial/export/fn_*.sql is a live function body recovered from "
            "the MU Study database. Read the name, then the LANGUAGE and SECURITY clause, then the body. "
            "SECURITY DEFINER functions run as the owner — they must check is_admin() or membership "
            "themselves because RLS on tables they touch may be bypassed.",
        )
    )
    files = sorted(EXPORT.glob("fn_*.sql"))
    for fp in files:
        body = fp.read_text(encoding="utf-8")
        s.append(h2(styles, fp.name))
        name = fp.stem.replace("fn_", "")
        s.append(
            p(
                styles,
                f"Function family: <b>{name}</b>. If the name starts with admin_, only an admin "
                "session should succeed. If it starts with trg_, it is a trigger helper. If it starts "
                "with is_ or can_, it is a boolean used inside RLS policies.",
            )
        )
        if "SECURITY DEFINER" in body:
            s.append(
                warn(
                    styles,
                    "SECURITY DEFINER",
                    "This function runs with the privileges of its owner. Confirm it checks "
                    "auth.uid() / is_admin() / membership before writing rows. Never expose a "
                    "definer that inserts into auth.users without an admin gate.",
                )
            )
        s.extend(code_chunks(styles, fp.name, body))
        s.append(
            checkpoint(
                styles,
                f"Explain {fp.name}",
                "In one sentence: who may call this, what table it writes or reads, and what "
                "exception it raises on unauthorized use. If you cannot answer, re-read the first "
                "20 lines of the body.",
            )
        )
        s.append(PageBreak())
    return s


def foundation_essays(styles):
    essays = [
        (
            "How a tap becomes a database row",
            [
                "A student taps Submit on a homework task. Flutter builds a gesture, the screen "
                "calls a Riverpod notifier, the notifier calls supabase.from('submissions').upsert(...). "
                "That HTTP request hits PostgREST on your Supabase project with the user’s JWT. "
                "Postgres checks RLS. If the student owns the student_id and belongs to the group, "
                "the row is written. A trigger may insert notifications for the teacher. Realtime "
                "notifies subscribed clients. The teacher’s submissions list rebuilds.",
                "If any layer lies — a forged student_id, a missing JWT, a policy that uses "
                "user_metadata — the system is unsafe. MU Study keeps authorization in Postgres "
                "helpers (is_admin, is_teacher_of_group, is_student_in_group) so the Flutter client "
                "is not the security boundary.",
                "Practice: pick one button in the running app and write this chain on paper: "
                "widget → provider → table/RPC → policy → trigger → UI refresh.",
            ],
        ),
        (
            "HTTP, JSON, and PostgREST",
            [
                "Supabase’s Data API is PostgREST: your table names become URL paths. "
                "GET /rest/v1/assignments?group_id=eq.<uuid> is what .from('assignments').select().eq('group_id', id) becomes. "
                "The Flutter SDK hides the HTTP, but you should still think in requests: method, "
                "headers (apikey, Authorization: Bearer <jwt>), and JSON body.",
                "JSON objects use snake_case column names from Postgres. Dart models convert to "
                "camelCase (full_name → fullName). If you forget the mapping, fromJson throws or "
                "shows empty names. That is a model bug, not a database bug.",
                "Errors arrive as PostgrestException with a message and often a Postgres code "
                "(42501 insufficient privilege for RLS denials that surface as empty results, "
                "23505 unique violation, 23503 foreign key).",
            ],
        ),
        (
            "JWT sessions without mysticism",
            [
                "After signInWithPassword, Supabase returns an access token (JWT) and a refresh token. "
                "The access token is a signed JSON object: subject (user id), expiry, role authenticated. "
                "Every .from() call sends that token. RLS reads auth.uid() from it.",
                "MU Study does not invent emails in the client. It asks get_auth_email_by_username "
                "for the synthetic address stored on profiles.auth_email. Disabled users get NULL, "
                "so login fails the same way as a wrong password — no account-enumeration toast.",
                "Deleting a user in the dashboard does not instantly kill an already-issued JWT. "
                "For school software, keep sessions reasonably short and disable profiles "
                "(is_disabled) so the RPC and policies stop the account even if a token still exists.",
            ],
        ),
        (
            "Postgres types used in MU Study",
            [
                "uuid — primary keys, generated with gen_random_uuid(). Never use serial integers "
                "for public IDs in this project; the live schema is UUID throughout.",
                "text — usernames, titles, bodies. Prefer text over varchar unless you have a length rule.",
                "timestamptz — created_at, due_date, submitted_at. Always timezone-aware.",
                "date — attendance.date, lesson_sessions.session_date, marks.marked_on.",
                "boolean — is_disabled, is_read, is_deleted, is_current, is_completed.",
                "numeric — marks.percentage (0–100), marks.weight (>0), submissions.score.",
                "jsonb — announcement image_urls/file_urls, assignment_templates.tasks.",
                "enums — user_role, sphere_type, assignment_type, attendance_status, "
                "submission_status, chat_message_type, mark_category. Changing an enum in production "
                "requires ALTER TYPE; plan names carefully.",
            ],
        ),
        (
            "Git hygiene for a school app",
            [
                ".env is gitignored. If you accidentally commit a key, rotate it in Supabase "
                "(Settings → API) and treat the old key as public.",
                "Do not commit service_role. Do not commit printed password PDFs from Admin → Credentials.",
                "Demo passwords such as password123 are for throwaway local projects only. "
                "The README says every account including @admin must get a real password before "
                "anyone outside the team can reach the instance.",
                "Prefer small commits that match a tutorial checkpoint: “add login RPC wiring”, "
                "not “stuff”.",
            ],
        ),
        (
            "Widget trees and rebuilds",
            [
                "Flutter rebuilds widgets when an ancestor setState or a watched provider changes. "
                "A ConsumerWidget that watches currentProfileProvider rebuilds when the profile "
                "Future completes. A StatelessWidget that only receives a Profile as a constructor "
                "argument rebuilds only when its parent rebuilds.",
                "MU Study uses themeAnimationDuration: Duration.zero so style switches do not "
                "animate through a muddy blend. That is a product choice, not a Flutter default.",
                "Heavy lists (chat, gradebook) should not rebuild the entire shell. Providers are "
                "scoped so a new message does not re-fetch academic years.",
            ],
        ),
        (
            "Security principles encoded in this repo",
            [
                "Authorization data lives in profiles.role and teachers/students tables, not in "
                "editable user_metadata. RLS and RPCs read those tables (or auth.uid()).",
                "Views that join sensitive rows must be treated carefully. chat_room_summaries "
                "is only safe if the underlying tables are RLS-protected and the view is not a "
                "security-definer leak. Prefer security_invoker views on modern Postgres.",
                "Storage paths encode roomId and profileId. Policies parse the object name. "
                "A client that uploads to someone else’s folder must 403.",
                "seed_demo_data and _demo_insert_user are development scaffolding. EXECUTE is "
                "revoked from anon and authenticated on a hardened project.",
            ],
        ),
        (
            "How teachers and groups actually work",
            [
                "Creating a teacher does not create Group 1/2/3. Admins type exact group titles "
                "under Admin → Groups. A unique index (teacher_id, title) prevents duplicate names "
                "for the same teacher.",
                "Inserting a group fires ensure_chat_room_for_group so a 1:1 chat_rooms row exists. "
                "Students appear in chat only after group_students membership.",
                "Teachers have a required sphere: math or english. The admin_create_user RPC "
                "raises 'Sphere required for teacher' if it is missing.",
            ],
        ),
        (
            "Homework packs versus static assignments",
            [
                "assignment_type is static or homework_pack. Static assignments are display-only "
                "in the student app (announcement-like work). Homework packs contain ordered tasks. "
                "Students open a pack, then a task, then submit text, file, and/or voice.",
                "One submission per (task_id, student_id). Teachers review in the submissions queue "
                "and may write score + feedback. A trigger can sync a mark row.",
                "Teachers can save assignment_templates as JSON drafts and reuse them.",
            ],
        ),
        (
            "Focus mode is local",
            [
                "Student Focus is a Pomodoro or free-count timer stored in SharedPreferences. "
                "There is no focus_sessions table. Chat badges can be muted during a session "
                "while notifications still arrive in the inbox table.",
                "This is a good example of not putting every UX idea in Postgres. If the phone "
                "is offline, focus still works.",
            ],
        ),
    ]
    s = [h1(styles, "Appendix L — Foundation essays")]
    s.append(
        p(
            styles,
            "These essays are slow explanations of ideas the tutorials assume. Read them when a "
            "tutorial feels like it skipped a year of computer science. They are written against "
            "MU Study, not a generic blog.",
        )
    )
    for title, paras in essays:
        s.append(h2(styles, title))
        for para in paras:
            s.append(p(styles, para))
        s.append(PageBreak())
    return s


def glossary(styles):
    terms = [
        ("anon / publishable key", "Public client key. Safe to ship in the app if RLS is correct. Still do not post it in a public gist with your project URL if you can avoid it."),
        ("service_role key", "Bypasses RLS. Server only. Never in Flutter."),
        ("auth.uid()", "UUID of the signed-in user inside Postgres."),
        ("auth_email", "Synthetic email on profiles, usually username@mustudy.internal."),
        ("RLS", "Row Level Security — per-row SQL predicates Postgres applies automatically."),
        ("SECURITY DEFINER", "Function runs as owner; must self-authorize."),
        ("PostgREST", "HTTP API generated from Postgres tables and RPCs."),
        ("RPC", "Remote Procedure Call — supabase.rpc('name', params)."),
        ("JWT", "Signed token proving a session."),
        ("ProviderScope", "Riverpod root widget in main.dart."),
        ("ConsumerWidget", "Widget that can watch Riverpod providers."),
        ("AsyncValue", "Riverpod loading / error / data triad."),
        ("ShellRoute", "go_router nest that keeps a navigation chrome while child routes change."),
        ("homework_pack", "Assignment type that contains tasks students submit."),
        ("static assignment", "Assignment type that is informational / display-only."),
        ("sphere", "Teacher subject: math or english."),
        ("lesson_session", "One group + one date; attendance rows hang off it."),
        ("chat_room_summaries", "View joining rooms, group title, last message, member_count."),
        ("ARB", "Application Resource Bundle — Flutter translation file."),
        ("AppStyle", "modern | naturePaper | softNeumorphism | monochromeWorkspace."),
        ("signed URL", "Time-limited Storage download link for a private object."),
        ("replica identity FULL", "Needed so Realtime UPDATE/DELETE payloads include old rows (reactions)."),
        ("is_disabled", "Soft-ban flag; login RPC hides the email."),
        ("preferred_language", "en, ru, or uz stored on profiles."),
        ("Focus", "Local study timer; not a database feature."),
    ]
    s = [h1(styles, "Appendix K — Glossary")]
    s.append(simple_table(styles, ["Term", "Meaning in MU Study"], [[a, b] for a, b in terms], [1.8 * inch, 4.7 * inch]))
    s.append(PageBreak())
    return s


def extra_quizzes(styles):
    bank = [
        ("Why does login call an RPC instead of concatenating username + '@mustudy.internal' in Dart?",
         "The RPC is the single source of truth, hides disabled users, and can change the email scheme without shipping a new app."),
        ("Why is profiles.id equal to auth.users.id?",
         "So auth.uid() in RLS matches the profile primary key with no extra join."),
        ("What unique constraint stops two groups named Algebra A for the same teacher?",
         "UNIQUE (teacher_id, title) / groups_teacher_title_uidx."),
        ("Why does member_count in chat_room_summaries add 1?",
         "It counts group_students plus the teacher."),
        ("Which bucket is public?",
         "avatars. Submissions, assignments, announcements, and chat-* are private."),
        ("Where is focus session state stored?",
         "SharedPreferences via focusSessionProvider — no SQL table."),
        ("Name three SECURITY DEFINER functions an admin uses.",
         "admin_create_user, admin_reset_password, admin_create_next_academic_year (and others in the atlas)."),
        ("What happens if a student queries marks for the whole table?",
         "RLS returns only rows they are allowed to see — typically their own."),
        ("Why themeAnimationDuration is Duration.zero?",
         "Instant theme/style switches without interpolating incompatible palettes."),
        ("How do chat uploads prove the uploader?",
         "Object path folder 2 must equal auth.uid(); storage policies enforce it."),
    ]
    s = [h1(styles, "Extra practice quizzes")]
    s.extend(quiz(styles, bank))
    # expand with table-driven questions
    for name, cols in TABLES.items():
        pk = next((c[0] for c in cols if "PK" in c[4]), cols[0][0])
        s.append(h3(styles, f"Table drill — {name}"))
        s.append(p(styles, f"Primary key column to remember: <b>{pk}</b>. Count of documented columns: {len(cols)}."))
        s.append(
            p(
                styles,
                "Write a SELECT that returns at most five rows from this table with the primary key "
                "and created_at if it exists. Then write the Flutter equivalent using .from().select().limit(5).",
            )
        )
        s.append(
            checkpoint(
                styles,
                f"{name} independence",
                f"In SQL Editor, run SELECT COUNT(*) FROM {name}; as a signed-in role you understand. "
                "If you are the anon role with no JWT, expect RLS to hide rows. That emptiness is success, not a broken table.",
            )
        )
    s.append(PageBreak())
    return s
