-- Stop auto-creating Group 1/2/3 when a teacher is created.
-- Admins create groups with exact titles from the Groups screen.
-- Also prevent duplicate (teacher_id, title) rows.

CREATE OR REPLACE FUNCTION public.admin_create_user(
  p_username TEXT,
  p_password TEXT,
  p_full_name TEXT,
  p_role public.user_role,
  p_sphere public.sphere_type DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
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
$$;

GRANT EXECUTE ON FUNCTION public.admin_create_user(
  TEXT, TEXT, TEXT, public.user_role, public.sphere_type
) TO authenticated;

-- Deduplicate same title for the same teacher (keep oldest).
DELETE FROM public.groups g
USING public.groups newer
WHERE g.teacher_id = newer.teacher_id
  AND g.title = newer.title
  AND g.created_at > newer.created_at;

-- One title per teacher.
CREATE UNIQUE INDEX IF NOT EXISTS groups_teacher_title_uidx
  ON public.groups (teacher_id, title);

-- Remove empty auto-groups named Group 1/2/3 with no students.
DELETE FROM public.groups g
WHERE g.title ~ '^Group [123]$'
  AND NOT EXISTS (
    SELECT 1 FROM public.group_students gs WHERE gs.group_id = g.id
  );
