import 'package:flutter/material.dart';
import 'package:muslimate/generated/assets/assets.gen.dart';

class AppBrandMark extends StatelessWidget {
  final double size;
  final Color? color;

  const AppBrandMark({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return AppAssets.icons.icMuslimate.svg();
  }
}
