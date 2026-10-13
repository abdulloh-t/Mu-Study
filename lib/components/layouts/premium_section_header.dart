import 'package:flutter/material.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';

class PremiumSectionHeader extends StatelessWidget {
  const PremiumSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.horizontalPadding = 0,
    this.decorAsset,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final double horizontalPadding;

  final String? decorAsset;

  @override
  Widget build(BuildContext context) {
    final tokens = AppStyleTokens.maybeOf(context);
    final headerGlow = tokens?.headerGlow ?? Colors.transparent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              subtitle!.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: tokens?.isMonochromeWorkspace == true
                    ? 1.4
                    : 1.2,
                fontWeight: FontWeight.w700,
                color: tokens?.isMonochromeWorkspace == true
                    ? AppColors.inkAlpha(context, 0.45)
                    : AppColors.accent(context).withValues(alpha: 0.92),
              ),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: tokens?.isMonochromeWorkspace == true
                      ? -0.7
                      : -0.5,
                  fontSize: tokens?.isMonochromeWorkspace == true ? 26 : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PaperDecor(
              decorAsset ?? PaperAssets.beigeLeaf,
              size: decorAsset == null ? 16 : 22,
              angle: decorAsset == null ? 0.5 : 0.1,
              opacity: 0.9,
            ),
          ],
        ),
      ],
    );

    if (headerGlow != Colors.transparent) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -28,
            top: -20,
            child: IgnorePointer(
              child: Container(
                width: 190,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  gradient: RadialGradient(
                    colors: [
                      headerGlow.withValues(alpha: isDark ? 0.10 : 0.26),
                      headerGlow.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          content,
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: content),
          ?trailing,
        ],
      ),
    );
  }
}
