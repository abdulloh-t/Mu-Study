import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/backgrounds/nature_paper_backdrop.dart';
import 'package:mu_study/components/backgrounds/soft_neumorphism_backdrop.dart';
import 'package:mu_study/core/constants/env.dart';
import 'package:mu_study/core/theme/app_theme.dart';
import 'package:mu_study/core/utils/responsive.dart';
import 'package:mu_study/l10n/app_localizations.dart';
import 'package:mu_study/providers/settings/locale_provider.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/settings/theme_provider.dart';
import 'package:mu_study/core/router/app_router.dart';
import 'package:mu_study/screens/auth/setup_required_screen.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();

  if (!Env.isConfigured) {
    runApp(const SetupRequiredScreen());
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  final initialThemeMode = await loadSavedThemeMode();
  final initialStyle = await loadSavedAppStyle();

  runApp(
    ProviderScope(
      overrides: [
        appStyleProvider.overrideWith((ref) {
          final controller = AppStyleController(ref, initial: initialStyle);
          ref.listen(currentProfileProvider, (prev, next) {
            next.whenData((profile) {
              final code = profile?.preferredStyle;
              if (code != null) controller.applyFromProfile(code);
            });
          });
          return controller;
        }),
        themeModeProvider.overrideWith((ref) {
          final controller = ThemeModeController(
            ref,
            initial: initialThemeMode,
          );
          ref.listen(currentProfileProvider, (prev, next) {
            next.whenData((profile) {
              final code = profile?.preferredTheme;
              if (code != null) controller.applyFromProfile(code);
            });
          });
          return controller;
        }),
      ],
      child: const MuStudyApp(),
    ),
  );
}

class MuStudyApp extends ConsumerWidget {
  const MuStudyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final style = ref.watch(appStyleProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(style),
      darkTheme: AppTheme.dark(style),
      themeMode: themeMode,
      themeAnimationDuration: Duration.zero,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: NaturePaperBackdrop(
          child: SoftNeumorphismBackdrop(child: child!),
        ),
        breakpoints: responsiveBreakpoints(),
      ),
      routerConfig: router,
    );
  }
}
