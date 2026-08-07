import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';

class AppArabicText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final TextAlign textAlign;
  final double height;

  const AppArabicText({
    super.key,
    required this.text,
    this.fontSize = 22,
    this.color,
    this.textAlign = TextAlign.right,
    this.height = 2.2,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.amiri(
        fontSize: fontSize,
        color: color ?? c.ink,
        height: height,
      ),
    );
  }
}
