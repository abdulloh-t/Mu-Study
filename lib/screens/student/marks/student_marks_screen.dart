import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/inputs/load_more_button.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/components/marks/mark_average_card.dart';
import 'package:mu_study/components/marks/percent_badge.dart';
import 'package:mu_study/components/marks/term_selector.dart';
import 'package:mu_study/core/marks/academic_term.dart';
import 'package:mu_study/core/progress/progress_report_share.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/domain_labels.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/marks/marks_providers.dart';

class StudentMarksScreen extends ConsumerWidget {
  const StudentMarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marks = ref.watch(myMarksProvider);
    final stats = ref.watch(myMarkStatsProvider);
    final average = ref.watch(myMarkAverageProvider).valueOrNull;
    final markCount = stats.valueOrNull?.length ?? 0;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marksTitle),
        actions: [
          IconButton(
            tooltip: l10n.progressReportShare,
            onPressed: () => _shareProgress(context, ref),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myMarksProvider);
          ref.invalidate(myMarkStatsProvider);
          ref.invalidate(myMarkAverageProvider);
        },
        child: marks.when(
          data: (page) => ListView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: shellContentBottomPadding(context),
            ),
            children: [
              const TermSelector(padding: EdgeInsets.only(bottom: 12)),
              MarkAverageCard(average: average, markCount: markCount),
              if (markCount > 0) ...[
                PremiumSectionHeader(
                  title: context.l10n.marksByCategory,
                  subtitle: context.l10n.marksWhereStrongest,
                  decorAsset: PaperAssets.brainVerified,
                ),
                _CategoryBreakdown(stats: stats.valueOrNull ?? const []),
                PremiumSectionHeader(
                  title: context.l10n.marksAll,
                  subtitle: context.l10n.marksNewestFirst,
                  decorAsset: PaperAssets.documentLayout,
                ),
                if (page.items.isEmpty)
                  EmptyState(
                    title: context.l10n.marksEmptyTitle,
                    subtitle: context.l10n.marksEmptySubtitle,
                    icon: Icons.grade_outlined,
                  )
                else ...[
                  ...page.items.map((m) => _StudentMarkTile(mark: m)),
                  LoadMoreButton(
                    hasMore: page.hasMore,
                    loading: page.loadingMore,
                    onPressed: () =>
                        ref.read(myMarksProvider.notifier).loadMore(),
                  ),
                ],
              ] else
                EmptyState(
                  title: context.l10n.marksEmptyTitle,
                  subtitle: context.l10n.marksEmptySubtitle,
                  icon: Icons.grade_outlined,
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(message: e.toString()),
        ),
      ),
    );
  }

  Future<void> _shareProgress(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final groupId = ref.read(activeGroupIdProvider);
    if (groupId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.progressReportNeedGroup)));
      return;
    }

    final student = await ref.read(studentProfileProvider.future);
    final profile = await ref.read(currentProfileProvider.future);
    if (student == null || profile == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.progressReportFailed('No profile'))),
        );
      }
      return;
    }

    final groups = ref.read(myGroupsProvider).valueOrNull ?? const [];
    final groupTitle =
        groups.where((g) => g.id == groupId).map((g) => g.title).firstOrNull ??
        'group';
    final term = ref.read(selectedMarkTermProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.progressReportSharing)));
    }

    try {
      await shareProgressReport(
        studentId: student.id,
        groupId: groupId,
        studentName: profile.fullName.isNotEmpty
            ? profile.fullName
            : profile.username,
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

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.stats});

  final List<({MarkCategory category, double percentage, double weight})> stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final byCategory =
        <MarkCategory, List<({double percentage, double weight})>>{};
    for (final s in stats) {
      byCategory.putIfAbsent(s.category, () => []).add((
        percentage: s.percentage,
        weight: s.weight,
      ));
    }

    final rows = byCategory.entries.map((entry) {
      final totalWeight = entry.value.fold<double>(0, (s, m) => s + m.weight);
      final weighted = entry.value.fold<double>(
        0,
        (s, m) => s + m.percentage * m.weight,
      );
      return (entry.key, totalWeight == 0 ? 0.0 : weighted / totalWeight);
    }).toList()..sort((a, b) => b.$2.compareTo(a.$2));

    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.$1.l10nLabel(l10n),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: row.$2 / 100,
                          minHeight: 6,
                          backgroundColor: AppColors.softSurface(context),
                          valueColor: AlwaysStoppedAnimation(
                            percentColor(row.$2, context: context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 48,
                      child: Text(
                        formatPercent(row.$2),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StudentMarkTile extends StatelessWidget {
  const _StudentMarkTile({required this.mark});

  final Mark mark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mark.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    mark.category.l10nLabel(l10n),
                    if (mark.groupTitle != null) mark.groupTitle!,
                    DateFormat.yMMMd().format(mark.markedOn),
                  ].join(' · '),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.inkAlpha(context, 0.5),
                  ),
                ),
              ],
            ),
          ),
          PercentBadge(percent: mark.percentage),
        ],
      ),
    );
  }
}
