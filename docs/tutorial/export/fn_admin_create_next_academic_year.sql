CREATE OR REPLACE FUNCTION public.admin_create_next_academic_year()
 RETURNS academic_years
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_next INT;
  v_now DATE := CURRENT_DATE;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only admins can create academic years';
  END IF;

  SELECT COALESCE(MAX(start_year), CASE
    WHEN EXTRACT(MONTH FROM v_now) >= 8 THEN EXTRACT(YEAR FROM v_now)::INT - 1
    ELSE EXTRACT(YEAR FROM v_now)::INT - 2
  END) + 1
  INTO v_next
  FROM public.academic_years;

  RETURN public.create_academic_year_with_terms(
    v_next,
    FALSE,
    auth.uid()
  );
END;
$function$
