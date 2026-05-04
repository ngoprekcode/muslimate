import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceMuted;
  final Color ink;
  final Color inkSoft;
  final Color inkMuted;
  final Color hairline;
  final Color navy;
  final Color navyDeep;
  final Color gold;
  final Color goldSoft;
  final Color goldDeep;
  final Color success;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceMuted,
    required this.ink,
    required this.inkSoft,
    required this.inkMuted,
    required this.hairline,
    required this.navy,
    required this.navyDeep,
    required this.gold,
    required this.goldSoft,
    required this.goldDeep,
    required this.success,
  });

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  // Serene — Light
  static const AppColors light = AppColors(
    bg: Color(0xFFFAF8F4),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF4EFE6),
    surfaceMuted: Color(0xFFEDE7DA),
    ink: Color(0xFF0F2A44),
    inkSoft: Color(0xFF3E5066),
    inkMuted: Color(0xFF8A95A5),
    hairline: Color(0xFFE5DECF),
    navy: Color(0xFF0F2A44),
    navyDeep: Color(0xFF081A2D),
    gold: Color(0xFFC9A961),
    goldSoft: Color(0xFFE6D9B4),
    goldDeep: Color(0xFFA88945),
    success: Color(0xFF3F7D58),
  );

  // Editorial — Dark
  static const AppColors dark = AppColors(
    bg: Color(0xFF0A1018),
    surface: Color(0xFF101924),
    surfaceAlt: Color(0xFF152030),
    surfaceMuted: Color(0xFF0D141C),
    ink: Color(0xFFEFEAD8),
    inkSoft: Color(0xFFB5BAC2),
    inkMuted: Color(0xFF727A85),
    hairline: Color(0xFF1E2A38),
    navy: Color(0xFF11202E),
    navyDeep: Color(0xFF050A12),
    gold: Color(0xFFCFA868),
    goldSoft: Color(0xFF5A4523),
    goldDeep: Color(0xFFDCB87A),
    success: Color(0xFF7BB48F),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceMuted,
    Color? ink,
    Color? inkSoft,
    Color? inkMuted,
    Color? hairline,
    Color? navy,
    Color? navyDeep,
    Color? gold,
    Color? goldSoft,
    Color? goldDeep,
    Color? success,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      inkMuted: inkMuted ?? this.inkMuted,
      hairline: hairline ?? this.hairline,
      navy: navy ?? this.navy,
      navyDeep: navyDeep ?? this.navyDeep,
      gold: gold ?? this.gold,
      goldSoft: goldSoft ?? this.goldSoft,
      goldDeep: goldDeep ?? this.goldDeep,
      success: success ?? this.success,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      navy: Color.lerp(navy, other.navy, t)!,
      navyDeep: Color.lerp(navyDeep, other.navyDeep, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldSoft: Color.lerp(goldSoft, other.goldSoft, t)!,
      goldDeep: Color.lerp(goldDeep, other.goldDeep, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}
