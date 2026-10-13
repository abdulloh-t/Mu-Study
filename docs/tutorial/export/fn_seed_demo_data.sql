CREATE OR REPLACE FUNCTION public.seed_demo_data()
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
DECLARE
  v_admin UUID; v_math UUID; v_eng UUID; v_student UUID;
  v_math_tid UUID; v_eng_tid UUID; v_student_sid UUID;
  v_group UUID; v_pack UUID;
BEGIN
  IF EXISTS (SELECT 1 FROM public.profiles LIMIT 1) THEN RETURN 'already_seeded'; END IF;

  v_admin := public._demo_insert_user('@admin', 'password123', 'Platform Admin', 'admin');
  v_math := public._demo_insert_user('@math_teacher', 'password123', 'Amina Math', 'teacher');
  v_eng := public._demo_insert_user('@english_teacher', 'password123', 'James English', 'teacher');
  v_student := public._demo_insert_user('@test_user', 'password123', 'Demo Student', 'student');

  INSERT INTO public.teachers (profile_id, sphere) VALUES (v_math, 'math') RETURNING id INTO v_math_tid;
  INSERT INTO public.teachers (profile_id, sphere) VALUES (v_eng, 'english') RETURNING id INTO v_eng_tid;

  INSERT INTO public.groups (teacher_id, title) VALUES (v_math_tid, 'Math Group A') RETURNING id INTO v_group;
  INSERT INTO public.groups (teacher_id, title) VALUES (v_math_tid, 'Math Group B');
  INSERT INTO public.groups (teacher_id, title) VALUES (v_math_tid, 'Math Group C');
  INSERT INTO public.groups (teacher_id, title) VALUES (v_eng_tid, 'English Group A');
  INSERT INTO public.groups (teacher_id, title) VALUES (v_eng_tid, 'English Group B');
  INSERT INTO public.groups (teacher_id, title) VALUES (v_eng_tid, 'English Group C');

  SELECT id INTO v_student_sid FROM public.students WHERE profile_id = v_student;
  INSERT INTO public.group_students (group_id, student_id) VALUES (v_group, v_student_sid);

  INSERT INTO public.assignments (teacher_id, group_id, type, title, description, due_date)
  VALUES (v_math_tid, v_group, 'static', 'Read page 12', 'Review chapter on linear equations.', NOW() + INTERVAL '2 days');

  INSERT INTO public.assignments (teacher_id, group_id, type, title, description, due_date)
  VALUES (v_math_tid, v_group, 'homework_pack', 'Algebra Week 1 Pack', 'Complete all tasks below.', NOW() + INTERVAL '5 days')
  RETURNING id INTO v_pack;

  INSERT INTO public.tasks (assignment_id, title, description, sort_order, link_url)
  VALUES (v_pack, 'Practice set A', 'Solve exercises 1-10.', 1, 'https://www.khanacademy.org/math/algebra');
  INSERT INTO public.tasks (assignment_id, title, description, sort_order)
  VALUES (v_pack, 'Written reflection', 'Explain how you checked your answers.', 2);

  INSERT INTO public.announcements (teacher_id, group_id, title, description)
  VALUES (v_math_tid, v_group, 'Welcome to Math Group A', 'Office hours every Wednesday.');

  INSERT INTO public.attendance (group_id, student_id, status, date)
  VALUES (v_group, v_student_sid, 'present', CURRENT_DATE);

  INSERT INTO public.notifications (user_id, title, body)
  VALUES (v_student, 'Welcome to MU Study', 'Your demo account is ready.');

  RETURN 'seeded';
END; $function$
