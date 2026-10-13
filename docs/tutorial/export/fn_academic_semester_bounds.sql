CREATE OR REPLACE FUNCTION public.academic_semester_bounds(p_start_year integer, p_semester integer)
 RETURNS TABLE(starts_on date, ends_on date)
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
  IF p_semester < 1 OR p_semester > 4 THEN
    RAISE EXCEPTION 'semester must be 1–4';
  END IF;

  RETURN QUERY
  SELECT
    CASE p_semester
      WHEN 1 THEN make_date(p_start_year, 8, 1)
      WHEN 2 THEN make_date(p_start_year, 11, 11)
      WHEN 3 THEN make_date(p_start_year + 1, 1, 11)
      ELSE make_date(p_start_year + 1, 3, 28)
    END,
    CASE p_semester
      WHEN 1 THEN make_date(p_start_year, 11, 2)
      WHEN 2 THEN make_date(p_start_year, 12, 28)
      WHEN 3 THEN make_date(p_start_year + 1, 3, 20)
      ELSE make_date(p_start_year + 1, 6, 19)
    END;
END;
$function$
