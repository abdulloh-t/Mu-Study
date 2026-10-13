import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mu_study/core/marks/academic_term.dart';
import 'package:mu_study/core/paging/page_result.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/supabase/supabase_client.dart';

Future<List<Map<String, dynamic>>> _fetchMarksPage({
  required int offset,
  String? groupId,
  String? studentId,
  AcademicTerm term = AcademicTerm.all,
  String select = '*, students(profiles(full_name, username))',
}) async {
  final limit = PageResult.fetchSize(PageResult.pageSize);
  var query = supabase.from('marks').select(select);
  if (groupId != null) query = query.eq('group_id', groupId);
  if (studentId != null) query = query.eq('student_id', studentId);
  final start = term.startKey;
  final end = term.endKey;
  if (start != null) query = query.gte('marked_on', start);
  if (end != null) query = query.lte('marked_on', end);

  final rows = await query
      .order('marked_on', ascending: false)
      .order('created_at', ascending: false)
      .range(offset, offset + limit - 1);
  return rows.map((e) => Map<String, dynamic>.from(e)).toList();
}

Map<String, double> _weightedAverages(List<Map<String, dynamic>> rows) {
  final totals = <String, double>{};
  final weights = <String, double>{};
  for (final row in rows) {
    final id = row['student_id'] as String;
    final pct = double.tryParse('${row['percentage']}') ?? 0;
    final w = double.tryParse('${row['weight']}') ?? 1;
    totals[id] = (totals[id] ?? 0) + pct * w;
    weights[id] = (weights[id] ?? 0) + w;
  }
  return {
    for (final id in totals.keys)
      id: weights[id] == 0 ? 0 : totals[id]! / weights[id]!,
  };
}

final groupMarksProvider =
    AsyncNotifierProvider.family<GroupMarksNotifier, PageResult<Mark>, String>(
      GroupMarksNotifier.new,
    );

class GroupMarksNotifier extends FamilyAsyncNotifier<PageResult<Mark>, String> {
  @override
  Future<PageResult<Mark>> build(String groupId) async {
    ref.watch(selectedMarkTermProvider);
    return _fetch(0);
  }

  Future<PageResult<Mark>> _fetch(int offset) async {
    final term = ref.read(selectedMarkTermProvider);
    final rows = await _fetchMarksPage(
      offset: offset,
      groupId: arg,
      term: term,
    );
    return PageResult.fromFetch(rows.map(Mark.fromJson).toList());
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

final groupMarkAveragesProvider =
    FutureProvider.family<Map<String, double>, String>((ref, groupId) async {
      final term = ref.watch(selectedMarkTermProvider);
      var query = supabase
          .from('marks')
          .select('student_id, percentage, weight')
          .eq('group_id', groupId);
      final start = term.startKey;
      final end = term.endKey;
      if (start != null) query = query.gte('marked_on', start);
      if (end != null) query = query.lte('marked_on', end);
      final rows = await query;
      return _weightedAverages(
        rows.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    });

final groupMarkCountProvider = FutureProvider.family<int, String>((
  ref,
  groupId,
) async {
  final term = ref.watch(selectedMarkTermProvider);
  var query = supabase.from('marks').select('id').eq('group_id', groupId);
  final start = term.startKey;
  final end = term.endKey;
  if (start != null) query = query.gte('marked_on', start);
  if (end != null) query = query.lte('marked_on', end);
  final result = await query.count(CountOption.exact);
  return result.count;
});

final memberMarksProvider =
    FutureProvider.family<List<Mark>, ({String groupId, String studentId})>((
      ref,
      key,
    ) async {
      final term = ref.watch(selectedMarkTermProvider);
      var query = supabase
          .from('marks')
          .select('*, students(profiles(full_name, username))')
          .eq('group_id', key.groupId)
          .eq('student_id', key.studentId);
      final start = term.startKey;
      final end = term.endKey;
      if (start != null) query = query.gte('marked_on', start);
      if (end != null) query = query.lte('marked_on', end);
      final rows = await query
          .order('marked_on', ascending: false)
          .order('created_at', ascending: false);
      return rows
          .map((e) => Mark.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });

final myMarksProvider =
    AsyncNotifierProvider<MyMarksNotifier, PageResult<Mark>>(
      MyMarksNotifier.new,
    );

class MyMarksNotifier extends AsyncNotifier<PageResult<Mark>> {
  @override
  Future<PageResult<Mark>> build() async {
    ref.watch(selectedMarkTermProvider);
    ref.watch(studentProfileProvider);
    return _fetch(0);
  }

  Future<PageResult<Mark>> _fetch(int offset) async {
    final student = await ref.read(studentProfileProvider.future);
    if (student == null) {
      return const PageResult(items: [], hasMore: false);
    }
    final term = ref.read(selectedMarkTermProvider);
    final rows = await _fetchMarksPage(
      offset: offset,
      studentId: student.id,
      term: term,
      select: '*, groups(title)',
    );
    return PageResult.fromFetch(rows.map(Mark.fromJson).toList());
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

final myMarkStatsProvider =
    FutureProvider<
      List<({MarkCategory category, double percentage, double weight})>
    >((ref) async {
      final student = await ref.watch(studentProfileProvider.future);
      if (student == null) return [];
      final term = ref.watch(selectedMarkTermProvider);
      var query = supabase
          .from('marks')
          .select('category, percentage, weight')
          .eq('student_id', student.id);
      final start = term.startKey;
      final end = term.endKey;
      if (start != null) query = query.gte('marked_on', start);
      if (end != null) query = query.lte('marked_on', end);
      final rows = await query;
      return rows
          .map(
            (e) => (
              category: markCategoryFromString(e['category'] as String?),
              percentage: double.tryParse('${e['percentage']}') ?? 0,
              weight: double.tryParse('${e['weight']}') ?? 1,
            ),
          )
          .toList();
    });

final myMarkAverageProvider = FutureProvider<double?>((ref) async {
  final stats = await ref.watch(myMarkStatsProvider.future);
  if (stats.isEmpty) return null;
  var total = 0.0;
  var weight = 0.0;
  for (final s in stats) {
    total += s.percentage * s.weight;
    weight += s.weight;
  }
  if (weight == 0) return null;
  return total / weight;
});

Future<void> saveMark({
  required String groupId,
  required String studentId,
  required String teacherId,
  required String title,
  required MarkCategory category,
  required double percentage,
  required double weight,
  required String comment,
  required DateTime markedOn,
  String? markId,
}) async {
  final payload = Mark(
    id: markId ?? '',
    groupId: groupId,
    studentId: studentId,
    teacherId: teacherId,
    title: title,
    percentage: percentage,
    category: category,
    weight: weight,
    comment: comment,
    markedOn: markedOn,
  ).toWrite();

  if (markId == null) {
    await supabase.from('marks').insert(payload);
  } else {
    await supabase.from('marks').update(payload).eq('id', markId);
  }
}

Future<void> deleteMark(String markId) async {
  await supabase.from('marks').delete().eq('id', markId);
}
