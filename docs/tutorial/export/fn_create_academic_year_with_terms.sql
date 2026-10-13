CREATE OR REPLACE FUNCTION public.create_academic_year_with_terms(p_start_year integer, p_is_current boolean DEFAULT false, p_created_by uuid DEFAULT NULL::uuid)
 RETURNS academic_years
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_year public.academic_years;
  v_sem INT;
  v_bounds RECORD;
BEGIN
  IF p_is_current THEN
    UPDATE public.academic_years SET is_current = FALSE WHERE is_current;
  END IF;

  INSERT INTO public.academic_years (start_year, label, is_current, created_by)
  VALUES (
    p_start_year,
    public.academic_year_label(p_start_year),
    p_is_current,
    p_created_by
  )
  RETURNING * INTO v_year;

  FOR v_sem IN 1..4 LOOP
    SELECT * INTO v_bounds
    FROM public.academic_semester_bounds(p_start_year, v_sem);

    INSERT INTO public.academic_terms (
      academic_year_id, semester, starts_on, ends_on
    ) VALUES (
      v_year.id, v_sem, v_bounds.starts_on, v_bounds.ends_on
    );
  END LOOP;

  RETURN v_year;
END;
$function$
