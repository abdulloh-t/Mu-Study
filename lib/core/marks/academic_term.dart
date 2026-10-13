import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/l10n/app_localizations.dart';
import 'package:mu_study/supabase/supabase_client.dart';

class AcademicTerm {
  const AcademicTerm({
    required this.id,
    required this.academicYearStart,
    required this.semester,
    this.startInclusive,
    this.endInclusive,
    this.yearIsCurrent = false,
    this.dbTermId,
    this.dbYearId,
  });

  final String id;

  final int? academicYearStart;

  final int? semester;

  final DateTime? startInclusive;
  final DateTime? endInclusive;

  final bool yearIsCurrent;

  final String? dbTermId;
  final String? dbYearId;

  bool get isAll => id == 'all';

  static const AcademicTerm all = AcademicTerm(
    id: 'all',
    academicYearStart: null,
    semester: null,
  );

  static (DateTime, DateTime) bounds(int academicYearStart, int semester) {
    assert(semester >= 1 && semester <= 4);
    return switch (semester) {
      1 => (
        DateTime(academicYearStart, 8, 1),
        DateTime(academicYearStart, 11, 2),
      ),
      2 => (
        DateTime(academicYearStart, 11, 11),
        DateTime(academicYearStart, 12, 28),
      ),
      3 => (
        DateTime(academicYearStart + 1, 1, 11),
        DateTime(academicYearStart + 1, 3, 20),
      ),
      _ => (
        DateTime(academicYearStart + 1, 3, 28),
        DateTime(academicYearStart + 1, 6, 19),
      ),
    };
  }

  static AcademicTerm semesterOf(
    int academicYearStart,
    int semester, {
    bool yearIsCurrent = false,
    String? dbTermId,
    String? dbYearId,
    DateTime? startInclusive,
    DateTime? endInclusive,
  }) {
    assert(semester >= 1 && semester <= 4);
    final (start, end) = bounds(academicYearStart, semester);
    return AcademicTerm(
      id: '$academicYearStart-$semester',
      academicYearStart: academicYearStart,
      semester: semester,
      startInclusive: startInclusive ?? start,
      endInclusive: endInclusive ?? end,
      yearIsCurrent: yearIsCurrent,
      dbTermId: dbTermId,
      dbYearId: dbYearId,
    );
  }

  static int academicYearFor(DateTime now) =>
      now.month >= 8 ? now.year : now.year - 1;

  static int semesterFor(DateTime now) {
    final ay = academicYearFor(now);
    final day = DateTime(now.year, now.month, now.day);
    for (var s = 1; s <= 4; s++) {
      final (start, end) = bounds(ay, s);
      if (!day.isBefore(start) && !day.isAfter(end)) return s;
    }
    for (var s = 1; s <= 4; s++) {
      final (start, _) = bounds(ay, s);
      if (day.isBefore(start)) return s;
    }
    return 4;
  }

  static AcademicTerm currentFrom(List<AcademicTerm> options, [DateTime? now]) {
    final n = now ?? DateTime.now();
    final day = DateTime(n.year, n.month, n.day);
    final terms = options.where((t) => !t.isAll).toList();
    if (terms.isEmpty) return all;

    final currentYearTerms = terms.where((t) => t.yearIsCurrent).toList();
    final pool = currentYearTerms.isNotEmpty ? currentYearTerms : terms;

    final matching = pool.where((t) {
      final start = t.startInclusive;
      final end = t.endInclusive;
      if (start == null || end == null) return false;
      return !day.isBefore(start) && !day.isAfter(end);
    }).toList();
    if (matching.isNotEmpty) return matching.first;

    pool.sort((a, b) => (a.semester ?? 0).compareTo(b.semester ?? 0));
    final first = pool.first;
    final last = pool.last;

    if (first.startInclusive != null && day.isBefore(first.startInclusive!)) {
      return all;
    }

    if (last.endInclusive != null && day.isAfter(last.endInclusive!)) {
      return all;
    }

    for (final t in pool) {
      final start = t.startInclusive;
      if (start != null && day.isBefore(start)) return t;
    }
    return last;
  }

