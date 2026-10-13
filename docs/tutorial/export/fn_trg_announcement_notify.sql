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
