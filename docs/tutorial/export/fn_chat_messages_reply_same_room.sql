CREATE OR REPLACE FUNCTION public.chat_messages_reply_same_room()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_room UUID;
BEGIN
  IF NEW.reply_to_message_id IS NULL THEN
    RETURN NEW;
  END IF;
  IF NEW.reply_to_message_id = NEW.id THEN
    RAISE EXCEPTION 'message cannot reply to itself';
  END IF;
  SELECT room_id INTO v_room
  FROM public.chat_messages
  WHERE id = NEW.reply_to_message_id;
  IF v_room IS NULL THEN
    RAISE EXCEPTION 'reply target not found';
  END IF;
  IF v_room <> NEW.room_id THEN
    RAISE EXCEPTION 'reply must be in the same chat room';
  END IF;
  RETURN NEW;
END;
$function$
