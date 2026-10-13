import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/nature_paper_colors.dart';

class AppColors {
  static const darkChocolate = Color(
    0xFF2D2422,
  ); // Slightly darker for Linear feel
  static const coffeeBrown = Color(0xFF4A3731);
  static const warmBeige = Color(0xFFD7CCC8);
  static const cream = Color(0xFFFBFBF9); // Cleaner cream for Notion feel
  static const sand = Color(0xFFEFEBE9);

  static const mutedGold = Color(0xFFC5A059);
  static const warmAmber = Color(0xFFD4813E);
  static const softOlive = Color(0xFF8D917A);
  static const successGreen = Color(0xFF6B8E6B);
  static const errorRed = Color(0xFFAA5B5B);

  static const surfaceDark = Color(0xFF1E1E1E);
  static const surfaceLight = Color(0xFFFFFFFF);

  static const darkBackground = Color(0xFF0F0F0F);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkSurfaceElevated = Color(0xFF2A2A2A);
  static const darkSurfaceHighest = Color(0xFF343434);
  static const darkBorder = Color(0xFF525252);
  static const darkTextPrimary = Color(0xFFF5F5F5);
  static const darkTextSecondary = Color(0xFFD0D0D0); // ~40% brighter secondary
  static const darkTextTertiary = Color(0xFFB8B8B8);
  static const darkAccent = Color(0xFFC5A059); // mutedGold for highlights

  static const mathAccent = coffeeBrown;
  static const englishAccent = mutedGold;

  static Color accent(BuildContext context) {
    final tokens = AppStyleTokens.maybeOf(context);
    if (tokens != null) return tokens.accent;
    return Theme.of(context).brightness == Brightness.dark
        ? mutedGold
        : coffeeBrown;
  }

  static Color resolveAccent(BuildContext context, Color color) {
    final tokens = AppStyleTokens.maybeOf(context);
    if (tokens?.isMonochromeWorkspace ?? false) return ink(context);
    // Modern coffee/math browns vanish on Nature Paper night cards.
    if ((tokens?.isNaturePaper ?? false) &&
        Theme.of(context).brightness == Brightness.dark &&
        color.computeLuminance() < 0.2) {
      return NaturePaperColors.moonBeige;
    }
    return color;
  }

  static Color onAccent(BuildContext context) {
    final mono =
        AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (mono) return isDark ? Colors.black : Colors.white;
    return isDark ? const Color(0xFF1A1408) : Colors.white;
  }

  static Color success(BuildContext context) =>
      AppStyleTokens.maybeOf(context)?.success ?? successGreen;

  static Color warning(BuildContext context) =>
      AppStyleTokens.maybeOf(context)?.warning ?? warmAmber;

  static Color danger(BuildContext context) =>
      AppStyleTokens.maybeOf(context)?.danger ?? errorRed;

  static Color goldAccent(BuildContext context) =>
      AppStyleTokens.maybeOf(context)?.gold ?? mutedGold;

  static Color ink(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color inkAlpha(BuildContext context, double alpha) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base =
        AppStyleTokens.maybeOf(context)?.inkBase ??
        (isDark ? darkTextPrimary : darkChocolate);
    if (!isDark) {
      return base.withValues(alpha: alpha);
    }

    final darkAlpha = switch (alpha) {
      <= 0.05 => 0.16,
      <= 0.08 => 0.22,
      <= 0.12 => 0.28,
      <= 0.2 => 0.36,
      <= 0.25 => 0.80,
      <= 0.35 => 0.84,
      <= 0.45 => 0.88,
      <= 0.55 => 0.90,
      <= 0.7 => 0.92,
      _ => alpha.clamp(0.80, 1.0),
    };
    return base.withValues(alpha: darkAlpha);
  }

  static Color controlSurface(BuildContext context) {
    final tokens = AppStyleTokens.maybeOf(context);
    if (tokens != null) return tokens.controlSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSurfaceHighest : Colors.white;
  }

  static Color softWash(BuildContext context, {double lightAlpha = 0.5}) {
    final tokens = AppStyleTokens.maybeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return tokens?.softWashColor ?? Colors.white.withValues(alpha: 0.10);
    }
    return (tokens?.softWashColor ?? sand).withValues(alpha: lightAlpha);
  }

  static Color softSurface(BuildContext context) {
    final tokens = AppStyleTokens.maybeOf(context);
    if (tokens != null) return tokens.softSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSurfaceHighest : sand;
  }

  static Color sheetSurface(BuildContext context) {
    final tokens = AppStyleTokens.maybeOf(context);
    if (tokens != null) return tokens.sheetSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSurfaceElevated : Colors.white;
  }
}
