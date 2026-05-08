import 'package:flutter/material.dart';
import 'package:muslimate/core/app_colors.dart';

enum AppPrayerTime { tahajjud, fajr, dhuhr, asr, maghrib, isha }

class AppPrayerIcon extends StatelessWidget {
  final AppPrayerTime prayer;
  final double size;
  final Color? color;

  const AppPrayerIcon({super.key, required this.prayer, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.of(context).gold;
    IconData icon;
    switch (prayer) {
      case AppPrayerTime.tahajjud:
        icon = Icons.bedtime_rounded;
        break;
      case AppPrayerTime.fajr:
        icon = Icons.wb_twilight_rounded;
        break;
      case AppPrayerTime.dhuhr:
        icon = Icons.wb_sunny_rounded;
        break;
      case AppPrayerTime.asr:
        icon = Icons.light_mode_outlined;
        break;
      case AppPrayerTime.maghrib:
        icon = Icons.wb_twilight_outlined;
        break;
      case AppPrayerTime.isha:
        icon = Icons.nights_stay_rounded;
        break;
    }
    return Icon(icon, color: c, size: size);
  }
}
