import 'package:flutter/material.dart';

class AppBrandArchPainter extends CustomPainter {
  final Color color;
  AppBrandArchPainter(this.color);

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
  bool shouldRepaint(AppBrandArchPainter old) => old.color != color;
}
