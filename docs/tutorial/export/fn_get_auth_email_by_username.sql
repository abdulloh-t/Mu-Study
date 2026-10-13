CREATE OR REPLACE FUNCTION public.get_auth_email_by_username(p_username text)
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT auth_email FROM public.profiles
  WHERE lower(username) = lower(trim(p_username)) AND is_disabled = FALSE LIMIT 1;
$function$
