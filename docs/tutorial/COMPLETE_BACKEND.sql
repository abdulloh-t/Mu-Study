
-- ============================================================
-- MU Study — Complete Backend Rebuild Script
-- Source: live Supabase project nmmdvdprczukaskxxdrs (EXACT)
-- Run in SQL Editor on a brand-new project, top to bottom.
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- ---------- ENUMS ----------
CREATE TYPE public.user_role AS ENUM ('student', 'teacher', 'admin');
CREATE TYPE public.sphere_type AS ENUM ('math', 'english');
CREATE TYPE public.assignment_type AS ENUM ('static', 'homework_pack');
CREATE TYPE public.attendance_status AS ENUM ('present', 'absent', 'late', 'excused');
CREATE TYPE public.submission_status AS ENUM ('pending', 'submitted', 'reviewed');
CREATE TYPE public.chat_message_type AS ENUM ('text', 'voice', 'image', 'video', 'file');
CREATE TYPE public.mark_category AS ENUM (
  'homework', 'classwork', 'quiz', 'test', 'exam', 'project', 'oral', 'other'
);

-- ---------- TABLES ----------
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL DEFAULT '',
  role public.user_role NOT NULL,
  auth_email TEXT NOT NULL UNIQUE,
  avatar_url TEXT,
  is_disabled BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  preferred_language TEXT,
  preferred_theme TEXT,
  preferred_style TEXT,
  CONSTRAINT profiles_preferred_language_check CHECK (
    preferred_language IS NULL OR preferred_language = ANY (ARRAY['en'::text, 'ru'::text, 'uz'::text])
  ),
  CONSTRAINT profiles_preferred_theme_check CHECK (
    preferred_theme IS NULL OR preferred_theme = ANY (ARRAY['light'::text, 'dark'::text, 'system'::text])
  ),
  CONSTRAINT profiles_preferred_style_check CHECK (
    preferred_style IS NULL OR preferred_style = ANY (ARRAY['modern'::text, 'naturePaper'::text, 'softNeumorphism'::text, 'monochromeWorkspace'::text])
  )
);
CREATE INDEX idx_profiles_username ON public.profiles USING btree (username);

CREATE TABLE public.teachers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  sphere public.sphere_type NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX groups_teacher_title_uidx ON public.groups USING btree (teacher_id, title);
CREATE INDEX idx_groups_teacher ON public.groups USING btree (teacher_id);

CREATE TABLE public.group_students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (group_id, student_id)
);

CREATE TABLE public.assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  type public.assignment_type NOT NULL DEFAULT 'static',
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  due_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_assignments_group ON public.assignments USING btree (group_id);

CREATE TABLE public.tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES public.assignments(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  attachment_url TEXT,
  link_url TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  text_answer TEXT,
  file_url TEXT,
  status public.submission_status NOT NULL DEFAULT 'pending',
  score NUMERIC,
  feedback TEXT,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  submitted_at TIMESTAMPTZ,
  voice_url TEXT,
  UNIQUE (task_id, student_id),
  CONSTRAINT submissions_score_percent_check CHECK (
    score IS NULL OR (score >= 0 AND score <= 100)
  )
);

CREATE TABLE public.lesson_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  session_date DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (group_id, session_date)
);
CREATE INDEX idx_lesson_sessions_group_date ON public.lesson_sessions USING btree (group_id, session_date DESC);

CREATE TABLE public.attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  status public.attendance_status NOT NULL,
  date DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  session_id UUID NOT NULL REFERENCES public.lesson_sessions(id) ON DELETE CASCADE,
  UNIQUE (group_id, student_id, date),
  UNIQUE (session_id, student_id)
);

CREATE TABLE public.marks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  submission_id UUID UNIQUE REFERENCES public.submissions(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  category public.mark_category NOT NULL DEFAULT 'other',
  percentage NUMERIC NOT NULL,
  weight NUMERIC NOT NULL DEFAULT 1,
  comment TEXT NOT NULL DEFAULT '',
  marked_on DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT marks_percentage_check CHECK (percentage >= 0 AND percentage <= 100),
  CONSTRAINT marks_weight_check CHECK (weight > 0)
);
CREATE INDEX idx_marks_group ON public.marks USING btree (group_id, marked_on DESC);
CREATE INDEX idx_marks_student ON public.marks USING btree (student_id, marked_on DESC);

CREATE TABLE public.announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID REFERENCES public.teachers(id) ON DELETE CASCADE,
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  image_urls JSONB NOT NULL DEFAULT '[]'::jsonb,
  file_urls JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  kind TEXT NOT NULL DEFAULT 'system',
  action_path TEXT,
  ref_id UUID
);
CREATE INDEX idx_notifications_user ON public.notifications USING btree (user_id, is_read, created_at DESC);
CREATE INDEX idx_notifications_user_kind_unread ON public.notifications USING btree (user_id, kind, is_read) WHERE (is_read = false);

CREATE TABLE public.assignment_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  type public.assignment_type NOT NULL DEFAULT 'static',
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  tasks JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX assignment_templates_teacher_idx ON public.assignment_templates USING btree (teacher_id, updated_at DESC);

CREATE TABLE public.academic_years (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  start_year INTEGER NOT NULL UNIQUE,
  label TEXT NOT NULL,
  is_current BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  CONSTRAINT academic_years_start_year_check CHECK (start_year >= 2000 AND start_year <= 2100)
);
CREATE UNIQUE INDEX academic_years_one_current ON public.academic_years USING btree ((true)) WHERE is_current;

CREATE TABLE public.academic_terms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  academic_year_id UUID NOT NULL REFERENCES public.academic_years(id) ON DELETE CASCADE,
  semester INTEGER NOT NULL,
  starts_on DATE NOT NULL,
  ends_on DATE NOT NULL,
  UNIQUE (academic_year_id, semester),
  CONSTRAINT academic_terms_semester_check CHECK (semester >= 1 AND semester <= 4),
  CONSTRAINT academic_terms_range_check CHECK (ends_on >= starts_on)
);
CREATE INDEX idx_academic_terms_dates ON public.academic_terms USING btree (starts_on, ends_on);
CREATE INDEX idx_academic_terms_year ON public.academic_terms USING btree (academic_year_id);

CREATE TABLE public.chat_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL UNIQUE REFERENCES public.groups(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_chat_rooms_group ON public.chat_rooms USING btree (group_id);

CREATE TABLE public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  message_type public.chat_message_type NOT NULL DEFAULT 'text',
  text_content TEXT,
  media_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  reply_to_message_id UUID REFERENCES public.chat_messages(id) ON DELETE SET NULL,
  CONSTRAINT chat_messages_content_check CHECK (
    is_deleted OR (
      ((message_type = 'text'::chat_message_type) AND (text_content IS NOT NULL) AND (length(TRIM(BOTH FROM text_content)) > 0))
      OR ((message_type <> 'text'::chat_message_type) AND (media_url IS NOT NULL) AND (length(TRIM(BOTH FROM media_url)) > 0))
    )
  )
);
CREATE INDEX idx_chat_messages_room_created ON public.chat_messages USING btree (room_id, created_at DESC);
CREATE INDEX idx_chat_messages_sender ON public.chat_messages USING btree (sender_id);
CREATE INDEX idx_chat_messages_reply_to ON public.chat_messages USING btree (reply_to_message_id) WHERE (reply_to_message_id IS NOT NULL);

CREATE TABLE public.message_reads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES public.chat_messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  read_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (message_id, user_id)
);
CREATE INDEX idx_message_reads_user ON public.message_reads USING btree (user_id, message_id);

CREATE TABLE public.message_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES public.chat_messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  emoji TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (message_id, user_id),
  CONSTRAINT message_reactions_emoji_len CHECK (char_length(emoji) >= 1 AND char_length(emoji) <= 16)
);
CREATE INDEX idx_message_reactions_message ON public.message_reactions USING btree (message_id);
ALTER TABLE public.message_reactions REPLICA IDENTITY FULL;


-- ---------- VIEWS ----------
CREATE OR REPLACE VIEW public.chat_room_summaries AS
 SELECT cr.id,
    cr.group_id,
    cr.created_at,
    g.title AS group_title,
    tp.full_name AS teacher_name,
    (( SELECT (count(*))::integer AS count
           FROM group_students gs
          WHERE (gs.group_id = g.id)) + 1) AS member_count,
    lm.id AS last_message_id,
    lm.message_type AS last_message_type,
    lm.text_content AS last_message_text,
    lm.media_url AS last_message_media_url,
    lm.created_at AS last_message_at,
    lm.is_deleted AS last_message_deleted,
    lm.sender_id AS last_message_sender_id,
    sp.full_name AS last_message_sender_name
   FROM (((((chat_rooms cr
     JOIN groups g ON ((g.id = cr.group_id)))
     JOIN teachers t ON ((t.id = g.teacher_id)))
     JOIN profiles tp ON ((tp.id = t.profile_id)))
     LEFT JOIN LATERAL ( SELECT m.id,
            m.room_id,
            m.sender_id,
            m.message_type,
            m.text_content,
            m.media_url,
            m.created_at,
            m.updated_at,
            m.is_deleted
           FROM chat_messages m
          WHERE (m.room_id = cr.id)
          ORDER BY m.created_at DESC
         LIMIT 1) lm ON (true))
     LEFT JOIN profiles sp ON ((sp.id = lm.sender_id)));

