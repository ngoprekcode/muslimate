import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/generated/assets/assets.gen.dart';
import 'package:muslimate/shared/models/app_prayer_type.dart';
import 'package:provider/provider.dart';
import 'package:prayers_times/prayers_times.dart';

class HomePrayerRail extends StatelessWidget {
  const HomePrayerRail({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final prayerProvider = context.watch<PrayerProvider>();
    final prayerTimes = prayerProvider.prayerTimes;
    final nextPrayer = prayerProvider.getNextPrayer();

    final prayers = [
      _Prayer(
        AppPrayerType.dawn.labelPrayer,
        prayerProvider.formatTime(prayerTimes?.fajrStartTime),
        AppAssets.icons.icDawn,
        nextPrayer == PrayerType.fajr,
      ),
      _Prayer(
        AppPrayerType.noon.labelPrayer,
        prayerProvider.formatTime(prayerTimes?.dhuhrStartTime),
        AppAssets.icons.icNoon,
        nextPrayer == PrayerType.dhuhr,
      ),
      _Prayer(
        AppPrayerType.afternoon.labelPrayer,
        prayerProvider.formatTime(prayerTimes?.asrStartTime),
        AppAssets.icons.icAfternoon,
        nextPrayer == PrayerType.asr,
      ),
      _Prayer(
        AppPrayerType.sunset.labelPrayer,
        prayerProvider.formatTime(prayerTimes?.maghribStartTime),
        AppAssets.icons.icSunset,
        nextPrayer == PrayerType.maghrib,
      ),
      _Prayer(
        AppPrayerType.night.labelPrayer,
        prayerProvider.formatTime(prayerTimes?.ishaStartTime),
        AppAssets.icons.icNight,
        nextPrayer == PrayerType.isha,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: prayers.map((p) {
          final isLast = p == prayers.last;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: p.active ? c.goldSoft : c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.active ? c.goldSoft : c.hairline),
              ),
              child: Column(
                children: [
                  p.icon.svg(
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      p.active ? c.goldDeep : c.inkSoft,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: p.active ? c.goldDeep : c.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.time,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: p.active ? c.goldDeep : c.ink,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Prayer {
  final String name;
  final String time;
  final SvgGenImage icon;
  final bool active;
  const _Prayer(this.name, this.time, this.icon, this.active);
}
