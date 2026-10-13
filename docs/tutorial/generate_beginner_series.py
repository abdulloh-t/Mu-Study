#!/usr/bin/env python3
"""Generate tutorials.pdf — 30-tutorial beginner-to-advanced MU Study series."""

from __future__ import annotations

import sys
from pathlib import Path

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import inch
from reportlab.platypus import PageBreak, SimpleDocTemplate

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(HERE))

from column_catalog import column_catalog  # noqa: E402
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
from pdf_styles import build_styles  # noqa: E402
from series_kit import (  # noqa: E402
    ASSETS,
    EXPORT,
    LIB,
    ROOT as KIT_ROOT,
    TEST,
    VIDEOS,
    code_chunks,
    extra_quizzes,
    foundation_essays,
    glossary,
    header_footer,
    how_to_use,
    source_atlas,
    sql_function_atlas,
    title_page,
    toc,
)
from series_expand import (  # noqa: E402
    annotated_source,
    arb_key_lessons,
    day_journal,
    every_line_book,
    generated_l10n_dump,
    interview_bank,
    provider_manual,
    rls_english,
    screen_manual,
    sql_line_lessons,
    widget_catalog,
)
from series_tutorials import all_tutorials  # noqa: E402

OUT = ROOT / "tutorials.pdf"

PACKAGES = [
    ("supabase_flutter", "^2.9.1", "Auth, PostgREST, Storage, Realtime client"),
    ("flutter_riverpod", "^2.6.1", "State: providers, notifiers, streams"),
    ("go_router", "^14.8.1", "Path routing + redirects"),
    ("freezed_annotation", "^2.4.4", "Available; models are hand-written today"),
    ("json_annotation", "^4.9.0", "Optional codegen annotations"),
    ("shared_preferences", "^2.5.3", "Theme, locale, focus, caches"),
    ("responsive_framework", "^1.5.1", "Breakpoints for phone vs rail"),
    ("flutter_animate", "^4.5.2", "Small motion on cards/emoji"),
    ("cached_network_image", "^3.4.1", "Avatar and media decode cache"),
    ("shimmer / skeletonizer", "^3 / ^2", "Loading placeholders"),
    ("file_picker / image_picker", "^8 / ^1", "Homework and chat attachments"),
    ("syncfusion_flutter_pdfviewer", "^30", "In-app PDF sheets"),
    ("syncfusion_flutter_charts", "^30", "Teacher/admin analytics"),
    ("syncfusion_flutter_pdf", "^30", "Credential slips + progress PDF"),
    ("intl", "^0.20.2", "Dates; used with l10n"),
    ("url_launcher", "^6.3.1", "Open assignment link_url"),
    ("google_fonts", "^6.2.1", "Typography for styles"),
    ("flutter_dotenv", "^5.2.1", "Load .env when dart-define absent"),
    ("record / audioplayers", "^6", "Voice notes and playback"),
    ("path_provider / path / cross_file", "Local temp files for recordings"),
    ("share_plus", "^11", "Share progress/credential PDFs"),
    ("video_player / get_thumbnail_video", "Chat video"),
    ("http / crypto", "Downloads and hashing helpers"),
    ("package_info_plus", "^9", "About / version on profile"),
    ("lottie / characters", "Animated emoji + grapheme safety"),
    ("flutter_cache_manager", "^3.4.2", "Custom cache stores for chat"),
    ("flutter_localizations / cupertino_icons", "SDK i18n + icons"),
    ("build_runner / freezed / json_serializable", "dev — optional codegen"),
    ("flutter_lints / flutter_test", "dev — analyze and tests"),
]


def appendix_backend(styles):
    s = [h1(styles, "Appendix A — Complete backend SQL")]
    s.append(
        p(
            styles,
            "Run this script in the SQL Editor on a brand-new Supabase project, top to bottom. "
            "It is the recovered live schema (enums, tables, views, functions, triggers, grants). "
            "After it succeeds, run Appendix I to create the first admin. Then apply RLS from "
            "export/rls_policies.sql if the complete file’s policy section is split.",
        )
    )
    sql_path = HERE / "COMPLETE_BACKEND.sql"
    if not sql_path.exists():
        sql_path = EXPORT / "COMPLETE_BACKEND.sql"
    s.extend(code_chunks(styles, "COMPLETE_BACKEND.sql", sql_path.read_text(encoding="utf-8")))
    s.append(PageBreak())
    rls = EXPORT / "rls_policies.sql"
    if rls.exists():
        s.append(h2(styles, "RLS policies (exact export)"))
        s.extend(code_chunks(styles, "rls_policies.sql", rls.read_text(encoding="utf-8")))
        s.append(PageBreak())
    return s


