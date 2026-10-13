import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/homework/due_date_label.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/homework/assignment_due.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/neumorphic.dart';
import 'package:mu_study/core/utils/time_of_day_greeting.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/components/marks/mark_average_card.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/homework/assignment_providers.dart';
import 'package:mu_study/providers/notifications/notification_providers.dart';
import 'package:mu_study/providers/marks/marks_providers.dart';
import 'package:mu_study/screens/student/home/widgets/dashboard_announcements.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState
    extends ConsumerState<StudentDashboardScreen> {
  late final int _dailyGreetingIndex;

  @override
  void initState() {
    super.initState();
    _dailyGreetingIndex = Random().nextInt(4);
  }

  String _dailyMotivation(AppLocalizations l10n) {
    final lines = [
      l10n.dailyMotivation1,
      l10n.dailyMotivation2,
      l10n.dailyMotivation3,
      l10n.dailyMotivation4,
    ];
    return lines[_dailyGreetingIndex];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider);
    final groupId = ref.watch(activeGroupIdProvider);
    final assignments = ref.watch(assignmentsProvider(groupId));
    final notifications = ref.watch(notificationsProvider);
    final announcements = ref.watch(announcementsProvider(groupId));
    final marks = ref.watch(myMarksProvider);
    final average = ref.watch(myMarkAverageProvider).valueOrNull;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myGroupsProvider);
        ref.invalidate(myMarksProvider);
        ref.invalidate(myMarkAverageProvider);
        if (groupId != null) {
          ref.invalidate(assignmentsProvider(groupId));
          ref.invalidate(announcementsProvider(groupId));
        }
      },
      child: ListView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: MediaQuery.of(context).padding.top + 24,
          bottom: shellContentBottomPadding(context),
        ),
        children: [
          profile.when(
            data: (p) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.accent(context),
                      child: Text(
                        (p?.fullName.isNotEmpty == true
                                ? p!.fullName
                                : p?.username ?? 'U')[0]
                            .toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.greetingWithName(timeOfDayGreeting(l10n), p?.fullName.split(' ').first ?? p?.username ?? '')} 👋',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dailyMotivation(l10n),
                            style: TextStyle(
                              color: AppColors.inkAlpha(context, 0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PaperDecor(PaperAssets.whiteCloud, size: 44, opacity: 0.8),
                  ],
                ),
              ],
            ),
            loading: () => Skeletonizer(
              enabled: true,
              child: ListTile(
                leading: const CircleAvatar(radius: 24),
                title: Text(l10n.greetingLoadingTitle),
                subtitle: Text(l10n.greetingLoadingSubtitle),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          MarkAverageCard(
            average: average,
            markCount: marks.valueOrNull?.items.length ?? 0,
            onTap: () => context.push('/student/marks'),
          ),
          const SizedBox(height: 16),

          PremiumSectionHeader(
            title: l10n.continueLearning,
            subtitle: l10n.continueLearningSubtitle,
            decorAsset: PaperAssets.yellowPencil,
          ),
          assignments.when(
            data: (page) {
              final list = sortAssignmentsByDue(page.items);
              if (list.isEmpty) {
                return PremiumCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      if (isNaturePaper(context))
                        const PaperEmptyIllustration(
                          asset: PaperAssets.envelopeSuccess,
                        )
                      else
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 48,
                          color: AppColors.accent(
                            context,
                          ).withValues(alpha: 0.85),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.everythingCompleted,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.caughtUpToday,
                        style: TextStyle(
                          color: AppColors.inkAlpha(context, 0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }
              final a = list.first;
              final isMath = a.title.toLowerCase().contains('math');
              final accent = assignmentIsOverdue(a)
                  ? AppColors.danger(context)
                  : isMath
                  ? AppColors.accent(context)
                  : AppColors.goldAccent(context);
              final heroRadius =
                  AppStyleTokens.maybeOf(context)?.cardRadius ?? 16.0;

              return PremiumCard(
                onTap: () => context.push('/student/assignments/${a.id}'),
                padding: EdgeInsets.zero,
                elevation: NeuElevation.floating,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(heroRadius),
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.82)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: isNaturePaper(context)
                            ? Opacity(
                                opacity: 0.16,
                                child: Transform.rotate(
                                  angle: 0.18,
                                  child: Image.asset(
                                    isMath
                                        ? PaperAssets.linedPaperPencil
                                        : PaperAssets.openBook,
                                    width: 130,
                                    filterQuality: FilterQuality.medium,
                                  ),
                                ),
                              )
                            : Icon(
                                isMath ? Icons.calculate : Icons.menu_book,
                                size: 140,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    a.type == AssignmentType.homeworkPack
                                        ? l10n.homeworkPack
                                        : l10n.staticTask,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                DueDateLabel(assignment: a, onDark: true),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              a.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (a.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                a.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Consumer(
                              builder: (context, ref, _) {
                                final progressAsync = ref.watch(
                                  assignmentProgressProvider(a.id),
                                );
                                final progress =
                                    progressAsync.valueOrNull ?? 0.0;

                                return Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                l10n.commonProgress,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.8),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                '${(progress * 100).toInt()}%',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween<double>(
                                                begin: 0,
                                                end: progress,
                                              ),
                                              duration: const Duration(
                                                milliseconds: 1000,
                                              ),
                                              curve: Curves.easeOutCubic,
                                              builder: (context, value, _) {
                                                return LinearProgressIndicator(
                                                  value: value,
                                                  backgroundColor:
                                                      Colors.black26,
                                                  valueColor:
                                                      const AlwaysStoppedAnimation(
                                                        Colors.white,
                                                      ),
                                                  minHeight: 6,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.play_arrow_rounded,
                                        color: accent,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Skeletonizer(
              enabled: true,
              child: PremiumCard(
                child: SizedBox(height: 200, width: double.infinity),
              ),
            ),
            error: (e, _) => ErrorState(message: e.toString()),
          ),
          const SizedBox(height: 24),

          PremiumCard(
            onTap: () => context.go('/student/focus'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                PaperGlyph(
                  icon: Icons.self_improvement_outlined,
                  size: 26,
                  color: AppColors.accent(context),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.focusTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.focusSubtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkAlpha(context, 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkAlpha(context, 0.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          PremiumSectionHeader(
            title: l10n.homeworkDueThisWeek,
            subtitle: l10n.homeworkDueThisWeekSubtitle,
            decorAsset: PaperAssets.stickyNotesPair,
          ),
          assignments.when(
            data: (page) {
              final dueFocus = assignmentsDueThisWeekFocus(page.items);
              if (dueFocus.isEmpty) {
                return PremiumCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      PaperGlyph(
                        icon: Icons.event_available_rounded,
                        size: 26,
                        color: AppColors.success(
                          context,
                        ).withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeworkNoDueThisWeek,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.homeworkNoDueThisWeekSubtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.inkAlpha(context, 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: dueFocus.take(5).map((a) {
                  final isHomeworkPack = a.type == AssignmentType.homeworkPack;
                  final overdue = assignmentIsOverdue(a);
                  return PremiumCard(
                    onTap: () => context.push('/student/assignments/${a.id}'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) {
                            final tone = AppColors.resolveAccent(
                              context,
                              overdue
                                  ? AppColors.danger(context)
                                  : isHomeworkPack
                                  ? AppColors.goldAccent(context)
                                  : AppColors.accent(context),
                            );
                            final iconData = overdue
                                ? Icons.warning_amber_rounded
                                : isHomeworkPack
                                ? Icons.inventory_2_rounded
                                : Icons.task_alt_rounded;
                            if (Neumorphic.isActive(context)) {
                              return NeuIconWell(
                                icon: iconData,
                                color: tone,
                                size: 20,
                              );
                            }
                            final isMono =
                                AppStyleTokens.maybeOf(
                                  context,
                                )?.isMonochromeWorkspace ??
                                false;
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: tone.withValues(
                                  alpha: isMono ? 0.08 : 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppStyleTokens.maybeOf(context)?.cardRadius ??
                                      12,
                                ),
                                border: isMono
                                    ? Border.all(
                                        color: tone.withValues(alpha: 0.18),
                                      )
                                    : null,
                              ),
                              child: PaperGlyph(
                                icon: iconData,
                                color: tone,
                                size: 20,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              DueDateLabel(assignment: a, compact: true),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.inkAlpha(context, 0.3),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),
          PremiumSectionHeader(
            title: context.l10n.announcementsTitle,
            subtitle: context.l10n.announcementsSubtitle,
            decorAsset: PaperAssets.tanNoteGreenTab,
          ),
          announcements.when(
            data: (list) => list.isEmpty
                ? EmptyState(
                    title: context.l10n.announcementsEmpty,
                    icon: Icons.campaign_rounded,
                  )
                : DashboardAnnouncements(announcements: list),
            loading: () => Skeletonizer(
              enabled: true,
              child: PremiumCard(child: Text(l10n.loadingAnnouncements)),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),
          notifications.when(
            data: (list) {
              final unread = list.where((n) => !n.isRead).length;
              return PremiumCard(
                onTap: () => context.go('/student/notifications'),
                child: Row(
                  children: [
                    NeuIconWell(
                      icon: Icons.notifications_none_rounded,
                      color: AppColors.accent(context),
                      size: 20,
                      child: Badge(
                        isLabelVisible: unread > 0,
                        label: Text(
                          '$unread',
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: AppColors.danger(context),
                        child: PaperGlyph(
                          icon: Icons.notifications_none_rounded,
                          color: AppColors.accent(context),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.notificationsCardTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            unread > 0
                                ? l10n.unreadAlerts(unread)
                                : l10n.upToDate,
                            style: TextStyle(
                              color: AppColors.inkAlpha(context, 0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.inkAlpha(context, 0.3),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