CREATE OR REPLACE VIEW public.student_mark_averages AS
 SELECT student_id,
    round((sum((percentage * weight)) / NULLIF(sum(weight), (0)::numeric)), 2) AS average_percent,
    (count(*))::integer AS marks_count,
    max(marked_on) AS last_marked_on
   FROM marks
  GROUP BY student_id;

CREATE OR REPLACE VIEW public.student_group_mark_averages AS
 SELECT student_id,
    group_id,
    round((sum((percentage * weight)) / NULLIF(sum(weight), (0)::numeric)), 2) AS average_percent,
    (count(*))::integer AS marks_count,
    max(marked_on) AS last_marked_on
   FROM marks
  GROUP BY student_id, group_id;

-- FILE: fn__demo_insert_user.sql
CREATE OR REPLACE FUNCTION public._demo_insert_user(p_username text, p_password text, p_full_name text, p_role user_role)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth', 'extensions'
AS $function$
DECLARE v_user_id UUID := gen_random_uuid(); v_email TEXT;
BEGIN
  v_email := lower(trim(replace(p_username, '@', ''))) || '@mustudy.internal';
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change,
    is_sso_user, is_anonymous
  ) VALUES (
    '00000000-0000-0000-0000-000000000000', v_user_id, 'authenticated', 'authenticated',
    v_email, extensions.crypt(p_password, extensions.gen_salt('bf')), NOW(),
    jsonb_build_object('provider','email','providers',ARRAY['email']),
    jsonb_build_object('username', p_username, 'full_name', p_full_name, 'role', p_role::text),
    NOW(), NOW(), '', '', '', '', false, false
  );
  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
  VALUES (
    gen_random_uuid(), v_user_id,
    jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true),
    'email', v_email, NOW(), NOW(), NOW()
  );
  INSERT INTO public.profiles (id, username, full_name, role, auth_email)
  VALUES (v_user_id, trim(p_username), p_full_name, p_role, v_email);
  IF p_role = 'student' THEN INSERT INTO public.students (profile_id) VALUES (v_user_id); END IF;
  RETURN v_user_id;
END; $function$

-- FILE: fn_academic_semester_bounds.sql
CREATE OR REPLACE FUNCTION public.academic_semester_bounds(p_start_year integer, p_semester integer)
 RETURNS TABLE(starts_on date, ends_on date)
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
  IF p_semester < 1 OR p_semester > 4 THEN
    RAISE EXCEPTION 'semester must be 1–4';
  END IF;

  RETURN QUERY
  SELECT
    CASE p_semester
      WHEN 1 THEN make_date(p_start_year, 8, 1)
      WHEN 2 THEN make_date(p_start_year, 11, 11)
      WHEN 3 THEN make_date(p_start_year + 1, 1, 11)
      ELSE make_date(p_start_year + 1, 3, 28)
    END,
    CASE p_semester
      WHEN 1 THEN make_date(p_start_year, 11, 2)
      WHEN 2 THEN make_date(p_start_year, 12, 28)
      WHEN 3 THEN make_date(p_start_year + 1, 3, 20)
      ELSE make_date(p_start_year + 1, 6, 19)
    END;
END;
$function$

-- FILE: fn_academic_year_label.sql
CREATE OR REPLACE FUNCTION public.academic_year_label(p_start_year integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  SELECT p_start_year::TEXT || '–' || lpad(((p_start_year + 1) % 100)::TEXT, 2, '0');
$function$

-- FILE: fn_admin_create_next_academic_year.sql
CREATE OR REPLACE FUNCTION public.admin_create_next_academic_year()
 RETURNS academic_years
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_next INT;
  v_now DATE := CURRENT_DATE;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only admins can create academic years';
  END IF;

  SELECT COALESCE(MAX(start_year), CASE
    WHEN EXTRACT(MONTH FROM v_now) >= 8 THEN EXTRACT(YEAR FROM v_now)::INT - 1
    ELSE EXTRACT(YEAR FROM v_now)::INT - 2
  END) + 1
  INTO v_next
  FROM public.academic_years;

  RETURN public.create_academic_year_with_terms(
    v_next,
    FALSE,
    auth.uid()
  );
END;
$function$

-- FILE: fn_admin_create_user.sql
CREATE OR REPLACE FUNCTION public.admin_create_user(p_username text, p_password text, p_full_name text, p_role user_role, p_sphere sphere_type DEFAULT NULL::sphere_type)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth', 'extensions'
AS $function$
DECLARE
  v_user_id UUID := gen_random_uuid();
  v_email TEXT;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  v_email := lower(trim(replace(p_username, '@', ''))) || '@mustudy.internal';

  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change,
    is_sso_user, is_anonymous
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    v_user_id,
    'authenticated',
    'authenticated',
    v_email,
    extensions.crypt(p_password, extensions.gen_salt('bf')),
    NOW(),
    jsonb_build_object('provider', 'email', 'providers', ARRAY['email']),
    jsonb_build_object(
      'username', p_username,
      'full_name', p_full_name,
      'role', p_role::text
    ),
    NOW(),
    NOW(),
    '',
    '',
    '',
    '',
    false,
    false
  );

  INSERT INTO auth.identities (
    id, user_id, identity_data, provider, provider_id,
    last_sign_in_at, created_at, updated_at
  ) VALUES (
    gen_random_uuid(),
    v_user_id,
    jsonb_build_object(
      'sub', v_user_id::text,
      'email', v_email,
      'email_verified', true
    ),
    'email',
    v_email,
    NOW(),
    NOW(),
    NOW()
  );

  INSERT INTO public.profiles (id, username, full_name, role, auth_email)
  VALUES (v_user_id, trim(p_username), p_full_name, p_role, v_email);

  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'login_credentials'
  ) THEN
    INSERT INTO public.login_credentials (profile_id, password, updated_at)
    VALUES (v_user_id, p_password, NOW())
    ON CONFLICT (profile_id) DO UPDATE
      SET password = excluded.password,
          updated_at = NOW();
  END IF;

  IF p_role = 'teacher' THEN
    IF p_sphere IS NULL THEN
      RAISE EXCEPTION 'Sphere required for teacher';
    END IF;
    -- Do NOT auto-create Group 1/2/3. Admins add groups manually.
    INSERT INTO public.teachers (profile_id, sphere)
    VALUES (v_user_id, p_sphere);
  ELSIF p_role = 'student' THEN
    INSERT INTO public.students (profile_id) VALUES (v_user_id);
  END IF;

  RETURN v_user_id;
END;
$function$

-- FILE: fn_admin_delete_academic_year.sql
CREATE OR REPLACE FUNCTION public.admin_delete_academic_year(p_year_id uuid)
 RETURNS academic_years
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_year public.academic_years;
  v_remaining INT;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only admins can delete academic years';
  END IF;

  SELECT * INTO v_year
  FROM public.academic_years
  WHERE id = p_year_id;

  IF v_year.id IS NULL THEN
    RAISE EXCEPTION 'Academic year not found';
  END IF;

  IF v_year.is_current THEN
    RAISE EXCEPTION 'Cannot delete the current academic year. Set another year as current first.';
  END IF;

  SELECT COUNT(*) INTO v_remaining FROM public.academic_years;
  IF v_remaining <= 1 THEN
    RAISE EXCEPTION 'Cannot delete the last academic year';
  END IF;

  DELETE FROM public.academic_years
  WHERE id = p_year_id
  RETURNING * INTO v_year;

  RETURN v_year;
END;
$function$

