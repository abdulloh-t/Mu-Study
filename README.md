# MU Study

School Management & Study Platform for **Math** and **English** teachers, built with **Flutter** and **Supabase**.

## Platforms

Android, iOS, and Web (responsive: bottom navigation on phones, navigation rail on tablet/web widths). Desktop-only permanent sidebar is intentionally omitted.

## Features

- Username + password login (no public registration; admins create accounts)
- Roles: Student, Teacher (Math/English), Admin
- Assignments (static + homework packs), submissions, attendance, announcements
- Realtime notifications (Supabase Realtime)
- Offline cache (SharedPreferences) for profile, assignments, notifications, dashboard
- Material 3 premium theme (chocolate / sand palette)

## Setup

### 1. Supabase project

Project URL (already configured as default): `https://nmmdvdprczukaskxxdrs.supabase.co`

Apply database schema:

```bash
# Option A: Supabase MCP — run apply_migration `initial_schema` from supabase/migrations/
# Option B: Paste and run supabase/seed_full.sql in the SQL editor
```

Copy your **anon/publishable key** into `.env`:

```bash
cp .env.example .env
# edit SUPABASE_ANON_KEY
```

### 2. Flutter

```bash
flutter pub get
flutter run --dart-define-from-file=.env
```

Web:

```bash
flutter run -d chrome --dart-define-from-file=.env
```

## Accounts

There is no public registration. An admin creates every account from
**Admin → Users**, which calls the `admin_create_user` RPC.

All six accounts on the current development project share the password
`password123`. That is a throwaway convenience for local testing and every one
of these accounts — including `@admin` — must be given a real password before
anyone outside the team can reach the instance.

`seed_demo_data()` and `_demo_insert_user()` are development-only scaffolding
and their `EXECUTE` grants are revoked from `anon` and `authenticated`. Do not
re-run them against a project that real users can reach.

> Users cannot change their own password yet; an admin has to reset it. Building
> password self-service is the next security task — see `AGENT_HANDOFF.md`.

## Project structure

```
lib/
  core/          constants, theme, services, utils
  models/
  screens/       auth, student, teacher, admin
  components/
  providers/
  routes/
  supabase/
```

## Notes

- Teachers do **not** get auto groups. Admins create exact group titles from **Admin → Groups**.
- Homework packs open task detail; static assignments are display-only.
- Configure Syncfusion license for production if required by their terms.
# Mu-Study
