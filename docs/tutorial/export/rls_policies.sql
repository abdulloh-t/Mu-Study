-- MU Study — Complete RLS Policies (EXACT from live project)
-- Run AFTER helper functions (is_admin, is_teacher_of_group, is_student_in_group,
-- can_access_chat_room, current_profile_role) exist.

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignment_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.academic_years ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.academic_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_reads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_reactions ENABLE ROW LEVEL SECURITY;

-- profiles
CREATE POLICY profiles_admin_all ON public.profiles FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY profiles_update_self ON public.profiles FOR UPDATE TO authenticated
  USING ((id = auth.uid()) AND (is_disabled = false)) WITH CHECK (id = auth.uid());
CREATE POLICY profiles_select ON public.profiles FOR SELECT TO authenticated USING (
  (id = auth.uid()) OR is_admin() OR (EXISTS (
    SELECT 1 FROM (((teachers t
      JOIN groups g ON ((g.teacher_id = t.id)))
      JOIN group_students gs ON ((gs.group_id = g.id)))
      JOIN students st ON ((st.id = gs.student_id)))
    WHERE ((t.profile_id = auth.uid()) AND (st.profile_id = profiles.id))
  ))
);
CREATE POLICY profiles_select_groupmates ON public.profiles FOR SELECT TO authenticated USING (
  (EXISTS (
    SELECT 1 FROM (((group_students gs_self
      JOIN students s_self ON ((s_self.id = gs_self.student_id)))
      JOIN group_students gs_other ON ((gs_other.group_id = gs_self.group_id)))
      JOIN students s_other ON ((s_other.id = gs_other.student_id)))
    WHERE ((s_self.profile_id = auth.uid()) AND (s_other.profile_id = profiles.id))
  )) OR (EXISTS (
    SELECT 1 FROM (((group_students gs
      JOIN students s ON ((s.id = gs.student_id)))
      JOIN groups g ON ((g.id = gs.group_id)))
      JOIN teachers t ON ((t.id = g.teacher_id)))
    WHERE ((s.profile_id = auth.uid()) AND (t.profile_id = profiles.id))
  )) OR (EXISTS (
    SELECT 1 FROM (((teachers t
      JOIN groups g ON ((g.teacher_id = t.id)))
      JOIN group_students gs ON ((gs.group_id = g.id)))
      JOIN students s ON ((s.id = gs.student_id)))
    WHERE ((t.profile_id = auth.uid()) AND (s.profile_id = profiles.id))
  ))
);
CREATE POLICY profiles_select_chat_message_senders ON public.profiles FOR SELECT TO authenticated USING (
  EXISTS (
    SELECT 1 FROM chat_messages m
    WHERE ((m.sender_id = profiles.id) AND can_access_chat_room(m.room_id))
  )
);

-- teachers / students
CREATE POLICY teachers_admin ON public.teachers FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY teachers_select ON public.teachers FOR SELECT TO authenticated USING (
  (profile_id = auth.uid()) OR is_admin() OR (current_profile_role() = 'student'::user_role)
);
CREATE POLICY students_admin ON public.students FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY students_select ON public.students FOR SELECT TO authenticated USING (
  (profile_id = auth.uid()) OR is_admin() OR (current_profile_role() = 'teacher'::user_role)
);

-- groups
CREATE POLICY groups_select ON public.groups FOR SELECT TO authenticated USING (
  is_teacher_of_group(id) OR is_student_in_group(id) OR is_admin()
);
CREATE POLICY groups_teacher_manage ON public.groups FOR ALL TO authenticated
  USING (is_teacher_of_group(id) OR is_admin())
  WITH CHECK (is_teacher_of_group(id) OR is_admin());

CREATE POLICY group_students_select ON public.group_students FOR SELECT TO authenticated USING (
  is_teacher_of_group(group_id) OR is_student_in_group(group_id) OR is_admin()
);
CREATE POLICY group_students_manage ON public.group_students FOR ALL TO authenticated
  USING (is_teacher_of_group(group_id) OR is_admin())
  WITH CHECK (is_teacher_of_group(group_id) OR is_admin());