-- FILE: fn_admin_mass_generate_school_data.sql
CREATE OR REPLACE FUNCTION public.admin_mass_generate_school_data(p_teachers jsonb, p_students jsonb, p_groups jsonb, p_assignments jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth', 'extensions'
AS $function$
DECLARE
  v_errors TEXT[] := ARRAY[]::TEXT[];

  v_teacher_upserted INT := 0;
  v_student_upserted INT := 0;
  v_groups_created INT := 0;
  v_assignments_inserted INT := 0;

  -- Auth/profile ids
  v_profile_id UUID;
  v_user_id UUID;
  v_teacher_id UUID;
  v_student_id UUID;
  v_group_id UUID;

  -- temp strings
  v_username TEXT;
  v_password TEXT;
  v_full_name TEXT;
  v_sphere TEXT;
  v_email TEXT;

  v_teacher_username TEXT;
  v_group_title TEXT;
  v_student_username TEXT;

  v_row JSONB;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  -- ==========================
  -- Teachers + teacher rows
  -- ==========================
  IF p_teachers IS NOT NULL THEN
    FOR v_row IN SELECT * FROM jsonb_array_elements(p_teachers)
    LOOP
      v_username := trim(both from v_row->>'username');
      v_password := v_row->>'password';
      v_full_name := trim(both from v_row->>'full_name');
      v_sphere := lower(trim(both from v_row->>'sphere'));

      IF v_username IS NULL OR v_username = '' OR v_password IS NULL OR v_password = '' THEN
        v_errors := v_errors || format('Teacher missing username/password: %s', v_row::TEXT);
        CONTINUE;
      END IF;

      IF v_sphere IS NULL OR (v_sphere <> 'math' AND v_sphere <> 'english') THEN
        v_errors := v_errors || format('Teacher invalid sphere for %s: %s', v_username, COALESCE(v_sphere,'<null>'));
        CONTINUE;
      END IF;

      v_email := lower(trim(replace(v_username, '@', ''))) || '@mustudy.internal';

      -- Existing profile?
      SELECT id INTO v_profile_id
      FROM public.profiles
      WHERE username = v_username
      LIMIT 1;

      IF v_profile_id IS NULL THEN
        v_user_id := gen_random_uuid();

        INSERT INTO auth.users (
          instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
          raw_app_meta_data, raw_user_meta_data,
          created_at, updated_at,
          confirmation_token, recovery_token, email_change_token_new, email_change,
          is_sso_user, is_anonymous
        ) VALUES (
          '00000000-0000-0000-0000-000000000000',
          v_user_id,
          'authenticated',
          'authenticated',
          v_email,
          extensions.crypt(v_password, extensions.gen_salt('bf')),
          NOW(),
          jsonb_build_object('provider','email','providers',ARRAY['email']),
          jsonb_build_object('username', v_username, 'full_name', v_full_name, 'role', 'teacher'),
          NOW(),
          NOW(),
          '', '', '', '',
          false, false
        );

        INSERT INTO auth.identities (
          id, user_id, identity_data, provider, provider_id,
          last_sign_in_at, created_at, updated_at
        ) VALUES (
          gen_random_uuid(),
          v_user_id,
          jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true),
          'email',
          v_user_id::text,
          NOW(), NOW(), NOW()
        );

        INSERT INTO public.profiles (id, username, full_name, role, auth_email)
        VALUES (v_user_id, v_username, COALESCE(v_full_name,'') , 'teacher', v_email);

        v_profile_id := v_user_id;
      ELSE
        -- Update password + basic profile fields
        v_user_id := v_profile_id;
        UPDATE auth.users
        SET encrypted_password = extensions.crypt(v_password, extensions.gen_salt('bf')),
            updated_at = NOW()
        WHERE id = v_user_id;

        UPDATE public.profiles
        SET full_name = COALESCE(v_full_name,''),
            role = 'teacher',
            auth_email = v_email
        WHERE id = v_user_id;
      END IF;

      -- Upsert teachers row
      INSERT INTO public.teachers (profile_id, sphere)
      VALUES (
        v_profile_id,
        CASE WHEN v_sphere = 'math' THEN 'math'::public.sphere_type ELSE 'english'::public.sphere_type END
      )
      ON CONFLICT (profile_id) DO UPDATE
      SET sphere = EXCLUDED.sphere;

      v_teacher_upserted := v_teacher_upserted + 1;
    END LOOP;
  END IF;

  -- ==========================
  -- Students + student rows
  -- ==========================
  IF p_students IS NOT NULL THEN
    FOR v_row IN SELECT * FROM jsonb_array_elements(p_students)
    LOOP
      v_username := trim(both from v_row->>'username');
      v_password := v_row->>'password';
      v_full_name := trim(both from v_row->>'full_name');

      IF v_username IS NULL OR v_username = '' OR v_password IS NULL OR v_password = '' THEN
        v_errors := v_errors || format('Student missing username/password: %s', v_row::TEXT);
        CONTINUE;
      END IF;

      v_email := lower(trim(replace(v_username, '@', ''))) || '@mustudy.internal';

      SELECT id INTO v_profile_id
      FROM public.profiles
      WHERE username = v_username
      LIMIT 1;

      IF v_profile_id IS NULL THEN
        v_user_id := gen_random_uuid();

        INSERT INTO auth.users (
          instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
          raw_app_meta_data, raw_user_meta_data,
          created_at, updated_at,
          confirmation_token, recovery_token, email_change_token_new, email_change,
          is_sso_user, is_anonymous
        ) VALUES (
          '00000000-0000-0000-0000-000000000000',
          v_user_id,
          'authenticated',
          'authenticated',
          v_email,
          extensions.crypt(v_password, extensions.gen_salt('bf')),
          NOW(),
          jsonb_build_object('provider','email','providers',ARRAY['email']),
          jsonb_build_object('username', v_username, 'full_name', v_full_name, 'role', 'student'),
          NOW(),
          NOW(),
          '', '', '', '',
          false, false
        );

        INSERT INTO auth.identities (
          id, user_id, identity_data, provider, provider_id,
          last_sign_in_at, created_at, updated_at
        ) VALUES (
          gen_random_uuid(),
          v_user_id,
          jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true),
          'email',
          v_user_id::text,
          NOW(), NOW(), NOW()
        );

        INSERT INTO public.profiles (id, username, full_name, role, auth_email)
        VALUES (v_user_id, v_username, COALESCE(v_full_name,'') , 'student', v_email);

        v_profile_id := v_user_id;
      ELSE
        v_user_id := v_profile_id;
        UPDATE auth.users
        SET encrypted_password = extensions.crypt(v_password, extensions.gen_salt('bf')),
            updated_at = NOW()
        WHERE id = v_user_id;

        UPDATE public.profiles
        SET full_name = COALESCE(v_full_name,''),
            role = 'student',
            auth_email = v_email
        WHERE id = v_user_id;
      END IF;

      INSERT INTO public.students (profile_id)
      VALUES (v_profile_id)
      ON CONFLICT (profile_id) DO NOTHING;

      v_student_upserted := v_student_upserted + 1;
    END LOOP;
  END IF;

  -- ==========================
  -- Groups (exact titles)
  -- ==========================
  IF p_groups IS NOT NULL THEN
    FOR v_row IN SELECT * FROM jsonb_array_elements(p_groups)
    LOOP
      v_teacher_username := trim(both from v_row->>'teacher_username');
      v_group_title := trim(both from v_row->>'title');

      IF v_teacher_username IS NULL OR v_teacher_username = '' OR v_group_title IS NULL OR v_group_title = '' THEN
        v_errors := v_errors || format('Group missing teacher_username/title: %s', v_row::TEXT);
        CONTINUE;
      END IF;

      SELECT t.id INTO v_teacher_id
      FROM public.teachers t
      JOIN public.profiles p ON p.id = t.profile_id
      WHERE p.username = v_teacher_username
        AND p.role = 'teacher'
      LIMIT 1;

      IF v_teacher_id IS NULL THEN
        v_errors := v_errors || format('Unknown teacher for group %s (teacher_username=%s)', v_group_title, v_teacher_username);
        CONTINUE;
      END IF;

      SELECT g.id INTO v_group_id
      FROM public.groups g
      WHERE g.teacher_id = v_teacher_id
        AND g.title = v_group_title
      LIMIT 1;

      IF v_group_id IS NULL THEN
        INSERT INTO public.groups (teacher_id, title)
        VALUES (v_teacher_id, v_group_title);
        v_groups_created := v_groups_created + 1;
      END IF;
    END LOOP;
  END IF;

  -- ==========================
  -- Assign students -> groups
  -- ==========================
  IF p_assignments IS NOT NULL THEN
    FOR v_row IN SELECT * FROM jsonb_array_elements(p_assignments)
    LOOP
      v_teacher_username := trim(both from v_row->>'teacher_username');
      v_group_title := trim(both from v_row->>'group_title');
      v_student_username := trim(both from v_row->>'student_username');

      IF v_teacher_username IS NULL OR v_teacher_username = '' OR
         v_group_title IS NULL OR v_group_title = '' OR
         v_student_username IS NULL OR v_student_username = '' THEN
        v_errors := v_errors || format('Assignment missing teacher_username/group_title/student_username: %s', v_row::TEXT);
        CONTINUE;
      END IF;

      -- Resolve group_id by teacher_username + group_title
      SELECT g.id INTO v_group_id
      FROM public.groups g
      JOIN public.teachers t ON t.id = g.teacher_id
      JOIN public.profiles p ON p.id = t.profile_id
      WHERE p.username = v_teacher_username
        AND p.role = 'teacher'
        AND g.title = v_group_title
      LIMIT 1;

      IF v_group_id IS NULL THEN
        v_errors := v_errors || format('Unknown group for assignment %s -> (teacher=%s, group_title=%s)', v_student_username, v_teacher_username, v_group_title);
        CONTINUE;
      END IF;

      -- Resolve student_id
      SELECT s.id INTO v_student_id
      FROM public.students s
      JOIN public.profiles p ON p.id = s.profile_id
      WHERE p.username = v_student_username
        AND p.role = 'student'
      LIMIT 1;

      IF v_student_id IS NULL THEN
        v_errors := v_errors || format('Unknown student username: %s', v_student_username);
        CONTINUE;
      END IF;

      INSERT INTO public.group_students (group_id, student_id)
      VALUES (v_group_id, v_student_id)
      ON CONFLICT (group_id, student_id) DO NOTHING;

      -- We don't have a portable "rowcount" here without extra GET DIAGNOSTICS.
      -- Still count by checking existence after insert.
      IF EXISTS (
        SELECT 1 FROM public.group_students gs
        WHERE gs.group_id = v_group_id AND gs.student_id = v_student_id
      ) THEN
        v_assignments_inserted := v_assignments_inserted + 1;
      END IF;
    END LOOP;
  END IF;

  RETURN jsonb_build_object(
    'teachers_upserted', v_teacher_upserted,
    'students_upserted', v_student_upserted,
    'groups_created', v_groups_created,
    'assignments_inserted', v_assignments_inserted,
    'errors', to_jsonb(v_errors)
  );
