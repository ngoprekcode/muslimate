import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/generated/assets/assets.gen.dart';

enum HomePrayerType {
  dawn,
  noon,
  afternoon,
  sunset,
  night;

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

  Color color(AppColors c) {
    switch (this) {
      case HomePrayerType.dawn:
        return c.ink;
      case HomePrayerType.noon:
        return c.ink;
      case HomePrayerType.afternoon:
        return c.ink;
      case HomePrayerType.sunset:
        return c.ink;
      case HomePrayerType.night:
        return c.ink;
    }
  }
}

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final type = HomePrayerType.noon;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
        child: Stack(
          children: [
            Positioned.fill(child: type.background.svg(fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppAssets.icons.icLocation.svg(
                        height: 13,
                        colorFilter: ColorFilter.mode(
                          c.ink.withValues(alpha: 0.78),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Buah Batu, Bandung',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: c.ink.withValues(alpha: 0.78),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Shalat berikutnya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: c.ink.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Dzuhur',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: c.ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '11:58',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: c.goldDeep,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: c.ink.withValues(alpha: 0.14)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tersisa',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: c.ink.withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '02:14:08',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: c.ink,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: c.ink.withValues(alpha: 0.14),
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hijriah',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: c.ink.withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '14 Syawal 1447',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: c.ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
