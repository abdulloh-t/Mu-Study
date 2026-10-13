CREATE OR REPLACE FUNCTION public.admin_set_current_academic_year(p_year_id uuid)
 RETURNS academic_years
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_year public.academic_years;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only admins can set the current academic year';
  END IF;

  UPDATE public.academic_years SET is_current = FALSE WHERE is_current;

  UPDATE public.academic_years
  SET is_current = TRUE
  WHERE id = p_year_id
  RETURNING * INTO v_year;

  IF v_year.id IS NULL THEN
    RAISE EXCEPTION 'Academic year not found';
  END IF;

  RETURN v_year;
END;
$function$