END;
$function$

-- FILE: fn_admin_reset_password.sql
CREATE OR REPLACE FUNCTION public.admin_reset_password(p_user_id uuid, p_password text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'auth', 'public', 'extensions'
AS $function$
BEGIN
  IF NOT public.is_admin() THEN RAISE EXCEPTION 'Not authorized'; END IF;
  UPDATE auth.users SET encrypted_password = extensions.crypt(p_password, extensions.gen_salt('bf')), updated_at = NOW() WHERE id = p_user_id;
END; $function$

-- FILE: fn_admin_set_current_academic_year.sql
CREATE OR REPLACE FUNCTION public.admin_set_current_academic_year(p_year_id uuid)
 RETURNS academic_years
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_year public.academic_years;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only admins can set the current academic year';
  END IF;

  UPDATE public.academic_years SET is_current = FALSE WHERE is_current;

  UPDATE public.academic_years
  SET is_current = TRUE
  WHERE id = p_year_id
  RETURNING * INTO v_year;

  IF v_year.id IS NULL THEN
    RAISE EXCEPTION 'Academic year not found';
  END IF;

  RETURN v_year;
END;
$function$

-- FILE: fn_admin_update_academic_term.sql
CREATE OR REPLACE FUNCTION public.admin_update_academic_term(p_term_id uuid, p_starts_on date, p_ends_on date)
 RETURNS academic_terms
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_term public.academic_terms;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only admins can edit term dates';
  END IF;

  IF p_ends_on < p_starts_on THEN
    RAISE EXCEPTION 'End date must be on or after start date';
  END IF;

  UPDATE public.academic_terms
  SET starts_on = p_starts_on, ends_on = p_ends_on
  WHERE id = p_term_id
  RETURNING * INTO v_term;

  IF v_term.id IS NULL THEN
    RAISE EXCEPTION 'Academic term not found';
  END IF;

  RETURN v_term;
END;
$function$

-- FILE: fn_attendance_sync_session.sql
CREATE OR REPLACE FUNCTION public.attendance_sync_session()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  IF NEW.date IS NOT NULL AND NEW.date > CURRENT_DATE THEN
    RAISE EXCEPTION 'Cannot mark attendance for a future date'
      USING ERRCODE = 'check_violation';
  END IF;

  IF NEW.session_id IS NULL AND NEW.group_id IS NOT NULL AND NEW.date IS NOT NULL THEN
    NEW.session_id := public.ensure_lesson_session(NEW.group_id, NEW.date::date);
  ELSIF NEW.session_id IS NOT NULL THEN
    SELECT ls.group_id, ls.session_date
      INTO NEW.group_id, NEW.date
    FROM public.lesson_sessions ls
    WHERE ls.id = NEW.session_id;
  END IF;

  IF NEW.date IS NOT NULL AND NEW.date > CURRENT_DATE THEN
    RAISE EXCEPTION 'Cannot mark attendance for a future date'
      USING ERRCODE = 'check_violation';
  END IF;

  RETURN NEW;
END;
$function$

-- FILE: fn_can_access_chat_room.sql
CREATE OR REPLACE FUNCTION public.can_access_chat_room(rid uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT public.is_admin()
    OR EXISTS (
      SELECT 1
      FROM public.chat_rooms cr
      WHERE cr.id = rid
        AND (
          public.is_teacher_of_group(cr.group_id)
          OR public.is_student_in_group(cr.group_id)
        )
    );
$function$

-- FILE: fn_chat_messages_reply_same_room.sql
CREATE OR REPLACE FUNCTION public.chat_messages_reply_same_room()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_room UUID;
BEGIN
  IF NEW.reply_to_message_id IS NULL THEN
    RETURN NEW;
  END IF;
  IF NEW.reply_to_message_id = NEW.id THEN
    RAISE EXCEPTION 'message cannot reply to itself';
  END IF;
  SELECT room_id INTO v_room
  FROM public.chat_messages
  WHERE id = NEW.reply_to_message_id;
  IF v_room IS NULL THEN
    RAISE EXCEPTION 'reply target not found';
  END IF;
  IF v_room <> NEW.room_id THEN
    RAISE EXCEPTION 'reply must be in the same chat room';
  END IF;
  RETURN NEW;
END;
$function$

-- FILE: fn_chat_storage_room_id.sql
CREATE OR REPLACE FUNCTION public.chat_storage_room_id(object_name text)
 RETURNS uuid
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'public'
AS $function$
DECLARE
  part TEXT := split_part(object_name, '/', 1);
BEGIN
  IF part ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
    RETURN part::UUID;
  END IF;
  RETURN NULL;
END;
$function$

-- FILE: fn_chat_unread_counts.sql
CREATE OR REPLACE FUNCTION public.chat_unread_counts()
 RETURNS TABLE(room_id uuid, unread_count bigint)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT
    m.room_id,
    COUNT(*)::BIGINT AS unread_count
  FROM public.chat_messages m
  WHERE m.is_deleted = FALSE
    AND m.sender_id <> auth.uid()
    AND public.can_access_chat_room(m.room_id)
    AND NOT EXISTS (
      SELECT 1
      FROM public.message_reads r
      WHERE r.message_id = m.id
        AND r.user_id = auth.uid()
    )
  GROUP BY m.room_id;
$function$

-- FILE: fn_create_academic_year_with_terms.sql
CREATE OR REPLACE FUNCTION public.create_academic_year_with_terms(p_start_year integer, p_is_current boolean DEFAULT false, p_created_by uuid DEFAULT NULL::uuid)
 RETURNS academic_years
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_year public.academic_years;
  v_sem INT;
  v_bounds RECORD;
BEGIN
  IF p_is_current THEN
    UPDATE public.academic_years SET is_current = FALSE WHERE is_current;
  END IF;

  INSERT INTO public.academic_years (start_year, label, is_current, created_by)
  VALUES (
    p_start_year,
    public.academic_year_label(p_start_year),
    p_is_current,
    p_created_by
  )
  RETURNING * INTO v_year;

  FOR v_sem IN 1..4 LOOP
    SELECT * INTO v_bounds
    FROM public.academic_semester_bounds(p_start_year, v_sem);

    INSERT INTO public.academic_terms (
      academic_year_id, semester, starts_on, ends_on
    ) VALUES (
      v_year.id, v_sem, v_bounds.starts_on, v_bounds.ends_on
    );
  END LOOP;

  RETURN v_year;
END;
$function$

-- FILE: fn_current_profile_role.sql
CREATE OR REPLACE FUNCTION public.current_profile_role()
 RETURNS user_role
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$ SELECT role FROM public.profiles WHERE id = auth.uid(); $function$

-- FILE: fn_ensure_chat_room_for_group.sql
CREATE OR REPLACE FUNCTION public.ensure_chat_room_for_group()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  INSERT INTO public.chat_rooms (group_id)
  VALUES (NEW.id)
  ON CONFLICT (group_id) DO NOTHING;
  RETURN NEW;
END;
$function$

-- FILE: fn_ensure_lesson_session.sql
CREATE OR REPLACE FUNCTION public.ensure_lesson_session(p_group_id uuid, p_session_date date)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  sid UUID;
BEGIN
  IF p_session_date > CURRENT_DATE THEN
    RAISE EXCEPTION 'Cannot create a lesson session for a future date'
      USING ERRCODE = 'check_violation';
  END IF;

  INSERT INTO public.lesson_sessions (group_id, session_date)
  VALUES (p_group_id, p_session_date)
  ON CONFLICT (group_id, session_date)
  DO UPDATE SET group_id = EXCLUDED.group_id
  RETURNING id INTO sid;
  RETURN sid;
END;
$function$

-- FILE: fn_get_auth_email_by_username.sql
CREATE OR REPLACE FUNCTION public.get_auth_email_by_username(p_username text)
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT auth_email FROM public.profiles
  WHERE lower(username) = lower(trim(p_username)) AND is_disabled = FALSE LIMIT 1;
$function$

-- FILE: fn_is_admin.sql
CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin' AND is_disabled = FALSE
  );
$function$

-- FILE: fn_is_student_in_group.sql
CREATE OR REPLACE FUNCTION public.is_student_in_group(gid uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM public.group_students gs
    JOIN public.students s ON s.id = gs.student_id
    WHERE gs.group_id = gid AND s.profile_id = auth.uid()
  );
$function$

-- FILE: fn_is_teacher_of_group.sql
CREATE OR REPLACE FUNCTION public.is_teacher_of_group(gid uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM public.groups g
    JOIN public.teachers t ON t.id = g.teacher_id
    WHERE g.id = gid AND t.profile_id = auth.uid()
  );
$function$

-- FILE: fn_notify_chat_message.sql
CREATE OR REPLACE FUNCTION public.notify_chat_message(p_user_id uuid, p_title text, p_body text, p_action_path text, p_room_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_id UUID;
BEGIN
  SELECT id INTO v_id
  FROM public.notifications
  WHERE user_id = p_user_id
    AND kind = 'chat'
    AND ref_id = p_room_id
    AND is_read = FALSE
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_id IS NOT NULL THEN
    UPDATE public.notifications
    SET title = p_title,
        body = COALESCE(p_body, ''),
        action_path = p_action_path,
        created_at = NOW()
    WHERE id = v_id;
  ELSE
    PERFORM public.notify_user(
      p_user_id, p_title, p_body, 'chat', p_action_path, p_room_id
    );
  END IF;
END;
$function$

-- FILE: fn_notify_user.sql
CREATE OR REPLACE FUNCTION public.notify_user(p_user_id uuid, p_title text, p_body text, p_kind text DEFAULT 'system'::text, p_action_path text DEFAULT NULL::text, p_ref_id uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  INSERT INTO public.notifications (user_id, title, body, kind, action_path, ref_id)
  VALUES (
    p_user_id,
    p_title,
    COALESCE(p_body, ''),
    COALESCE(NULLIF(trim(p_kind), ''), 'system'),
    p_action_path,
    p_ref_id
  );
END;
$function$

-- FILE: fn_profile_route_prefix.sql
CREATE OR REPLACE FUNCTION public.profile_route_prefix(p_user_id uuid)
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT CASE role
    WHEN 'teacher' THEN '/teacher'
    WHEN 'admin' THEN '/admin'
    ELSE '/student'
  END
  FROM public.profiles
  WHERE id = p_user_id;
$function$

-- FILE: fn_seed_demo_data.sql
CREATE OR REPLACE FUNCTION public.seed_demo_data()
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
DECLARE
  v_admin UUID; v_math UUID; v_eng UUID; v_student UUID;
  v_math_tid UUID; v_eng_tid UUID; v_student_sid UUID;
  v_group UUID; v_pack UUID;
BEGIN
  IF EXISTS (SELECT 1 FROM public.profiles LIMIT 1) THEN RETURN 'already_seeded'; END IF;

  v_admin := public._demo_insert_user('@admin', 'password123', 'Platform Admin', 'admin');
  v_math := public._demo_insert_user('@math_teacher', 'password123', 'Amina Math', 'teacher');
  v_eng := public._demo_insert_user('@english_teacher', 'password123', 'James English', 'teacher');
  v_student := public._demo_insert_user('@test_user', 'password123', 'Demo Student', 'student');

  INSERT INTO public.teachers (profile_id, sphere) VALUES (v_math, 'math') RETURNING id INTO v_math_tid;
  INSERT INTO public.teachers (profile_id, sphere) VALUES (v_eng, 'english') RETURNING id INTO v_eng_tid;

  INSERT INTO public.groups (teacher_id, title) VALUES (v_math_tid, 'Math Group A') RETURNING id INTO v_group;
  INSERT INTO public.groups (teacher_id, title) VALUES (v_math_tid, 'Math Group B');
  INSERT INTO public.groups (teacher_id, title) VALUES (v_math_tid, 'Math Group C');
  INSERT INTO public.groups (teacher_id, title) VALUES (v_eng_tid, 'English Group A');
  INSERT INTO public.groups (teacher_id, title) VALUES (v_eng_tid, 'English Group B');
  INSERT INTO public.groups (teacher_id, title) VALUES (v_eng_tid, 'English Group C');

  SELECT id INTO v_student_sid FROM public.students WHERE profile_id = v_student;
  INSERT INTO public.group_students (group_id, student_id) VALUES (v_group, v_student_sid);

  INSERT INTO public.assignments (teacher_id, group_id, type, title, description, due_date)
  VALUES (v_math_tid, v_group, 'static', 'Read page 12', 'Review chapter on linear equations.', NOW() + INTERVAL '2 days');

  INSERT INTO public.assignments (teacher_id, group_id, type, title, description, due_date)
  VALUES (v_math_tid, v_group, 'homework_pack', 'Algebra Week 1 Pack', 'Complete all tasks below.', NOW() + INTERVAL '5 days')
  RETURNING id INTO v_pack;

  INSERT INTO public.tasks (assignment_id, title, description, sort_order, link_url)
  VALUES (v_pack, 'Practice set A', 'Solve exercises 1-10.', 1, 'https://www.khanacademy.org/math/algebra');
  INSERT INTO public.tasks (assignment_id, title, description, sort_order)
  VALUES (v_pack, 'Written reflection', 'Explain how you checked your answers.', 2);

  INSERT INTO public.announcements (teacher_id, group_id, title, description)
  VALUES (v_math_tid, v_group, 'Welcome to Math Group A', 'Office hours every Wednesday.');

  INSERT INTO public.attendance (group_id, student_id, status, date)
  VALUES (v_group, v_student_sid, 'present', CURRENT_DATE);

  INSERT INTO public.notifications (user_id, title, body)
  VALUES (v_student, 'Welcome to MU Study', 'Your demo account is ready.');

  RETURN 'seeded';
END; $function$

-- FILE: fn_sync_submission_mark.sql
CREATE OR REPLACE FUNCTION public.sync_submission_mark()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE v_group_id UUID; v_teacher_id UUID; v_title TEXT;
BEGIN
  IF NEW.score IS NULL THEN
    DELETE FROM public.marks WHERE submission_id = NEW.id;
    RETURN NEW;
  END IF;

  SELECT a.group_id, a.teacher_id, tk.title
    INTO v_group_id, v_teacher_id, v_title
  FROM public.tasks tk
  JOIN public.assignments a ON a.id = tk.assignment_id
  WHERE tk.id = NEW.task_id;

  IF v_group_id IS NULL THEN RETURN NEW; END IF;

  INSERT INTO public.marks (
    group_id, student_id, teacher_id, submission_id, title, category, percentage, comment
  ) VALUES (
    v_group_id, NEW.student_id, v_teacher_id, NEW.id,
    COALESCE(v_title, 'Homework'), 'homework', NEW.score, COALESCE(NEW.feedback, '')
  )
  ON CONFLICT (submission_id) DO UPDATE SET
    percentage = EXCLUDED.percentage,
    title = EXCLUDED.title,
    comment = EXCLUDED.comment,
    updated_at = NOW();

  RETURN NEW;
END; $function$

-- FILE: fn_toggle_message_reaction.sql
CREATE OR REPLACE FUNCTION public.toggle_message_reaction(p_message_id uuid, p_emoji text)
 RETURNS message_reactions
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid UUID := auth.uid();
  v_existing public.message_reactions;
  v_result public.message_reactions;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF p_emoji IS NULL OR char_length(trim(p_emoji)) < 1 THEN
    RAISE EXCEPTION 'Emoji required';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.chat_messages m
    WHERE m.id = p_message_id
      AND m.is_deleted = FALSE
      AND public.can_access_chat_room(m.room_id)
  ) THEN
    RAISE EXCEPTION 'Message not found or inaccessible';
  END IF;

  SELECT * INTO v_existing
  FROM public.message_reactions
  WHERE message_id = p_message_id AND user_id = v_uid;

  IF v_existing.id IS NOT NULL AND v_existing.emoji = p_emoji THEN
    DELETE FROM public.message_reactions WHERE id = v_existing.id;
    RETURN v_existing;
  END IF;

  INSERT INTO public.message_reactions (message_id, user_id, emoji)
  VALUES (p_message_id, v_uid, p_emoji)
  ON CONFLICT (message_id, user_id)
  DO UPDATE SET emoji = EXCLUDED.emoji, created_at = NOW()
  RETURNING * INTO v_result;

  RETURN v_result;
END;
$function$

-- FILE: fn_touch_chat_message_updated_at.sql
CREATE OR REPLACE FUNCTION public.touch_chat_message_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$function$

-- FILE: fn_touch_updated_at.sql
CREATE OR REPLACE FUNCTION public.touch_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $function$

-- FILE: fn_trg_announcement_notify.sql
CREATE OR REPLACE FUNCTION public.trg_announcement_notify()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  r RECORD;
  v_prefix TEXT;
BEGIN
  FOR r IN
    SELECT s.profile_id AS uid
    FROM public.group_students gs
    JOIN public.students s ON s.id = gs.student_id
    WHERE gs.group_id = NEW.group_id
  LOOP
    v_prefix := COALESCE(public.profile_route_prefix(r.uid), '/student');
    PERFORM public.notify_user(
      r.uid,
      'Announcement',
      NEW.title,
      'announcement',
      v_prefix || '/dashboard',
      NEW.id
    );
  END LOOP;
  RETURN NEW;
END;
$function$

-- FILE: fn_trg_assignment_notify.sql
CREATE OR REPLACE FUNCTION public.trg_assignment_notify()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  r RECORD;
  v_prefix TEXT;
BEGIN
  FOR r IN
    SELECT s.profile_id AS uid
    FROM public.group_students gs
    JOIN public.students s ON s.id = gs.student_id
    WHERE gs.group_id = NEW.group_id
  LOOP
    v_prefix := COALESCE(public.profile_route_prefix(r.uid), '/student');
    PERFORM public.notify_user(
      r.uid,
      'New homework',
      NEW.title,
      'assignment',
      v_prefix || '/assignments/' || NEW.id::text,
      NEW.id
    );
  END LOOP;
  RETURN NEW;
END;
$function$

-- FILE: fn_trg_chat_message_notify.sql
CREATE OR REPLACE FUNCTION public.trg_chat_message_notify()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  r RECORD;
  v_group_id UUID;
  v_group_title TEXT;
  v_sender_name TEXT;
  v_preview TEXT;
  v_prefix TEXT;
  v_path TEXT;
BEGIN
  IF NEW.is_deleted THEN
    RETURN NEW;
  END IF;

  SELECT cr.group_id, g.title
    INTO v_group_id, v_group_title
  FROM public.chat_rooms cr
  JOIN public.groups g ON g.id = cr.group_id
  WHERE cr.id = NEW.room_id;

  IF v_group_id IS NULL THEN RETURN NEW; END IF;

  SELECT COALESCE(full_name, username, 'Someone')
    INTO v_sender_name
  FROM public.profiles
  WHERE id = NEW.sender_id;

  v_preview := CASE NEW.message_type
    WHEN 'text' THEN left(COALESCE(NEW.text_content, ''), 120)
    WHEN 'image' THEN 'Photo'
    WHEN 'video' THEN 'Video'
    WHEN 'voice' THEN 'Voice message'
    ELSE 'New message'
  END;

  FOR r IN
    SELECT DISTINCT uid FROM (
      SELECT s.profile_id AS uid
      FROM public.group_students gs
      JOIN public.students s ON s.id = gs.student_id
      WHERE gs.group_id = v_group_id
      UNION
      SELECT t.profile_id AS uid
      FROM public.groups g
      JOIN public.teachers t ON t.id = g.teacher_id
      WHERE g.id = v_group_id
    ) members
    WHERE uid IS DISTINCT FROM NEW.sender_id
  LOOP
    v_prefix := COALESCE(public.profile_route_prefix(r.uid), '/student');
    v_path := v_prefix || '/chat/' || NEW.room_id::text;
    PERFORM public.notify_chat_message(
      r.uid,
      COALESCE(v_group_title, 'Chat'),
      COALESCE(v_sender_name, 'Someone') || ': ' || v_preview,
      v_path,
      NEW.room_id
    );
  END LOOP;

  RETURN NEW;
END;
$function$

-- FILE: fn_trg_mark_notify.sql
CREATE OR REPLACE FUNCTION public.trg_mark_notify()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid UUID;
  v_prefix TEXT;
  v_body TEXT;
BEGIN
  IF TG_OP = 'UPDATE'
     AND NEW.percentage IS NOT DISTINCT FROM OLD.percentage
     AND NEW.comment IS NOT DISTINCT FROM OLD.comment THEN
    RETURN NEW;
  END IF;

  SELECT profile_id INTO v_uid FROM public.students WHERE id = NEW.student_id;
  IF v_uid IS NULL THEN RETURN NEW; END IF;

  v_prefix := COALESCE(public.profile_route_prefix(v_uid), '/student');
  v_body := NEW.title || ' — ' || ROUND(NEW.percentage)::TEXT || '%';
  IF NEW.comment IS NOT NULL AND length(trim(NEW.comment)) > 0 THEN
    v_body := v_body || E'\n' || left(trim(NEW.comment), 160);
  END IF;

  PERFORM public.notify_user(
    v_uid,
    'Work graded',
    v_body,
    'graded',
    v_prefix || '/marks',
    NEW.id
  );
  RETURN NEW;
END;
$function$

-- FILE: fn_trg_submission_notify.sql
CREATE OR REPLACE FUNCTION public.trg_submission_notify()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_teacher_profile UUID;
  v_student_name TEXT;
  v_task_title TEXT;
  v_assignment_id UUID;
  v_prefix TEXT;
  v_is_submit BOOLEAN;
BEGIN
  v_is_submit :=
    (TG_OP = 'INSERT' AND (NEW.file_url IS NOT NULL OR NEW.text_answer IS NOT NULL OR NEW.submitted_at IS NOT NULL))
    OR (
      TG_OP = 'UPDATE'
      AND (
        (OLD.file_url IS DISTINCT FROM NEW.file_url AND NEW.file_url IS NOT NULL)
        OR (OLD.text_answer IS DISTINCT FROM NEW.text_answer AND NEW.text_answer IS NOT NULL)
        OR (OLD.submitted_at IS DISTINCT FROM NEW.submitted_at AND NEW.submitted_at IS NOT NULL)
        OR (OLD.is_completed IS DISTINCT FROM NEW.is_completed AND NEW.is_completed IS TRUE)
      )
    );

  IF NOT v_is_submit THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE'
     AND OLD.score IS DISTINCT FROM NEW.score
     AND OLD.file_url IS NOT DISTINCT FROM NEW.file_url
     AND OLD.text_answer IS NOT DISTINCT FROM NEW.text_answer
     AND OLD.submitted_at IS NOT DISTINCT FROM NEW.submitted_at
     AND OLD.is_completed IS NOT DISTINCT FROM NEW.is_completed THEN
    RETURN NEW;
  END IF;

  SELECT t.profile_id, tk.title, a.id
    INTO v_teacher_profile, v_task_title, v_assignment_id
  FROM public.tasks tk
  JOIN public.assignments a ON a.id = tk.assignment_id
  JOIN public.teachers t ON t.id = a.teacher_id
  WHERE tk.id = NEW.task_id;

  IF v_teacher_profile IS NULL THEN RETURN NEW; END IF;

  SELECT COALESCE(p.full_name, p.username, 'Student')
    INTO v_student_name
  FROM public.students s
  JOIN public.profiles p ON p.id = s.profile_id
  WHERE s.id = NEW.student_id;

  v_prefix := COALESCE(public.profile_route_prefix(v_teacher_profile), '/teacher');

  PERFORM public.notify_user(
    v_teacher_profile,
    'New submission',
    COALESCE(v_student_name, 'Student') || ' · ' || COALESCE(v_task_title, 'Task'),
    'submission',
    v_prefix || '/assignments/' || v_assignment_id::text,
    NEW.id
  );
  RETURN NEW;
END;
$function$


-- ---------- TRIGGERS ----------
CREATE TRIGGER announcement_created_notify AFTER INSERT ON announcements FOR EACH ROW EXECUTE FUNCTION trg_announcement_notify();
CREATE TRIGGER assignment_created_notify AFTER INSERT ON assignments FOR EACH ROW EXECUTE FUNCTION trg_assignment_notify();
CREATE TRIGGER tr_attendance_sync_session BEFORE INSERT OR UPDATE ON attendance FOR EACH ROW EXECUTE FUNCTION attendance_sync_session();
CREATE TRIGGER tr_chat_message_notify AFTER INSERT ON chat_messages FOR EACH ROW EXECUTE FUNCTION trg_chat_message_notify();
CREATE TRIGGER tr_chat_messages_reply_same_room BEFORE INSERT OR UPDATE OF reply_to_message_id, room_id ON chat_messages FOR EACH ROW EXECUTE FUNCTION chat_messages_reply_same_room();
CREATE TRIGGER tr_chat_messages_updated_at BEFORE UPDATE ON chat_messages FOR EACH ROW EXECUTE FUNCTION touch_chat_message_updated_at();
CREATE TRIGGER tr_groups_create_chat_room AFTER INSERT ON groups FOR EACH ROW EXECUTE FUNCTION ensure_chat_room_for_group();
CREATE TRIGGER tr_mark_notify AFTER INSERT OR UPDATE ON marks FOR EACH ROW EXECUTE FUNCTION trg_mark_notify();
CREATE TRIGGER tr_marks_touch BEFORE UPDATE ON marks FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER tr_submission_mark AFTER INSERT OR UPDATE OF score, feedback ON submissions FOR EACH ROW EXECUTE FUNCTION sync_submission_mark();
CREATE TRIGGER tr_submission_notify AFTER INSERT OR UPDATE ON submissions FOR EACH ROW EXECUTE FUNCTION trg_submission_notify();




-- MU Study — Complete RLS Policies (EXACT from live project)
-- Run AFTER helper functions (is_admin, is_teacher_of_group, is_student_in_group,
-- can_access_chat_room, current_profile_role) exist.

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignment_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.academic_years ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.academic_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_reads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_reactions ENABLE ROW LEVEL SECURITY;

-- profiles
CREATE POLICY profiles_admin_all ON public.profiles FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY profiles_update_self ON public.profiles FOR UPDATE TO authenticated
  USING ((id = auth.uid()) AND (is_disabled = false)) WITH CHECK (id = auth.uid());
CREATE POLICY profiles_select ON public.profiles FOR SELECT TO authenticated USING (
  (id = auth.uid()) OR is_admin() OR (EXISTS (
    SELECT 1 FROM (((teachers t
      JOIN groups g ON ((g.teacher_id = t.id)))
      JOIN group_students gs ON ((gs.group_id = g.id)))
      JOIN students st ON ((st.id = gs.student_id)))
    WHERE ((t.profile_id = auth.uid()) AND (st.profile_id = profiles.id))
  ))
);
CREATE POLICY profiles_select_groupmates ON public.profiles FOR SELECT TO authenticated USING (
  (EXISTS (
    SELECT 1 FROM (((group_students gs_self
      JOIN students s_self ON ((s_self.id = gs_self.student_id)))
      JOIN group_students gs_other ON ((gs_other.group_id = gs_self.group_id)))
      JOIN students s_other ON ((s_other.id = gs_other.student_id)))
    WHERE ((s_self.profile_id = auth.uid()) AND (s_other.profile_id = profiles.id))
  )) OR (EXISTS (
    SELECT 1 FROM (((group_students gs
      JOIN students s ON ((s.id = gs.student_id)))
      JOIN groups g ON ((g.id = gs.group_id)))
      JOIN teachers t ON ((t.id = g.teacher_id)))
    WHERE ((s.profile_id = auth.uid()) AND (t.profile_id = profiles.id))
  )) OR (EXISTS (
    SELECT 1 FROM (((teachers t
      JOIN groups g ON ((g.teacher_id = t.id)))
      JOIN group_students gs ON ((gs.group_id = g.id)))
      JOIN students s ON ((s.id = gs.student_id)))
    WHERE ((t.profile_id = auth.uid()) AND (s.profile_id = profiles.id))
  ))
);
CREATE POLICY profiles_select_chat_message_senders ON public.profiles FOR SELECT TO authenticated USING (
  EXISTS (
    SELECT 1 FROM chat_messages m
    WHERE ((m.sender_id = profiles.id) AND can_access_chat_room(m.room_id))
  )
);

-- teachers / students
CREATE POLICY teachers_admin ON public.teachers FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY teachers_select ON public.teachers FOR SELECT TO authenticated USING (
  (profile_id = auth.uid()) OR is_admin() OR (current_profile_role() = 'student'::user_role)
);
CREATE POLICY students_admin ON public.students FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY students_select ON public.students FOR SELECT TO authenticated USING (
  (profile_id = auth.uid()) OR is_admin() OR (current_profile_role() = 'teacher'::user_role)
);

-- groups
CREATE POLICY groups_select ON public.groups FOR SELECT TO authenticated USING (
  is_teacher_of_group(id) OR is_student_in_group(id) OR is_admin()
);
CREATE POLICY groups_teacher_manage ON public.groups FOR ALL TO authenticated
  USING (is_teacher_of_group(id) OR is_admin())
  WITH CHECK (is_teacher_of_group(id) OR is_admin());

CREATE POLICY group_students_select ON public.group_students FOR SELECT TO authenticated USING (
  is_teacher_of_group(group_id) OR is_student_in_group(group_id) OR is_admin()
);
CREATE POLICY group_students_manage ON public.group_students FOR ALL TO authenticated
  USING (is_teacher_of_group(group_id) OR is_admin())
  WITH CHECK (is_teacher_of_group(group_id) OR is_admin());

-- assignments / tasks
CREATE POLICY assignments_select ON public.assignments FOR SELECT TO authenticated USING (
  is_teacher_of_group(group_id) OR is_student_in_group(group_id) OR is_admin()
);
CREATE POLICY assignments_teacher ON public.assignments FOR ALL TO authenticated
  USING ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = assignments.teacher_id AND t.profile_id = auth.uid())) OR is_admin())
  WITH CHECK ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = assignments.teacher_id AND t.profile_id = auth.uid())) OR is_admin());

