CREATE OR REPLACE FUNCTION public.current_profile_role()
 RETURNS user_role
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$ SELECT role FROM public.profiles WHERE id = auth.uid(); $function$
