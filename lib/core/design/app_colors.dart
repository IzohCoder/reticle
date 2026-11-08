import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Reticle colour roles — Precision Darkroom palette
// Dark-primary: carbon and ash. Signal Red as a laser line.
// ---------------------------------------------------------------------------

abstract final class AppColorsLight {
  // Surfaces — warm bone and ash
  static const Color surface = Color(0xFFF5F3F0);
  static const Color surfaceElevated = Color(0xFFEDEAE5);
  static const Color surfaceContainer = Color(0xFFE4E0DA);

  // Ink
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceMuted = Color(0xFF6B6B6B);
  static const Color onSurfaceDisabled = Color(0xFFA8A8A8);

  // Borders
  static const Color outline = Color(0xFFD0CCC6);
  static const Color outlineVariant = Color(0xFFE4E0DA);

  // Signal — laser red
  static const Color accent = Color(0xFFD43030);
  static const Color accentDark = Color(0xFFA82424);
  static const Color accentSurface = Color(0xFFFDE8E8);
  static const Color onAccent = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF1B8A4A);
  static const Color successSurface = Color(0xFFE6F4EC);
  static const Color warning = Color(0xFFC06800);
  static const Color warningSurface = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFB00020);
  static const Color errorSurface = Color(0xFFFFF0F0);

  // Camera overlay (used in viewfinder on light backgrounds)
  static const Color viewfinder = Color(0xFF1A1A1A);
}

abstract final class AppColorsDark {
  // Surfaces — carbon
  static const Color surface = Color(0xFF141414);
  static const Color surfaceElevated = Color(0xFF1E1E1E);
  static const Color surfaceContainer = Color(0xFF282828);

  // Ink
  static const Color onSurface = Color(0xFFE8E6E2);
  static const Color onSurfaceMuted = Color(0xFF8A8A8A);
  static const Color onSurfaceDisabled = Color(0xFF4A4A4A);

  // Borders
  static const Color outline = Color(0xFF333333);
  static const Color outlineVariant = Color(0xFF282828);

  // Signal
  static const Color accent = Color(0xFFE23B3B);
  static const Color accentDark = Color(0xFFBB2D2D);
  static const Color accentSurface = Color(0xFF2D1515);
  static const Color onAccent = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF34C76A);
  static const Color successSurface = Color(0xFF0D2E1A);
  static const Color warning = Color(0xFFE8922A);
  static const Color warningSurface = Color(0xFF2E1A00);
  static const Color error = Color(0xFFCF6679);
  static const Color errorSurface = Color(0xFF2E0010);

  // Camera overlay
  static const Color viewfinder = Color(0xFFE8E6E2);
}
