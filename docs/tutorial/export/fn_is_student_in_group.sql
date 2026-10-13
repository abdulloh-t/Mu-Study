CREATE OR REPLACE FUNCTION public.is_student_in_group(gid uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM public.group_students gs
    JOIN public.students s ON s.id = gs.student_id
    WHERE gs.group_id = gid AND s.profile_id = auth.uid()
  );
$function$
