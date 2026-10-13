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
