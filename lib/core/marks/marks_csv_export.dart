import 'dart:convert';

import 'package:mu_study/core/marks/academic_term.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/attendance/attendance_providers.dart';
import 'package:mu_study/supabase/supabase_client.dart';
import 'package:share_plus/share_plus.dart';

String _csvCell(Object? value) {
  final s = '${value ?? ''}';
  if (s.contains(',') ||
      s.contains('"') ||
      s.contains('\n') ||
      s.contains('\r')) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

Future<void> exportGroupMarksCsv({
  required String groupId,
  required String groupTitle,
  required AcademicTerm term,
}) async {
  var query = supabase
      .from('marks')
      .select('*, students(profiles(full_name, username))')
      .eq('group_id', groupId);

  final start = term.startKey;
  final end = term.endKey;
  if (start != null) query = query.gte('marked_on', start);
  if (end != null) query = query.lte('marked_on', end);

  final rows = await query
      .order('marked_on', ascending: false)
      .order('created_at', ascending: false);

  final buffer = StringBuffer()
    ..writeln(
      [
        'Student',
        'Username',
        'Title',
        'Category',
        'Percentage',
        'Weight',
        'Date',
        'Comment',
      ].map(_csvCell).join(','),
    );

  for (final row in rows) {
    final mark = Mark.fromJson(Map<String, dynamic>.from(row));
    final student = row['students'] as Map?;
    final profile = student?['profiles'] as Map?;
    buffer.writeln(
      [
        profile?['full_name'] ?? mark.studentName ?? '',
        profile?['username'] ?? '',
        mark.title,
        mark.category.name,
        mark.percentage,
        mark.weight,
        dateKey(mark.markedOn),
        mark.comment,
      ].map(_csvCell).join(','),
    );
  }

  final safeTitle = groupTitle
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  final fileName =
      'marks_${safeTitle.isEmpty ? groupId : safeTitle}_${term.id}.csv';
  final bytes = utf8.encode(buffer.toString());

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'text/csv', name: fileName)],
      fileNameOverrides: [fileName],
      subject: 'Marks — $groupTitle',
      downloadFallbackEnabled: true,
    ),
  );
}
