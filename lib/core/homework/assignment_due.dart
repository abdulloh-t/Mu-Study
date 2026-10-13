import 'package:mu_study/models/models.dart';

enum AssignmentDueStatus { none, upcoming, dueSoon, dueToday, overdue }

DateTime assignmentCalendarDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime? assignmentDueDay(Assignment a) {
  final d = a.dueDate;
  if (d == null) return null;
  return assignmentCalendarDay(d);
}

DateTime startOfWeek(DateTime day) {
  final d = assignmentCalendarDay(day);
  return d.subtract(Duration(days: d.weekday - DateTime.monday));
}

DateTime endOfWeek(DateTime day) =>
    startOfWeek(day).add(const Duration(days: 6));

AssignmentDueStatus assignmentDueStatus(Assignment a, [DateTime? now]) {
  final due = assignmentDueDay(a);
  if (due == null) return AssignmentDueStatus.none;
  final today = assignmentCalendarDay(now ?? DateTime.now());
  if (due.isBefore(today)) return AssignmentDueStatus.overdue;
  if (due == today) return AssignmentDueStatus.dueToday;
  final days = due.difference(today).inDays;
  if (days <= 2) return AssignmentDueStatus.dueSoon;
  return AssignmentDueStatus.upcoming;
}

bool assignmentIsDueThisWeek(Assignment a, [DateTime? now]) {
  final due = assignmentDueDay(a);
  if (due == null) return false;
  final n = now ?? DateTime.now();
  final start = startOfWeek(n);
  final end = endOfWeek(n);
  return !due.isBefore(start) && !due.isAfter(end);
}

bool assignmentIsOverdue(Assignment a, [DateTime? now]) =>
    assignmentDueStatus(a, now) == AssignmentDueStatus.overdue;

List<Assignment> sortAssignmentsByDue(
  Iterable<Assignment> items, [
  DateTime? now,
]) {
  final list = items.toList();
  final n = now ?? DateTime.now();
  list.sort((a, b) {
    final da = assignmentDueDay(a);
    final db = assignmentDueDay(b);
    if (da == null && db == null) {
      return (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
        a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
    }
    if (da == null) return 1;
    if (db == null) return -1;
    final today = assignmentCalendarDay(n);
    final aOver = da.isBefore(today);
    final bOver = db.isBefore(today);
    if (aOver != bOver) return aOver ? -1 : 1;
    return da.compareTo(db);
  });
  return list;
}

List<Assignment> assignmentsDueThisWeekFocus(
  Iterable<Assignment> items, [
  DateTime? now,
]) {
  final n = now ?? DateTime.now();
  final filtered = items.where((a) {
    if (assignmentIsOverdue(a, n)) return true;
    return assignmentIsDueThisWeek(a, n);
  });
  return sortAssignmentsByDue(filtered, n);
}

List<Assignment> assignmentsForFocusSession(
  Iterable<Assignment> items, [
  DateTime? now,
]) => sortAssignmentsByDue(items, now);