CREATE POLICY tasks_select ON public.tasks FOR SELECT TO authenticated USING (
  EXISTS (
    SELECT 1 FROM assignments a
    WHERE a.id = tasks.assignment_id
      AND (is_teacher_of_group(a.group_id) OR is_student_in_group(a.group_id) OR is_admin())
  )
);
CREATE POLICY tasks_teacher ON public.tasks FOR ALL TO authenticated
  USING ((EXISTS (
    SELECT 1 FROM (assignments a JOIN teachers t ON t.id = a.teacher_id)
    WHERE a.id = tasks.assignment_id AND t.profile_id = auth.uid()
  )) OR is_admin())
  WITH CHECK ((EXISTS (
    SELECT 1 FROM (assignments a JOIN teachers t ON t.id = a.teacher_id)
    WHERE a.id = tasks.assignment_id AND t.profile_id = auth.uid()
  )) OR is_admin());

-- submissions
CREATE POLICY submissions_select ON public.submissions FOR SELECT TO authenticated USING (
  (EXISTS (SELECT 1 FROM students s WHERE s.id = submissions.student_id AND s.profile_id = auth.uid()))
  OR (EXISTS (
    SELECT 1 FROM (tasks tk JOIN assignments a ON a.id = tk.assignment_id)
    WHERE tk.id = submissions.task_id AND is_teacher_of_group(a.group_id)
  ))
  OR is_admin()
);
CREATE POLICY submissions_student ON public.submissions FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM students s WHERE s.id = submissions.student_id AND s.profile_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM students s WHERE s.id = submissions.student_id AND s.profile_id = auth.uid()));
CREATE POLICY submissions_teacher_update ON public.submissions FOR UPDATE TO authenticated
  USING ((EXISTS (
    SELECT 1 FROM (tasks tk JOIN assignments a ON a.id = tk.assignment_id)
    WHERE tk.id = submissions.task_id AND is_teacher_of_group(a.group_id)
  )) OR is_admin())
  WITH CHECK ((EXISTS (
    SELECT 1 FROM (tasks tk JOIN assignments a ON a.id = tk.assignment_id)
    WHERE tk.id = submissions.task_id AND is_teacher_of_group(a.group_id)
  )) OR is_admin());