  String label(AppLocalizations l10n) {
    if (isAll) return l10n.marksTermAll;
    final start = academicYearStart!;
    final endShort = (start + 1) % 100;
    final yearRange = '$start–${endShort.toString().padLeft(2, '0')}';
    return l10n.marksTermSemester(yearRange, semester!);
  }

  String? get startKey => startInclusive?.toIso8601String().split('T').first;

  String? get endKey => endInclusive?.toIso8601String().split('T').first;
}

class AcademicYearRecord {
  const AcademicYearRecord({
    required this.id,
    required this.startYear,
    required this.label,
    required this.isCurrent,
    required this.terms,
  });

  final String id;
  final int startYear;
  final String label;
  final bool isCurrent;
  final List<AcademicTerm> terms;

  factory AcademicYearRecord.fromJson(
    Map<String, dynamic> json,
    List<Map<String, dynamic>> termRows,
  ) {
    final yearId = json['id'] as String;
    final startYear = json['start_year'] as int;
    final isCurrent = json['is_current'] as bool? ?? false;
    final terms = termRows.map((t) {
      final semester = t['semester'] as int;
      final start = DateTime.parse(t['starts_on'] as String);
      final end = DateTime.parse(t['ends_on'] as String);
      return AcademicTerm.semesterOf(
        startYear,
        semester,
        yearIsCurrent: isCurrent,
        dbTermId: t['id'] as String?,
        dbYearId: yearId,
        startInclusive: DateTime(start.year, start.month, start.day),
        endInclusive: DateTime(end.year, end.month, end.day),
      );
    }).toList()..sort((a, b) => (a.semester ?? 0).compareTo(b.semester ?? 0));

    return AcademicYearRecord(
      id: yearId,
      startYear: startYear,
      label:
          json['label'] as String? ??
          '$startYear–${((startYear + 1) % 100).toString().padLeft(2, '0')}',
      isCurrent: isCurrent,
      terms: terms,
    );
  }
}

Future<List<AcademicYearRecord>> fetchAcademicYears() async {
  final years = await supabase
      .from('academic_years')
      .select('id, start_year, label, is_current, created_at')
      .order('start_year', ascending: false);

  final yearList = (years as List).cast<Map<String, dynamic>>();
  if (yearList.isEmpty) return const [];

  final terms = await supabase
      .from('academic_terms')
      .select('id, academic_year_id, semester, starts_on, ends_on')
      .order('semester');

  final termList = (terms as List).cast<Map<String, dynamic>>();
  final byYear = <String, List<Map<String, dynamic>>>{};
  for (final t in termList) {
    final yid = t['academic_year_id'] as String;
    byYear.putIfAbsent(yid, () => []).add(t);
  }

  return [
    for (final y in yearList)
      AcademicYearRecord.fromJson(y, byYear[y['id'] as String] ?? const []),
  ];
}

final academicTermOptionsProvider = FutureProvider<List<AcademicTerm>>((
  ref,
) async {
  final years = await fetchAcademicYears();
  return [AcademicTerm.all, for (final y in years) ...y.terms];
});

final academicYearsProvider = FutureProvider<List<AcademicYearRecord>>((
  ref,
) async {
  return fetchAcademicYears();
});

class SelectedMarkTermNotifier extends Notifier<AcademicTerm> {
  bool _initializedFromDb = false;

  @override
  AcademicTerm build() {
    ref.listen(academicTermOptionsProvider, (prev, next) {
      next.whenData((options) {
        if (options.length <= 1) return;
        final current = state;
        AcademicTerm? match;
        for (final t in options) {
          if (t.id == current.id) {
            match = t;
            break;
          }
        }
        if (!_initializedFromDb || match == null) {
          _initializedFromDb = true;
          state = AcademicTerm.currentFrom(options);
          return;
        }
        if (match.startKey != current.startKey ||
            match.endKey != current.endKey ||
            match.yearIsCurrent != current.yearIsCurrent) {
          state = match;
        }
      });
    });
    return AcademicTerm.all;
  }

  void select(AcademicTerm term) {
    state = term;
  }
}

final selectedMarkTermProvider =
    NotifierProvider<SelectedMarkTermNotifier, AcademicTerm>(
      SelectedMarkTermNotifier.new,
    );
