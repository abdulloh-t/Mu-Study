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