-- attendance / sessions
CREATE POLICY attendance_select ON public.attendance FOR SELECT TO authenticated USING (
  is_teacher_of_group(group_id) OR is_student_in_group(group_id) OR is_admin()
);
CREATE POLICY attendance_teacher ON public.attendance FOR ALL TO authenticated
  USING (is_teacher_of_group(group_id) OR is_admin())
  WITH CHECK (is_teacher_of_group(group_id) OR is_admin());
CREATE POLICY lesson_sessions_select ON public.lesson_sessions FOR SELECT TO authenticated USING (
  is_teacher_of_group(group_id) OR is_student_in_group(group_id) OR is_admin()
);
CREATE POLICY lesson_sessions_manage ON public.lesson_sessions FOR ALL TO authenticated
  USING (is_teacher_of_group(group_id) OR is_admin())
  WITH CHECK (is_teacher_of_group(group_id) OR is_admin());

-- marks
CREATE POLICY marks_select ON public.marks FOR SELECT TO authenticated USING (
  (EXISTS (SELECT 1 FROM students s WHERE s.id = marks.student_id AND s.profile_id = auth.uid()))
  OR is_teacher_of_group(group_id) OR is_admin()
);
CREATE POLICY marks_teacher_manage ON public.marks FOR ALL TO authenticated
  USING (is_teacher_of_group(group_id) OR is_admin())
  WITH CHECK (is_teacher_of_group(group_id) OR is_admin());

