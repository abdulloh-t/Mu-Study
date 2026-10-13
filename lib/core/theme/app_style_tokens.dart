import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style.dart';
import 'package:mu_study/core/theme/monochrome_workspace_colors.dart';
import 'package:mu_study/core/theme/nature_paper_colors.dart';
import 'package:mu_study/core/theme/soft_neumorphism_colors.dart';

class AppStyleTokens extends ThemeExtension<AppStyleTokens> {
  const AppStyleTokens({
    required this.style,
    required this.accent,
    required this.inkBase,
    required this.success,
    required this.warning,
    required this.danger,
    required this.gold,
    required this.controlSurface,
    required this.softSurface,
    required this.softWashColor,
    required this.sheetSurface,
    required this.cardSurface,
    required this.cardBorder,
    required this.cardRadius,
    required this.navSurface,
    required this.navGlow,
    required this.headerGlow,
    this.chartPositive,
    this.chartWarning,
    this.chartDanger,
  });

  final AppStyle style;

  final Color accent;

  final Color inkBase;

  final Color success;
  final Color warning;
  final Color danger;

  final Color gold;

  final Color controlSurface;

  final Color softSurface;

  final Color softWashColor;

  final Color sheetSurface;

  final Color cardSurface;

  final Color cardBorder;

  final double cardRadius;

  final Color navSurface;

  final Color navGlow;

  final Color headerGlow;

  final LinearGradient? chartPositive;
  final LinearGradient? chartWarning;
  final LinearGradient? chartDanger;

  bool get isNaturePaper => style == AppStyle.naturePaper;

  bool get isSoftNeumorphism => style == AppStyle.softNeumorphism;

  bool get isMonochromeWorkspace => style == AppStyle.monochromeWorkspace;

  bool get usesAmbientBackdrop => isNaturePaper || isSoftNeumorphism;

  bool get prefersChartLabelsInside => isNaturePaper || isSoftNeumorphism;

  static AppStyleTokens? maybeOf(BuildContext context) =>
      Theme.of(context).extension<AppStyleTokens>();

  static const modernLight = AppStyleTokens(
    style: AppStyle.modern,
    accent: AppColors.coffeeBrown,
    inkBase: AppColors.darkChocolate,
    success: AppColors.successGreen,
    warning: AppColors.warmAmber,
    danger: AppColors.errorRed,
    gold: AppColors.mutedGold,
    controlSurface: Colors.white,
    softSurface: AppColors.sand,
    softWashColor: AppColors.sand,
    sheetSurface: Colors.white,
    cardSurface: Colors.white,
    cardBorder: Color(0x0F2D2422), // darkChocolate @ 6%
    cardRadius: 16,
    navSurface: Color(0xE0FBFBF9), // cream @ 88%
    navGlow: Colors.transparent,
    headerGlow: Colors.transparent,
  );

  static const modernDark = AppStyleTokens(
    style: AppStyle.modern,
    accent: AppColors.mutedGold,
    inkBase: AppColors.darkTextPrimary,
    success: AppColors.successGreen,
    warning: AppColors.warmAmber,
    danger: Color(0xFFE57373),
    gold: AppColors.mutedGold,
    controlSurface: AppColors.darkSurfaceHighest,
    softSurface: AppColors.darkSurfaceHighest,
    softWashColor: Color(0x1AFFFFFF), // white @ 10%, used as-is in dark
    sheetSurface: AppColors.darkSurfaceElevated,
    cardSurface: AppColors.darkSurfaceElevated,
    cardBorder: AppColors.darkBorder,
    cardRadius: 16,
    navSurface: Color(0xF5343434), // darkSurfaceHighest @ 96%
    navGlow: Colors.transparent,
    headerGlow: Colors.transparent,
  );

