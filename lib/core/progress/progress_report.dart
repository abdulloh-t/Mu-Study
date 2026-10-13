import 'package:intl/intl.dart';
import 'package:mu_study/core/marks/academic_term.dart';
import 'package:mu_study/l10n/app_localizations.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/attendance/attendance_providers.dart';
import 'package:mu_study/supabase/supabase_client.dart';

class ProgressReport {
  const ProgressReport({
    required this.studentName,
    required this.groupTitle,
    required this.termLabel,
    required this.term,
    required this.average,
    required this.markCount,
    required this.attendance,
    required this.categoryAverages,
    required this.recentMarks,
    this.generatedAt,
  });

  final String studentName;
  final String groupTitle;
  final String termLabel;
  final AcademicTerm term;
  final double? average;
  final int markCount;
  final AttendanceStats attendance;
  final List<({MarkCategory category, double average})> categoryAverages;
  final List<Mark> recentMarks;
  final DateTime? generatedAt;

  double get attendanceRate => attendance.presentPercent;
}

Future<ProgressReport> fetchProgressReport({
  required String studentId,
  required String groupId,
  required String studentName,
  required String groupTitle,
  required AcademicTerm term,
  required AppLocalizations l10n,
}) async {
  var marksQuery = supabase
      .from('marks')
      .select()
      .eq('student_id', studentId)
      .eq('group_id', groupId);
  final start = term.startKey;
  final end = term.endKey;
  if (start != null) marksQuery = marksQuery.gte('marked_on', start);
  if (end != null) marksQuery = marksQuery.lte('marked_on', end);

  final markRows = await marksQuery
      .order('marked_on', ascending: false)
      .order('created_at', ascending: false);
  final marks = markRows
      .map((e) => Mark.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  double? average;
  if (marks.isNotEmpty) {
    var total = 0.0;
    var weight = 0.0;
    for (final m in marks) {
      total += m.percentage * m.weight;
      weight += m.weight;
    }
    if (weight > 0) average = total / weight;
  }

  final byCategory = <MarkCategory, List<Mark>>{};
  for (final m in marks) {
    byCategory.putIfAbsent(m.category, () => []).add(m);
  }
  final categoryAverages = byCategory.entries.map((e) {
    var total = 0.0;
    var weight = 0.0;
    for (final m in e.value) {
      total += m.percentage * m.weight;
      weight += m.weight;
    }
    return (category: e.key, average: weight == 0 ? 0.0 : total / weight);
  }).toList()..sort((a, b) => b.average.compareTo(a.average));

  final now = DateTime.now();
  final from =
      term.startInclusive ??
      DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 120));
  final to = term.endInclusive ?? DateTime(now.year, now.month, now.day);

  final attendanceRows = await supabase
      .from('attendance')
      .select()
      .eq('group_id', groupId)
      .eq('student_id', studentId)
      .gte('date', dateKey(from))
      .lte('date', dateKey(to))
      .order('date', ascending: true);

  final attendance = AttendanceStats.fromRecords(
    attendanceRows.map(
      (e) => AttendanceRecord.fromJson(Map<String, dynamic>.from(e)),
    ),
  );

  return ProgressReport(
    studentName: studentName,
    groupTitle: groupTitle,
    termLabel: term.label(l10n),
    term: term,
    average: average,
    markCount: marks.length,
    attendance: attendance,
    categoryAverages: categoryAverages,
    recentMarks: marks.take(12).toList(),
    generatedAt: DateTime.now(),
  );
}

String progressReportShareText(ProgressReport report, AppLocalizations l10n) {
  final avg = report.average;
  final avgLine = avg == null
      ? l10n.marksNoneYet
      : '${avg.toStringAsFixed(avg % 1 == 0 ? 0 : 1)}%';
  final att = report.attendance;
  final buf = StringBuffer()
    ..writeln(l10n.progressReportTitle)
    ..writeln('${report.studentName} · ${report.groupTitle}')
    ..writeln(report.termLabel)
    ..writeln()
    ..writeln('${l10n.marksOverallAverage}: $avgLine')
    ..writeln('${l10n.progressReportMarksCounted}: ${report.markCount}')
    ..writeln(
      '${l10n.progressReportAttendanceRate}: '
      '${att.total == 0 ? '—' : '${report.attendanceRate.toStringAsFixed(0)}%'}',
    );
  if (att.total > 0) {
    buf.writeln(
      '${l10n.attendancePresentWord}: ${att.present} · '
      '${l10n.attendanceAbsentWord}: ${att.absent} · '
      '${l10n.attendanceLateWord}: ${att.late} · '
      '${l10n.attendanceExcusedWord}: ${att.excused}',
    );
  }
  buf
    ..writeln()
    ..writeln(
      l10n.progressReportGeneratedOn(
        DateFormat.yMMMd().add_jm().format(
          report.generatedAt ?? DateTime.now(),
        ),
      ),
    );
  return buf.toString();
}
