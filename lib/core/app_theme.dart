import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_tokens.dart';

export 'app_colors.dart';
export 'app_tokens.dart';

class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);

    final jakarta = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    final textTheme = jakarta
        .copyWith(
          displayLarge: jakarta.displayLarge?.copyWith(
            fontSize: 32,
            height: 40 / 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineLarge: jakarta.headlineLarge?.copyWith(
            fontSize: 24,
            height: 32 / 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          headlineMedium: jakarta.headlineMedium?.copyWith(
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          headlineSmall: jakarta.headlineSmall?.copyWith(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: jakarta.bodyLarge?.copyWith(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: jakarta.bodyMedium?.copyWith(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w400,
          ),
          labelMedium: jakarta.labelMedium?.copyWith(
            fontSize: 11,
            height: 16 / 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        )
        .apply(bodyColor: c.ink, displayColor: c.ink);

    return base.copyWith(
      scaffoldBackgroundColor: c.bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.navy,
        onPrimary: AppColors.light.surface,
        secondary: c.gold,
        onSecondary: c.navy,
        error: base.colorScheme.error,
        onError: base.colorScheme.onError,
        surface: c.surface,
        onSurface: c.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        elevation: 0,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      textTheme: textTheme,
      dividerColor: c.hairline,
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: c.hairline),
        ),
      ),
      extensions: [c],
    );
  }
}
