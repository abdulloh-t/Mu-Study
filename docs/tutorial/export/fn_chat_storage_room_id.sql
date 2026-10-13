CREATE OR REPLACE FUNCTION public.chat_storage_room_id(object_name text)
 RETURNS uuid
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'public'
AS $function$
DECLARE
  part TEXT := split_part(object_name, '/', 1);
BEGIN
  IF part ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
    RETURN part::UUID;
  END IF;
  RETURN NULL;
END;
$function$
