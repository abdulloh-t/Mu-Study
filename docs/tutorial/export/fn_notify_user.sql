CREATE OR REPLACE FUNCTION public.notify_user(p_user_id uuid, p_title text, p_body text, p_kind text DEFAULT 'system'::text, p_action_path text DEFAULT NULL::text, p_ref_id uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  INSERT INTO public.notifications (user_id, title, body, kind, action_path, ref_id)
  VALUES (
    p_user_id,
    p_title,
    COALESCE(p_body, ''),
    COALESCE(NULLIF(trim(p_kind), ''), 'system'),
    p_action_path,
    p_ref_id
  );
END;
$function$
