import 'package:flutter/material.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/generated/assets/assets.gen.dart';

enum HomePrayerType {
  dawn,
  noon,
  afternoon,
  sunset,
  night;

  static HomePrayerType fromPrayerType(String? type) {
    switch (type) {
      case 'fajr':
        return HomePrayerType.dawn;
      case 'dhuhr':
        return HomePrayerType.noon;
      case 'asr':
        return HomePrayerType.afternoon;
      case 'maghrib':
        return HomePrayerType.sunset;
      case 'isha':
        return HomePrayerType.night;
      default:
        return HomePrayerType.noon;
    }
  }

  SvgGenImage get background {
    switch (this) {
      case HomePrayerType.dawn:
        return AppAssets.images.bgDawn;
      case HomePrayerType.noon:
        return AppAssets.images.bgNoon;
      case HomePrayerType.afternoon:
        return AppAssets.images.bgAfternoon;
      case HomePrayerType.sunset:
        return AppAssets.images.bgSunset;
      case HomePrayerType.night:
        return AppAssets.images.bgNight;
    }
  }

  String get labelPrayer {
    switch (this) {
      case HomePrayerType.dawn:
        return 'Shubuh';
      case HomePrayerType.noon:
        return 'Dzuhur';
      case HomePrayerType.afternoon:
        return 'Ashar';
      case HomePrayerType.sunset:
        return 'Maghrib';
      case HomePrayerType.night:
        return 'Isya';
    }
  }

  Color colorMain(AppColors c) {
    switch (this) {
      case HomePrayerType.dawn:
      case HomePrayerType.sunset:
      case HomePrayerType.night:
        return c.surface;
      case HomePrayerType.noon:
      case HomePrayerType.afternoon:
        return c.ink;
    }
  }

  Color colorSecondary(AppColors c) {
    switch (this) {
      case HomePrayerType.dawn:
      case HomePrayerType.sunset:
      case HomePrayerType.night:
        return c.surfaceMuted;
      case HomePrayerType.noon:
      case HomePrayerType.afternoon:
        return c.ink;
    }
  }

  Color colorTimePrayer(AppColors c) {
    switch (this) {
      case HomePrayerType.dawn:
      case HomePrayerType.sunset:
      case HomePrayerType.night:
        return c.gold;
      case HomePrayerType.noon:
        return c.goldDeep;
      case HomePrayerType.afternoon:
        return c.ink;
    }
  }

  Color colorDivider(AppColors c) {
    switch (this) {
      case HomePrayerType.dawn:
      case HomePrayerType.sunset:
      case HomePrayerType.night:
        return c.surface;
      case HomePrayerType.noon:
      case HomePrayerType.afternoon:
        return c.ink;
    }
  }
}
