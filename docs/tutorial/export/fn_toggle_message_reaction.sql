CREATE OR REPLACE FUNCTION public.toggle_message_reaction(p_message_id uuid, p_emoji text)
 RETURNS message_reactions
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid UUID := auth.uid();
  v_existing public.message_reactions;
  v_result public.message_reactions;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF p_emoji IS NULL OR char_length(trim(p_emoji)) < 1 THEN
    RAISE EXCEPTION 'Emoji required';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.chat_messages m
    WHERE m.id = p_message_id
      AND m.is_deleted = FALSE
      AND public.can_access_chat_room(m.room_id)
  ) THEN
    RAISE EXCEPTION 'Message not found or inaccessible';
  END IF;

  SELECT * INTO v_existing
  FROM public.message_reactions
  WHERE message_id = p_message_id AND user_id = v_uid;

  IF v_existing.id IS NOT NULL AND v_existing.emoji = p_emoji THEN
    DELETE FROM public.message_reactions WHERE id = v_existing.id;
    RETURN v_existing;
  END IF;

  INSERT INTO public.message_reactions (message_id, user_id, emoji)
  VALUES (p_message_id, v_uid, p_emoji)
  ON CONFLICT (message_id, user_id)
  DO UPDATE SET emoji = EXCLUDED.emoji, created_at = NOW()
  RETURNING * INTO v_result;

  RETURN v_result;
END;
$function$
