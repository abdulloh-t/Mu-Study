import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme buildJakartaTextTheme({
  required TextTheme base,
  required Color primary,
  required Color secondary,
  required Color tertiary,
}) {
  final jakarta = GoogleFonts.plusJakartaSansTextTheme(base);
  return jakarta.copyWith(
    displayLarge: jakarta.displayLarge?.copyWith(
      fontWeight: FontWeight.w800,
      color: primary,
      letterSpacing: -1,
    ),
    displayMedium: jakarta.displayMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: primary,
      letterSpacing: -0.8,
    ),
    displaySmall: jakarta.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: -0.5,
    ),
    headlineLarge: jakarta.headlineLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: primary,
    ),
    headlineMedium: jakarta.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: primary,
    ),
    headlineSmall: jakarta.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: primary,
    ),
    titleLarge: jakarta.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: primary,
    ),
    titleMedium: jakarta.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    titleSmall: jakarta.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    bodyLarge: jakarta.bodyLarge?.copyWith(
      color: primary.withValues(alpha: 0.92),
      fontSize: 16,
    ),
    bodyMedium: jakarta.bodyMedium?.copyWith(color: secondary, fontSize: 14),
    bodySmall: jakarta.bodySmall?.copyWith(color: tertiary, fontSize: 12),
    labelLarge: jakarta.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    labelMedium: jakarta.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: secondary,
    ),
    labelSmall: jakarta.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: tertiary,
    ),
  );
}
