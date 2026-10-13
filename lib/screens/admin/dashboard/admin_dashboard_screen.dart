import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/admin/admin_providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminPlatformStatsProvider);

    return stats.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(message: e.toString()),
      data: (s) {
        final l10n = context.l10n;
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminPlatformStatsProvider),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              shellContentBottomPadding(context, extra: 24),
            ),
            children: [
              Text(
                l10n.adminWorkspace,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkAlpha(context, 0.5),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.adminPlatformOverview,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: 32),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _AdminStatCard(
                    title: l10n.adminTeachers,
                    value: s['teachers']!,
                    icon: Icons.school_outlined,
                    color: AppColors.accent(context),
                  ),
                  _AdminStatCard(
                    title: l10n.adminStudents,
                    value: s['students']!,
                    icon: Icons.people_outline,
                    color: AppColors.mutedGold,
                  ),
                  _AdminStatCard(
                    title: l10n.adminGroupsLabel,
                    value: s['groups']!,
                    icon: Icons.groups_outlined,
                    color: AppColors.successGreen,
                  ),
                  _AdminStatCard(
                    title: l10n.adminMarksLabel,
                    value: s['marks'] ?? 0,
                    icon: Icons.grade_outlined,
                    color: AppColors.warmAmber,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              PremiumSectionHeader(
                title: l10n.adminActivityInsights,
                subtitle: l10n.adminCurrentMetrics,
              ),
              PremiumCard(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  height: 200,
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: const CategoryAxis(
                      majorGridLines: MajorGridLines(width: 0),
                      axisLine: AxisLine(width: 0),
                    ),
                    primaryYAxis: const NumericAxis(
                      majorGridLines: MajorGridLines(
                        width: 1,
                        color: Color(0xFFF0F0F0),
                      ),
                      axisLine: AxisLine(width: 0),
                    ),
                    series: <CartesianSeries>[
                      ColumnSeries<_AdminChartData, String>(
                        dataSource: [
                          _AdminChartData(
                            l10n.adminChartTasks,
                            s['assignments']!.toDouble(),
                          ),
                          _AdminChartData(
                            l10n.adminChartGroups,
                            s['groups']!.toDouble(),
                          ),
                          _AdminChartData(
                            l10n.adminChartStaff,
                            s['teachers']!.toDouble(),
                          ),
                        ],
                        xValueMapper: (d, _) => d.label,
                        yValueMapper: (d, _) => d.value,
                        color: AppColors.accent(context),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PremiumSectionHeader(
                title: l10n.adminAcademicYears,
                subtitle: l10n.adminAcademicYearsSubtitle,
              ),
              PremiumCard(
                onTap: () => context.push('/admin/academic-years'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softWash(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.accent(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.adminAcademicYearsTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.adminCreateNextYear,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.inkAlpha(context, 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.inkAlpha(context, 0.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                onTap: () => context.push('/admin/credential-print'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softWash(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.print_outlined,
                        color: AppColors.accent(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.adminCredentialPrintTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.adminCredentialPrintSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.inkAlpha(context, 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.inkAlpha(context, 0.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                onTap: () => context.push('/admin/mass-generator'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softWash(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.dataset_outlined,
                        color: AppColors.accent(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mass Data Generator',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Paste teachers, groups and students; generate in one go.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.inkAlpha(context, 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.inkAlpha(context, 0.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tone = AppColors.resolveAccent(context, color);
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: tone),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.ink(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.0,
              fontWeight: FontWeight.w800,
              color: AppColors.inkAlpha(context, 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminChartData {
  _AdminChartData(this.label, this.value);
  final String label;
  final double value;
}
