import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mu_study/components/buttons/primary_button.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/homework/due_date_label.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/homework/assignment_due.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/homework/assignment_providers.dart';

class FocusHomeView extends ConsumerWidget {
  const FocusHomeView({super.key, required this.onStart});

  final Future<void> Function(Assignment a) onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final groupId = ref.watch(activeGroupIdProvider);
    final assignments = ref.watch(assignmentsProvider(groupId));
    final nature = isNaturePaper(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          if (groupId != null) ref.invalidate(assignmentsProvider(groupId));
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.paddingOf(context).top + 20,
            20,
            shellContentBottomPadding(context),
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.focusTitle,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.focusSubtitle,
                        style: TextStyle(
                          color: AppColors.inkAlpha(context, 0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (nature)
                  const PaperDecor(
                    PaperAssets.whiteCloud,
                    size: 48,
                    opacity: 0.7,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            PremiumSectionHeader(
              title: l10n.focusTodaysFocus,
              subtitle: l10n.focusTodaysFocusSubtitle,
              decorAsset: PaperAssets.yellowPencil,
            ),
            assignments.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => ErrorState(message: e.toString()),
              data: (page) {
                final focusItems = assignmentsForFocusSession(
                  page.items,
                ).take(3).toList();
                if (focusItems.isEmpty) {
                  return EmptyState(
                    title: l10n.focusEmptyTitle,
                    subtitle: l10n.focusEmptySubtitle,
                    icon: Icons.self_improvement_outlined,
                  );
                }
                final primary = focusItems.first;
                return Column(
                  children: [
                    PremiumCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              PaperGlyph(
                                icon: Icons.task_alt_rounded,
                                size: 28,
                                color: AppColors.accent(context),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      primary.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    DueDateLabel(
                                      assignment: primary,
                                      compact: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            label: l10n.focusContinueHomework,
                            onPressed: () => onStart(primary),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.push(
                              '/student/assignments/${primary.id}',
                            ),
                            child: Text(l10n.focusOpenAssignment),
                          ),
                        ],
                      ),
                    ),
                    if (focusItems.length > 1) ...[
                      const SizedBox(height: 16),
                      PremiumSectionHeader(
                        title: l10n.focusAlsoDue,
                        decorAsset: PaperAssets.stickyNotesPair,
                      ),
                      for (final a in focusItems.skip(1))
                        PremiumCard(
                          onTap: () => onStart(a),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              PaperGlyph(
                                icon: assignmentIsOverdue(a)
                                    ? Icons.warning_amber_rounded
                                    : Icons.assignment_outlined,
                                color: assignmentIsOverdue(a)
                                    ? AppColors.danger(context)
                                    : AppColors.accent(context),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    DueDateLabel(assignment: a, compact: true),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.play_circle_outline_rounded,
                                color: AppColors.inkAlpha(context, 0.35),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            PremiumCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 20,
                    color: AppColors.inkAlpha(context, 0.45),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.focusChatMuteHint,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.inkAlpha(context, 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
