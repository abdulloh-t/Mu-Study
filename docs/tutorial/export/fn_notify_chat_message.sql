CREATE OR REPLACE FUNCTION public.notify_chat_message(p_user_id uuid, p_title text, p_body text, p_action_path text, p_room_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_id UUID;
BEGIN
  SELECT id INTO v_id
  FROM public.notifications
  WHERE user_id = p_user_id
    AND kind = 'chat'
    AND ref_id = p_room_id
    AND is_read = FALSE
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_id IS NOT NULL THEN
    UPDATE public.notifications
    SET title = p_title,
        body = COALESCE(p_body, ''),
        action_path = p_action_path,
        created_at = NOW()
    WHERE id = v_id;
  ELSE
    PERFORM public.notify_user(
      p_user_id, p_title, p_body, 'chat', p_action_path, p_room_id
    );
  END IF;
END;
$function$
