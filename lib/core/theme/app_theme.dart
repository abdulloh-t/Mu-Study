import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/app_text_theme.dart';
import 'package:mu_study/core/theme/monochrome_workspace_theme.dart';
import 'package:mu_study/core/theme/nature_paper_theme.dart';
import 'package:mu_study/core/theme/soft_neumorphism_theme.dart';

class AppTheme {
  /// Light theme for the given [style] (defaults to Modern Professional).
  static ThemeData light([AppStyle style = AppStyle.modern]) => switch (style) {
    AppStyle.modern => _modernLight(),
    AppStyle.naturePaper => NaturePaperTheme.light(),
    AppStyle.softNeumorphism => SoftNeumorphismTheme.light(),
    AppStyle.monochromeWorkspace => MonochromeWorkspaceTheme.light(),
  };

  /// Dark theme for the given [style] (defaults to Modern Professional).
  static ThemeData dark([AppStyle style = AppStyle.modern]) => switch (style) {
    AppStyle.modern => _modernDark(),
    AppStyle.naturePaper => NaturePaperTheme.dark(),
    AppStyle.softNeumorphism => SoftNeumorphismTheme.dark(),
    AppStyle.monochromeWorkspace => MonochromeWorkspaceTheme.dark(),
  };

  static TextTheme _jakartaTextTheme({
    required TextTheme base,
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) => buildJakartaTextTheme(
    base: base,
    primary: primary,
    secondary: secondary,
    tertiary: tertiary,
  );

  static ThemeData _modernLight() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coffeeBrown,
        primary: AppColors.coffeeBrown,
        secondary: AppColors.mutedGold,
        surface: AppColors.cream,
        onSurface: AppColors.darkChocolate,
        surfaceContainerLow: AppColors.sand,
        surfaceContainer: Colors.white,
      ),
    );

    final textTheme = _jakartaTextTheme(
      base: base.textTheme,
      primary: AppColors.darkChocolate,
      secondary: AppColors.darkChocolate.withValues(alpha: 0.8),
      tertiary: AppColors.darkChocolate.withValues(alpha: 0.55),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      extensions: const [AppStyleTokens.modernLight],
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkChocolate,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.darkChocolate,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.darkChocolate.withValues(alpha: 0.05),
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkChocolate.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkChocolate.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.coffeeBrown, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: AppColors.coffeeBrown),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coffeeBrown,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.coffeeBrown,
          side: BorderSide(color: AppColors.coffeeBrown.withValues(alpha: 0.2)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.coffeeBrown,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.coffeeBrown,
        foregroundColor: Colors.white,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: const StadiumBorder(),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        indicatorColor: AppColors.warmBeige.withValues(alpha: 0.3),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall!.copyWith(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? AppColors.coffeeBrown
                : AppColors.darkChocolate.withValues(alpha: 0.5),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.coffeeBrown
                : AppColors.darkChocolate.withValues(alpha: 0.5),
          );
        }),
      ),
    );
  }

  static ThemeData _modernDark() {
    const onSurface = AppColors.darkTextPrimary;
    const onSurfaceVariant = AppColors.darkTextSecondary;
    const outline = AppColors.darkBorder;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.mutedGold,
      onPrimary: const Color(0xFF1A1408),
      primaryContainer: const Color(0xFF3D3420),
      onPrimaryContainer: AppColors.warmBeige,
      secondary: AppColors.warmBeige,
      onSecondary: const Color(0xFF1A1512),
      secondaryContainer: const Color(0xFF3A322E),
      onSecondaryContainer: AppColors.warmBeige,
      tertiary: AppColors.warmAmber,
      onTertiary: const Color(0xFF1A1208),
      error: const Color(0xFFE57373),
      onError: const Color(0xFF1A0A0A),
      surface: AppColors.darkSurface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: const Color(0xFF151515),
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerHigh: AppColors.darkSurfaceElevated,
      surfaceContainerHighest: AppColors.darkSurfaceHighest,
      outline: outline,
      outlineVariant: const Color(0xFF3D3D3D),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFE8E8E8),
      onInverseSurface: const Color(0xFF1A1A1A),
      inversePrimary: AppColors.coffeeBrown,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
    );

    final textTheme = _jakartaTextTheme(
      base: base.textTheme,
      primary: onSurface,
      secondary: onSurfaceVariant,
      tertiary: AppColors.darkTextTertiary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkBackground,
      extensions: const [AppStyleTokens.modernDark],
      dividerColor: outline,
      disabledColor: AppColors.darkTextTertiary,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: onSurfaceVariant),
      primaryIconTheme: const IconThemeData(color: AppColors.mutedGold),
      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onSurfaceVariant,
        textColor: onSurface,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.mutedGold.withValues(alpha: 0.16),
        disabledColor: AppColors.darkSurface,
        selectedColor: AppColors.mutedGold.withValues(alpha: 0.32),
        secondarySelectedColor: AppColors.mutedGold.withValues(alpha: 0.32),
        labelStyle: textTheme.labelLarge!.copyWith(
          color: AppColors.warmBeige,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: textTheme.labelLarge!.copyWith(
          color: AppColors.warmBeige,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: AppColors.mutedGold.withValues(alpha: 0.45)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.mutedGold,
        unselectedLabelColor: onSurfaceVariant,
        indicatorColor: AppColors.mutedGold,
        dividerColor: outline,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: onSurface),
        actionsIconTheme: const IconThemeData(color: onSurfaceVariant),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outline, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.darkSurfaceElevated,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceHighest,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
        actionTextColor: AppColors.mutedGold,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurfaceHighest,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceHighest,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceHighest,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextTertiary,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.mutedGold,
        ),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mutedGold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mutedGold,
          foregroundColor: const Color(0xFF1A1408),
          disabledBackgroundColor: AppColors.darkSurfaceHighest,
          disabledForegroundColor: AppColors.darkTextTertiary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mutedGold,
          side: BorderSide(color: AppColors.mutedGold.withValues(alpha: 0.65)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mutedGold,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.mutedGold,
        foregroundColor: const Color(0xFF1A1408),
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: const StadiumBorder(),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        indicatorColor: AppColors.mutedGold.withValues(alpha: 0.28),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall!.copyWith(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.mutedGold : onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.mutedGold : onSurfaceVariant,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.mutedGold.withValues(alpha: 0.28),
        selectedIconTheme: const IconThemeData(color: AppColors.mutedGold),
        unselectedIconTheme: const IconThemeData(color: onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.mutedGold,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mutedGold;
          }
          return onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mutedGold.withValues(alpha: 0.42);
          }
          return AppColors.darkSurfaceHighest;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.mutedGold,
        circularTrackColor: AppColors.darkSurfaceHighest,
      ),
    );
  }
}
