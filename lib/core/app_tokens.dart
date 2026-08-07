import 'package:flutter/material.dart';

/// Muslimate's non-color tokens, mirrored from the active design system.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 22;
  static const double full = 999;
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

extension MuslimateTextStyles on TextTheme {
  TextStyle get display => displayLarge!;
  TextStyle get h1 => headlineLarge!;
  TextStyle get h2 => headlineMedium!;
  TextStyle get h3 => headlineSmall!;
  TextStyle get bodyLg => bodyLarge!;
  TextStyle get bodyMd => bodyMedium!;
  TextStyle get labelMd => labelMedium!;
}
