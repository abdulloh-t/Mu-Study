CREATE OR REPLACE FUNCTION public.sync_submission_mark()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE v_group_id UUID; v_teacher_id UUID; v_title TEXT;
BEGIN
  IF NEW.score IS NULL THEN
    DELETE FROM public.marks WHERE submission_id = NEW.id;
    RETURN NEW;
  END IF;

  SELECT a.group_id, a.teacher_id, tk.title
    INTO v_group_id, v_teacher_id, v_title
  FROM public.tasks tk
  JOIN public.assignments a ON a.id = tk.assignment_id
  WHERE tk.id = NEW.task_id;

  IF v_group_id IS NULL THEN RETURN NEW; END IF;

  INSERT INTO public.marks (
    group_id, student_id, teacher_id, submission_id, title, category, percentage, comment
  ) VALUES (
    v_group_id, NEW.student_id, v_teacher_id, NEW.id,
    COALESCE(v_title, 'Homework'), 'homework', NEW.score, COALESCE(NEW.feedback, '')
  )
  ON CONFLICT (submission_id) DO UPDATE SET
    percentage = EXCLUDED.percentage,
    title = EXCLUDED.title,
    comment = EXCLUDED.comment,
    updated_at = NOW();

  RETURN NEW;
END; $function$