  static const natureLight = AppStyleTokens(
    style: AppStyle.naturePaper,
    accent: NaturePaperColors.forest,
    inkBase: NaturePaperColors.dayInk,
    success: NaturePaperColors.sage,
    warning: NaturePaperColors.softOrange,
    danger: NaturePaperColors.dayDanger,
    gold: NaturePaperColors.softOrange,
    controlSurface: NaturePaperColors.dayCard,
    softSurface: NaturePaperColors.paperBeige,
    softWashColor: NaturePaperColors.paperBeige,
    sheetSurface: NaturePaperColors.dayCard,
    cardSurface: NaturePaperColors.dayCard,
    cardBorder: Color(0x2E8A6A4A), // warmBrown @ 18%
    cardRadius: 24,
    navSurface: Color(0xE6FFFCF4), // dayCard @ 90%
    navGlow: NaturePaperColors.sunGlow,
    headerGlow: NaturePaperColors.sunGlow,
    chartPositive: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [NaturePaperColors.forest, Color(0xFFC9C36A)],
    ),
    chartWarning: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [NaturePaperColors.warmBrown, NaturePaperColors.softOrange],
    ),
    chartDanger: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF7E4437), NaturePaperColors.dayDanger],
    ),
  );

  static const natureDark = AppStyleTokens(
    style: AppStyle.naturePaper,
    accent: NaturePaperColors.amber,
    inkBase: NaturePaperColors.nightInk,
    success: NaturePaperColors.sageNight,
    warning: NaturePaperColors.amber,
    danger: NaturePaperColors.dustyRose,
    gold: NaturePaperColors.amber,
    controlSurface: NaturePaperColors.nightCardHigh,
    softSurface: NaturePaperColors.nightCardHigh,
    softWashColor: Color(0x14E6DCC8), // moonBeige @ 8%, used as-is in dark
    sheetSurface: NaturePaperColors.nightCardHigh,
    cardSurface: NaturePaperColors.nightCard,
    cardBorder: NaturePaperColors.nightBorder,
    cardRadius: 24,
    navSurface: Color(0xF0283630), // nightCardHigh @ 94%
    navGlow: NaturePaperColors.moonGlow,
    headerGlow: NaturePaperColors.moonGlow,
    chartPositive: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF4C6A50), NaturePaperColors.sageNight],
    ),
    chartWarning: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF8A6434), NaturePaperColors.amber],
    ),
    chartDanger: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF6E4444), NaturePaperColors.dustyRose],
    ),
  );

  static const softNeuLight = AppStyleTokens(
    style: AppStyle.softNeumorphism,
    accent: SoftNeumorphismColors.sage,
    inkBase: SoftNeumorphismColors.morningInk,
    success: SoftNeumorphismColors.sage,
    warning: SoftNeumorphismColors.amber,
    danger: SoftNeumorphismColors.morningDanger,
    gold: SoftNeumorphismColors.amber,
    controlSurface: SoftNeumorphismColors.morningSurfaceHigh,
    softSurface: SoftNeumorphismColors.morningInset,
    softWashColor: SoftNeumorphismColors.morningInset,
    sheetSurface: SoftNeumorphismColors.morningSurfaceHigh,
    cardSurface: SoftNeumorphismColors.morningSurface,
    cardBorder: Color(0x00000000),
    cardRadius: 18,
    navSurface: SoftNeumorphismColors.morningSurface,
    navGlow: SoftNeumorphismColors.sage,
    headerGlow: SoftNeumorphismColors.sage,
    chartPositive: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [SoftNeumorphismColors.sageDeep, SoftNeumorphismColors.sage],
    ),
    chartWarning: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFFB8844A), SoftNeumorphismColors.amber],
    ),
    chartDanger: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF8A5050), SoftNeumorphismColors.morningDanger],
    ),
  );

  static const softNeuDark = AppStyleTokens(
    style: AppStyle.softNeumorphism,
    accent: SoftNeumorphismColors.emerald,
    inkBase: SoftNeumorphismColors.nightInk,
    success: SoftNeumorphismColors.emerald,
    warning: SoftNeumorphismColors.amber,
    danger: SoftNeumorphismColors.nightDanger,
    gold: SoftNeumorphismColors.amber,
    controlSurface: SoftNeumorphismColors.nightSurfaceHigh,
    softSurface: SoftNeumorphismColors.nightInset,
    softWashColor: Color(0x14F2F0EB), // nightInk @ 8%
    sheetSurface: SoftNeumorphismColors.nightSurfaceHigh,
    cardSurface: SoftNeumorphismColors.nightSurface,
    cardBorder: Color(0x00000000),
    cardRadius: 18,
    navSurface: SoftNeumorphismColors.nightSurface,
    navGlow: SoftNeumorphismColors.emeraldGlow,
    headerGlow: SoftNeumorphismColors.emeraldGlow,
    chartPositive: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF3D6E55), SoftNeumorphismColors.emeraldGlow],
    ),
    chartWarning: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF8A6434), SoftNeumorphismColors.amber],
    ),
    chartDanger: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF6E4444), SoftNeumorphismColors.nightDanger],
    ),
  );

  static const monoLight = AppStyleTokens(
    style: AppStyle.monochromeWorkspace,
    accent: MonochromeWorkspaceColors.lightAccent,
    inkBase: MonochromeWorkspaceColors.lightInk,
    success: MonochromeWorkspaceColors.lightSuccess,
    warning: MonochromeWorkspaceColors.lightWarning,
    danger: MonochromeWorkspaceColors.lightDanger,
    gold: MonochromeWorkspaceColors.lightGold,
    controlSurface: MonochromeWorkspaceColors.lightControl,
    softSurface: MonochromeWorkspaceColors.lightWash,
    softWashColor: MonochromeWorkspaceColors.lightWash,
    sheetSurface: MonochromeWorkspaceColors.lightCard,
    cardSurface: MonochromeWorkspaceColors.lightCard,
    cardBorder: MonochromeWorkspaceColors.lightBorder,
    cardRadius: 4,
    navSurface: Color(0xF5FFFFFF), // white @ 96%
    navGlow: Colors.transparent,
    headerGlow: Colors.transparent,
  );

  static const monoDark = AppStyleTokens(
    style: AppStyle.monochromeWorkspace,
    accent: MonochromeWorkspaceColors.darkAccent,
    inkBase: MonochromeWorkspaceColors.darkInk,
    success: MonochromeWorkspaceColors.darkSuccess,
    warning: MonochromeWorkspaceColors.darkWarning,
    danger: MonochromeWorkspaceColors.darkDanger,
    gold: MonochromeWorkspaceColors.darkGold,
    controlSurface: MonochromeWorkspaceColors.darkControl,
    softSurface: MonochromeWorkspaceColors.darkWash,
    softWashColor: Color(0x14FFFFFF), // white @ 8%
    sheetSurface: MonochromeWorkspaceColors.darkControl,
    cardSurface: MonochromeWorkspaceColors.darkCard,
    cardBorder: MonochromeWorkspaceColors.darkBorder,
    cardRadius: 4,
    navSurface: Color(0xF51A1A1A), // darkCard @ 96%
    navGlow: Colors.transparent,
    headerGlow: Colors.transparent,
  );

  @override
  AppStyleTokens copyWith({
    AppStyle? style,
    Color? accent,
    Color? inkBase,
    Color? success,
    Color? warning,
    Color? danger,
    Color? gold,
    Color? controlSurface,
    Color? softSurface,
    Color? softWashColor,
    Color? sheetSurface,
    Color? cardSurface,
    Color? cardBorder,
    double? cardRadius,
    Color? navSurface,
    Color? navGlow,
    Color? headerGlow,
    LinearGradient? chartPositive,
    LinearGradient? chartWarning,
    LinearGradient? chartDanger,
  }) {
    return AppStyleTokens(
      style: style ?? this.style,
      accent: accent ?? this.accent,
      inkBase: inkBase ?? this.inkBase,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      gold: gold ?? this.gold,
      controlSurface: controlSurface ?? this.controlSurface,
      softSurface: softSurface ?? this.softSurface,
      softWashColor: softWashColor ?? this.softWashColor,
      sheetSurface: sheetSurface ?? this.sheetSurface,
      cardSurface: cardSurface ?? this.cardSurface,
      cardBorder: cardBorder ?? this.cardBorder,
      cardRadius: cardRadius ?? this.cardRadius,
      navSurface: navSurface ?? this.navSurface,
      navGlow: navGlow ?? this.navGlow,
      headerGlow: headerGlow ?? this.headerGlow,
      chartPositive: chartPositive ?? this.chartPositive,
      chartWarning: chartWarning ?? this.chartWarning,
      chartDanger: chartDanger ?? this.chartDanger,
    );
  }

  @override
  AppStyleTokens lerp(ThemeExtension<AppStyleTokens>? other, double t) {
    if (other is! AppStyleTokens) return this;
    return AppStyleTokens(
      style: t < 0.5 ? style : other.style,
      accent: Color.lerp(accent, other.accent, t)!,
      inkBase: Color.lerp(inkBase, other.inkBase, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      controlSurface: Color.lerp(controlSurface, other.controlSurface, t)!,
      softSurface: Color.lerp(softSurface, other.softSurface, t)!,
      softWashColor: Color.lerp(softWashColor, other.softWashColor, t)!,
      sheetSurface: Color.lerp(sheetSurface, other.sheetSurface, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
      navSurface: Color.lerp(navSurface, other.navSurface, t)!,
      navGlow: Color.lerp(navGlow, other.navGlow, t)!,
      headerGlow: Color.lerp(headerGlow, other.headerGlow, t)!,
      chartPositive: t < 0.5 ? chartPositive : other.chartPositive,
      chartWarning: t < 0.5 ? chartWarning : other.chartWarning,
      chartDanger: t < 0.5 ? chartDanger : other.chartDanger,
    );
  }
}
