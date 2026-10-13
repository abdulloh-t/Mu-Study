import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/app_text_theme.dart';
import 'package:mu_study/core/theme/monochrome_workspace_colors.dart';

class MonochromeWorkspaceTheme {
  static const _fadeTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
    },
  );

  static const _radius = 4.0;
  static const _controlRadius = 4.0;

  static ThemeData light() {
    const ink = MonochromeWorkspaceColors.lightInk;
    const secondary = MonochromeWorkspaceColors.lightTextSecondary;
    const tertiary = MonochromeWorkspaceColors.lightTextTertiary;
    const accent = MonochromeWorkspaceColors.lightAccent;
    const bg = MonochromeWorkspaceColors.lightBg;
    const card = MonochromeWorkspaceColors.lightCard;
    const border = MonochromeWorkspaceColors.lightBorder;

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        tertiary: tertiary,
        error: MonochromeWorkspaceColors.lightDanger,
        surface: card,
        onSurface: ink,
        surfaceContainerLowest: bg,
        surfaceContainerLow: MonochromeWorkspaceColors.lightWash,
        surfaceContainer: card,
        surfaceContainerHigh: card,
        surfaceContainerHighest: MonochromeWorkspaceColors.lightWash,
        outline: border,
      ),
    );

    final textTheme = _editorialTextTheme(
      base: base.textTheme,
      primary: ink,
      secondary: secondary,
      tertiary: tertiary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      pageTransitionsTheme: _fadeTransitions,
      textTheme: textTheme,
      dividerColor: border,
      extensions: const [AppStyleTokens.monoLight],
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: border),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: border),
        ),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: secondary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: textTheme.bodyMedium?.copyWith(color: tertiary),
        labelStyle: const TextStyle(color: secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _monoButtonStyle(
          background: accent,
          foreground: Colors.white,
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _monoButtonStyle(
          background: accent,
          foreground: Colors.white,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_controlRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: MonochromeWorkspaceColors.lightWash,
        selectedColor: ink.withValues(alpha: 0.10),
        labelStyle: textTheme.labelLarge!.copyWith(
          color: ink,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return card;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return MonochromeWorkspaceColors.lightWash;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(border),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: border, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        circularTrackColor: MonochromeWorkspaceColors.lightWash,
        linearTrackColor: MonochromeWorkspaceColors.lightWash,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: ink.withValues(alpha: 0.08),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall!.copyWith(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? ink : tertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected) ? ink : tertiary,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: card,
        indicatorColor: ink.withValues(alpha: 0.08),
        selectedIconTheme: const IconThemeData(color: ink),
        unselectedIconTheme: const IconThemeData(color: tertiary),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: secondary,
        textColor: ink,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: secondary,
          fontSize: 13,
        ),
      ),
    );
  }

  static ThemeData dark() {
    const ink = MonochromeWorkspaceColors.darkInk;
    const secondary = MonochromeWorkspaceColors.darkTextSecondary;
    const tertiary = MonochromeWorkspaceColors.darkTextTertiary;
    const accent = MonochromeWorkspaceColors.darkAccent;
    const bg = MonochromeWorkspaceColors.darkBg;
    const card = MonochromeWorkspaceColors.darkCard;
    const control = MonochromeWorkspaceColors.darkControl;
    const border = MonochromeWorkspaceColors.darkBorder;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: accent,
      onPrimary: MonochromeWorkspaceColors.darkBg,
      primaryContainer: control,
      onPrimaryContainer: ink,
      secondary: secondary,
      onSecondary: bg,
      secondaryContainer: control,
      onSecondaryContainer: ink,
      tertiary: tertiary,
      onTertiary: bg,
      error: MonochromeWorkspaceColors.darkDanger,
      onError: bg,
      surface: card,
      onSurface: ink,
      onSurfaceVariant: secondary,
      surfaceContainerLowest: bg,
      surfaceContainerLow: MonochromeWorkspaceColors.darkWash,
      surfaceContainer: card,
      surfaceContainerHigh: control,
      surfaceContainerHighest: const Color(0xFF2A2A2A),
      outline: border,
      outlineVariant: const Color(0xFF3A3A3A),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: MonochromeWorkspaceColors.lightCard,
      onInverseSurface: MonochromeWorkspaceColors.lightInk,
      inversePrimary: MonochromeWorkspaceColors.lightAccent,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
    );

    final textTheme = _editorialTextTheme(
      base: base.textTheme,
      primary: ink,
      secondary: secondary,
      tertiary: tertiary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      pageTransitionsTheme: _fadeTransitions,
      dividerColor: border,
      disabledColor: tertiary,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: secondary),
      primaryIconTheme: const IconThemeData(color: accent),
      extensions: const [AppStyleTokens.monoDark],
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: secondary,
        textColor: ink,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: secondary,
          fontSize: 13,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: ink),
        actionsIconTheme: const IconThemeData(color: secondary),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: border),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: control,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: border),
        ),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: secondary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: control,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: control,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: control,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: ink),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: textTheme.bodyMedium?.copyWith(color: tertiary),
        labelStyle: const TextStyle(color: secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _monoButtonStyle(
          background: accent,
          foreground: bg,
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _monoButtonStyle(
          background: accent,
          foreground: bg,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_controlRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: bg,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: control,
        selectedColor: accent.withValues(alpha: 0.16),
        labelStyle: textTheme.labelLarge!.copyWith(
          color: ink,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return bg;
          return secondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return control;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(border),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(
          MonochromeWorkspaceColors.darkBg,
        ),
        side: const BorderSide(color: border, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        circularTrackColor: control,
        linearTrackColor: control,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: accent.withValues(alpha: 0.12),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall!.copyWith(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? ink : tertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected) ? ink : tertiary,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: card,
        indicatorColor: accent.withValues(alpha: 0.12),
        selectedIconTheme: const IconThemeData(color: ink),
        unselectedIconTheme: const IconThemeData(color: tertiary),
      ),
    );
  }

  static TextTheme _editorialTextTheme({
    required TextTheme base,
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) {
    final jakarta = buildJakartaTextTheme(
      base: base,
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
    );
    return jakarta.copyWith(
      displayLarge: jakarta.displayLarge?.copyWith(
        fontSize: 40,
        height: 1.15,
        letterSpacing: -1.2,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: jakarta.displayMedium?.copyWith(
        fontSize: 32,
        height: 1.18,
        letterSpacing: -0.9,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: jakarta.headlineLarge?.copyWith(
        fontSize: 28,
        height: 1.2,
        letterSpacing: -0.6,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: jakarta.headlineMedium?.copyWith(
        fontSize: 24,
        height: 1.25,
        letterSpacing: -0.4,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: jakarta.headlineSmall?.copyWith(
        fontSize: 20,
        height: 1.3,
        letterSpacing: -0.3,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: jakarta.titleLarge?.copyWith(
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: jakarta.labelSmall?.copyWith(
        fontSize: 11,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w600,
        color: tertiary,
      ),
      bodyLarge: jakarta.bodyLarge?.copyWith(height: 1.55),
      bodyMedium: jakarta.bodyMedium?.copyWith(height: 1.5),
    );
  }

  static ButtonStyle _monoButtonStyle({
    required Color background,
    required Color foreground,
    required TextStyle? textStyle,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
      ),
      textStyle: textStyle?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
    );
  }
}
