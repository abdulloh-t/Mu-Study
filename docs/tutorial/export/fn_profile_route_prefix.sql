CREATE OR REPLACE FUNCTION public.profile_route_prefix(p_user_id uuid)
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT CASE role
    WHEN 'teacher' THEN '/teacher'
    WHEN 'admin' THEN '/admin'
    ELSE '/student'
  END
  FROM public.profiles
  WHERE id = p_user_id;
$function$