def appendix_deps(styles):
    s = [h1(styles, "Appendix B — All dependencies explained")]
    s.append(
        p(
            styles,
            "Versions are from pubspec.yaml at generation time. Run flutter pub get after edits. "
            "audioplayers_darwin is overridden to 6.3.0 for a platform resolution pin.",
        )
    )
    s.append(simple_table(styles, ["Package", "Version", "Why MU Study needs it"], PACKAGES, [2.1 * inch, 1.1 * inch, 3.3 * inch]))
    s.append(h2(styles, "What you do not depend on"))
    s.extend(
        bullets(
            styles,
            [
                "firebase_core / firebase_messaging — not used (Tutorial 20).",
                "provider / bloc — Riverpod only.",
                "auto_route — go_router only.",
            ],
        )
    )
    s.append(PageBreak())
    return s


def appendix_videos(styles):
    s = [h1(styles, "Appendix C — Video resources by topic")]
    rows = [[title, url] for title, url in VIDEOS.values()]
    s.append(simple_table(styles, ["Resource", "URL"], rows, [2.8 * inch, 3.7 * inch]))
    s.append(
        p(
            styles,
            "Videos teach the ecosystem. This book teaches MU Study. If a video shows email "
            "signup or Firebase, translate the idea; do not copy the architecture.",
        )
    )
    s.append(PageBreak())
    return s


def appendix_trouble(styles):
    s = [h1(styles, "Appendix D — Troubleshooting guide")]
    rows = [
        ["SetupRequiredScreen", "Key empty/sanitized", "Print Env after load; check eyJ/sb_publishable_", "Splash or login appears"],
        ["Login always incorrect", "RPC null, bad password, unconfirmed email", "SELECT auth_email, is_disabled; Auth settings confirm email", "Session exists"],
        ["Bounces to login after sign-in", "No profiles row", "SELECT * FROM profiles WHERE id = auth user id", "Profile loads"],
        ["Stuck on /boot", "Profile Future hanging", "Network + RLS on profiles_select", "Redirect to language or home"],
        ["Stuck on /language", "preferred_language null forever", "Update failed RLS profiles_update_self", "Column set; home opens"],
        ["Empty assignment list", "Wrong group or RLS", "group_students membership; teacher_id", "Rows appear"],
        ["Save mark does nothing", "UPDATE without SELECT policy", "Add marks SELECT for teacher", "Row percentage changes"],
        ["Storage 403", "Path folders / policy", "roomId and uid segments", "Upload 200"],
        ["Realtime silent", "Not in publication", "supabase_realtime tables", "Live insert shows"],
        ["Chat under nav bar", "extendBody / padding", "shellContentBottomPadding", "Timestamp visible"],
        ["gen-l10n fails", "Key missing in ru/uz", "Diff ARB keys", "flutter gen-l10n exits 0"],
        ["Nature Paper looks empty", "Assets not copied", "pubspec assets/images/nature-paper", "Backdrop paints"],
        ["Mic permission crash", "Manifest/plist", "RECORD_AUDIO + usage string", "Record starts"],
        ["Duplicate group title", "unique (teacher_id, title)", "Pick another title", "Insert succeeds"],
        ["Teacher create fails", "sphere null", "Pass math or english", "teachers row exists"],
        ["Student sees all marks", "RLS off or service_role in app", "Remove god key; enable RLS", "Only own rows"],
        ["Demo RPC callable", "EXECUTE granted to anon", "REVOKE from anon, authenticated", "Permission denied"],
    ]
    s.append(simple_table(styles, ["Symptom", "Likely why", "Diagnose", "Fixed when"], rows, [1.5 * inch, 1.6 * inch, 1.8 * inch, 1.6 * inch]))
    s.append(h2(styles, "FAQ"))
    s.append(p(styles, "<b>Can students register?</b> No. Admin creates accounts."))
    s.append(p(styles, "<b>Can I use Google login?</b> Not in this product. Username + password only."))
    s.append(p(styles, "<b>Where is Arabic?</b> Not shipped. Add a new ARB only as a new product decision."))
    s.append(p(styles, "<b>Where is FCM?</b> Not shipped. Inbox + Realtime is the notification system."))
    s.append(p(styles, "<b>Why @ in usernames?</b> Cosmetic. Email strips @ before @mustudy.internal."))
    s.append(PageBreak())
    return s


