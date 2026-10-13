CREATE OR REPLACE FUNCTION public.trg_mark_notify()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid UUID;
  v_prefix TEXT;
  v_body TEXT;
BEGIN
  IF TG_OP = 'UPDATE'
     AND NEW.percentage IS NOT DISTINCT FROM OLD.percentage
     AND NEW.comment IS NOT DISTINCT FROM OLD.comment THEN
    RETURN NEW;
  END IF;

  SELECT profile_id INTO v_uid FROM public.students WHERE id = NEW.student_id;
  IF v_uid IS NULL THEN RETURN NEW; END IF;

  v_prefix := COALESCE(public.profile_route_prefix(v_uid), '/student');
  v_body := NEW.title || ' — ' || ROUND(NEW.percentage)::TEXT || '%';
  IF NEW.comment IS NOT NULL AND length(trim(NEW.comment)) > 0 THEN
    v_body := v_body || E'\n' || left(trim(NEW.comment), 160);
  END IF;

  PERFORM public.notify_user(
    v_uid,
    'Work graded',
    v_body,
    'graded',
    v_prefix || '/marks',
    NEW.id
  );
  RETURN NEW;
END;
$function$
