import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/models/models.dart';

class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({
    super.key,
    required this.profile,
    required this.roleLabel,
    required this.onEditPhoto,
    required this.onEditName,
    this.sphereLabel,
    this.uploading = false,
  });

  final Profile profile;
  final String roleLabel;
  final String? sphereLabel;
  final VoidCallback onEditPhoto;
  final VoidCallback onEditName;
  final bool uploading;

  String get _initials {
    final parts = profile.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      final u = profile.username;
      return u.isEmpty ? '?' : u.substring(0, 1).toUpperCase();
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF2A2420), Color(0xFF1C1816)]
              : const [Color(0xFFE8D9C4), Color(0xFFF5EEE4)],
        ),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              PaperScallopedAvatar(
                avatarSize: 88,
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.accent(context),
                  backgroundImage:
                      profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(profile.avatarUrl!)
                      : null,
                  child: uploading
                      ? SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                          ),
                        )
                      : (profile.avatarUrl == null ||
                            profile.avatarUrl!.isEmpty)
                      ? Text(
                          _initials,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                          ),
                        )
                      : null,
                ),
              ),
              Material(
                color: theme.colorScheme.surface,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: uploading ? null : onEditPhoto,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: AppColors.accent(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onEditName,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      profile.fullName.isNotEmpty
                          ? profile.fullName
                          : profile.username,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.inkAlpha(context, 0.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.username.startsWith('@')
                ? profile.username
                : '@${profile.username}',
            style: TextStyle(color: AppColors.inkAlpha(context, 0.5)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _ProfileChip(label: roleLabel),
              if (sphereLabel != null) _ProfileChip(label: sphereLabel!),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.55 : 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.accent(context),
        ),
      ),
    );
  }
}
