import 'package:mu_study/models/enums.dart';

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.groupId,
    required this.studentId,
    required this.status,
    required this.date,
    this.sessionId,
    this.studentName,
  });

  final String id;
  final String groupId;
  final String studentId;
  final AttendanceStatus status;
  final DateTime date;
  final String? sessionId;
  final String? studentName;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final student = json['students'] as Map?;
    final profile = student?['profiles'] as Map?;
    return AttendanceRecord(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      studentId: json['student_id'] as String,
      status: attendanceFromString(json['status'] as String),
      date: DateTime.parse(json['date'] as String),
      sessionId: json['session_id'] as String?,
      studentName: profile?['full_name'] as String?,
    );
  }
}

class AttendanceStats {
  const AttendanceStats({
    this.present = 0,
    this.absent = 0,
    this.late = 0,
    this.excused = 0,
  });

  final int present;
  final int absent;
  final int late;
  final int excused;

  int get total => present + absent + late + excused;

  double get presentPercent => total == 0 ? 0 : (present / total) * 100;

  factory AttendanceStats.fromCounts(Map<String, int> counts) {
    return AttendanceStats(
      present: counts['present'] ?? 0,
      absent: counts['absent'] ?? 0,
      late: counts['late'] ?? 0,
      excused: counts['excused'] ?? 0,
    );
  }

  factory AttendanceStats.fromRecords(Iterable<AttendanceRecord> records) {
    var present = 0, absent = 0, late = 0, excused = 0;
    for (final r in records) {
      switch (r.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.late:
          late++;
        case AttendanceStatus.excused:
          excused++;
      }
    }
    return AttendanceStats(
      present: present,
      absent: absent,
      late: late,
      excused: excused,
    );
  }
}
