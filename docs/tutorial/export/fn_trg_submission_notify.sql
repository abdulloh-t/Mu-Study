CREATE OR REPLACE FUNCTION public.trg_submission_notify()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_teacher_profile UUID;
  v_student_name TEXT;
  v_task_title TEXT;
  v_assignment_id UUID;
  v_prefix TEXT;
  v_is_submit BOOLEAN;
BEGIN
  v_is_submit :=
    (TG_OP = 'INSERT' AND (NEW.file_url IS NOT NULL OR NEW.text_answer IS NOT NULL OR NEW.submitted_at IS NOT NULL))
    OR (
      TG_OP = 'UPDATE'
      AND (
        (OLD.file_url IS DISTINCT FROM NEW.file_url AND NEW.file_url IS NOT NULL)
        OR (OLD.text_answer IS DISTINCT FROM NEW.text_answer AND NEW.text_answer IS NOT NULL)
        OR (OLD.submitted_at IS DISTINCT FROM NEW.submitted_at AND NEW.submitted_at IS NOT NULL)
        OR (OLD.is_completed IS DISTINCT FROM NEW.is_completed AND NEW.is_completed IS TRUE)
      )
    );

  IF NOT v_is_submit THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE'
     AND OLD.score IS DISTINCT FROM NEW.score
     AND OLD.file_url IS NOT DISTINCT FROM NEW.file_url
     AND OLD.text_answer IS NOT DISTINCT FROM NEW.text_answer
     AND OLD.submitted_at IS NOT DISTINCT FROM NEW.submitted_at
     AND OLD.is_completed IS NOT DISTINCT FROM NEW.is_completed THEN
    RETURN NEW;
  END IF;

  SELECT t.profile_id, tk.title, a.id
    INTO v_teacher_profile, v_task_title, v_assignment_id
  FROM public.tasks tk
  JOIN public.assignments a ON a.id = tk.assignment_id
  JOIN public.teachers t ON t.id = a.teacher_id
  WHERE tk.id = NEW.task_id;

  IF v_teacher_profile IS NULL THEN RETURN NEW; END IF;

  SELECT COALESCE(p.full_name, p.username, 'Student')
    INTO v_student_name
  FROM public.students s
  JOIN public.profiles p ON p.id = s.profile_id
  WHERE s.id = NEW.student_id;

  v_prefix := COALESCE(public.profile_route_prefix(v_teacher_profile), '/teacher');

  PERFORM public.notify_user(
    v_teacher_profile,
    'New submission',
    COALESCE(v_student_name, 'Student') || ' · ' || COALESCE(v_task_title, 'Task'),
    'submission',
    v_prefix || '/assignments/' || v_assignment_id::text,
    NEW.id
  );
  RETURN NEW;
END;
$function$
