CREATE OR REPLACE FUNCTION public.chat_unread_counts()
 RETURNS TABLE(room_id uuid, unread_count bigint)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT
    m.room_id,
    COUNT(*)::BIGINT AS unread_count
  FROM public.chat_messages m
  WHERE m.is_deleted = FALSE
    AND m.sender_id <> auth.uid()
    AND public.can_access_chat_room(m.room_id)
    AND NOT EXISTS (
      SELECT 1
      FROM public.message_reads r
      WHERE r.message_id = m.id
        AND r.user_id = auth.uid()
    )
  GROUP BY m.room_id;
$function$
