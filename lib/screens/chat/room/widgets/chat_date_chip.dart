import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/l10n/l10n_x.dart';

class ChatDateChip extends StatelessWidget {
  const ChatDateChip({super.key, required this.date});

  final DateTime date;

  String _label(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final day = DateTime(date.year, date.month, date.day);

    if (day == today) return l10n.chatDateToday;
    if (day == yesterday) return l10n.chatDateYesterday;

    final locale = Localizations.localeOf(context).toString();
    if (day.year == today.year) {
      return DateFormat.MMMMd(locale).format(day);
    }
    return DateFormat.yMMMMd(locale).format(day);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono =
        AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? scheme.surfaceContainerHighest.withValues(alpha: 0.9)
                : AppColors.sand.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(isMono ? 4 : 999),
            border: isMono
                ? Border.all(color: AppColors.inkAlpha(context, 0.12))
                : null,
            boxShadow: isMono
                ? null
                : [
                    BoxShadow(
                      color: AppColors.inkAlpha(context, 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            _label(context),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.inkAlpha(context, 0.7),
              fontFeatures: isMono
                  ? const [FontFeature.tabularFigures()]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