def appendix_arch(styles):
    s = [h1(styles, "Appendix E — Architecture diagrams")]
    s.append(h2(styles, "Data flow"))
    s.append(
        code_block(
            styles,
            "ascii",
            "Widget  →  Riverpod  →  supabase.from / rpc / storage / channel\n"
            "                         ↓\n"
            "                   JWT + anon key\n"
            "                         ↓\n"
            "              PostgREST / Auth / Storage / Realtime\n"
            "                         ↓\n"
            "              PostgreSQL RLS + triggers + views\n",
        )
    )
    s.append(h2(styles, "Widget hierarchy (role session)"))
    s.append(
        code_block(
            styles,
            "ascii",
            "MaterialApp.router\n"
            "  ResponsiveBreakpoints\n"
            "    NaturePaperBackdrop\n"
            "      SoftNeumorphismBackdrop\n"
            "        ShellRoute (AppShell + nav)\n"
            "          Feature screen (dashboard, chat, …)\n"
            "            Components (cards, lists)\n",
        )
    )
    s.append(h2(styles, "Provider dependencies (core)"))
    s.append(
        code_block(
            styles,
            "ascii",
            "authStateProvider --> currentProfileProvider --> teacherProfileProvider\n"
            "                   --> currentProfileProvider --> studentProfileProvider\n"
            "                   --> routerProvider (refreshListenable)\n"
            "currentProfileProvider --> locale/theme applyFromProfile\n"
            "myGroupsProvider --> activeGroupId --> assignments / attendance / announcements\n"
            "chatRoomsProvider --> unreadChatCountProvider (shell badge)\n"
            "notificationsProvider --> unreadNotificationsCountProvider\n",
        )
    )
    s.append(h2(styles, "Database relationship sketch"))
    s.append(
        code_block(
            styles,
            "ascii",
            "auth.users 1──1 profiles 1──0..1 teachers 1──* groups 1──1 chat_rooms\n"
            "                 └─0..1 students *──* groups (group_students)\n"
            "groups 1──* assignments 1──* tasks 1──* submissions\n"
            "groups 1──* lesson_sessions 1──* attendance\n"
            "groups 1──* marks  (optional submissions.submission_id)\n"
            "groups 1──* announcements     profiles 1──* notifications\n"
            "chat_rooms 1──* chat_messages 1──* reads/reactions\n"
            "academic_years 1──* academic_terms\n",
        )
    )
    s.append(PageBreak())
    return s


def appendix_style(styles):
    s = [h1(styles, "Appendix F — Code style guide")]
    s.append(h2(styles, "Naming"))
    s.extend(
        bullets(
            styles,
            [
                "Files: snake_case.dart matching the main type (login_screen.dart).",
                "Widgets: PascalCase, private State with leading underscore.",
                "Providers: camelCase + Provider suffix (currentProfileProvider).",
                "JSON keys: snake_case matching Postgres.",
                "RPCs: snake_case matching SQL (get_auth_email_by_username).",
            ],
        )
    )
    s.append(h2(styles, "File organization"))
    s.extend(
        bullets(
            styles,
            [
                "Screens do not embed raw SQL strings; they call providers.",
                "Providers do not build widgets.",
                "Models do not import Flutter.",
                "Shared chat/profile live outside role folders.",
            ],
        )
    )
    s.append(h2(styles, "Comments"))
    s.append(
        p(
            styles,
            "Comment why, not what. The router’s note about /boot and semantics.parentDataDirty "
            "is the right kind of comment. Do not comment // increment counter.",
        )
    )
    s.append(h2(styles, "Best practices in this repo"))
    s.extend(
        numbered(
            styles,
            [
                "maybeSingle when zero rows are valid.",
                "if (!mounted) return after await in State.",
                "l10n for every user-visible string.",
                "Dispose channels and controllers.",
                "Never log passwords or full JWTs.",
            ],
        )
    )
    s.append(PageBreak())
    return s


def appendix_arb(styles):
    s = [h1(styles, "Appendix H — ARB localization catalogs")]
    for name in ("app_en.arb", "app_ru.arb", "app_uz.arb"):
        fp = LIB / "l10n" / name
        if fp.exists():
            s.append(h2(styles, name))
            s.extend(code_chunks(styles, f"lib/l10n/{name}", fp.read_text(encoding="utf-8")))
            s.append(PageBreak())
    return s


