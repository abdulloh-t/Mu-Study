import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/attendance/attendance_calendar_grid.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/inputs/group_selector.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/attendance/attendance_providers.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  ConsumerState<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState
    extends ConsumerState<StudentAttendanceScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final groupId = ref.watch(activeGroupIdProvider);
    final student = ref.watch(studentProfileProvider);

    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.attendanceTitle)),
        body: EmptyState(title: l10n.attendanceNoGroup),
      );
    }

    final studentId = student.valueOrNull?.id;
    if (studentId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.attendanceTitle)),
        body: student.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(message: e.toString()),
          data: (_) => EmptyState(title: l10n.attendanceNoGroup),
        ),
      );
    }

    final from = DateTime(_month.year, _month.month, 1);
    final to = DateTime(_month.year, _month.month + 1, 0);
    final query = AttendanceQuery(
      groupId: groupId,
      studentId: studentId,
      from: from,
      to: to,
    );
    final records = ref.watch(attendanceRangeProvider(query));
    final stats = ref.watch(attendanceRangeStatsProvider(query));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.attendanceTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(attendanceRangeProvider(query));
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            shellContentBottomPadding(context, extra: 16),
          ),
          children: [
            const GroupSelector(padding: EdgeInsets.only(bottom: 8)),
            AttendanceMonthHeader(
              month: _month,
              onPrev: () => setState(() {
                _month = DateTime(_month.year, _month.month - 1);
              }),
              onNext: () => setState(() {
                _month = DateTime(_month.year, _month.month + 1);
              }),
            ),
            const SizedBox(height: 8),
            stats.when(
              data: (s) => AttendanceStatsBar(stats: s),
              loading: () => const SizedBox(height: 56),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            PremiumCard(
              child: records.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => ErrorState(message: e.toString()),
                data: (list) {
                  final byDate = <DateTime, AttendanceStatus>{
                    for (final r in list)
                      DateTime(r.date.year, r.date.month, r.date.day): r.status,
                  };
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.attendanceHistory,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          PaperDecor(
                            PaperAssets.calendarWithClock,
                            size: 34,
                            angle: 0.08,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AttendanceCalendarGrid(
                        month: _month,
                        statusByDate: byDate,
                      ),
                      const SizedBox(height: 16),
                      const AttendanceLegendRow(),
                      if (list.isEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          l10n.attendanceCalendarEmpty,
                          style: TextStyle(
                            color: AppColors.inkAlpha(context, 0.5),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
