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
