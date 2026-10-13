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
