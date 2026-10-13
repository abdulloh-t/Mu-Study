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
