import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/marks/percent_badge.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/domain_labels.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';

class MarkRow extends StatelessWidget {
  const MarkRow({
    super.key,
    required this.mark,
    required this.onEdit,
    this.onDelete,
    this.showStudent = true,
  });

  final Mark mark;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool showStudent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtitle = [
      mark.category.l10nLabel(l10n),
      if (showStudent && mark.studentName != null) mark.studentName!,
      DateFormat.MMMd().format(mark.markedOn),
      if (mark.weight != 1)
        '×${mark.weight.toStringAsFixed(mark.weight.truncateToDouble() == mark.weight ? 0 : 1)}',
    ].join(' · ');

    return PremiumCard(
      onTap: onEdit,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          PercentBadge(percent: mark.percentage, compact: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mark.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.inkAlpha(context, 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (mark.isFromSubmission)
            Tooltip(
              message: l10n.marksFromSubmission,
              child: Icon(
                Icons.link_rounded,
                size: 16,
                color: AppColors.inkAlpha(context, 0.3),
              ),
            ),
          if (onDelete != null)
            IconButton(
              tooltip: context.l10n.commonDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.inkAlpha(context, 0.35),
              ),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