-- announcements / templates / notifications
CREATE POLICY announcements_select ON public.announcements FOR SELECT TO authenticated USING (
  is_teacher_of_group(group_id) OR is_student_in_group(group_id) OR is_admin()
);
CREATE POLICY announcements_teacher ON public.announcements FOR ALL TO authenticated
  USING ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = announcements.teacher_id AND t.profile_id = auth.uid())) OR is_admin())
  WITH CHECK ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = announcements.teacher_id AND t.profile_id = auth.uid())) OR is_admin());
CREATE POLICY assignment_templates_teacher ON public.assignment_templates FOR ALL TO authenticated
  USING ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = assignment_templates.teacher_id AND t.profile_id = auth.uid())) OR is_admin())
  WITH CHECK ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = assignment_templates.teacher_id AND t.profile_id = auth.uid())) OR is_admin());
CREATE POLICY notifications_own ON public.notifications FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- academic
CREATE POLICY academic_years_select ON public.academic_years FOR SELECT TO authenticated USING (true);
CREATE POLICY academic_years_admin ON public.academic_years FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY academic_terms_select ON public.academic_terms FOR SELECT TO authenticated USING (true);
CREATE POLICY academic_terms_admin ON public.academic_terms FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());

-- chat
CREATE POLICY chat_rooms_select ON public.chat_rooms FOR SELECT TO authenticated
  USING (can_access_chat_room(id));
