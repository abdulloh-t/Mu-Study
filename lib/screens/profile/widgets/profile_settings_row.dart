import 'package:flutter/material.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/theme/app_colors.dart';

class ProfileSettingsRow extends StatelessWidget {
  const ProfileSettingsRow({
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
    return ListTile(
      leading: PaperGlyph(
        icon: icon,
        size: 24,
        color: AppColors.accent(context),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.inkAlpha(context, 0.35),
      ),
      onTap: onTap,
    );
  }
}