-- assignments / tasks
CREATE POLICY assignments_select ON public.assignments FOR SELECT TO authenticated USING (
  is_teacher_of_group(group_id) OR is_student_in_group(group_id) OR is_admin()
);
CREATE POLICY assignments_teacher ON public.assignments FOR ALL TO authenticated
  USING ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = assignments.teacher_id AND t.profile_id = auth.uid())) OR is_admin())
  WITH CHECK ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = assignments.teacher_id AND t.profile_id = auth.uid())) OR is_admin());

CREATE POLICY tasks_select ON public.tasks FOR SELECT TO authenticated USING (
  EXISTS (
    SELECT 1 FROM assignments a
    WHERE a.id = tasks.assignment_id
      AND (is_teacher_of_group(a.group_id) OR is_student_in_group(a.group_id) OR is_admin())
  )
);
CREATE POLICY tasks_teacher ON public.tasks FOR ALL TO authenticated
  USING ((EXISTS (
    SELECT 1 FROM (assignments a JOIN teachers t ON t.id = a.teacher_id)
    WHERE a.id = tasks.assignment_id AND t.profile_id = auth.uid()
  )) OR is_admin())
  WITH CHECK ((EXISTS (
    SELECT 1 FROM (assignments a JOIN teachers t ON t.id = a.teacher_id)
    WHERE a.id = tasks.assignment_id AND t.profile_id = auth.uid()
  )) OR is_admin());

-- submissions
CREATE POLICY submissions_select ON public.submissions FOR SELECT TO authenticated USING (
  (EXISTS (SELECT 1 FROM students s WHERE s.id = submissions.student_id AND s.profile_id = auth.uid()))
  OR (EXISTS (
    SELECT 1 FROM (tasks tk JOIN assignments a ON a.id = tk.assignment_id)
    WHERE tk.id = submissions.task_id AND is_teacher_of_group(a.group_id)
  ))
  OR is_admin()
);
CREATE POLICY submissions_student ON public.submissions FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM students s WHERE s.id = submissions.student_id AND s.profile_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM students s WHERE s.id = submissions.student_id AND s.profile_id = auth.uid()));
CREATE POLICY submissions_teacher_update ON public.submissions FOR UPDATE TO authenticated
  USING ((EXISTS (
    SELECT 1 FROM (tasks tk JOIN assignments a ON a.id = tk.assignment_id)
    WHERE tk.id = submissions.task_id AND is_teacher_of_group(a.group_id)
  )) OR is_admin())
  WITH CHECK ((EXISTS (
    SELECT 1 FROM (tasks tk JOIN assignments a ON a.id = tk.assignment_id)
    WHERE tk.id = submissions.task_id AND is_teacher_of_group(a.group_id)
  )) OR is_admin());

-- attendance / sessions
CREATE POLICY attendance_select ON public.attendance FOR SELECT TO authenticated USING (
  is_teacher_of_group(group_id) OR is_student_in_group(group_id) OR is_admin()
);
CREATE POLICY attendance_teacher ON public.attendance FOR ALL TO authenticated
  USING (is_teacher_of_group(group_id) OR is_admin())
  WITH CHECK (is_teacher_of_group(group_id) OR is_admin());
CREATE POLICY lesson_sessions_select ON public.lesson_sessions FOR SELECT TO authenticated USING (
  is_teacher_of_group(group_id) OR is_student_in_group(group_id) OR is_admin()
);
CREATE POLICY lesson_sessions_manage ON public.lesson_sessions FOR ALL TO authenticated
  USING (is_teacher_of_group(group_id) OR is_admin())
  WITH CHECK (is_teacher_of_group(group_id) OR is_admin());

-- marks
CREATE POLICY marks_select ON public.marks FOR SELECT TO authenticated USING (
  (EXISTS (SELECT 1 FROM students s WHERE s.id = marks.student_id AND s.profile_id = auth.uid()))
  OR is_teacher_of_group(group_id) OR is_admin()
);
CREATE POLICY marks_teacher_manage ON public.marks FOR ALL TO authenticated
  USING (is_teacher_of_group(group_id) OR is_admin())
  WITH CHECK (is_teacher_of_group(group_id) OR is_admin());

