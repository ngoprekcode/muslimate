import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.navy,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            // decorative arch
            Positioned(
              top: -20,
              right: -30,
              child: Opacity(
                opacity: 0.55,
                child: CustomPaint(
                  size: const Size(150, 170),
                  painter: _ArchPainter(c.gold),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFFE6D9B4),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Bandung, ID',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE6D9B4),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Shalat berikutnya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFFC7D3E0),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Dzuhur',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '11:58',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.12)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tersisa',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFFC7D3E0),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '02:14:08',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFeatures: [
                                const FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withOpacity(0.15),
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hijriah',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFFC7D3E0),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '14 Syawal 1447',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchPainter extends CustomPainter {
  final Color color;
  _ArchPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final w = size.width;
    final h = size.height;

    // outer arch
    final outer = Path()
      ..moveTo(10, h)
      ..lineTo(10, h * 0.44)
      ..arcToPoint(
        Offset(w - 10, h * 0.44),
        radius: Radius.circular(w * 0.42),
        clockwise: false,
      )
      ..lineTo(w - 10, h);
    canvas.drawPath(outer, paint..color = color.withOpacity(0.6));

    // inner arch
    final inner = Path()
      ..moveTo(22, h)
      ..lineTo(22, h * 0.45)
      ..arcToPoint(
        Offset(w - 22, h * 0.45),
        radius: Radius.circular(w * 0.32),
        clockwise: false,
      )
      ..lineTo(w - 22, h);
    canvas.drawPath(inner, paint..color = color.withOpacity(0.36));
  }

  @override
  bool shouldRepaint(_ArchPainter old) => old.color != color;
}
