CREATE OR REPLACE FUNCTION public.academic_year_label(p_start_year integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  SELECT p_start_year::TEXT || '–' || lpad(((p_start_year + 1) % 100)::TEXT, 2, '0');
$function$
