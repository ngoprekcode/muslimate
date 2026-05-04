import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';

enum AppPillTone { gold, navy, muted }

class AppPill extends StatelessWidget {
  final String text;
  final AppPillTone tone;

  const AppPill({super.key, required this.text, this.tone = AppPillTone.gold});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Color bg, fg;
    switch (tone) {
      case AppPillTone.gold:
        bg = c.goldSoft;
        fg = c.goldDeep;
        break;
      case AppPillTone.navy:
        bg = c.surfaceAlt;
        fg = c.navy;
        break;
      case AppPillTone.muted:
        bg = c.surfaceMuted;
        fg = c.inkSoft;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
