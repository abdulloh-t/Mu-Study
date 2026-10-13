import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/app_text_theme.dart';
import 'package:mu_study/core/theme/nature_paper_colors.dart';

class NaturePaperTheme {
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

  static ThemeData light() {
    const ink = NaturePaperColors.dayInk;
    const forest = NaturePaperColors.forest;
    const card = NaturePaperColors.dayCard;
    final border = NaturePaperColors.warmBrown.withValues(alpha: 0.18);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forest,
        primary: forest,
        onPrimary: NaturePaperColors.cream,
        secondary: NaturePaperColors.sage,
        onSecondary: const Color(0xFF1F2A1E),
        tertiary: NaturePaperColors.softOrange,
        error: NaturePaperColors.dayDanger,
        surface: card,
        onSurface: ink,
        surfaceContainerLowest: NaturePaperColors.cream,
        surfaceContainerLow: NaturePaperColors.paperBeige,
        surfaceContainer: card,
        surfaceContainerHigh: const Color(0xFFF4ECD9),
        surfaceContainerHighest: NaturePaperColors.paperBeige,
        outline: border,
      ),
    );

    final textTheme = buildJakartaTextTheme(
      base: base.textTheme,
      primary: ink,
      secondary: ink.withValues(alpha: 0.78),
      tertiary: ink.withValues(alpha: 0.56),
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: NaturePaperColors.cream,
      pageTransitionsTheme: _fadeTransitions,
      textTheme: textTheme,
      dividerColor: NaturePaperColors.warmBrown.withValues(alpha: 0.14),
      extensions: const [AppStyleTokens.natureLight],
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: border),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: ink.withValues(alpha: 0.8),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF4B3D2C),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: NaturePaperColors.cream,
        ),
        actionTextColor: NaturePaperColors.sunGlow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: ink.withValues(alpha: 0.45),
        ),
        labelStyle: TextStyle(color: forest.withValues(alpha: 0.9)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: forest, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _paperButtonStyle(
          background: forest,
          foreground: NaturePaperColors.cream,
          shadow: NaturePaperColors.warmBrown.withValues(alpha: 0.45),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _paperButtonStyle(
          background: forest,
          foreground: NaturePaperColors.cream,
          shadow: NaturePaperColors.warmBrown.withValues(alpha: 0.45),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forest,
          side: BorderSide(
            color: NaturePaperColors.sage.withValues(alpha: 0.65),
            width: 1.4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: forest,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: forest,
        foregroundColor: NaturePaperColors.cream,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: NaturePaperColors.sage.withValues(alpha: 0.16),
        selectedColor: NaturePaperColors.sage.withValues(alpha: 0.34),
        labelStyle: textTheme.labelLarge!.copyWith(
          color: NaturePaperColors.deepForest,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: NaturePaperColors.sage.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card.withValues(alpha: 0.9),
        indicatorColor: NaturePaperColors.sage.withValues(alpha: 0.28),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall!.copyWith(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? forest : ink.withValues(alpha: 0.5),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? forest
                : ink.withValues(alpha: 0.5),
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: NaturePaperColors.cream.withValues(alpha: 0.86),
        indicatorColor: NaturePaperColors.sage.withValues(alpha: 0.28),
        selectedIconTheme: const IconThemeData(color: forest),
        unselectedIconTheme: IconThemeData(color: ink.withValues(alpha: 0.5)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: forest,
        circularTrackColor: NaturePaperColors.paperBeige.withValues(alpha: 0.7),
      ),
    );
  }

  static ThemeData dark() {
    const ink = NaturePaperColors.nightInk;
    const inkSecondary = NaturePaperColors.nightTextSecondary;
    const sage = NaturePaperColors.sageNight;
    const amber = NaturePaperColors.amber;
    const card = NaturePaperColors.nightCard;
    const cardHigh = NaturePaperColors.nightCardHigh;
    const border = NaturePaperColors.nightBorder;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: sage,
      onPrimary: const Color(0xFF0F1A12),
      primaryContainer: const Color(0xFF32463A),
      onPrimaryContainer: NaturePaperColors.moonBeige,
      secondary: NaturePaperColors.moonBeige,
      onSecondary: const Color(0xFF1B1A12),
      secondaryContainer: const Color(0xFF3B4438),
      onSecondaryContainer: NaturePaperColors.moonBeige,
      tertiary: amber,
      onTertiary: const Color(0xFF221708),
      error: NaturePaperColors.dustyRose,
      onError: const Color(0xFF200F0F),
      surface: card,
      onSurface: ink,
      onSurfaceVariant: inkSecondary,
      surfaceContainerLowest: NaturePaperColors.midnight,
      surfaceContainerLow: NaturePaperColors.forestNight,
      surfaceContainer: card,
      surfaceContainerHigh: cardHigh,
      surfaceContainerHighest: NaturePaperColors.nightCardHighest,
      outline: border,
      outlineVariant: const Color(0xFF35413B),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: NaturePaperColors.moonBeige,
      onInverseSurface: const Color(0xFF23201A),
      inversePrimary: NaturePaperColors.forest,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
    );

    final textTheme = buildJakartaTextTheme(
      base: base.textTheme,
      primary: ink,
      secondary: inkSecondary,
      tertiary: NaturePaperColors.nightTextTertiary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: NaturePaperColors.midnight,
      pageTransitionsTheme: _fadeTransitions,
      dividerColor: border,
      disabledColor: NaturePaperColors.nightTextTertiary,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: inkSecondary),
      primaryIconTheme: const IconThemeData(color: amber),
      extensions: const [AppStyleTokens.natureDark],
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: inkSecondary,
        textColor: ink,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: inkSecondary,
          fontSize: 13,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: sage.withValues(alpha: 0.18),
        disabledColor: card,
        selectedColor: sage.withValues(alpha: 0.36),
        secondarySelectedColor: sage.withValues(alpha: 0.36),
        labelStyle: textTheme.labelLarge!.copyWith(
          color: NaturePaperColors.moonBeige,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: textTheme.labelLarge!.copyWith(
          color: NaturePaperColors.moonBeige,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: sage.withValues(alpha: 0.45)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: amber,
        unselectedLabelColor: inkSecondary,
        indicatorColor: amber,
        dividerColor: border,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: ink),
        actionsIconTheme: const IconThemeData(color: inkSecondary),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: inkSecondary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardHigh,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: cardHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NaturePaperColors.nightCardHighest,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: ink),
        actionTextColor: amber,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: NaturePaperColors.nightCardHighest,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium?.copyWith(color: ink),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium?.copyWith(color: ink),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: cardHigh,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardHigh,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: NaturePaperColors.nightTextTertiary,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: inkSecondary),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: amber),
        prefixIconColor: inkSecondary,
        suffixIconColor: inkSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: amber, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _paperButtonStyle(
          background: sage,
          foreground: const Color(0xFF0F1A12),
          shadow: Colors.black.withValues(alpha: 0.6),
          textStyle: textTheme.labelLarge,
          disabledBackground: cardHigh,
          disabledForeground: NaturePaperColors.nightTextTertiary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _paperButtonStyle(
          background: sage,
          foreground: const Color(0xFF0F1A12),
          shadow: Colors.black.withValues(alpha: 0.6),
          textStyle: textTheme.labelLarge,
          disabledBackground: cardHigh,
          disabledForeground: NaturePaperColors.nightTextTertiary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NaturePaperColors.moonBeige,
          side: BorderSide(
            color: NaturePaperColors.moonBeige.withValues(alpha: 0.45),
            width: 1.4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: amber,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: sage,
        foregroundColor: const Color(0xFF0F1A12),
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardHigh,
        indicatorColor: amber.withValues(alpha: 0.26),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall!.copyWith(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? amber : inkSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? amber : inkSecondary,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: NaturePaperColors.forestNight.withValues(alpha: 0.88),
        indicatorColor: amber.withValues(alpha: 0.26),
        selectedIconTheme: const IconThemeData(color: amber),
        unselectedIconTheme: const IconThemeData(color: inkSecondary),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: amber,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: inkSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return amber;
          return inkSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return amber.withValues(alpha: 0.42);
          }
          return cardHigh;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: amber,
        circularTrackColor: cardHigh,
      ),
    );
  }

  static ButtonStyle _paperButtonStyle({
    required Color background,
    required Color foreground,
    required Color shadow,
    TextStyle? textStyle,
    Color? disabledBackground,
    Color? disabledForeground,
  }) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledBackground ?? background.withValues(alpha: 0.4);
        }
        return background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledForeground ?? foreground.withValues(alpha: 0.5);
        }
        return foreground;
      }),
      shadowColor: WidgetStatePropertyAll(shadow),
      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return 0;
        if (states.contains(WidgetState.pressed)) return 7;
        if (states.contains(WidgetState.hovered)) return 5;
        return 3;
      }),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      textStyle: WidgetStatePropertyAll(
        textStyle?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}
