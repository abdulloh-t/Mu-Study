import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/core/homework/assignment_due.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/app_localizations.dart';
import 'package:mu_study/models/models.dart';

class DueDateLabel extends StatelessWidget {
  const DueDateLabel({
    super.key,
    required this.assignment,
    this.compact = false,
    this.onDark = false,
  });

  final Assignment assignment;
  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = assignmentDueStatus(assignment);
    final due = assignment.dueDate;
    final muted = onDark
        ? Colors.white.withValues(alpha: 0.85)
        : AppColors.inkAlpha(context, 0.55);

    if (status == AssignmentDueStatus.none || due == null) {
      return Text(
        l10n.commonNoDueDate,
        style: TextStyle(color: muted, fontSize: compact ? 12 : 13),
      );
    }

    final (label, color) = _labelAndColor(context, l10n, status, due, onDark);

    if (compact) {
      return Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: onDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: onDark ? Colors.white : color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static (String, Color) _labelAndColor(
    BuildContext context,
    AppLocalizations l10n,
    AssignmentDueStatus status,
    DateTime due,
    bool onDark,
  ) {
    final dateStr = DateFormat.MMMd().format(due);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case AssignmentDueStatus.overdue:
        return (
          l10n.homeworkOverdue(dateStr),
          onDark
              ? const Color(0xFFFFCDD2)
              : (isDark ? const Color(0xFFE57373) : AppColors.errorRed),
        );
      case AssignmentDueStatus.dueToday:
        return (
          l10n.homeworkDueToday,
          onDark
              ? const Color(0xFFFFE0B2)
              : (isDark ? const Color(0xFFFFB74D) : AppColors.warmAmber),
        );
      case AssignmentDueStatus.dueSoon:
        final today = assignmentCalendarDay(DateTime.now());
        final days = assignmentCalendarDay(due).difference(today).inDays;
        final label = days == 1
            ? l10n.homeworkDueTomorrow
            : l10n.homeworkDueInDays(days);
        return (label, onDark ? const Color(0xFFFFE0B2) : AppColors.mutedGold);
      case AssignmentDueStatus.upcoming:
        return (
          l10n.commonDueDate(dateStr),
          onDark ? Colors.white : AppColors.inkAlpha(context, 0.7),
        );
      case AssignmentDueStatus.none:
        return (
          l10n.commonNoDueDate,
          onDark ? Colors.white70 : AppColors.inkAlpha(context, 0.55),
        );
    }
  }
}
