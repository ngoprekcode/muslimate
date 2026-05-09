import 'package:flutter/material.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/generated/assets/assets.gen.dart';

enum AppPrayerType {
  dawn,
  noon,
  afternoon,
  sunset,
  night;

  static AppPrayerType fromPrayerType(String? type) {
    switch (type) {
      case 'fajr':
        return AppPrayerType.dawn;
      case 'dhuhr':
        return AppPrayerType.noon;
      case 'asr':
        return AppPrayerType.afternoon;
      case 'maghrib':
        return AppPrayerType.sunset;
      case 'isha':
        return AppPrayerType.night;
      default:
        return AppPrayerType.noon;
    }
  }

  SvgGenImage get icon {
    switch (this) {
      case AppPrayerType.dawn:
        return AppAssets.icons.icDawn;
      case AppPrayerType.noon:
        return AppAssets.icons.icNoon;
      case AppPrayerType.afternoon:
        return AppAssets.icons.icAfternoon;
      case AppPrayerType.sunset:
        return AppAssets.icons.icSunset;
      case AppPrayerType.night:
        return AppAssets.icons.icNight;
    }
  }

  SvgGenImage get background {
    switch (this) {
      case AppPrayerType.dawn:
        return AppAssets.images.bgDawn;
      case AppPrayerType.noon:
        return AppAssets.images.bgNoon;
      case AppPrayerType.afternoon:
        return AppAssets.images.bgAfternoon;
      case AppPrayerType.sunset:
        return AppAssets.images.bgSunset;
      case AppPrayerType.night:
        return AppAssets.images.bgNight;
    }
  }

  String get labelPrayer {
    switch (this) {
      case AppPrayerType.dawn:
        return 'Shubuh';
      case AppPrayerType.noon:
        return 'Dzuhur';
      case AppPrayerType.afternoon:
        return 'Ashar';
      case AppPrayerType.sunset:
        return 'Maghrib';
      case AppPrayerType.night:
        return 'Isya';
    }
  }

  Color colorMain(AppColors c) {
    switch (this) {
      case AppPrayerType.dawn:
      case AppPrayerType.sunset:
      case AppPrayerType.night:
        return c.surface;
      case AppPrayerType.noon:
      case AppPrayerType.afternoon:
        return c.ink;
    }
  }

  Color colorSecondary(AppColors c) {
    switch (this) {
      case AppPrayerType.dawn:
      case AppPrayerType.sunset:
      case AppPrayerType.night:
        return c.surfaceMuted;
      case AppPrayerType.noon:
      case AppPrayerType.afternoon:
        return c.ink;
    }
  }

  Color colorTimePrayer(AppColors c) {
    switch (this) {
      case AppPrayerType.dawn:
      case AppPrayerType.sunset:
      case AppPrayerType.night:
        return c.gold;
      case AppPrayerType.noon:
        return c.goldDeep;
      case AppPrayerType.afternoon:
        return c.ink;
    }
  }

  Color colorDivider(AppColors c) {
    switch (this) {
      case AppPrayerType.dawn:
      case AppPrayerType.sunset:
      case AppPrayerType.night:
        return c.surface;
      case AppPrayerType.noon:
      case AppPrayerType.afternoon:
        return c.ink;
    }
  }
}
