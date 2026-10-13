"""Appendix M — full column catalog for every public table."""

from reportlab.lib.units import inch
from reportlab.platypus import PageBreak

from pdf_helpers import bullets, h1, h2, p, simple_table, task


TABLES = {
    "academic_terms": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("academic_year_id", "uuid", "NO", "—", "FK → academic_years.id CASCADE"),
        ("semester", "int4", "NO", "—", "1–4"),
        ("starts_on", "date", "NO", "—", ""),
        ("ends_on", "date", "NO", "—", ""),
    ],
    "academic_years": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("start_year", "int4", "NO", "—", "UNIQUE"),
        ("label", "text", "NO", "—", ""),
        ("is_current", "bool", "NO", "false", "partial unique one current"),
        ("created_at", "timestamptz", "NO", "now()", ""),
        ("created_by", "uuid", "YES", "—", ""),
    ],
    "announcements": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("teacher_id", "uuid", "YES", "—", "FK teachers CASCADE; null for admin"),
        ("group_id", "uuid", "NO", "—", "FK groups CASCADE"),
        ("title", "text", "NO", "—", ""),
        ("description", "text", "NO", "''", ""),
        ("image_urls", "jsonb", "NO", "[]", ""),
        ("file_urls", "jsonb", "NO", "[]", ""),
        ("created_at", "timestamptz", "NO", "now()", ""),
    ],
    "assignment_templates": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("teacher_id", "uuid", "NO", "—", "FK teachers CASCADE"),
        ("type", "assignment_type", "NO", "static", ""),
        ("title", "text", "NO", "—", ""),
        ("description", "text", "NO", "''", ""),
        ("tasks", "jsonb", "NO", "[]", "task drafts"),
        ("created_at", "timestamptz", "NO", "now()", ""),
        ("updated_at", "timestamptz", "NO", "now()", ""),
    ],
    "assignments": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("teacher_id", "uuid", "NO", "—", "FK teachers CASCADE"),
        ("group_id", "uuid", "NO", "—", "FK groups CASCADE"),
        ("type", "assignment_type", "NO", "static", "static|homework_pack"),
        ("title", "text", "NO", "—", ""),
        ("description", "text", "NO", "''", ""),
        ("due_date", "timestamptz", "YES", "—", ""),
        ("created_at", "timestamptz", "NO", "now()", ""),
    ],
    "attendance": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("group_id", "uuid", "NO", "—", "FK groups CASCADE"),
        ("student_id", "uuid", "NO", "—", "FK students CASCADE"),
        ("status", "attendance_status", "NO", "—", ""),
        ("date", "date", "NO", "—", "UNIQUE with group+student"),
        ("created_at", "timestamptz", "NO", "now()", ""),
        ("session_id", "uuid", "NO", "—", "FK lesson_sessions CASCADE"),
    ],
    "chat_messages": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("room_id", "uuid", "NO", "—", "FK chat_rooms CASCADE"),
        ("sender_id", "uuid", "NO", "—", "FK profiles CASCADE"),
        ("message_type", "chat_message_type", "NO", "text", ""),
        ("text_content", "text", "YES", "—", ""),
        ("media_url", "text", "YES", "—", "signed URL"),
        ("created_at", "timestamptz", "NO", "now()", ""),
        ("updated_at", "timestamptz", "NO", "now()", ""),
        ("is_deleted", "bool", "NO", "false", "soft delete"),
        ("reply_to_message_id", "uuid", "YES", "—", "FK self SET NULL"),
    ],
    "chat_rooms": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("group_id", "uuid", "NO", "—", "UNIQUE FK groups CASCADE"),
        ("created_at", "timestamptz", "NO", "now()", ""),
    ],
    "group_students": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("group_id", "uuid", "NO", "—", "FK groups CASCADE"),
        ("student_id", "uuid", "NO", "—", "FK students CASCADE"),
        ("created_at", "timestamptz", "NO", "now()", ""),
    ],
    "groups": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("teacher_id", "uuid", "NO", "—", "FK teachers CASCADE"),
        ("title", "text", "NO", "—", "UNIQUE with teacher_id"),
        ("created_at", "timestamptz", "NO", "now()", ""),
    ],
    "lesson_sessions": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("group_id", "uuid", "NO", "—", "FK groups CASCADE"),
        ("session_date", "date", "NO", "—", "UNIQUE with group_id"),
        ("created_at", "timestamptz", "NO", "now()", ""),
    ],
    "marks": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("group_id", "uuid", "NO", "—", "FK groups CASCADE"),
        ("student_id", "uuid", "NO", "—", "FK students CASCADE"),
        ("teacher_id", "uuid", "NO", "—", "FK teachers CASCADE"),
        ("submission_id", "uuid", "YES", "—", "UNIQUE FK submissions CASCADE"),
        ("title", "text", "NO", "—", ""),
        ("category", "mark_category", "NO", "other", ""),
        ("percentage", "numeric", "NO", "—", ""),
        ("weight", "numeric", "NO", "1", ""),
        ("comment", "text", "NO", "''", ""),
        ("marked_on", "date", "NO", "CURRENT_DATE", ""),
        ("created_at", "timestamptz", "NO", "now()", ""),
        ("updated_at", "timestamptz", "NO", "now()", ""),
    ],
    "message_reactions": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("message_id", "uuid", "NO", "—", "FK chat_messages CASCADE"),
        ("user_id", "uuid", "NO", "—", "FK profiles CASCADE"),
        ("emoji", "text", "NO", "—", ""),
        ("created_at", "timestamptz", "NO", "now()", ""),
    ],
    "message_reads": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("message_id", "uuid", "NO", "—", "FK chat_messages CASCADE"),
        ("user_id", "uuid", "NO", "—", "FK profiles CASCADE"),
        ("read_at", "timestamptz", "NO", "now()", ""),
    ],
    "notifications": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("user_id", "uuid", "NO", "—", "FK profiles CASCADE"),
        ("title", "text", "NO", "—", ""),
        ("body", "text", "NO", "''", ""),
        ("is_read", "bool", "NO", "false", ""),
        ("created_at", "timestamptz", "NO", "now()", ""),
        ("kind", "text", "NO", "system", ""),
        ("action_path", "text", "YES", "—", "deep link"),
        ("ref_id", "uuid", "YES", "—", ""),
    ],
    "profiles": [
        ("id", "uuid", "NO", "—", "PK = auth.users.id"),
        ("username", "text", "NO", "—", "UNIQUE"),
        ("full_name", "text", "NO", "''", ""),
        ("role", "user_role", "NO", "—", ""),
        ("auth_email", "text", "NO", "—", "UNIQUE synthetic"),
        ("avatar_url", "text", "YES", "—", ""),
        ("is_disabled", "bool", "NO", "false", ""),
        ("created_at", "timestamptz", "NO", "now()", ""),
        ("preferred_language", "text", "YES", "—", "en|ru|uz"),
        ("preferred_theme", "text", "YES", "—", "light|dark|system"),
        ("preferred_style", "text", "YES", "—", "AppStyle name"),
    ],
    "students": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("profile_id", "uuid", "NO", "—", "UNIQUE FK profiles CASCADE"),
        ("created_at", "timestamptz", "NO", "now()", ""),
    ],
    "submissions": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("task_id", "uuid", "NO", "—", "FK tasks CASCADE"),
        ("student_id", "uuid", "NO", "—", "FK students CASCADE"),
        ("text_answer", "text", "YES", "—", ""),
        ("file_url", "text", "YES", "—", ""),
        ("status", "submission_status", "NO", "pending", ""),
        ("score", "numeric", "YES", "—", ""),
        ("feedback", "text", "YES", "—", ""),
        ("is_completed", "bool", "NO", "false", ""),
        ("submitted_at", "timestamptz", "YES", "—", ""),
        ("voice_url", "text", "YES", "—", ""),
    ],
    "tasks": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("assignment_id", "uuid", "NO", "—", "FK assignments CASCADE"),
        ("title", "text", "NO", "—", ""),
        ("description", "text", "NO", "''", ""),
        ("attachment_url", "text", "YES", "—", ""),
        ("link_url", "text", "YES", "—", ""),
        ("sort_order", "int4", "NO", "0", ""),
        ("created_at", "timestamptz", "NO", "now()", ""),
    ],
    "teachers": [
        ("id", "uuid", "NO", "gen_random_uuid()", "PK"),
        ("profile_id", "uuid", "NO", "—", "UNIQUE FK profiles CASCADE"),
        ("sphere", "sphere_type", "NO", "—", "math|english"),
        ("created_at", "timestamptz", "NO", "now()", ""),
    ],
}


def column_catalog(styles):
    s = [h1(styles, "Appendix M — Full Column Catalog (Every Table)")]
    s.append(
        p(
            styles,
            "Inspected from information_schema on the live MU Study Supabase database. "
            "Recreate every column with these nullability and default rules.",
        )
    )
    for name, cols in TABLES.items():
        s.append(h2(styles, f"Table public.{name}"))
        rows = [[c[0], c[1], c[2], c[3], c[4]] for c in cols]
        s.append(
            simple_table(
                styles,
                ["Column", "Type", "Null", "Default", "Notes"],
                rows,
                [1.5 * inch, 1.3 * inch, 0.6 * inch, 1.4 * inch, 1.7 * inch],
            )
        )
    s.append(h2(styles, "Views (not base tables)"))
    s.extend(
        bullets(
            styles,
            [
                "chat_room_summaries — see Appendix C",
                "student_mark_averages — student_id, average_percent, marks_count, last_marked_on",
                "student_group_mark_averages — + group_id",
            ],
        )
    )
    s.append(
        task(
            styles,
            "Column audit",
            "After creating tables, run the Chapter 34 column query and diff against this appendix. "
            "Any missing column is a defect.",
        )
    )
    s.append(PageBreak())
    return s
