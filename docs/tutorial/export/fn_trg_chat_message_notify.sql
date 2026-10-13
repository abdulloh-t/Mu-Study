CREATE OR REPLACE FUNCTION public.trg_chat_message_notify()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  r RECORD;
  v_group_id UUID;
  v_group_title TEXT;
  v_sender_name TEXT;
  v_preview TEXT;
  v_prefix TEXT;
  v_path TEXT;
BEGIN
  IF NEW.is_deleted THEN
    RETURN NEW;
  END IF;

  SELECT cr.group_id, g.title
    INTO v_group_id, v_group_title
  FROM public.chat_rooms cr
  JOIN public.groups g ON g.id = cr.group_id
  WHERE cr.id = NEW.room_id;

  IF v_group_id IS NULL THEN RETURN NEW; END IF;

  SELECT COALESCE(full_name, username, 'Someone')
    INTO v_sender_name
  FROM public.profiles
  WHERE id = NEW.sender_id;

  v_preview := CASE NEW.message_type
    WHEN 'text' THEN left(COALESCE(NEW.text_content, ''), 120)
    WHEN 'image' THEN 'Photo'
    WHEN 'video' THEN 'Video'
    WHEN 'voice' THEN 'Voice message'
    ELSE 'New message'
  END;

  FOR r IN
    SELECT DISTINCT uid FROM (
      SELECT s.profile_id AS uid
      FROM public.group_students gs
      JOIN public.students s ON s.id = gs.student_id
      WHERE gs.group_id = v_group_id
      UNION
      SELECT t.profile_id AS uid
      FROM public.groups g
      JOIN public.teachers t ON t.id = g.teacher_id
      WHERE g.id = v_group_id
    ) members
    WHERE uid IS DISTINCT FROM NEW.sender_id
  LOOP
    v_prefix := COALESCE(public.profile_route_prefix(r.uid), '/student');
    v_path := v_prefix || '/chat/' || NEW.room_id::text;
    PERFORM public.notify_chat_message(
      r.uid,
      COALESCE(v_group_title, 'Chat'),
      COALESCE(v_sender_name, 'Someone') || ': ' || v_preview,
      v_path,
      NEW.room_id
    );
  END LOOP;

  RETURN NEW;
END;
$function$
