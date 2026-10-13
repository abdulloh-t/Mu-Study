import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/l10n/app_localizations.dart';

Color percentColor(double percent, {BuildContext? context}) {
  final mono =
      context != null &&
      (AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false);
  final isDark =
      context != null && Theme.of(context).brightness == Brightness.dark;

  if (mono) {
    if (isDark) {
      if (percent >= 85) return const Color(0xFFF5F5F5);
      if (percent >= 70) return const Color(0xFFC8C8C8);
      if (percent >= 50) return const Color(0xFF9A9A9A);
      return const Color(0xFF707070);
    }
    if (percent >= 85) return const Color(0xFF111111);
    if (percent >= 70) return const Color(0xFF3A3A3A);
    if (percent >= 50) return const Color(0xFF6B6B6B);
    return const Color(0xFF8E8E8E);
  }

  if (percent >= 85) return AppColors.successGreen;
  if (percent >= 70) return AppColors.mutedGold;
  if (percent >= 50) return AppColors.warmAmber;
  return AppColors.errorRed;
}

String percentLabel(double percent, [AppLocalizations? l10n]) {
  if (percent >= 85) return l10n?.percentExcellent ?? 'Excellent';
  if (percent >= 70) return l10n?.percentGood ?? 'Good';
  if (percent >= 50) return l10n?.percentNeedsWork ?? 'Needs work';
  return l10n?.percentAtRisk ?? 'At risk';
}

String formatPercent(double? percent) {
  if (percent == null) return '—';
  final rounded = percent.roundToDouble();
  return percent == rounded
      ? '${rounded.toInt()}%'
      : '${percent.toStringAsFixed(1)}%';
}

class PercentBadge extends StatelessWidget {
  const PercentBadge({super.key, required this.percent, this.compact = false});

  final double? percent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final value = percent;
    final color = value == null
        ? AppColors.inkAlpha(context, 0.3)
        : percentColor(value, context: context);
    final tokens = AppStyleTokens.maybeOf(context);
    final isNature = tokens?.isNaturePaper ?? false;
    final radius = tokens?.isMonochromeWorkspace == true
        ? (compact ? 4.0 : 6.0)
        : isNature
        ? (compact ? 12.0 : 16.0)
        : (compact ? 8.0 : 12.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isNature ? 0.14 : 0.12),
        borderRadius: BorderRadius.circular(radius),
        border: tokens?.isMonochromeWorkspace == true
            ? Border.all(color: color.withValues(alpha: 0.28))
            : isNature
            ? Border.all(color: color.withValues(alpha: 0.22))
            : null,
      ),
      child: Text(
        formatPercent(value),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: compact ? 13 : 16,
          letterSpacing: -0.3,
          fontFeatures: tokens?.isMonochromeWorkspace == true
              ? const [FontFeature.tabularFigures()]
              : null,
        ),
      ),
    );
  }
}