-- announcements / templates / notifications
CREATE POLICY announcements_select ON public.announcements FOR SELECT TO authenticated USING (
  is_teacher_of_group(group_id) OR is_student_in_group(group_id) OR is_admin()
);
CREATE POLICY announcements_teacher ON public.announcements FOR ALL TO authenticated
  USING ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = announcements.teacher_id AND t.profile_id = auth.uid())) OR is_admin())
  WITH CHECK ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = announcements.teacher_id AND t.profile_id = auth.uid())) OR is_admin());
CREATE POLICY assignment_templates_teacher ON public.assignment_templates FOR ALL TO authenticated
  USING ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = assignment_templates.teacher_id AND t.profile_id = auth.uid())) OR is_admin())
  WITH CHECK ((EXISTS (SELECT 1 FROM teachers t WHERE t.id = assignment_templates.teacher_id AND t.profile_id = auth.uid())) OR is_admin());
CREATE POLICY notifications_own ON public.notifications FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- academic
CREATE POLICY academic_years_select ON public.academic_years FOR SELECT TO authenticated USING (true);
CREATE POLICY academic_years_admin ON public.academic_years FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY academic_terms_select ON public.academic_terms FOR SELECT TO authenticated USING (true);
CREATE POLICY academic_terms_admin ON public.academic_terms FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());

-- chat
CREATE POLICY chat_rooms_select ON public.chat_rooms FOR SELECT TO authenticated
  USING (can_access_chat_room(id));
CREATE POLICY chat_rooms_admin_insert ON public.chat_rooms FOR INSERT TO authenticated
  WITH CHECK (is_admin() OR is_teacher_of_group(group_id));

CREATE POLICY chat_messages_select ON public.chat_messages FOR SELECT TO authenticated
  USING (can_access_chat_room(room_id));
CREATE POLICY chat_messages_insert ON public.chat_messages FOR INSERT TO authenticated
  WITH CHECK ((sender_id = auth.uid()) AND can_access_chat_room(room_id));
CREATE POLICY chat_messages_update ON public.chat_messages FOR UPDATE TO authenticated
  USING (is_admin() OR ((sender_id = auth.uid()) AND can_access_chat_room(room_id)))
  WITH CHECK (is_admin() OR ((sender_id = auth.uid()) AND can_access_chat_room(room_id)));
CREATE POLICY chat_messages_delete ON public.chat_messages FOR DELETE TO authenticated
  USING (is_admin() OR ((sender_id = auth.uid()) AND can_access_chat_room(room_id)));

CREATE POLICY message_reads_select ON public.message_reads FOR SELECT TO authenticated USING (
  (user_id = auth.uid()) OR is_admin() OR (EXISTS (
    SELECT 1 FROM chat_messages m WHERE m.id = message_reads.message_id AND can_access_chat_room(m.room_id)
  ))
);
CREATE POLICY message_reads_insert ON public.message_reads FOR INSERT TO authenticated
  WITH CHECK ((user_id = auth.uid()) AND (EXISTS (
    SELECT 1 FROM chat_messages m WHERE m.id = message_reads.message_id AND can_access_chat_room(m.room_id)
  )));
CREATE POLICY message_reads_delete ON public.message_reads FOR DELETE TO authenticated
  USING ((user_id = auth.uid()) OR is_admin());

CREATE POLICY message_reactions_select ON public.message_reactions FOR SELECT TO authenticated USING (
  EXISTS (SELECT 1 FROM chat_messages m WHERE m.id = message_reactions.message_id AND can_access_chat_room(m.room_id))
);
CREATE POLICY message_reactions_insert ON public.message_reactions FOR INSERT TO authenticated
  WITH CHECK ((user_id = auth.uid()) AND (EXISTS (
    SELECT 1 FROM chat_messages m
    WHERE m.id = message_reactions.message_id AND m.is_deleted = false AND can_access_chat_room(m.room_id)
  )));
CREATE POLICY message_reactions_update ON public.message_reactions FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY message_reactions_delete ON public.message_reactions FOR DELETE TO authenticated
  USING ((user_id = auth.uid()) OR is_admin());
