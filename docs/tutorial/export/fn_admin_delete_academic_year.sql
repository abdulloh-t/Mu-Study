CREATE OR REPLACE FUNCTION public.admin_delete_academic_year(p_year_id uuid)
 RETURNS academic_years
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_year public.academic_years;
  v_remaining INT;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only admins can delete academic years';
  END IF;

  SELECT * INTO v_year
  FROM public.academic_years
  WHERE id = p_year_id;

  IF v_year.id IS NULL THEN
    RAISE EXCEPTION 'Academic year not found';
  END IF;

  IF v_year.is_current THEN
    RAISE EXCEPTION 'Cannot delete the current academic year. Set another year as current first.';
  END IF;

  SELECT COUNT(*) INTO v_remaining FROM public.academic_years;
  IF v_remaining <= 1 THEN
    RAISE EXCEPTION 'Cannot delete the last academic year';
  END IF;

  DELETE FROM public.academic_years
  WHERE id = p_year_id
  RETURNING * INTO v_year;

  RETURN v_year;
END;
$function$
