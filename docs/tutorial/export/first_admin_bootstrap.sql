-- First admin bootstrap (EXACT pattern mirroring admin_create_user).
-- Run in Supabase SQL Editor AFTER any app user exists.
-- Replace YOUR_STRONG_PASSWORD. Username example: @admin

DO $$
DECLARE
  v_user_id UUID := gen_random_uuid();
  v_username TEXT := '@admin';
  v_password TEXT := 'YOUR_STRONG_PASSWORD';
  v_full_name TEXT := 'System Admin';
  v_email TEXT;
BEGIN
  v_email := lower(trim(replace(v_username, '@', ''))) || '@mustudy.internal';

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
    extensions.crypt(v_password, extensions.gen_salt('bf')),
    NOW(),
    jsonb_build_object('provider', 'email', 'providers', ARRAY['email']),
    jsonb_build_object('username', v_username, 'full_name', v_full_name, 'role', 'admin'),
    NOW(), NOW(), '', '', '', '', false, false
  );

  INSERT INTO auth.identities (
    id, user_id, identity_data, provider, provider_id,
    last_sign_in_at, created_at, updated_at
  ) VALUES (
    gen_random_uuid(),
    v_user_id,
    jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true),
    'email',
    v_email,
    NOW(), NOW(), NOW()
  );

  INSERT INTO public.profiles (id, username, full_name, role, auth_email)
  VALUES (v_user_id, trim(v_username), v_full_name, 'admin', v_email);

  RAISE NOTICE 'Created admin id=% email=% username=%', v_user_id, v_email, v_username;
END $$;

-- VERIFY:
-- SELECT id, username, role, auth_email, is_disabled FROM profiles WHERE role = 'admin';
-- Then login in the app with username @admin and YOUR_STRONG_PASSWORD.
