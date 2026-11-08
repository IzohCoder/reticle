import 'package:flutter/material.dart';

abstract final class AppFonts {
  /// Technical display font — geometric, has tabular figures.
  static const String display = 'SpaceGrotesk';

  /// Body/UI font — proven readability.
  static const String sans = 'Inter';
}

TextTheme buildTextTheme(Color onSurface, Color onSurfaceMuted) {
  return TextTheme(
    // Display — Space Grotesk for headings
    displayLarge: TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 32,
      fontWeight: FontWeight.w500,
      color: onSurface,
      letterSpacing: -0.5,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: onSurface,
      letterSpacing: -0.3,
      height: 1.2,
    ),

    // Titles — Space Grotesk for structure
    titleLarge: TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: onSurface,
      letterSpacing: -0.2,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: onSurface,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: onSurface,
      height: 1.4,
    ),

    // Body — Inter for readability
    bodyLarge: TextStyle(
      fontFamily: AppFonts.sans,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: onSurface,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppFonts.sans,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: onSurface,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontFamily: AppFonts.sans,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: onSurfaceMuted,
      height: 1.4,
    ),

    // Labels — Inter for compact UI elements
    labelSmall: TextStyle(
      fontFamily: AppFonts.sans,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: onSurfaceMuted,
      letterSpacing: 0.4,
      height: 1.3,
    ),
    labelMedium: TextStyle(
      fontFamily: AppFonts.sans,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: onSurface,
      letterSpacing: 0.2,
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontFamily: AppFonts.sans,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: onSurface,
      height: 1.3,
    ),
  );
}

extension TabularTextStyle on TextStyle {
  /// Use tabular figures for numeric displays (page counts, sizes, dates).
  TextStyle get tabular =>
      copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
