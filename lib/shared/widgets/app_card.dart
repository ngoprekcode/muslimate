import 'package:flutter/material.dart';
import 'package:muslimate/core/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: c.hairline),
      ),
      child: child,
    );
  }
}
