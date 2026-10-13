import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mu_study/core/locale/app_locale.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/settings/locale_provider.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  AppLanguage? _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selected = AppLanguage.fromLocale(ref.read(localeProvider));
      });
    });
  }

  Future<void> _continue() async {
    final lang = _selected;
    if (lang == null || _saving) return;

    setState(() => _saving = true);
    try {
      await ref.read(localeProvider.notifier).setLanguage(lang);
      if (!mounted) return;
      context.go('/boot');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.languageTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.languageSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.inkAlpha(context, 0.55),
                      height: 1.4,
                    ),
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.fullName.isNotEmpty
                          ? profile.fullName
                          : profile.username,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkAlpha(context, 0.4),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  _LanguageCard(
                    language: AppLanguage.english,
                    title: 'English',
                    subtitle: l10n.languageEnglish,
                    flag: 'EN',
                    selected: _selected == AppLanguage.english,
                    onTap: () =>
                        setState(() => _selected = AppLanguage.english),
                  ),
                  const SizedBox(height: 12),
                  _LanguageCard(
                    language: AppLanguage.russian,
                    title: 'Русский',
                    subtitle: l10n.languageRussian,
                    flag: 'RU',
                    selected: _selected == AppLanguage.russian,
                    onTap: () =>
                        setState(() => _selected = AppLanguage.russian),
                  ),
                  const SizedBox(height: 12),
                  _LanguageCard(
                    language: AppLanguage.uzbek,
                    title: 'O‘zbekcha',
                    subtitle: l10n.languageUzbek,
                    flag: 'UZ',
                    selected: _selected == AppLanguage.uzbek,
                    onTap: () => setState(() => _selected = AppLanguage.uzbek),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _saving || _selected == null ? null : _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.coffeeBrown,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.languageContinue),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.title,
    required this.subtitle,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final String title;
  final String subtitle;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.controlSurface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.accent(context)
                  : AppColors.inkAlpha(context, 0.08),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.accent(context).withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent(context)
                      : AppColors.softWash(context, lightAlpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  flag,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: selected ? Colors.white : AppColors.accent(context),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkAlpha(context, 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? AppColors.accent(context)
                    : AppColors.inkAlpha(context, 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
