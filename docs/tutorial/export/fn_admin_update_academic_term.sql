CREATE OR REPLACE FUNCTION public.admin_update_academic_term(p_term_id uuid, p_starts_on date, p_ends_on date)
 RETURNS academic_terms
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_term public.academic_terms;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only admins can edit term dates';
  END IF;

  IF p_ends_on < p_starts_on THEN
    RAISE EXCEPTION 'End date must be on or after start date';
  END IF;

  UPDATE public.academic_terms
  SET starts_on = p_starts_on, ends_on = p_ends_on
  WHERE id = p_term_id
  RETURNING * INTO v_term;

  IF v_term.id IS NULL THEN
    RAISE EXCEPTION 'Academic term not found';
  END IF;

  RETURN v_term;
END;
$function$
