import 'package:flutter/material.dart';
import 'package:muslimate/core/app_colors.dart';

class AppBrandMark extends StatelessWidget {
  final double size;
  final Color? color;

  const AppBrandMark({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.of(context).gold;
    return CustomPaint(
      size: Size(size, size),
      painter: _BrandMarkPainter(c),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  final Color color;
  _BrandMarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * s
      ..strokeCap = StrokeCap.round;

    // outer circle
    paint.color = color.withOpacity(0.35);
    canvas.drawCircle(Offset(24 * s, 24 * s), 22 * s, paint);
    paint.color = color;

    // dome arch
    final domePath = Path()
      ..moveTo(16 * s, 32 * s)
      ..lineTo(16 * s, 22 * s)
      ..arcToPoint(Offset(32 * s, 22 * s),
          radius: Radius.circular(8 * s), clockwise: false)
      ..lineTo(32 * s, 32 * s);
    canvas.drawPath(domePath, paint);

    // base line
    canvas.drawLine(Offset(14 * s, 32 * s), Offset(34 * s, 32 * s), paint);

    // door arch
    final doorPath = Path()
      ..moveTo(21 * s, 32 * s)
      ..lineTo(21 * s, 28 * s)
      ..arcToPoint(Offset(27 * s, 28 * s),
          radius: Radius.circular(3 * s), clockwise: false)
      ..lineTo(27 * s, 32 * s);
    canvas.drawPath(doorPath, paint);

    // minaret top
    canvas.drawLine(Offset(24 * s, 14 * s), Offset(24 * s, 11 * s), paint);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(24 * s, 10 * s), 1.4 * s, paint);
  }

  @override
  bool shouldRepaint(_BrandMarkPainter old) => old.color != color;
}
