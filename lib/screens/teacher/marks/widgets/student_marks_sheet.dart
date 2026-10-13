import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/components/marks/percent_badge.dart';
import 'package:mu_study/core/marks/academic_term.dart';
import 'package:mu_study/core/progress/progress_report_share.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/marks/marks_providers.dart';
import 'package:mu_study/screens/teacher/marks/widgets/gradebook_helpers.dart';
import 'package:mu_study/screens/teacher/marks/widgets/mark_row.dart';

const studentMarksSheetAdd = 'add';

class StudentMarksSheet extends ConsumerWidget {
  const StudentMarksSheet({
    super.key,
    required this.groupId,
    required this.member,
  });

  final String groupId;
  final GroupMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marks = ref.watch(
      memberMarksProvider((groupId: groupId, studentId: member.studentId)),
    );
    final mine = marks.valueOrNull ?? const <Mark>[];
    final average = ref
        .watch(groupMarkAveragesProvider(groupId))
        .valueOrNull?[member.studentId];
    final l10n = context.l10n;

    return GradebookSheetScaffold(
      title: member.fullName,
      subtitle: average == null
          ? l10n.marksNoMarksYetShort
          : l10n.marksAverageLine(
              formatPercent(average),
              percentLabel(average, l10n),
            ),
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () => _shareProgress(context, ref),
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(l10n.progressReportShare),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: gradebookPrimaryButtonStyle(context),
            onPressed: () => Navigator.pop(context, studentMarksSheetAdd),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              l10n.marksAddMark,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      child: marks.isLoading
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          : mine.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: EmptyState(
                title: l10n.marksNothingYet,
                subtitle: l10n.marksAddFirst,
                icon: Icons.grade_outlined,
              ),
            )
          : ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: mine
                  .map(
                    (mark) => MarkRow(
                      mark: mark,
                      showStudent: false,
                      onEdit: () => Navigator.pop(context, mark),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Future<void> _shareProgress(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final groups = ref.read(myGroupsProvider).valueOrNull ?? const [];
    final groupTitle =
        groups.where((g) => g.id == groupId).map((g) => g.title).firstOrNull ??
        'group';
    final term = ref.read(selectedMarkTermProvider);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.progressReportSharing)));

    try {
      await shareProgressReport(
        studentId: member.studentId,
        groupId: groupId,
        studentName: member.fullName,
        groupTitle: groupTitle,
        term: term,
        l10n: l10n,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.progressReportDone)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.progressReportFailed('$e'))),
        );
      }
    }
  }
}
