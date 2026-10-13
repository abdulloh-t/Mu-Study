import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/supabase/supabase_client.dart';

final teacherSubmissionsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final teacher = await ref.watch(teacherProfileProvider.future);
  if (teacher == null) return [];

  final assignments = await supabase
      .from('assignments')
      .select('id')
      .eq('teacher_id', teacher.id);
  final assignmentIds = assignments.map((e) => e['id'] as String).toList();
  if (assignmentIds.isEmpty) return [];

  final tasks = await supabase
      .from('tasks')
      .select('id')
      .inFilter('assignment_id', assignmentIds);
  final taskIds = tasks.map((e) => e['id'] as String).toList();
  if (taskIds.isEmpty) return [];

  final rows = await supabase
      .from('submissions')
      .select('''
            id, status, score, feedback, text_answer, file_url, voice_url,
            submitted_at,
            tasks(title, assignments(title)),
            students(profiles(full_name, username))
          ''')
      .inFilter('task_id', taskIds)
      .order('submitted_at', ascending: false);

  return rows.map((s) {
    final task = s['tasks'] as Map?;
    final assignment = task?['assignments'] as Map?;
    final profile = (s['students'] as Map?)?['profiles'] as Map?;
    return {
      'id': s['id'],
      'status': s['status'],
      'score': s['score'],
      'feedback': s['feedback'],
      'text_answer': s['text_answer'],
      'file_url': s['file_url'],
      'voice_url': s['voice_url'],
      'task_title': task?['title'],
      'assignment_title': assignment?['title'],
      'student_name':
          profile?['full_name'] ?? profile?['username'] ?? 'Student',
    };
  }).toList();
});
