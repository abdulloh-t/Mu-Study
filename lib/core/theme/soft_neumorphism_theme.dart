import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/app_text_theme.dart';
import 'package:mu_study/core/theme/soft_neumorphism_colors.dart';

class SoftNeumorphismTheme {
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

  static const _radius = 18.0;
  static const _controlRadius = 14.0;

  static ThemeData light() {
    const ink = SoftNeumorphismColors.morningInk;
    const sage = SoftNeumorphismColors.sage;
    const surface = SoftNeumorphismColors.morningSurface;
    const bg = SoftNeumorphismColors.morningBg;

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: sage,
        primary: sage,
        onPrimary: SoftNeumorphismColors.morningSurfaceHigh,
        secondary: SoftNeumorphismColors.amber,
        onSecondary: const Color(0xFF2A2218),
        tertiary: SoftNeumorphismColors.sageDeep,
        error: SoftNeumorphismColors.morningDanger,
        surface: surface,
        onSurface: ink,
        surfaceContainerLowest: bg,
        surfaceContainerLow: SoftNeumorphismColors.morningInset,
        surfaceContainer: surface,
        surfaceContainerHigh: SoftNeumorphismColors.morningSurfaceHigh,
        surfaceContainerHighest: SoftNeumorphismColors.morningSurfaceHigh,
        outline: SoftNeumorphismColors.morningShadow.withValues(alpha: 0.35),
      ),
    );

    final textTheme = buildJakartaTextTheme(
      base: base.textTheme,
      primary: ink,
      secondary: SoftNeumorphismColors.morningTextSecondary,
      tertiary: SoftNeumorphismColors.morningTextTertiary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: bg,
      pageTransitionsTheme: _fadeTransitions,
      textTheme: textTheme,
      dividerColor: SoftNeumorphismColors.morningShadow.withValues(alpha: 0.22),
      extensions: const [AppStyleTokens.softNeuLight],
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
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SoftNeumorphismColors.morningSurfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: SoftNeumorphismColors.morningTextSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SoftNeumorphismColors.morningSurfaceHigh,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: SoftNeumorphismColors.morningSurfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SoftNeumorphismColors.sageDeep,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: SoftNeumorphismColors.morningSurfaceHigh,
        ),
        actionTextColor: SoftNeumorphismColors.amber,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SoftNeumorphismColors.morningInset,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: SoftNeumorphismColors.morningTextTertiary,
        ),
        labelStyle: TextStyle(
          color: SoftNeumorphismColors.morningTextSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: sage, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _neuButtonStyle(
          background: sage,
          foreground: SoftNeumorphismColors.morningSurfaceHigh,
          shadow: SoftNeumorphismColors.morningShadow.withValues(alpha: 0.35),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _neuButtonStyle(
          background: sage,
          foreground: SoftNeumorphismColors.morningSurfaceHigh,
          shadow: SoftNeumorphismColors.morningShadow.withValues(alpha: 0.35),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SoftNeumorphismColors.sageDeep,
          side: BorderSide(color: sage.withValues(alpha: 0.45), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_controlRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SoftNeumorphismColors.sageDeep,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: sage,
        foregroundColor: SoftNeumorphismColors.morningSurfaceHigh,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SoftNeumorphismColors.morningInset,
        selectedColor: sage.withValues(alpha: 0.28),
        labelStyle: textTheme.labelLarge!.copyWith(
          color: SoftNeumorphismColors.sageDeep,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SoftNeumorphismColors.morningSurfaceHigh;
          }
          return SoftNeumorphismColors.morningSurfaceHigh;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return sage;
          }
          return SoftNeumorphismColors.morningInset;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: sage,
        circularTrackColor: SoftNeumorphismColors.morningInset,
        linearTrackColor: SoftNeumorphismColors.morningInset,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SoftNeumorphismColors.morningSurfaceHigh,
        indicatorColor: sage.withValues(alpha: 0.22),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall!.copyWith(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? SoftNeumorphismColors.sageDeep
                : SoftNeumorphismColors.morningTextTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? SoftNeumorphismColors.sageDeep
                : SoftNeumorphismColors.morningTextTertiary,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: SoftNeumorphismColors.morningSurface.withValues(
          alpha: 0.92,
        ),
        indicatorColor: sage.withValues(alpha: 0.22),
        selectedIconTheme: const IconThemeData(
          color: SoftNeumorphismColors.sageDeep,
        ),
        unselectedIconTheme: const IconThemeData(
          color: SoftNeumorphismColors.morningTextTertiary,
        ),
      ),
    );
  }

  static ThemeData dark() {
    const ink = SoftNeumorphismColors.nightInk;
    const inkSecondary = SoftNeumorphismColors.nightTextSecondary;
    const emerald = SoftNeumorphismColors.emerald;
    const amber = SoftNeumorphismColors.amber;
    const surface = SoftNeumorphismColors.nightSurface;
    const surfaceHigh = SoftNeumorphismColors.nightSurfaceHigh;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: emerald,
      onPrimary: const Color(0xFF0E1812),
      primaryContainer: const Color(0xFF2A3F34),
      onPrimaryContainer: SoftNeumorphismColors.nightInk,
      secondary: amber,
      onSecondary: const Color(0xFF1A140C),
      secondaryContainer: const Color(0xFF3A3228),
      onSecondaryContainer: SoftNeumorphismColors.nightInk,
      tertiary: SoftNeumorphismColors.emeraldGlow,
      onTertiary: const Color(0xFF0E1812),
      error: SoftNeumorphismColors.nightDanger,
      onError: const Color(0xFF1A0C0C),
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: inkSecondary,
      surfaceContainerLowest: SoftNeumorphismColors.nightBg,
      surfaceContainerLow: SoftNeumorphismColors.nightInset,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: const Color(0xFF323840),
      outline: SoftNeumorphismColors.nightHighlight,
      outlineVariant: const Color(0xFF2E343C),
      shadow: SoftNeumorphismColors.nightShadow,
      scrim: Colors.black,
      inverseSurface: SoftNeumorphismColors.morningSurface,
      onInverseSurface: SoftNeumorphismColors.morningInk,
      inversePrimary: SoftNeumorphismColors.sage,
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
      tertiary: SoftNeumorphismColors.nightTextTertiary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: SoftNeumorphismColors.nightBg,
      pageTransitionsTheme: _fadeTransitions,
      dividerColor: SoftNeumorphismColors.nightHighlight.withValues(
        alpha: 0.45,
      ),
      disabledColor: SoftNeumorphismColors.nightTextTertiary,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: inkSecondary),
      primaryIconTheme: const IconThemeData(color: emerald),
      extensions: const [AppStyleTokens.softNeuDark],
      dividerTheme: DividerThemeData(
        color: SoftNeumorphismColors.nightHighlight.withValues(alpha: 0.45),
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
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: inkSecondary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SoftNeumorphismColors.nightSurfaceHigh,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: SoftNeumorphismColors.nightSurfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: ink),
        actionTextColor: amber,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SoftNeumorphismColors.nightInset,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: SoftNeumorphismColors.nightTextTertiary,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: inkSecondary),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: emerald),
        prefixIconColor: inkSecondary,
        suffixIconColor: inkSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: emerald, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _neuButtonStyle(
          background: emerald,
          foreground: const Color(0xFF0E1812),
          shadow: SoftNeumorphismColors.nightShadow.withValues(alpha: 0.55),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _neuButtonStyle(
          background: emerald,
          foreground: const Color(0xFF0E1812),
          shadow: SoftNeumorphismColors.nightShadow.withValues(alpha: 0.55),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SoftNeumorphismColors.emeraldGlow,
          side: BorderSide(color: emerald.withValues(alpha: 0.55), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_controlRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SoftNeumorphismColors.emeraldGlow,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: emerald,
        foregroundColor: const Color(0xFF0E1812),
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SoftNeumorphismColors.nightInset,
        selectedColor: emerald.withValues(alpha: 0.32),
        labelStyle: textTheme.labelLarge!.copyWith(
          color: SoftNeumorphismColors.nightInk,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(
          SoftNeumorphismColors.nightInk,
        ),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return emerald;
          }
          return SoftNeumorphismColors.nightInset;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: emerald,
        circularTrackColor: SoftNeumorphismColors.nightInset,
        linearTrackColor: SoftNeumorphismColors.nightInset,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceHigh,
        indicatorColor: emerald.withValues(alpha: 0.28),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall!.copyWith(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? SoftNeumorphismColors.emeraldGlow
                : SoftNeumorphismColors.nightTextTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? SoftNeumorphismColors.emeraldGlow
                : SoftNeumorphismColors.nightTextTertiary,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: SoftNeumorphismColors.nightSurface,
        indicatorColor: emerald.withValues(alpha: 0.28),
        selectedIconTheme: const IconThemeData(
          color: SoftNeumorphismColors.emeraldGlow,
        ),
        unselectedIconTheme: const IconThemeData(
          color: SoftNeumorphismColors.nightTextTertiary,
        ),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: SoftNeumorphismColors.emeraldGlow,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: SoftNeumorphismColors.nightTextTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: SoftNeumorphismColors.emeraldGlow,
        unselectedLabelColor: inkSecondary,
        indicatorColor: emerald,
        dividerColor: SoftNeumorphismColors.nightHighlight.withValues(
          alpha: 0.4,
        ),
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceHigh,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium?.copyWith(color: ink),
      ),
    );
  }

  static ButtonStyle _neuButtonStyle({
    required Color background,
    required Color foreground,
    required Color shadow,
    TextStyle? textStyle,
  }) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return background.withValues(alpha: 0.40);
        }
        if (states.contains(WidgetState.pressed)) {
          return Color.lerp(background, Colors.black, 0.08);
        }
        return background;
      }),
      foregroundColor: WidgetStatePropertyAll(foreground),
      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return 1;
        if (states.contains(WidgetState.hovered)) return 5;
        return 3;
      }),
      shadowColor: WidgetStatePropertyAll(shadow),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        textStyle?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}
