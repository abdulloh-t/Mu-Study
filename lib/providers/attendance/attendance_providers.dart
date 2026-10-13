import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/supabase/supabase_client.dart';

String dateKey(DateTime date) => DateTime(
  date.year,
  date.month,
  date.day,
).toIso8601String().split('T').first;

DateTime calendarDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool isAttendanceWeekend(DateTime date) {
  final weekday = calendarDay(date).weekday;
  return weekday == DateTime.saturday || weekday == DateTime.sunday;
}

bool isAttendanceDateAllowed(DateTime date) {
  final day = calendarDay(date);
  final today = calendarDay(DateTime.now());
  if (day.isAfter(today)) return false;
  if (isAttendanceWeekend(day)) return false;
  return true;
}

class AttendanceFutureDateException implements Exception {
  const AttendanceFutureDateException();

  @override
  String toString() => 'AttendanceFutureDateException';
}

class AttendanceWeekendException implements Exception {
  const AttendanceWeekendException();

  @override
  String toString() => 'AttendanceWeekendException';
}

Never _rejectAttendanceDate(DateTime date) {
  final day = calendarDay(date);
  if (isAttendanceWeekend(day)) {
    throw const AttendanceWeekendException();
  }
  final today = calendarDay(DateTime.now());
  if (day.isAfter(today)) {
    throw const AttendanceFutureDateException();
  }
  throw StateError('Attendance date rejected unexpectedly: $day');
}

class AttendanceQuery {
  const AttendanceQuery({
    required this.groupId,
    this.studentId,
    required this.from,
    required this.to,
  });

  final String groupId;
  final String? studentId;
  final DateTime from;
  final DateTime to;

  @override
  bool operator ==(Object other) =>
      other is AttendanceQuery &&
      other.groupId == groupId &&
      other.studentId == studentId &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(groupId, studentId, from, to);
}

final attendanceRangeProvider =
    FutureProvider.family<List<AttendanceRecord>, AttendanceQuery>((
      ref,
      query,
    ) async {
      var filtered = supabase
          .from('attendance')
          .select('*, students(profiles(full_name))')
          .eq('group_id', query.groupId)
          .gte('date', dateKey(query.from))
          .lte('date', dateKey(query.to));

      if (query.studentId != null) {
        filtered = filtered.eq('student_id', query.studentId!);
      }

      final rows = await filtered.order('date', ascending: true);
      return rows
          .map((e) => AttendanceRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });

final attendanceRangeStatsProvider =
    Provider.family<AsyncValue<AttendanceStats>, AttendanceQuery>((ref, query) {
      return ref
          .watch(attendanceRangeProvider(query))
          .whenData(AttendanceStats.fromRecords);
    });

final todayAttendanceProvider =
    FutureProvider.family<Map<String, AttendanceStatus>, String>((
      ref,
      groupId,
    ) async {
      final rows = await supabase
          .from('attendance')
          .select('student_id, status')
          .eq('group_id', groupId)
          .eq('date', dateKey(DateTime.now()));
      return {
        for (final row in rows)
          row['student_id'] as String: attendanceFromString(
            row['status'] as String,
          ),
      };
    });

class AttendanceWeekBucket {
  const AttendanceWeekBucket({
    this.present = 0,
    this.absent = 0,
    this.late = 0,
  });

  final int present;
  final int absent;
  final int late;

  int get max => [present, absent, late].fold(0, (a, b) => a > b ? a : b);
}

class AttendanceWeekTrend {
  const AttendanceWeekTrend({required this.thisWeek, required this.lastWeek});

  final AttendanceWeekBucket thisWeek;
  final AttendanceWeekBucket lastWeek;

  bool get isEmpty => thisWeek.max == 0 && lastWeek.max == 0;
}

final attendanceWeekTrendProvider =
    FutureProvider.family<AttendanceWeekTrend, String>((ref, groupId) async {
      final today = calendarDay(DateTime.now());
      final thisFrom = today.subtract(const Duration(days: 6));
      final lastTo = today.subtract(const Duration(days: 7));
      final lastFrom = today.subtract(const Duration(days: 13));

      final rows = await supabase
          .from('attendance')
          .select('status, date')
          .eq('group_id', groupId)
          .gte('date', dateKey(lastFrom))
          .lte('date', dateKey(today));

      var thisPresent = 0, thisAbsent = 0, thisLate = 0;
      var lastPresent = 0, lastAbsent = 0, lastLate = 0;

      for (final row in rows) {
        final day = calendarDay(DateTime.parse(row['date'] as String));
        final status = row['status'] as String;
        final inThisWeek = !day.isBefore(thisFrom) && !day.isAfter(today);
        final inLastWeek = !day.isBefore(lastFrom) && !day.isAfter(lastTo);

        if (inThisWeek) {
          switch (status) {
            case 'present':
              thisPresent++;
            case 'absent':
              thisAbsent++;
            case 'late':
              thisLate++;
          }
        } else if (inLastWeek) {
          switch (status) {
            case 'present':
              lastPresent++;
            case 'absent':
              lastAbsent++;
            case 'late':
              lastLate++;
          }
        }
      }

      return AttendanceWeekTrend(
        thisWeek: AttendanceWeekBucket(
          present: thisPresent,
          absent: thisAbsent,
          late: thisLate,
        ),
        lastWeek: AttendanceWeekBucket(
          present: lastPresent,
          absent: lastAbsent,
          late: lastLate,
        ),
      );
    });

Future<void> upsertAttendance({
  required String groupId,
  required String studentId,
  required AttendanceStatus status,
  required DateTime date,
}) async {
  if (!isAttendanceDateAllowed(date)) {
    _rejectAttendanceDate(date);
  }
  final key = dateKey(date);
  await supabase.rpc(
    'ensure_lesson_session',
    params: {'p_group_id': groupId, 'p_session_date': key},
  );
  await supabase.from('attendance').upsert({
    'group_id': groupId,
    'student_id': studentId,
    'status': status.name,
    'date': key,
  }, onConflict: 'group_id,student_id,date');
}

Future<void> upsertAttendanceBulk({
  required String groupId,
  required DateTime date,
  required Map<String, AttendanceStatus> byStudentId,
}) async {
  if (byStudentId.isEmpty) return;
  if (!isAttendanceDateAllowed(date)) {
    _rejectAttendanceDate(date);
  }
  final key = dateKey(date);
  await supabase.rpc(
    'ensure_lesson_session',
    params: {'p_group_id': groupId, 'p_session_date': key},
  );
  final rows = byStudentId.entries
      .map(
        (e) => {
          'group_id': groupId,
          'student_id': e.key,
          'status': e.value.name,
          'date': key,
        },
      )
      .toList();
  await supabase
      .from('attendance')
      .upsert(rows, onConflict: 'group_id,student_id,date');
}