CREATE POLICY chat_rooms_admin_insert ON public.chat_rooms FOR INSERT TO authenticated
  WITH CHECK (is_admin() OR is_teacher_of_group(group_id));

CREATE POLICY chat_messages_select ON public.chat_messages FOR SELECT TO authenticated
  USING (can_access_chat_room(room_id));
CREATE POLICY chat_messages_insert ON public.chat_messages FOR INSERT TO authenticated
  WITH CHECK ((sender_id = auth.uid()) AND can_access_chat_room(room_id));
CREATE POLICY chat_messages_update ON public.chat_messages FOR UPDATE TO authenticated
  USING (is_admin() OR ((sender_id = auth.uid()) AND can_access_chat_room(room_id)))
  WITH CHECK (is_admin() OR ((sender_id = auth.uid()) AND can_access_chat_room(room_id)));
CREATE POLICY chat_messages_delete ON public.chat_messages FOR DELETE TO authenticated
  USING (is_admin() OR ((sender_id = auth.uid()) AND can_access_chat_room(room_id)));

CREATE POLICY message_reads_select ON public.message_reads FOR SELECT TO authenticated USING (
  (user_id = auth.uid()) OR is_admin() OR (EXISTS (
    SELECT 1 FROM chat_messages m WHERE m.id = message_reads.message_id AND can_access_chat_room(m.room_id)
  ))
);
CREATE POLICY message_reads_insert ON public.message_reads FOR INSERT TO authenticated
  WITH CHECK ((user_id = auth.uid()) AND (EXISTS (
    SELECT 1 FROM chat_messages m WHERE m.id = message_reads.message_id AND can_access_chat_room(m.room_id)
  )));
CREATE POLICY message_reads_delete ON public.message_reads FOR DELETE TO authenticated
  USING ((user_id = auth.uid()) OR is_admin());

CREATE POLICY message_reactions_select ON public.message_reactions FOR SELECT TO authenticated USING (
  EXISTS (SELECT 1 FROM chat_messages m WHERE m.id = message_reactions.message_id AND can_access_chat_room(m.room_id))
);
CREATE POLICY message_reactions_insert ON public.message_reactions FOR INSERT TO authenticated
  WITH CHECK ((user_id = auth.uid()) AND (EXISTS (
    SELECT 1 FROM chat_messages m
    WHERE m.id = message_reactions.message_id AND m.is_deleted = false AND can_access_chat_room(m.room_id)
  )));
CREATE POLICY message_reactions_update ON public.message_reactions FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY message_reactions_delete ON public.message_reactions FOR DELETE TO authenticated
  USING ((user_id = auth.uid()) OR is_admin());


-- ---------- STORAGE BUCKETS ----------
INSERT INTO storage.buckets (id, name, public) VALUES
  ('avatars', 'avatars', true),
  ('submissions', 'submissions', false),
  ('assignments', 'assignments', false),
  ('announcements', 'announcements', false),
  ('chat-images', 'chat-images', false),
  ('chat-videos', 'chat-videos', false),
  ('chat-voices', 'chat-voices', false),
  ('chat-files', 'chat-files', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies (EXACT from live)
CREATE POLICY storage_avatars_auth ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'avatars') WITH CHECK (bucket_id = 'avatars');
CREATE POLICY storage_avatars_read ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'avatars');
CREATE POLICY storage_submissions_auth ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'submissions') WITH CHECK (bucket_id = 'submissions');
CREATE POLICY storage_assignments_auth ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'assignments') WITH CHECK (bucket_id = 'assignments');
CREATE POLICY storage_announcements_auth ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'announcements') WITH CHECK (bucket_id = 'announcements');

CREATE POLICY storage_chat_images_select ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'chat-images' AND can_access_chat_room(chat_storage_room_id(name)));
CREATE POLICY storage_chat_images_insert ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'chat-images' AND can_access_chat_room(chat_storage_room_id(name)) AND (storage.foldername(name))[2] = (auth.uid())::text);
CREATE POLICY storage_chat_images_update ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'chat-images' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text))
  WITH CHECK (bucket_id = 'chat-images' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text));
CREATE POLICY storage_chat_images_delete ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'chat-images' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text));

CREATE POLICY storage_chat_videos_select ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'chat-videos' AND can_access_chat_room(chat_storage_room_id(name)));
CREATE POLICY storage_chat_videos_insert ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'chat-videos' AND can_access_chat_room(chat_storage_room_id(name)) AND (storage.foldername(name))[2] = (auth.uid())::text);
CREATE POLICY storage_chat_videos_update ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'chat-videos' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text))
  WITH CHECK (bucket_id = 'chat-videos' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text));
CREATE POLICY storage_chat_videos_delete ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'chat-videos' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text));

CREATE POLICY storage_chat_voices_select ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'chat-voices' AND can_access_chat_room(chat_storage_room_id(name)));
CREATE POLICY storage_chat_voices_insert ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'chat-voices' AND can_access_chat_room(chat_storage_room_id(name)) AND (storage.foldername(name))[2] = (auth.uid())::text);
CREATE POLICY storage_chat_voices_update ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'chat-voices' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text))
  WITH CHECK (bucket_id = 'chat-voices' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text));
CREATE POLICY storage_chat_voices_delete ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'chat-voices' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text));

CREATE POLICY storage_chat_files_select ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'chat-files' AND can_access_chat_room(chat_storage_room_id(name)));
CREATE POLICY storage_chat_files_insert ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'chat-files' AND can_access_chat_room(chat_storage_room_id(name)) AND (storage.foldername(name))[2] = (auth.uid())::text);
CREATE POLICY storage_chat_files_update ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'chat-files' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text))
  WITH CHECK (bucket_id = 'chat-files' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text));
CREATE POLICY storage_chat_files_delete ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'chat-files' AND (is_admin() OR (storage.foldername(name))[2] = (auth.uid())::text));


-- ---------- REALTIME ----------
-- Add tables to supabase_realtime publication (Dashboard or):
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.message_reads;
ALTER PUBLICATION supabase_realtime ADD TABLE public.message_reactions;


-- ---------- GRANTS (recommended hardening vs live) ----------
-- EXACT live: many RPCs executable by anon; harden for production:
REVOKE EXECUTE ON FUNCTION public.seed_demo_data() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public._demo_insert_user(text, text, text, user_role) FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_auth_email_by_username(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.admin_create_user(text, text, text, user_role, sphere_type) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_reset_password(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.chat_unread_counts() TO authenticated;
GRANT EXECUTE ON FUNCTION public.toggle_message_reaction(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.ensure_lesson_session(uuid, date) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_access_chat_room(uuid) TO authenticated;
