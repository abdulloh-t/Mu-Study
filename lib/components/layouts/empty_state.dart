import 'package:flutter/material.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/neumorphic.dart';
import 'package:mu_study/l10n/l10n_x.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final paperAsset = isNaturePaper(context)
        ? (paperAssetForIcon(icon) ?? PaperAssets.tornPaperScrap)
        : null;
    final isNeu = isSoftNeumorphism(context);
    final isMono = isMonochromeWorkspace(context);

    Widget leading;
    if (paperAsset != null) {
      leading = PaperEmptyIllustration(asset: paperAsset);
    } else if (isNeu) {
      leading = NeuIconWell(
        icon: icon,
        color: AppColors.accent(context),
        size: 36,
        padding: 26,
        elevation: NeuElevation.raised,
      );
    } else if (isMono) {
      leading = Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.inkAlpha(context, 0.12)),
        ),
        child: Icon(icon, size: 28, color: AppColors.inkAlpha(context, 0.45)),
      );
    } else {
      leading = Icon(icon, size: 56, color: AppColors.inkAlpha(context, 0.25));
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.ink(context),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkAlpha(context, 0.55),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isNaturePaper(context))
              const PaperEmptyIllustration(asset: PaperAssets.tornPaperScrap)
            else
              Icon(
                Icons.error_outline,
                color: AppColors.danger(context),
                size: 48,
              ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: Text(context.l10n.commonTryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
