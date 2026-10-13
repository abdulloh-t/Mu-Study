import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/supabase/supabase_client.dart';

final myGroupsProvider = FutureProvider<List<StudyGroup>>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) return [];

  if (profile.role == UserRole.teacher) {
    final teacher = await ref.watch(teacherProfileProvider.future);
    if (teacher == null) return [];
    final rows = await supabase
        .from('groups')
        .select()
        .eq('teacher_id', teacher.id)
        .order('title');
    return rows
        .map((e) => StudyGroup.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  if (profile.role == UserRole.student) {
    final student = await ref.watch(studentProfileProvider.future);
    if (student == null) return [];
    final rows = await supabase
        .from('group_students')
        .select('groups(*)')
        .eq('student_id', student.id);
    return rows
        .map(
          (e) => StudyGroup.fromJson(
            Map<String, dynamic>.from(e['groups'] as Map),
          ),
        )
        .toList();
  }

  final rows = await supabase.from('groups').select().order('title');
  return rows
      .map((e) => StudyGroup.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});

final selectedGroupIdProvider = StateProvider<String?>((ref) => null);

final activeGroupIdProvider = Provider<String?>((ref) {
  final selected = ref.watch(selectedGroupIdProvider);
  final groups = ref.watch(myGroupsProvider).valueOrNull ?? const [];
  if (selected != null && groups.any((g) => g.id == selected)) return selected;
  return groups.isEmpty ? null : groups.first.id;
});

final groupMembersProvider = FutureProvider.family<List<GroupMember>, String>((
  ref,
  groupId,
) async {
  final rows = await supabase
      .from('group_students')
      .select('students(id, profiles(full_name, username))')
      .eq('group_id', groupId);
  final members = rows
      .map((e) => GroupMember.fromGroupStudentRow(Map<String, dynamic>.from(e)))
      .toList();
  members.sort(
    (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
  );
  return members;
});
