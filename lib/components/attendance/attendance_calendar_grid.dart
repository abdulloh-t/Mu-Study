import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/attendance/attendance_providers.dart';

Color attendanceStatusColor(AttendanceStatus? status, {BuildContext? context}) {
  return switch (status) {
    AttendanceStatus.present => AppColors.successGreen,
    AttendanceStatus.late => AppColors.warmAmber,
    AttendanceStatus.absent => AppColors.errorRed,
    AttendanceStatus.excused => const Color(0xFF5B8DB8),
    null =>
      context != null
          ? AppColors.inkAlpha(context, 0.08)
          : const Color(0xFF808080).withValues(alpha: 0.2),
  };
}

List<List<DateTime?>> buildMonthWeekRows(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final startOffset = first.weekday - 1;
  final cells = <DateTime?>[];
  for (var i = 0; i < startOffset; i++) {
    cells.add(null);
  }
  for (var d = 1; d <= daysInMonth; d++) {
    cells.add(DateTime(month.year, month.month, d));
  }
  while (cells.length % 7 != 0) {
    cells.add(null);
  }

  final weeks = <List<DateTime?>>[];
  for (var i = 0; i < cells.length; i += 7) {
    weeks.add(cells.sublist(i, i + 5));
  }
  while (weeks.isNotEmpty && weeks.last.every((d) => d == null)) {
    weeks.removeLast();
  }
  return weeks;
}

class AttendanceCalendarGrid extends StatelessWidget {
  const AttendanceCalendarGrid({
    super.key,
    required this.month,
    required this.statusByDate,
    this.onDayTap,
    this.editable = false,
  });

  final DateTime month;

  final Map<DateTime, AttendanceStatus> statusByDate;
  final ValueChanged<DateTime>? onDayTap;
  final bool editable;

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weeks = buildMonthWeekRows(month);
    final labels = [
      l10n.attendanceWeekdayMon,
      l10n.attendanceWeekdayTue,
      l10n.attendanceWeekdayWed,
      l10n.attendanceWeekdayThu,
      l10n.attendanceWeekdayFri,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final label in labels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkAlpha(context, 0.45),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final week in weeks) ...[
          Row(
            children: [
              for (final day in week)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: _DayCell(
                      day: day,
                      status: day == null ? null : statusByDate[_dayKey(day)],
                      editable:
                          editable &&
                          day != null &&
                          isAttendanceDateAllowed(day),
                      isFuture: day != null && !isAttendanceDateAllowed(day),
                      onTap:
                          day == null ||
                              onDayTap == null ||
                              !isAttendanceDateAllowed(day)
                          ? null
                          : () => onDayTap!(day),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.status,
    required this.editable,
    this.isFuture = false,
    this.onTap,
  });

  final DateTime? day;
  final AttendanceStatus? status;
  final bool editable;
  final bool isFuture;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.inkAlpha(context, 0.03),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    final color = attendanceStatusColor(status, context: context);
    final hasStatus = status != null;
    final today = DateTime.now();
    final isToday =
        day!.year == today.year &&
        day!.month == today.month &&
        day!.day == today.day;

    final bg = isFuture
        ? AppColors.inkAlpha(context, 0.04)
        : hasStatus
        ? color.withValues(alpha: 0.92)
        : AppColors.inkAlpha(context, 0.06);

    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: editable ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isToday
                  ? Border.all(color: AppColors.accent(context), width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '${day!.day}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: isFuture
                      ? AppColors.inkAlpha(context, 0.22)
                      : hasStatus
                      ? Colors.white
                      : AppColors.inkAlpha(context, 0.45),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AttendanceMonthHeader extends StatelessWidget {
  const AttendanceMonthHeader({
    super.key,
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat.yMMMM(
      Localizations.localeOf(context).toString(),
    ).format(month);

    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class AttendanceStatsBar extends StatelessWidget {
  const AttendanceStatsBar({super.key, required this.stats});

  final AttendanceStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: l10n.attendancePercentLabel,
            value: '${stats.presentPercent.toStringAsFixed(0)}%',
            color: AppColors.accent(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: l10n.attendancePresentWord,
            value: '${stats.present}',
            color: AppColors.successGreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: l10n.attendanceAbsentWord,
            value: '${stats.absent}',
            color: AppColors.errorRed,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: l10n.attendanceLateWord,
            value: '${stats.late}',
            color: AppColors.warmAmber,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.inkAlpha(context, 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceLegendRow extends StatelessWidget {
  const AttendanceLegendRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _Legend(
          color: AppColors.successGreen,
          label: l10n.attendancePresentWord,
        ),
        _Legend(color: AppColors.warmAmber, label: l10n.attendanceLateWord),
        _Legend(color: AppColors.errorRed, label: l10n.attendanceAbsentWord),
        _Legend(
          color: const Color(0xFF5B8DB8),
          label: l10n.attendanceExcusedWord,
        ),
        _Legend(
          color: AppColors.inkAlpha(context, 0.12),
          label: l10n.attendanceNoLesson,
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.inkAlpha(context, 0.6),
          ),
        ),
      ],
    );
  }
}

AttendanceStatus nextAttendanceStatus(AttendanceStatus? current) {
  return switch (current) {
    null => AttendanceStatus.present,
    AttendanceStatus.present => AttendanceStatus.late,
    AttendanceStatus.late => AttendanceStatus.absent,
    AttendanceStatus.absent => AttendanceStatus.excused,
    AttendanceStatus.excused => AttendanceStatus.present,
  };
}
