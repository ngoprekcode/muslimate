import 'package:flutter/material.dart';
import 'package:muslimate/core/app_colors.dart';

class AppIconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? iconColor;
  final Color? bgColor;
  final double radius;

  const AppIconBox({
    super.key,
    required this.icon,
    this.size = 36,
    this.iconColor,
    this.bgColor,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor ?? c.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: iconColor ?? c.gold, size: size * 0.5),
    );
  }
}
