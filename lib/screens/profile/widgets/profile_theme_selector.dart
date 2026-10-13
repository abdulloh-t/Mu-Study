import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style.dart';
import 'package:mu_study/core/theme/monochrome_workspace_colors.dart';
import 'package:mu_study/core/theme/nature_paper_colors.dart';
import 'package:mu_study/core/theme/neumorphic.dart';
import 'package:mu_study/core/theme/soft_neumorphism_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/settings/theme_provider.dart';

class ProfileThemeSelector extends ConsumerWidget {
  const ProfileThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(themeModeProvider);
    final style = ref.watch(appStyleProvider);
    final selected = switch (mode) {
      ThemeMode.light => AppThemePreference.light,
      ThemeMode.dark => AppThemePreference.dark,
      ThemeMode.system => AppThemePreference.system,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileAppearance,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        SegmentedButton<AppThemePreference>(
          segments: [
            ButtonSegment(
              value: AppThemePreference.light,
              label: Text(l10n.profileThemeLight),
              icon: const Icon(Icons.light_mode_outlined, size: 16),
            ),
            ButtonSegment(
              value: AppThemePreference.dark,
              label: Text(l10n.profileThemeDark),
              icon: const Icon(Icons.dark_mode_outlined, size: 16),
            ),
            ButtonSegment(
              value: AppThemePreference.system,
              label: Text(l10n.profileThemeSystem),
              icon: const Icon(Icons.brightness_auto_outlined, size: 16),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (set) {
            final next = set.first;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(themeModeProvider.notifier).setPreference(next);
            });
          },
        ),
        const SizedBox(height: 16),
        Text(
          l10n.profileStyle,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: tileWidth,
                  child: _StyleOptionCard(
                    label: l10n.profileStyleModern,
                    icon: Icons.business_center_outlined,
                    previewColors: const [
                      AppColors.cream,
                      AppColors.warmBeige,
                      AppColors.coffeeBrown,
                    ],
                    isSelected: style == AppStyle.modern,
                    onTap: () => ref
                        .read(appStyleProvider.notifier)
                        .setStyle(AppStyle.modern),
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _StyleOptionCard(
                    label: l10n.profileStyleNature,
                    icon: Icons.eco_outlined,
                    previewColors: const [
                      NaturePaperColors.cream,
                      NaturePaperColors.sage,
                      NaturePaperColors.forest,
                    ],
                    isSelected: style == AppStyle.naturePaper,
                    onTap: () => ref
                        .read(appStyleProvider.notifier)
                        .setStyle(AppStyle.naturePaper),
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _StyleOptionCard(
                    label: l10n.profileStyleSoftNeu,
                    icon: Icons.layers_outlined,
                    previewColors: const [
                      SoftNeumorphismColors.morningBg,
                      SoftNeumorphismColors.sage,
                      SoftNeumorphismColors.amber,
                    ],
                    isSelected: style == AppStyle.softNeumorphism,
                    onTap: () => ref
                        .read(appStyleProvider.notifier)
                        .setStyle(AppStyle.softNeumorphism),
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _StyleOptionCard(
                    label: l10n.profileStyleMonochrome,
                    icon: Icons.contrast_outlined,
                    previewColors: const [
                      MonochromeWorkspaceColors.lightBg,
                      MonochromeWorkspaceColors.lightBorder,
                      MonochromeWorkspaceColors.lightInk,
                    ],
                    isSelected: style == AppStyle.monochromeWorkspace,
                    onTap: () => ref
                        .read(appStyleProvider.notifier)
                        .setStyle(AppStyle.monochromeWorkspace),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StyleOptionCard extends StatelessWidget {
  const _StyleOptionCard({
    required this.label,
    required this.icon,
    required this.previewColors,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final List<Color> previewColors;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final isNeu = Neumorphic.isActive(context);
    final radius = BorderRadius.circular(isNeu ? 18 : 16);

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: isNeu
            ? Neumorphic.decoration(
                context,
                elevation: isSelected
                    ? NeuElevation.pressed
                    : NeuElevation.raised,
                borderRadius: radius,
                color: isSelected ? accent.withValues(alpha: 0.12) : null,
              )
            : BoxDecoration(
                color: isSelected
                    ? accent.withValues(alpha: 0.10)
                    : AppColors.softWash(context, lightAlpha: 0.35),
                borderRadius: radius,
                border: Border.all(
                  color: isSelected
                      ? accent
                      : AppColors.inkAlpha(context, 0.12),
                  width: isSelected ? 1.6 : 1,
                ),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (final c in previewColors)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.inkAlpha(context, 0.12),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, size: 16, color: accent)
                else
                  Icon(icon, size: 16, color: AppColors.inkAlpha(context, 0.4)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? accent : AppColors.inkAlpha(context, 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
