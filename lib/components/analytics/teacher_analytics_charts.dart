import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/attendance/attendance_providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsChartPoint {
  const AnalyticsChartPoint(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class MarkDistributionDoughnut extends StatelessWidget {
  const MarkDistributionDoughnut({super.key, required this.points});

  final List<AnalyticsChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final total = points.fold<double>(0, (sum, p) => sum + p.value).round();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelsInside =
        AppStyleTokens.maybeOf(context)?.prefersChartLabelsInside ?? false;

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.analyticsTotalMarks(total),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            series: <CircularSeries<AnalyticsChartPoint, String>>[
              DoughnutSeries<AnalyticsChartPoint, String>(
                dataSource: points,
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.value,
                pointColorMapper: (d, _) => d.color,
                innerRadius: '62%',
                radius: '78%',
                strokeWidth: isDark ? 2 : 1,
                strokeColor: isDark ? const Color(0xFF1A1A1A) : scheme.surface,
                animationDuration: 1100,
                animationDelay: 80,
                dataLabelMapper: (d, _) {
                  final pct = total == 0
                      ? 0
                      : ((d.value / total) * 100).round();
                  return '${d.value.round()}\n$pct%';
                },
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: labelsInside
                      ? ChartDataLabelPosition.inside
                      : ChartDataLabelPosition.outside,
                  connectorLineSettings: ConnectorLineSettings(
                    type: ConnectorType.curve,
                    length: '12%',
                    width: labelsInside ? 0 : 1.2,
                    color: scheme.onSurface.withValues(alpha: 0.35),
                  ),
                  textStyle: TextStyle(
                    color: labelsInside ? Colors.white : scheme.onSurface,
                    fontSize: 11,
                    fontWeight: labelsInside
                        ? FontWeight.w700
                        : FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final p in points)
              _LegendPill(
                color: p.color,
                label: '${p.label}: ${p.value.round()}',
              ),
          ],
        ),
      ],
    );
  }
}

class AttendanceTrendBars extends StatelessWidget {
  const AttendanceTrendBars({super.key, required this.trend});

  final AttendanceWeekTrend trend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = AppStyleTokens.maybeOf(context);
    final isMono = tokens?.isMonochromeWorkspace ?? false;
    final barRadius = isMono
        ? const BorderRadius.vertical(top: Radius.circular(2))
        : const BorderRadius.vertical(top: Radius.circular(6));
    final labelOnBar = isMono && !isDark
        ? AppColors.ink(context)
        : Colors.white;
    final categories = <_WeekCategory>[
      _WeekCategory(
        l10n.analyticsThisWeek,
        trend.thisWeek.present.toDouble(),
        trend.thisWeek.absent.toDouble(),
        trend.thisWeek.late.toDouble(),
      ),
      _WeekCategory(
        l10n.analyticsLastWeek,
        trend.lastWeek.present.toDouble(),
        trend.lastWeek.absent.toDouble(),
        trend.lastWeek.late.toDouble(),
      ),
    ];
    final maxY = [
      trend.thisWeek.max,
      trend.lastWeek.max,
      1,
    ].reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: SfCartesianChart(
            margin: const EdgeInsets.only(top: 8, right: 8),
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              labelStyle: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: (maxY + 1).toDouble(),
              interval: maxY <= 5 ? 1 : null,
              majorGridLines: MajorGridLines(
                width: 1,
                color: scheme.onSurface.withValues(alpha: isDark ? 0.12 : 0.08),
              ),
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              labelStyle: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.45),
                fontSize: 11,
              ),
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
              iconHeight: 10,
              iconWidth: 10,
              padding: 0,
              itemPadding: 12,
              textStyle: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
            series: <CartesianSeries<_WeekCategory, String>>[
              ColumnSeries<_WeekCategory, String>(
                name: l10n.attendancePresentWord,
                dataSource: categories,
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.present,
                dataLabelMapper: (d, _) =>
                    d.present == 0 ? '' : '${d.present.round()}',
                color: AppColors.success(context),
                gradient: isMono ? null : tokens?.chartPositive,
                borderRadius: barRadius,
                width: isMono ? 0.55 : 0.7,
                spacing: 0.18,
                animationDuration: 1000,
                animationDelay: 60,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.middle,
                  textStyle: TextStyle(
                    color: isMono && !isDark ? Colors.white : labelOnBar,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ColumnSeries<_WeekCategory, String>(
                name: l10n.attendanceAbsentWord,
                dataSource: categories,
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.absent,
                dataLabelMapper: (d, _) =>
                    d.absent == 0 ? '' : '${d.absent.round()}',
                color: AppColors.danger(context),
                gradient: isMono ? null : tokens?.chartDanger,
                borderRadius: barRadius,
                width: isMono ? 0.55 : 0.7,
                spacing: 0.18,
                animationDuration: 1100,
                animationDelay: 160,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.middle,
                  textStyle: TextStyle(
                    color: isMono && !isDark ? Colors.white : labelOnBar,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ColumnSeries<_WeekCategory, String>(
                name: l10n.attendanceLateWord,
                dataSource: categories,
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.late,
                dataLabelMapper: (d, _) =>
                    d.late == 0 ? '' : '${d.late.round()}',
                color: AppColors.warning(context),
                gradient: isMono ? null : tokens?.chartWarning,
                borderRadius: barRadius,
                width: isMono ? 0.55 : 0.7,
                spacing: 0.18,
                animationDuration: 1200,
                animationDelay: 260,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.middle,
                  textStyle: TextStyle(
                    color: isMono && !isDark ? Colors.white : labelOnBar,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

List<AnalyticsChartPoint> markBandPoints(
  BuildContext context,
  AppLocalizations l10n,
  List<double> averages,
) {
  var excellent = 0, good = 0, needsWork = 0, atRisk = 0;
  for (final value in averages) {
    if (value >= 85) {
      excellent++;
    } else if (value >= 70) {
      good++;
    } else if (value >= 50) {
      needsWork++;
    } else {
      atRisk++;
    }
  }
  return [
    AnalyticsChartPoint(
      l10n.chartBandExcellent,
      excellent.toDouble(),
      AppColors.success(context),
    ),
    AnalyticsChartPoint(
      l10n.chartBandGood,
      good.toDouble(),
      AppColors.goldAccent(context),
    ),
    AnalyticsChartPoint(
      l10n.chartBandNeedsWork,
      needsWork.toDouble(),
      AppColors.warning(context),
    ),
    AnalyticsChartPoint(
      l10n.chartBandAtRisk,
      atRisk.toDouble(),
      AppColors.danger(context),
    ),
  ].where((p) => p.value > 0).toList();
}

class _WeekCategory {
  const _WeekCategory(this.label, this.present, this.absent, this.late);
  final String label;
  final double present;
  final double absent;
  final double late;
}

class _LegendPill extends StatelessWidget {
  const _LegendPill({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono =
        AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : scheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(isMono ? 4 : 20),
        border: isMono
            ? Border.all(color: scheme.onSurface.withValues(alpha: 0.08))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
