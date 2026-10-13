import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/analytics/teacher_analytics_charts.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/inputs/group_selector.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/attendance/attendance_providers.dart';
import 'package:mu_study/providers/marks/marks_providers.dart';

class TeacherAnalyticsScreen extends ConsumerWidget {
  const TeacherAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(activeGroupIdProvider);
    final l10n = context.l10n;

    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navAnalytics)),
        body: EmptyState(title: l10n.teacherNoData),
      );
    }

    final attendance = ref.watch(attendanceWeekTrendProvider(groupId));
    final averages = ref.watch(groupMarkAveragesProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navAnalytics)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(attendanceWeekTrendProvider(groupId));
          ref.invalidate(groupMarkAveragesProvider(groupId));
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            shellContentBottomPadding(context, extra: 8),
          ),
          children: [
            const GroupSelector(padding: EdgeInsets.only(bottom: 8)),
            PremiumSectionHeader(
              title: l10n.teacherMarkDistribution,
              subtitle: l10n.teacherStudentsByAverage,
              decorAsset: PaperAssets.texturedTanStar,
            ),
            averages.when(
              data: (map) {
                final bands = markBandPoints(
                  context,
                  l10n,
                  map.values.toList(),
                );
                if (bands.isEmpty) {
                  return EmptyState(
                    title: l10n.marksNoRecorded,
                    subtitle: l10n.teacherNoMarksTrends,
                    icon: Icons.grade_outlined,
                  );
                }
                return PaperTaped(
                  alignment: 0.45,
                  child: PremiumCard(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: MarkDistributionDoughnut(points: bands),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorState(message: e.toString()),
            ),
            const SizedBox(height: 8),
            PremiumSectionHeader(
              title: l10n.attendanceTrend,
              subtitle: l10n.attendanceOverall,
              decorAsset: PaperAssets.calendar,
            ),
            attendance.when(
              data: (trend) => PaperTaped(
                alignment: -0.45,
                child: PremiumCard(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: AttendanceTrendBars(trend: trend),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorState(message: e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
