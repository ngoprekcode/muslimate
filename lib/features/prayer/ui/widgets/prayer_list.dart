import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'package:prayers_times/prayers_times.dart';
import 'package:provider/provider.dart';

class PrayerList extends StatelessWidget {
  const PrayerList({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final provider = context.watch<PrayerProvider>();
    final pt = provider.prayerTimes;
    
    if (pt == null) return const SizedBox.shrink();

    final now = DateTime.now();
    
    // 1. Ambil Tahajjud dini hari untuk TANGGAL YANG DIPILIH
    final tahajjudThisDate = provider.getTahajjudToday();

    final List<_PrayerItemData> items = [
      _PrayerItemData('Tahajjud', tahajjudThisDate, AppPrayerTime.tahajjud),
      _PrayerItemData('Subuh', pt.fajrStartTime, AppPrayerTime.fajr),
      _PrayerItemData('Terbit', pt.sunrise, AppPrayerTime.dhuhr),
      _PrayerItemData('Dzuhur', pt.dhuhrStartTime, AppPrayerTime.dhuhr),
      _PrayerItemData('Ashar', pt.asrStartTime, AppPrayerTime.asr),
      _PrayerItemData('Maghrib', pt.maghribStartTime, AppPrayerTime.maghrib),
      _PrayerItemData('Isya', pt.ishaStartTime, AppPrayerTime.isha),
    ];

    // Logika pencarian "Sekarang" dan "Berikutnya" secara GLOBAL (lintas hari)
    final tomorrowPT = PrayerTimes(
      coordinates: provider.coordinates!,
      calculationParameters: provider.params,
      dateTime: now.add(const Duration(days: 1)),
      locationName: 'Asia/Jakarta',
    );
    final tahajjudTomorrow = SunnahInsights(tomorrowPT).lastThirdOfTheNight;

    final List<DateTime> timeline = [
      ...items.where((e) => e.time != null).map((e) => e.time!.toLocal()),
      tahajjudTomorrow!.toLocal(),
    ]..sort();

    final absoluteNextTime = timeline.firstWhere(
      (t) => t.isAfter(now),
      orElse: () => now,
    );
    final absoluteCurrentTime = timeline.lastWhere(
      (t) => t.isBefore(now),
      orElse: () => now,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: List.generate(items.length, (i) {
          final p = items[i];
          final pTimeLocal = p.time?.toLocal();

          bool isActive = pTimeLocal == absoluteCurrentTime;
          bool isNext = pTimeLocal == absoluteNextTime;
          bool isPast = pTimeLocal != null && pTimeLocal.isBefore(absoluteCurrentTime);

          String statusLabel = 'Mendatang';
          if (isActive) {
            statusLabel = 'Sekarang';
          } else if (isNext) {
            final diff = pTimeLocal!.difference(now);
            statusLabel = diff.inHours >= 1
                ? '${diff.inHours} jam lagi'
                : '${diff.inMinutes} menit lagi';
          } else if (isPast) {
            statusLabel = 'Sudah lewat';
          }

          return Opacity(
            opacity: (isPast && !isActive) ? 0.55 : 1.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: isActive ? c.navy : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive ? c.gold.withOpacity(0.18) : c.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: AppPrayerIcon(
                        prayer: p.icon,
                        size: 20,
                        color: c.gold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : c.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statusLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: isActive
                                ? const Color(0xFFC7D3E0)
                                : (isNext ? c.gold : c.inkMuted),
                            fontWeight: isNext
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    provider.formatTime(p.time),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isActive ? c.gold : c.ink,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 15,
                    color: isActive ? c.gold : c.inkMuted,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PrayerItemData {
  final String name;
  final DateTime? time;
  final AppPrayerTime icon;
  _PrayerItemData(this.name, this.time, this.icon);
}
