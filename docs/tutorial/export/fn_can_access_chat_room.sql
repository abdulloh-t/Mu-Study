CREATE OR REPLACE FUNCTION public.can_access_chat_room(rid uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT public.is_admin()
    OR EXISTS (
      SELECT 1
      FROM public.chat_rooms cr
      WHERE cr.id = rid
        AND (
          public.is_teacher_of_group(cr.group_id)
          OR public.is_student_in_group(cr.group_id)
        )
    );
$function$
