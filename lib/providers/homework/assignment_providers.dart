import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/core/paging/page_result.dart';
import 'package:mu_study/core/services/cache_service.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/supabase/supabase_client.dart';

final assignmentsProvider =
    AsyncNotifierProvider.family<
      AssignmentsNotifier,
      PageResult<Assignment>,
      String?
    >(AssignmentsNotifier.new);

class AssignmentsNotifier
    extends FamilyAsyncNotifier<PageResult<Assignment>, String?> {
  @override
  Future<PageResult<Assignment>> build(String? groupId) => _fetch(0);

  Future<PageResult<Assignment>> _fetch(int offset) async {
    final cache = ref.watch(cacheServiceProvider).valueOrNull;
    final limit = PageResult.fetchSize(PageResult.pageSize);

    try {
      var query = supabase.from('assignments').select();
      if (arg != null) query = query.eq('group_id', arg!);
      final rows = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      final list = rows.map((e) => Map<String, dynamic>.from(e)).toList();
      if (offset == 0) await cache?.cacheAssignments(list);
      return PageResult.fromFetch(list.map(Assignment.fromJson).toList());
    } catch (_) {
      if (offset == 0) {
        final cached = cache?.cachedAssignments;
        if (cached != null) {
          return PageResult(
            items: cached.map(Assignment.fromJson).toList(),
            hasMore: false,
          );
        }
      }
      rethrow;
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await _fetch(current.items.length);
      state = AsyncData(current.append(next.items, hasMore: next.hasMore));
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
      rethrow;
    }
  }
}

final assignmentDetailProvider = FutureProvider.family<Assignment?, String>((
  ref,
  id,
) async {
  final data = await supabase
      .from('assignments')
      .select()
      .eq('id', id)
      .maybeSingle();
  if (data == null) return null;
  return Assignment.fromJson(Map<String, dynamic>.from(data));
});

final tasksProvider = FutureProvider.family<List<TaskItem>, String>((
  ref,
  assignmentId,
) async {
  final rows = await supabase
      .from('tasks')
      .select()
      .eq('assignment_id', assignmentId)
      .order('sort_order');
  return rows
      .map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});

final assignmentProgressProvider = FutureProvider.family<double, String>((
  ref,
  assignmentId,
) async {
  final student = await ref.watch(studentProfileProvider.future);
  if (student == null) return 0.0;

  final tasks = await supabase
      .from('tasks')
      .select('id')
      .eq('assignment_id', assignmentId);
  if (tasks.isEmpty) return 0.0;

  final taskIds = tasks.map((t) => t['id'] as String).toList();
  final completed = await supabase
      .from('submissions')
      .select('task_id')
      .eq('student_id', student.id)
      .eq('is_completed', true)
      .inFilter('task_id', taskIds);

  return completed.length / tasks.length;
});
