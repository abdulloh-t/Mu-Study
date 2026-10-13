import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';

class AttachChip extends StatelessWidget {
  const AttachChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMono =
        AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;
    final radius = isMono ? 4.0 : 14.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accent(context).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(radius),
          border: isMono
              ? Border.all(color: AppColors.inkAlpha(context, 0.14))
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent(context)),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
