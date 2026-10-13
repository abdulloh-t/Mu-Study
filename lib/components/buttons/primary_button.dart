import 'package:flutter/material.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/nature_paper_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nature = isNaturePaper(context);
    final bg =
        backgroundColor ??
        (nature ? AppColors.accent(context) : AppColors.coffeeBrown);
    final fg =
        foregroundColor ??
        (nature ? theme.colorScheme.onPrimary : Colors.white);

    final ButtonStyle style;
    if (nature && backgroundColor == null && foregroundColor == null) {
      style = (theme.elevatedButtonTheme.style ?? const ButtonStyle()).merge(
        ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
      );
    } else {
      style = ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(nature ? 18 : 14),
        ),
        elevation: nature ? 3 : 0,
        shadowColor: nature
            ? NaturePaperColors.warmBrown.withValues(alpha: 0.45)
            : null,
      );
    }

    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: style,
      child: loading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  PaperGlyph(icon: icon!, size: 20, color: fg),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: fg,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
    );
  }
}
