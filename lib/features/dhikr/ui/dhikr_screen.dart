import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  int _count = 23;
  static const int _target = 33;

  static const _categories = [
    _DhikrCategory('Dzikir Pagi', 12, Icons.wb_twilight_rounded),
    _DhikrCategory('Dzikir Petang', 12, Icons.wb_twilight_outlined),
    _DhikrCategory('Setelah Shalat', 8, Icons.access_time_filled_rounded),
    _DhikrCategory('Doa Harian', 36, Icons.auto_awesome_rounded),
  ];

  static const _doa = [
    _Doa('Doa sebelum makan', 'اللَّهُمَّ بَارِكْ لَنَا',
        'Ya Allah, berkahilah kami...'),
    _Doa('Doa keluar rumah', 'بِسْمِ اللَّهِ تَوَكَّلْتُ',
        'Dengan nama Allah aku bertawakkal...'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final pct = math.min(1.0, _count / _target);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: 'Wirid & Doa',
              subtitle: 'Dzikir pengingat hati',
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildTasbih(context, c, pct),
                  _buildCategories(context, c),
                  _buildDoa(context, c),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasbih(BuildContext context, AppColors c, double pct) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        decoration: BoxDecoration(
          color: c.navy,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            // header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TASBIH DIGITAL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFC7D3E0),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppArabicText(
                        text: 'سُبْحَانَ اللَّهِ',
                        fontSize: 24,
                        color: c.gold,
                        textAlign: TextAlign.left,
                        height: 1.4,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Subhanallah — Maha Suci Allah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFFF1ECDD),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _count = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Reset',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // counter ring
            SizedBox(
              width: 168,
              height: 168,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(168, 168),
                    painter: _RingPainter(pct: pct, trackColor: Colors.white.withOpacity(0.12), fillColor: c.gold),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_count',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: c.gold,
                          letterSpacing: -1,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        '/ $_target',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFC7D3E0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // tap button
            GestureDetector(
              onTap: () => setState(() {
                _count = _count >= _target ? 0 : _count + 1;
              }),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: c.gold,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Tap untuk berdzikir',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.navy,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: 'Koleksi Dzikir'),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.7,
            children: _categories.map((cat) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.goldSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cat.icon, color: c.goldDeep, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                      ),
                    ),
                    Text(
                      '${cat.count} bacaan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: c.inkMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDoa(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: 'Doa Harian', action: 'Lihat semua'),
          ..._doa.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.hairline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: c.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AppArabicText(
                          text: d.arabic,
                          fontSize: 17,
                          color: c.gold,
                          textAlign: TextAlign.right,
                          height: 1.6,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.translation,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: c.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.chevron_right_rounded, color: c.inkMuted, size: 18),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final Color trackColor;
  final Color fillColor;
  const _RingPainter({required this.pct, required this.trackColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // fill arc
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * pct;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.pct != pct;
}

class _DhikrCategory {
  final String name;
  final int count;
  final IconData icon;
  const _DhikrCategory(this.name, this.count, this.icon);
}

class _Doa {
  final String name;
  final String arabic;
  final String translation;
  const _Doa(this.name, this.arabic, this.translation);
}
