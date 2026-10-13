import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mu_study/core/paging/page_result.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/supabase/supabase_client.dart';

Future<int> _exactCount(String table) async {
  final result = await supabase
      .from(table)
      .select('id')
      .count(CountOption.exact);
  return result.count;
}

final adminPlatformStatsProvider = FutureProvider<Map<String, int>>((
  ref,
) async {
  final teachers = await _exactCount('teachers');
  final students = await _exactCount('students');
  final groups = await _exactCount('groups');
  final assignments = await _exactCount('assignments');
  final marks = await _exactCount('marks');
  return {
    'teachers': teachers,
    'students': students,
    'groups': groups,
    'assignments': assignments,
    'marks': marks,
  };
});

final adminGroupsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final rows = await supabase
      .from('groups')
      .select('id, title, teachers(sphere, profiles(full_name))')
      .order('title');
  return rows.map((e) => Map<String, dynamic>.from(e)).toList();
});

final adminAnnouncementsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final rows = await supabase
      .from('announcements')
      .select()
      .order('created_at', ascending: false);
  return rows.map((e) => Map<String, dynamic>.from(e)).toList();
});

final allProfilesProvider =
    AsyncNotifierProvider<AllProfilesNotifier, PageResult<Profile>>(
      AllProfilesNotifier.new,
    );

class AllProfilesNotifier extends AsyncNotifier<PageResult<Profile>> {
  @override
  Future<PageResult<Profile>> build() => _fetch(0);

  Future<PageResult<Profile>> _fetch(int offset) async {
    final limit = PageResult.fetchSize(PageResult.pageSize);
    final rows = await supabase
        .from('profiles')
        .select()
        .order('username')
        .range(offset, offset + limit - 1);
    return PageResult.fromFetch(
      rows.map((e) => Profile.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
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
