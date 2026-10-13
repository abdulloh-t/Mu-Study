import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/admin/admin_providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminPlatformStatsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminAnalytics)),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (s) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminPlatformStatsProvider),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              shellContentBottomPadding(context),
            ),
            children: [
              PremiumSectionHeader(
                title: l10n.adminActivityDistribution,
                subtitle: l10n.adminGlobalMetrics,
              ),
              PremiumCard(
                padding: const EdgeInsets.all(24),
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  series: <CartesianSeries>[
                    ColumnSeries<_AdminChartData, String>(
                      dataSource: [
                        _AdminChartData(
                          l10n.adminChartAssignments,
                          (s['assignments'] ?? 0).toDouble(),
                        ),
                        _AdminChartData(
                          l10n.adminChartMarks,
                          (s['marks'] ?? 0).toDouble(),
                        ),
                        _AdminChartData(
                          l10n.adminChartStudents,
                          (s['students'] ?? 0).toDouble(),
                        ),
                        _AdminChartData(
                          l10n.adminChartGroups,
                          (s['groups'] ?? 0).toDouble(),
                        ),
                      ],
                      xValueMapper: (d, _) => d.label,
                      yValueMapper: (d, _) => d.value,
                      color: AppColors.accent(context),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminChartData {
  _AdminChartData(this.label, this.value);
  final String label;
  final double value;
}
