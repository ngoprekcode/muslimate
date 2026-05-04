import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  static const double _kiblatBearing = 295.0;
  double _heading = 28.0;
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    // Simulate compass heading drift
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      setState(() {
        _heading = (_heading + (math.Random().nextDouble() - 0.45) * 1.6 + 360) % 360;
      });
      return true;
    });
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  double get _delta {
    final d = ((_kiblatBearing - _heading + 540) % 360) - 180;
    return d;
  }

  bool get _aligned => _delta.abs() < 4;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: 'Cek Kiblat',
              subtitle: 'Arahkan ponsel Anda',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: c.gold, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Bandung, Jawa Barat • 295° dari Utara',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: c.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildCompass(context, c),
            const SizedBox(height: 24),
            _buildStatus(context, c),
            const SizedBox(height: 20),
            _buildTip(context, c),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(BuildContext context, AppColors c) {
    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // glow ring when aligned
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _aligned
                    ? RadialGradient(colors: [
                        c.goldSoft.withOpacity(0.6),
                        Colors.transparent,
                      ])
                    : null,
              ),
            ),
            // outer ring
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surface,
                border: Border.all(color: c.hairline),
              ),
            ),
            // rotating tick marks and labels
            Transform.rotate(
              angle: -_heading * math.pi / 180,
              child: CustomPaint(
                size: const Size(280, 280),
                painter: _CompassFacePainter(
                  tickColor: c.hairline,
                  majorColor: c.gold,
                  labelColor: c.inkMuted,
                  northColor: c.gold,
                  kiblatBearing: _kiblatBearing,
                  kiblatColor: c.gold,
                  kiblatNavyColor: c.navy,
                  headingForLabels: _heading,
                ),
              ),
            ),
            // fixed needle (points to top = current forward direction)
            Positioned(
              top: 12,
              child: Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [c.gold, c.goldDeep],
                  ),
                ),
              ),
            ),
            // center dot with kaaba icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.navy,
                boxShadow: [
                  BoxShadow(
                    color: c.navy.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(Icons.explore_rounded, color: c.gold, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(BuildContext context, AppColors c) {
    final aligned = _aligned;
    final deg = _delta.abs().round();
    final dir = _delta > 0 ? 'ke kanan' : 'ke kiri';

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: AppPill(
            key: ValueKey(aligned),
            text: aligned ? '✓ Lurus ke Kiblat' : '$deg° $dir',
            tone: aligned ? AppPillTone.gold : AppPillTone.muted,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            "Putar ponsel perlahan hingga Ka'bah berada di puncak penanda emas.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: c.inkSoft,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTip(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.hairline),
        ),
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: c.inkSoft,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: 'Tips kalibrasi: ',
                style: TextStyle(color: c.ink, fontWeight: FontWeight.w600),
              ),
              const TextSpan(
                text:
                    'jauhkan dari benda logam, gerakkan ponsel membentuk angka 8 untuk akurasi terbaik.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassFacePainter extends CustomPainter {
  final Color tickColor;
  final Color majorColor;
  final Color labelColor;
  final Color northColor;
  final double kiblatBearing;
  final Color kiblatColor;
  final Color kiblatNavyColor;
  final double headingForLabels;

  _CompassFacePainter({
    required this.tickColor,
    required this.majorColor,
    required this.labelColor,
    required this.northColor,
    required this.kiblatBearing,
    required this.kiblatColor,
    required this.kiblatNavyColor,
    required this.headingForLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const r2 = 138.0;

    // tick marks
    for (int i = 0; i < 72; i++) {
      final major = i % 9 == 0;
      final a = i * 360 / 72 * math.pi / 180;
      final r1 = major ? 124.0 : 130.0;
      final x1 = center.dx + math.sin(a) * r1;
      final y1 = center.dy - math.cos(a) * r1;
      final x2 = center.dx + math.sin(a) * r2;
      final y2 = center.dy - math.cos(a) * r2;

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = major ? majorColor : tickColor
          ..strokeWidth = major ? 2 : 1,
      );
    }

    // cardinal labels (counter-rotate to stay upright)
    final cardinals = [
      ('U', 0.0, northColor),
      ('T', 90.0, labelColor),
      ('S', 180.0, labelColor),
      ('B', 270.0, labelColor),
    ];

    final textStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );

    for (final (label, bearing, color) in cardinals) {
      final a = bearing * math.pi / 180;
      final x = center.dx + math.sin(a) * 108;
      final y = center.dy - math.cos(a) * 108;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(headingForLabels * math.pi / 180);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: textStyle.copyWith(color: color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Kiblat marker
    final ka = kiblatBearing * math.pi / 180;
    final kx = center.dx + math.sin(ka) * 108;
    final ky = center.dy - math.cos(ka) * 108;

    canvas.save();
    canvas.translate(kx, ky);
    canvas.rotate(headingForLabels * math.pi / 180);

    // gold circle
    canvas.drawCircle(
      Offset.zero,
      18,
      Paint()..color = kiblatColor,
    );

    // simple kaaba square
    final kPaint = Paint()
      ..color = kiblatNavyColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, -5, 20, 14),
        const Radius.circular(1),
      ),
      kPaint,
    );

    // roof lines
    final roofPaint = Paint()
      ..color = kiblatColor.withOpacity(0.8)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final roofPath = Path()
      ..moveTo(-12, -5)
      ..lineTo(0, -10)
      ..lineTo(12, -5);
    canvas.drawPath(roofPath, roofPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CompassFacePainter old) => true;
}
