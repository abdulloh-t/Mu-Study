import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/locale/app_locale.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/settings/locale_provider.dart';

class LanguageSettingsTile extends ConsumerWidget {
  const LanguageSettingsTile({super.key, this.embedded = false});

  final bool embedded;

  String _nativeName(AppLanguage lang) => switch (lang) {
    AppLanguage.english => 'English',
    AppLanguage.russian => 'Русский',
    AppLanguage.uzbek => 'O‘zbekcha',
  };

  String _codeLabel(AppLanguage lang) => switch (lang) {
    AppLanguage.english => 'EN',
    AppLanguage.russian => 'RU',
    AppLanguage.uzbek => 'UZ',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = AppLanguage.fromLocale(ref.watch(localeProvider));
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!embedded) ...[
          Text(
            l10n.languageSection,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.languageHint,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.inkAlpha(context, 0.5),
            ),
          ),
          const SizedBox(height: 12),
        ] else ...[
          Text(
            l10n.languageSection,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: paperControlDecoration(
            context,
            color: embedded
                ? AppColors.inkAlpha(context, 0.05)
                : AppColors.controlSurface(context),
          ),
          child: Row(
            children: [
              PaperGlyph(
                icon: Icons.language_rounded,
                size: 18,
                color: AppColors.accent(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AppLanguage>(
                    value: current,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(
                      paperControlRadius(context),
                    ),
                    dropdownColor: AppColors.controlSurface(context),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.inkAlpha(context, 0.45),
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: onSurface,
                    ),
                    items: AppLanguage.values
                        .map(
                          (lang) => DropdownMenuItem(
                            value: lang,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    _codeLabel(lang),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: lang == current
                                          ? AppColors.accent(context)
                                          : AppColors.inkAlpha(context, 0.45),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _nativeName(lang),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (lang) {
                      if (lang == null || lang == current) return;
                      // rebuild (avoids semantics.parentDataDirty).
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(localeProvider.notifier).setLanguage(lang);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
