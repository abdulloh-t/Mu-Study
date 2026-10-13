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
