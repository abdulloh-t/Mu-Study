import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/neumorphic.dart';
import 'package:mu_study/core/utils/time_of_day_greeting.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/notifications/notification_providers.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final teacher = ref.watch(teacherProfileProvider);
    final groups = ref.watch(myGroupsProvider);
    final sphere = teacher.valueOrNull?.sphere;
    final l10n = context.l10n;

    return Scaffold(
      extendBody: true,
      floatingActionButtonLocation: shellFabLocation(context),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            // The shell's nav bar floats above its own body, so sheets opened
            // on the shell navigator would slide out underneath it.
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) {
              final isMono =
                  AppStyleTokens.maybeOf(ctx)?.isMonochromeWorkspace ?? false;
              final sheetRadius = isMono ? 8.0 : 24.0;
              final iconRadius = isMono ? 4.0 : 20.0;

              Widget actionIcon({
                required Color color,
                required IconData icon,
              }) {
                final fill = AppColors.resolveAccent(ctx, color);
                final isNeu = Neumorphic.isActive(ctx);
                if (isNeu) {
                  return NeuIconWell(
                    icon: icon,
                    color: fill,
                    size: 20,
                    padding: 10,
                    elevation: NeuElevation.raised,
                  );
                }
                return Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(iconRadius),
                  ),
                  child: Icon(icon, color: AppColors.onAccent(ctx), size: 20),
                );
              }

              return Container(
                margin: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.viewPaddingOf(ctx).bottom,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.sheetSurface(ctx),
                  borderRadius: BorderRadius.circular(sheetRadius),
                  border: isMono
                      ? Border.all(color: AppColors.inkAlpha(ctx, 0.12))
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PremiumSectionHeader(
                      title: l10n.teacherQuickActions,
                      subtitle: l10n.teacherCreateItems,
                    ),
                    ListTile(
                      leading: actionIcon(
                        color: AppColors.coffeeBrown,
                        icon: Icons.assignment_outlined,
                      ),
                      title: Text(
                        l10n.teacherNewAssignment,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink(ctx),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/teacher/assignments');
                      },
                    ),
                    ListTile(
                      leading: actionIcon(
                        color: AppColors.mutedGold,
                        icon: Icons.campaign_outlined,
                      ),
                      title: Text(
                        l10n.teacherNewAnnouncement,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink(ctx),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/teacher/announcements');
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentProfileProvider);
          ref.invalidate(teacherProfileProvider);
          ref.invalidate(myGroupsProvider);
        },
        child: ListView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: MediaQuery.of(context).padding.top + 24,
            bottom: shellContentBottomPadding(context, hasFab: true),
          ),
          children: [
            profile.when(
              data: (p) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (context) {
                          final sphereColor = AppColors.resolveAccent(
                            context,
                            sphere == Sphere.english
                                ? AppColors.englishAccent
                                : AppColors.mathAccent,
                          );
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: sphereColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppStyleTokens.maybeOf(
                                          context,
                                        )?.isMonochromeWorkspace ==
                                        true
                                    ? 6
                                    : 8,
                              ),
                              border:
                                  (AppStyleTokens.maybeOf(
                                        context,
                                      )?.isMonochromeWorkspace ??
                                      false)
                                  ? Border.all(
                                      color: sphereColor.withValues(alpha: 0.2),
                                    )
                                  : null,
                            ),
                            child: PaperGlyph(
                              icon: sphere == Sphere.english
                                  ? Icons.menu_book
                                  : Icons.calculate,
                              color: sphereColor,
                              size: 20,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.teacherWorkspace,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.inkAlpha(context, 0.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.greetingWithName(
                      timeOfDayGreeting(l10n),
                      p?.fullName.split(' ').first ?? p?.username ?? '',
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (_, _) => SizedBox.shrink(),
            ),
            SizedBox(height: 32),
            groups.when(
              data: (g) => Row(
                children: [
                  _StatCard(
                    label: l10n.teacherActiveGroups,
                    value: '${g.length}',
                    icon: Icons.groups_outlined,
                    color: AppColors.accent(context),
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: l10n.teacherSubject,
                    value: sphere?.name.toUpperCase() ?? '—',
                    icon: Icons.subject_outlined,
                    color: AppColors.mutedGold,
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            ref
                .watch(notificationsProvider)
                .when(
                  data: (list) {
                    final unread = list.where((n) => !n.isRead).length;
                    return PremiumCard(
                      onTap: () => context.push('/teacher/notifications'),
                      child: Row(
                        children: [
                          NeuIconWell(
                            icon: Icons.notifications_outlined,
                            color: AppColors.accent(context),
                            child: Badge(
                              isLabelVisible: unread > 0,
                              label: Text(
                                '$unread',
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: AppColors.danger(context),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: AppColors.accent(context),
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
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  unread > 0
                                      ? l10n.unreadAlerts(unread)
                                      : l10n.upToDate,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.inkAlpha(context, 0.55),
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
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
            const SizedBox(height: 24),
            PremiumSectionHeader(
              title: l10n.teacherDailyTasks,
              subtitle: l10n.teacherNeedsAttention,
            ),
            _QuickActionCard(
              title: l10n.attendanceMark,
              subtitle: l10n.attendanceDailyTracking,
              icon: Icons.how_to_reg_rounded,
              onTap: () => context.push('/teacher/attendance'),
              accentColor: AppColors.mutedGold,
            ),
            _QuickActionCard(
              title: l10n.teacherGradebook,
              subtitle: l10n.teacherRecordMarks,
              icon: Icons.grade_rounded,
              onTap: () => context.push('/teacher/marks'),
              accentColor: AppColors.mathAccent,
            ),
            _QuickActionCard(
              title: l10n.teacherReviewSubmissions,
              subtitle: l10n.teacherCheckAssignments,
              icon: Icons.fact_check_rounded,
              onTap: () => context.push('/teacher/submissions'),
              accentColor: AppColors.successGreen,
            ),
            _QuickActionCard(
              title: l10n.assignmentManage,
              subtitle: l10n.assignmentManageSubtitle,
              icon: Icons.assignment_rounded,
              onTap: () => context.push('/teacher/assignments'),
              accentColor: AppColors.coffeeBrown,
            ),
            _QuickActionCard(
              title: l10n.announcementsTitle,
              subtitle: l10n.announcementsShareUpdates,
              icon: Icons.campaign_rounded,
              onTap: () => context.push('/teacher/announcements'),
              accentColor: AppColors.englishAccent,
            ),
            _QuickActionCard(
              title: l10n.teacherPerformanceAnalytics,
              subtitle: l10n.teacherTrackProgress,
              icon: Icons.analytics_rounded,
              onTap: () => context.push('/teacher/analytics'),
              accentColor: AppColors.warmAmber,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tone = AppColors.resolveAccent(context, color);
    final isNeu = Neumorphic.isActive(context);
    return Expanded(
      child: PremiumCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkAlpha(context, 0.4),
                  ),
                ),
                if (isNeu)
                  NeuIconWell(icon: icon, color: tone, size: 18, padding: 8)
                else
                  PaperGlyph(
                    icon: icon,
                    size: 18,
                    color: tone.withValues(alpha: 0.5),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: tone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final tone = AppColors.resolveAccent(context, accentColor);

    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          NeuIconWell(icon: icon, color: tone, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
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
            color: AppColors.inkAlpha(context, 0.2),
          ),
        ],
      ),
    );
  }
}
