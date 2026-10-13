import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/inputs/group_selector.dart';
import 'package:mu_study/components/inputs/load_more_button.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/components/marks/percent_badge.dart';
import 'package:mu_study/components/marks/term_selector.dart';
import 'package:mu_study/core/marks/academic_term.dart';
import 'package:mu_study/core/marks/marks_csv_export.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/marks/marks_providers.dart';
import 'package:mu_study/screens/teacher/marks/widgets/bulk_mark_sheet.dart';
import 'package:mu_study/screens/teacher/marks/widgets/mark_editor_sheet.dart';
import 'package:mu_study/screens/teacher/marks/widgets/mark_row.dart';
import 'package:mu_study/screens/teacher/marks/widgets/student_marks_sheet.dart';

class TeacherMarksScreen extends ConsumerWidget {
  const TeacherMarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(activeGroupIdProvider);
    final l10n = context.l10n;

    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.teacherGradebook)),
        body: EmptyState(
          title: l10n.teacherNoGroups,
          subtitle: l10n.teacherNoGroupsSubtitle,
          icon: Icons.groups_outlined,
        ),
      );
    }

    final members = ref.watch(groupMembersProvider(groupId));
    final averages = ref.watch(groupMarkAveragesProvider(groupId));
    final marks = ref.watch(groupMarksProvider(groupId));
    final markCount =
        ref.watch(groupMarkCountProvider(groupId)).valueOrNull ?? 0;
    final groups = ref.watch(myGroupsProvider).valueOrNull ?? const [];
    final groupTitle = groups
        .where((g) => g.id == groupId)
        .map((g) => g.title)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.teacherGradebook),
        actions: [
          IconButton(
            tooltip: l10n.marksExportCsv,
            onPressed: () =>
                _export(context, ref, groupId, groupTitle ?? 'group'),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      floatingActionButtonLocation: shellFabLocation(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBulkEntry(context, ref, groupId),
        icon: const Icon(Icons.playlist_add_rounded),
        label: Text(l10n.teacherGradeClass),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(ref, groupId),
        child: ListView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: shellContentBottomPadding(context, hasFab: true),
          ),
          children: [
            const GroupSelector(padding: EdgeInsets.only(bottom: 8)),
            const TermSelector(padding: EdgeInsets.only(bottom: 12)),
            _ClassSummaryCard(
              averages: averages.valueOrNull ?? const {},
              studentCount: members.valueOrNull?.length ?? 0,
              markCount: markCount,
            ),
            PremiumSectionHeader(
              title: l10n.marksStudentsHeader,
              subtitle: l10n.marksStudentsSubtitle,
            ),
            members.when(
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    title: l10n.marksNoStudents,
                    subtitle: l10n.marksNoStudentsSubtitle,
                    icon: Icons.person_off_outlined,
                  );
                }
                final avg = averages.valueOrNull ?? const <String, double>{};
                return Column(
                  children: list
                      .map(
                        (m) => _StudentRow(
                          member: m,
                          average: avg[m.studentId],
                          onTap: () =>
                              _openStudentSheet(context, ref, groupId, m),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => ErrorState(message: e.toString()),
            ),
            const SizedBox(height: 8),
            PremiumSectionHeader(
              title: l10n.marksRecent,
              subtitle: l10n.marksRecentSubtitle,
            ),
            marks.when(
              data: (page) {
                if (page.items.isEmpty) {
                  return EmptyState(
                    title: l10n.marksNoRecorded,
                    subtitle: l10n.marksNoRecordedSubtitle,
                    icon: Icons.grade_outlined,
                  );
                }
                return Column(
                  children: [
                    ...page.items.map(
                      (mark) => MarkRow(
                        mark: mark,
                        onEdit: () => _openMarkEditor(
                          context,
                          ref,
                          groupId: groupId,
                          studentId: mark.studentId,
                          studentName: mark.studentName ?? l10n.commonStudent,
                          existing: mark,
                        ),
                        onDelete: () => _confirmDelete(context, ref, mark),
                      ),
                    ),
                    LoadMoreButton(
                      hasMore: page.hasMore,
                      loading: page.loadingMore,
                      onPressed: () => ref
                          .read(groupMarksProvider(groupId).notifier)
                          .loadMore(),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, _) => ErrorState(message: e.toString()),
            ),
          ],
        ),
      ),
    );
  }

  void _refresh(WidgetRef ref, String groupId) {
    ref.invalidate(groupMembersProvider(groupId));
    ref.invalidate(groupMarkAveragesProvider(groupId));
    ref.invalidate(groupMarkCountProvider(groupId));
    ref.invalidate(groupMarksProvider(groupId));
    ref.invalidate(memberMarksProvider);
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    String groupId,
    String groupTitle,
  ) async {
    final l10n = context.l10n;
    try {
      await exportGroupMarksCsv(
        groupId: groupId,
        groupTitle: groupTitle,
        term: ref.read(selectedMarkTermProvider),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.marksExportDone)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.commonExportFailed('$e'))));
      }
    }
  }

  Future<void> _openStudentSheet(
    BuildContext context,
    WidgetRef ref,
    String groupId,
    GroupMember member,
  ) async {
    final result = await showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      // The shell's nav bar floats above its own body, so a sheet opened on
      // the shell navigator would come up underneath it.
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentMarksSheet(groupId: groupId, member: member),
    );

    if (context.mounted && result != null) {
      await _openMarkEditor(
        context,
        ref,
        groupId: groupId,
        studentId: member.studentId,
        studentName: member.fullName,
        existing: result is Mark ? result : null,
      );
    }
    _refresh(ref, groupId);
  }

  Future<void> _openBulkEntry(
    BuildContext context,
    WidgetRef ref,
    String groupId,
  ) async {
    final members = await ref.read(groupMembersProvider(groupId).future);
    if (!context.mounted) return;
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.marksGroupHasNoStudents)),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BulkMarkSheet(groupId: groupId, members: members),
    );
    _refresh(ref, groupId);
  }

  Future<void> _openMarkEditor(
    BuildContext context,
    WidgetRef ref, {
    required String groupId,
    required String studentId,
    required String studentName,
    Mark? existing,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MarkEditorSheet(
        groupId: groupId,
        studentId: studentId,
        studentName: studentName,
        existing: existing,
      ),
    );
    _refresh(ref, groupId);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Mark mark,
  ) async {
    if (mark.isFromSubmission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.marksFromSubmissionDelete)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = context.l10n;
        return AlertDialog(
          title: Text(l10n.marksDeleteTitle),
          content: Text(l10n.marksDeleteBody(mark.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.errorRed,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await deleteMark(mark.id);
    _refresh(ref, mark.groupId);
  }
}

class _ClassSummaryCard extends StatelessWidget {
  const _ClassSummaryCard({
    required this.averages,
    required this.studentCount,
    required this.markCount,
  });

  final Map<String, double> averages;
  final int studentCount;
  final int markCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final values = averages.values.toList();
    final classAverage = values.isEmpty
        ? null
        : values.reduce((a, b) => a + b) / values.length;

    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.marksOverallAverage.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.inkAlpha(context, 0.4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formatPercent(classAverage),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: classAverage == null
                      ? AppColors.inkAlpha(context, 0.3)
                      : percentColor(classAverage, context: context),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SummaryStat(
                label: l10n.marksSummaryStudents,
                value: '$studentCount',
              ),
              const SizedBox(height: 8),
              _SummaryStat(label: l10n.marksSummaryMarks, value: '$markCount'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.inkAlpha(context, 0.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ],
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.member,
    required this.average,
    required this.onTap,
  });

  final GroupMember member;
  final double? average;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.softSurface(context),
            child: Text(
              member.fullName.isEmpty ? '?' : member.fullName[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.accent(context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  average == null
                      ? l10n.marksNoMarksYetShort
                      : percentLabel(average ?? 0, l10n),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.inkAlpha(context, 0.5),
                  ),
                ),
              ],
            ),
          ),
          PercentBadge(percent: average),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.inkAlpha(context, 0.25),
          ),
        ],
      ),
    );
  }
}