def appendix_admin(styles):
    s = [h1(styles, "Appendix I — Bootstrapping the first admin")]
    s.append(
        warn(
            styles,
            "Replace the password",
            "The script uses YOUR_STRONG_PASSWORD as a placeholder. Never leave password123 on "
            "a reachable project.",
        )
    )
    fp = EXPORT / "first_admin_bootstrap.sql"
    if fp.exists():
        s.extend(code_chunks(styles, "first_admin_bootstrap.sql", fp.read_text(encoding="utf-8")))
    for name in ("optional_login_credentials.sql", "optional_fix_admin_create_user.sql"):
        f = EXPORT / name
        if f.exists():
            s.append(h2(styles, name))
            s.extend(code_chunks(styles, name, f.read_text(encoding="utf-8")))
    s.append(
        checkpoint(
            styles,
            "Admin exists",
            "SELECT username, role, auth_email FROM profiles WHERE role = 'admin'; "
            "Then log in from the app.",
        )
    )
    s.append(PageBreak())
    return s


def appendix_config(styles):
    s = [h1(styles, "Appendix J — Config files")]
    for rel in [
        "pubspec.yaml",
        "l10n.yaml",
        "Makefile",
        "analysis_options.yaml",
        "android/app/src/main/AndroidManifest.xml",
        "ios/Runner/Info.plist",
    ]:
        fp = ROOT / rel
        if fp.exists():
            s.append(h2(styles, rel))
            s.extend(code_chunks(styles, rel, fp.read_text(encoding="utf-8")))
    s.append(PageBreak())
    if TEST.exists():
        s.append(h2(styles, "Repository tests"))
        for fp in sorted(TEST.glob("*.dart")):
            rel = fp.relative_to(ROOT).as_posix()
            s.extend(code_chunks(styles, rel, fp.read_text(encoding="utf-8")))
    s.append(PageBreak())
    return s


def appendix_assets(styles):
    s = [h1(styles, "Asset inventory")]
    s.append(
        p(
            styles,
            "Binary images and Lottie files cannot be reconstructed from text. Copy assets/ from "
            "the original tree for visual fidelity. Logic runs without them (Material fallbacks).",
        )
    )
    rows = []
    if ASSETS.exists():
        for fp in sorted(ASSETS.rglob("*")):
            if not fp.is_file() or fp.name in {".DS_Store", ".gitkeep"}:
                continue
            rel = fp.relative_to(ROOT).as_posix()
            kind = "Lottie" if "lottie" in rel else "Image"
            rows.append([rel, kind])
    for i in range(0, len(rows), 40):
        s.append(simple_table(styles, ["Path", "Kind"], rows[i : i + 40], [5.2 * inch, 1.3 * inch]))
    s.append(PageBreak())
    return s


def build():
    styles = build_styles()
    story = []
    story += title_page(styles)
    story += how_to_use(styles)
    story += toc(styles)
    print("Tutorials 1–30…")
    story += all_tutorials(styles)
    print("Source atlas…")
    story += source_atlas(styles)
    print("Annotated source…")
    story += annotated_source(styles)
    print("SQL function atlas…")
    story += sql_function_atlas(styles)
    print("Annotated SQL…")
    story += sql_line_lessons(styles)
    print("Screen / provider / component manuals…")
    story += screen_manual(styles)
    story += provider_manual(styles)
    story += widget_catalog(styles)
    print("Every-line Dart commentary…")
    story += every_line_book(styles)
    print("ARB keys + RLS English…")
    story += arb_key_lessons(styles)
    story += rls_english(styles)
    print("Journal, oral exam, generated l10n…")
    story += day_journal(styles)
    story += interview_bank(styles)
    story += generated_l10n_dump(styles)
    print("Appendices…")
    story += appendix_backend(styles)
    story += appendix_deps(styles)
    story += appendix_videos(styles)
    story += appendix_trouble(styles)
    story += appendix_arch(styles)
    story += appendix_style(styles)
    story += column_catalog(styles)
    story += appendix_arb(styles)
    story += appendix_admin(styles)
    story += appendix_config(styles)
    story += appendix_assets(styles)
    story += glossary(styles)
    story += extra_quizzes(styles)
    story += foundation_essays(styles)

    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=A4,
        leftMargin=0.7 * inch,
        rightMargin=0.7 * inch,
        topMargin=0.7 * inch,
        bottomMargin=0.65 * inch,
        title="MU Study — Complete Tutorial Series",
        author="MU Study Tutorial Generator",
    )
    print(f"Building PDF ({len(story)} flowables)…")
    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
    print(f"Wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    build()
