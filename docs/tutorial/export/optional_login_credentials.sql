-- Admin printable login slips.
-- Stores the password that was set at create/reset time (Auth only keeps a hash).

CREATE TABLE IF NOT EXISTS public.login_credentials (
  profile_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  password text NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.login_credentials ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.login_credentials FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.admin_save_login_password(
  p_user_id uuid,
  p_password text
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not allowed';
  END IF;

  INSERT INTO public.login_credentials (profile_id, password, updated_at)
  VALUES (p_user_id, p_password, now())
  ON CONFLICT (profile_id) DO UPDATE
    SET password = excluded.password,
        updated_at = now();
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_list_login_slips(
  p_role public.user_role DEFAULT 'student',
  p_group_id uuid DEFAULT NULL
)
RETURNS TABLE (
  profile_id uuid,
  username text,
  full_name text,
  password text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
  r record;
  v_password text;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not allowed';
  END IF;

  FOR r IN
    SELECT * FROM (
      SELECT DISTINCT ON (p.id)
        p.id,
        p.username,
        coalesce(nullif(trim(p.full_name), ''), p.username) AS full_name,
        c.password AS saved_password
      FROM public.profiles p
      LEFT JOIN public.login_credentials c ON c.profile_id = p.id
      LEFT JOIN public.students s ON s.profile_id = p.id
      LEFT JOIN public.group_students gs ON gs.student_id = s.id
      WHERE p.role = p_role
        AND coalesce(p.is_disabled, false) = false
        AND (
          p_group_id IS NULL
          OR gs.group_id = p_group_id
        )
      ORDER BY p.id
    ) unique_profiles
    ORDER BY unique_profiles.full_name, unique_profiles.username
  LOOP
    v_password := r.saved_password;
    IF v_password IS NULL OR v_password = '' THEN
      LOOP
        v_password := substr(replace(gen_random_uuid()::text, '-', ''), 1, 16);
        EXIT WHEN NOT EXISTS (
          SELECT 1 FROM public.login_credentials WHERE password = v_password
        );
      END LOOP;

      UPDATE auth.users
      SET encrypted_password = extensions.crypt(v_password, extensions.gen_salt('bf')),
          updated_at = now()
      WHERE id = r.id;

      INSERT INTO public.login_credentials (profile_id, password, updated_at)
      VALUES (r.id, v_password, now())
      ON CONFLICT (profile_id) DO UPDATE
        SET password = excluded.password,
            updated_at = now();
    END IF;

    profile_id := r.id;
    username := r.username;
    full_name := r.full_name;
    password := v_password;
    RETURN NEXT;
  END LOOP;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_save_login_password(uuid, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.admin_list_login_slips(public.user_role, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_save_login_password(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_list_login_slips(public.user_role, uuid) TO authenticated;
