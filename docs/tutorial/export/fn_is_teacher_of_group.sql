CREATE OR REPLACE FUNCTION public.is_teacher_of_group(gid uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM public.groups g
    JOIN public.teachers t ON t.id = g.teacher_id
    WHERE g.id = gid AND t.profile_id = auth.uid()
  );
$function$
