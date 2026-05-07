import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class HomePrayerRail extends StatelessWidget {
  const HomePrayerRail({super.key});

  static const _prayers = [
    _Prayer('Subuh', '04:32', AppPrayerTime.fajr, false),
    _Prayer('Dzuhur', '11:58', AppPrayerTime.dhuhr, true),
    _Prayer('Ashar', '15:21', AppPrayerTime.asr, false),
    _Prayer('Maghrib', '17:54', AppPrayerTime.maghrib, false),
    _Prayer('Isya', '19:06', AppPrayerTime.isha, false),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: _prayers.map((p) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: p == _prayers.last ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: p.active ? c.goldSoft : c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.active ? c.goldSoft : c.hairline),
              ),
              child: Column(
                children: [
                  AppPrayerIcon(
                    prayer: p.prayerTime,
                    size: 20,
                    color: p.active ? c.goldDeep : c.inkSoft,
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
  final AppPrayerTime prayerTime;
  final bool active;
  const _Prayer(this.name, this.time, this.prayerTime, this.active);
}
