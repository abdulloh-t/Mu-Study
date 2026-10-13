import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:mu_study/supabase/supabase_client.dart';

const _snippetsPrefsKey = 'teacher_feedback_snippets';
const _maxSnippets = 20;

Future<List<String>> loadFeedbackSnippets({required String teacherId}) async {
  final prefs = await SharedPreferences.getInstance();
  final local = _readLocal(prefs, teacherId);

  final remote = await _fetchRecentFeedbackFromDb(teacherId);
  return _mergeUnique(local, remote);
}

Future<void> rememberFeedbackSnippet({
  required String teacherId,
  required String feedback,
}) async {
  final text = feedback.trim();
  if (text.isEmpty) return;

  final prefs = await SharedPreferences.getInstance();
  final current = _readLocal(prefs, teacherId);
  final next = _mergeUnique([text], current).take(_maxSnippets).toList();

  final all = _readAll(prefs);
  all[teacherId] = next;
  await prefs.setString(_snippetsPrefsKey, jsonEncode(all));
}

Future<int> applyFeedbackToOtherPendingForSameTask({
  required String submissionId,
  required String feedback,
}) async {
  final text = feedback.trim();
  if (text.isEmpty) return 0;

  final row = await supabase
      .from('submissions')
      .select('task_id')
      .eq('id', submissionId)
      .maybeSingle();
  final taskId = row?['task_id'] as String?;
  if (taskId == null) return 0;

  final siblings = await supabase
      .from('submissions')
      .select('id')
      .eq('task_id', taskId)
      .neq('id', submissionId)
      .inFilter('status', ['pending', 'submitted']);

  if (siblings.isEmpty) return 0;

  final ids = siblings.map((e) => e['id'] as String).toList();
  await supabase
      .from('submissions')
      .update({'feedback': text})
      .inFilter('id', ids);
  return ids.length;
}

Future<List<String>> _fetchRecentFeedbackFromDb(String teacherId) async {
  final assignments = await supabase
      .from('assignments')
      .select('id')
      .eq('teacher_id', teacherId);
  final assignmentIds = assignments.map((e) => e['id'] as String).toList();
  if (assignmentIds.isEmpty) return const [];

  final tasks = await supabase
      .from('tasks')
      .select('id')
      .inFilter('assignment_id', assignmentIds);
  final taskIds = tasks.map((e) => e['id'] as String).toList();
  if (taskIds.isEmpty) return const [];

  final rows = await supabase
      .from('submissions')
      .select('feedback')
      .inFilter('task_id', taskIds)
      .order('submitted_at', ascending: false)
      .limit(40);

  final out = <String>[];
  for (final row in rows) {
    final f = (row['feedback'] as String?)?.trim();
    if (f == null || f.isEmpty) continue;
    if (!out.contains(f)) out.add(f);
    if (out.length >= _maxSnippets) break;
  }
  return out;
}

List<String> _readLocal(SharedPreferences prefs, String teacherId) {
  final all = _readAll(prefs);
  final list = all[teacherId];
  if (list is! List) return const [];
  return list
      .whereType<String>()
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

Map<String, dynamic> _readAll(SharedPreferences prefs) {
  final raw = prefs.getString(_snippetsPrefsKey);
  if (raw == null || raw.isEmpty) return {};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), v));
    }
  } catch (_) {}
  return {};
}

List<String> _mergeUnique(List<String> primary, List<String> secondary) {
  final seen = <String>{};
  final out = <String>[];
  for (final item in [...primary, ...secondary]) {
    final t = item.trim();
    if (t.isEmpty || seen.contains(t)) continue;
    seen.add(t);
    out.add(t);
  }
  return out;
}
