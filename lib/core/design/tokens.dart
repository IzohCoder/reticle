import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Spacing — 8pt grid
// ---------------------------------------------------------------------------
abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

// ---------------------------------------------------------------------------
// Border radii — instrument precision: tight geometry
// ---------------------------------------------------------------------------
abstract final class Radii {
  /// Document surfaces — near-sharp for precision feel
  static const double document = 2;

  /// Standard cards and buttons
  static const double card = 6;

  /// Buttons
  static const double button = 6;

  /// Bottom sheets
  static const double sheet = 12;

  /// Chips, tags — fully rounded
  static const double chip = 100;

  /// Input fields
  static const double input = 4;

  static const BorderRadius documentAll =
      BorderRadius.all(Radius.circular(document));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius buttonAll =
      BorderRadius.all(Radius.circular(button));
  static const BorderRadius sheetTop = BorderRadius.only(
    topLeft: Radius.circular(sheet),
    topRight: Radius.circular(sheet),
  );
  static const BorderRadius chipAll = BorderRadius.all(Radius.circular(chip));
}

// ---------------------------------------------------------------------------
// Motion — precise, mechanical, not bouncy
// ---------------------------------------------------------------------------
abstract final class Motion {
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration long = Duration(milliseconds: 300);
  static const Duration xlong = Duration(milliseconds: 400);

  /// Edge lock total sequence time.
  static const Duration edgeLock = Duration(milliseconds: 250);

  /// Paper shuffle flight.
  static const Duration paperShuffle = Duration(milliseconds: 300);

  /// OCR block stagger interval.
  static const Duration ocrStagger = Duration(milliseconds: 50);

  static const Curve standard = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve snap = Curves.easeOutBack;
}

// ---------------------------------------------------------------------------
// Elevation / Shadow strategy
// ---------------------------------------------------------------------------
// Hairline borders on all surfaces. Shadows only on floating elements.
abstract final class AppShadows {
  /// Subtle depth for document thumbnails
  static List<BoxShadow> document(Color inkColor) => [
        BoxShadow(
          color: inkColor.withValues(alpha: 0.04),
          blurRadius: 0,
          offset: Offset.zero,
        ),
        BoxShadow(
          color: inkColor.withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Floating element shadow (FAB, sheets)
  static List<BoxShadow> floating(Color inkColor) => [
        BoxShadow(
          color: inkColor.withValues(alpha: 0.14),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}

// ---------------------------------------------------------------------------
// Touch targets
// ---------------------------------------------------------------------------
abstract final class TouchTargets {
  static const double minimum = 48;
}
