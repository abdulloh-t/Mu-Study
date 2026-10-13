import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/homework/due_date_label.dart';
import 'package:mu_study/components/inputs/group_selector.dart';
import 'package:mu_study/components/inputs/load_more_button.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/homework/assignment_due.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/neumorphic.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/homework/assignment_providers.dart';

class StudentAssignmentsScreen extends ConsumerWidget {
  const StudentAssignmentsScreen({super.key});

  void _open(BuildContext context, Assignment a) {
    context.push('/student/assignments/${a.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(activeGroupIdProvider);
    final assignments = ref.watch(assignmentsProvider(groupId));

    final l10n = context.l10n;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: Text(l10n.assignmentsTitle)),
      body: assignments.when(
        data: (page) {
          final list = sortAssignmentsByDue(page.items);
          if (list.isEmpty) {
            return ListView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: shellContentBottomPadding(context),
              ),
              children: [
                const GroupSelector(padding: EdgeInsets.only(bottom: 12)),
                EmptyState(
                  title: l10n.assignmentsEmpty,
                  subtitle: l10n.assignmentsEmptySubtitle,
                  icon: Icons.task_alt_rounded,
                ),
              ],
            );
          }
          final isNeu = Neumorphic.isActive(context);
          return ListView.builder(
            clipBehavior: isNeu ? Clip.none : Clip.hardEdge,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: shellContentBottomPadding(context),
            ),
            itemCount: list.length + 1 + (page.hasMore ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GroupSelector(padding: EdgeInsets.only(bottom: 8)),
                    PremiumSectionHeader(
                      title: l10n.assignmentsLearningPath,
                      subtitle: l10n.assignmentsActive,
                    ),
                  ],
                );
              }
              if (i == list.length + 1) {
                return LoadMoreButton(
                  hasMore: page.hasMore,
                  loading: page.loadingMore,
                  onPressed: () => ref
                      .read(assignmentsProvider(groupId).notifier)
                      .loadMore(),
                );
              }
              final a = list[i - 1];
              final isPack = a.type == AssignmentType.homeworkPack;
              final isMath = a.title.toLowerCase().contains('math');
              final overdue = assignmentIsOverdue(a);
              final accent = AppColors.resolveAccent(
                context,
                overdue
                    ? AppColors.danger(context)
                    : (isMath ? AppColors.mathAccent : AppColors.englishAccent),
              );
              final iconData = overdue
                  ? Icons.warning_amber_rounded
                  : isMath
                  ? Icons.calculate_rounded
                  : Icons.menu_book_rounded;

              return PremiumCard(
                onTap: () => _open(context, a),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    NeuIconWell(icon: iconData, color: accent, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  a.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (overdue) ...[
                                const SizedBox(width: 8),
                                Text(
                                  l10n.homeworkLateBadge,
                                  style: TextStyle(
                                    color: AppColors.danger(context),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          DueDateLabel(assignment: a, compact: true),
                          if (a.description.isNotEmpty &&
                              a.dueDate == null) ...[
                            const SizedBox(height: 2),
                            Text(
                              a.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.inkAlpha(context, 0.5),
                                fontSize: 13,
                              ),
                            ),
                          ],
                          if (isPack) ...[
                            const SizedBox(height: 2),
                            Text(
                              l10n.homeworkPack,
                              style: TextStyle(
                                color: AppColors.inkAlpha(context, 0.4),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.inkAlpha(context, 0.3),
                      size: 20,
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
      ),
    );
  }
}

class StudentAssignmentDetailScreen extends ConsumerWidget {
  const StudentAssignmentDetailScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignment = ref.watch(assignmentDetailProvider(assignmentId));
    final tasks = ref.watch(tasksProvider(assignmentId));

    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.assignmentDetails)),
      body: assignment.when(
        data: (a) {
          if (a == null) {
            return EmptyState(title: l10n.assignmentNotFound);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(assignmentDetailProvider(assignmentId));
              ref.invalidate(tasksProvider(assignmentId));
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                shellContentBottomPadding(context, extra: 24),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.accent(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent(context).withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (a.type == AssignmentType.homeworkPack
                                ? l10n.homeworkPack
                                : l10n.staticTask)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      DueDateLabel(assignment: a, onDark: true),
                      if (a.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          a.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                PremiumSectionHeader(
                  title: l10n.assignmentTasks,
                  subtitle: l10n.assignmentTasksSubtitle,
                ),
                tasks.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return EmptyState(
                        title: l10n.assignmentsEmpty,
                        icon: Icons.task_alt_rounded,
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final t = items[index];
                        return PremiumCard(
                          onTap: () => context.push('/student/tasks/${t.id}'),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.softWash(
                                    context,
                                    lightAlpha: 0.3,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.accent(context),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (t.description.isNotEmpty)
                                      Text(
                                        t.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.inkAlpha(
                                            context,
                                            0.5,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => ErrorState(message: e.toString()),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
      ),
    );
  }
}
