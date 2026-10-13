import 'package:flutter/material.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/marks/percent_badge.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';

class MarkAverageCard extends StatelessWidget {
  const MarkAverageCard({
    super.key,
    required this.average,
    required this.markCount,
    this.onTap,
  });

  final double? average;
  final int markCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = average;
    final color = value == null
        ? AppColors.accent(context)
        : percentColor(value, context: context);
    final starAsset = paperStarForPercent(value);

    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: (value ?? 0) / 100),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, progress, _) {
                const stroke = 8.0;
                const labelInset = stroke * 2 + 10;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.softSurface(context),
                        valueColor: AlwaysStoppedAnimation(color),
                        strokeWidth: stroke,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(labelInset / 2),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatPercent(value),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            height: 1,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.marksOverallAverage,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value == null
                      ? context.l10n.marksNoneYet
                      : context.l10n.marksBasedOn(
                          percentLabel(value, context.l10n),
                          markCount,
                        ),
                  style: TextStyle(
                    color: AppColors.inkAlpha(context, 0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (starAsset != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: PaperDecor(starAsset, size: 42, angle: 0.14),
            ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.inkAlpha(context, 0.3),
            ),
        ],
      ),
    );
  }
}
