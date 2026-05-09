import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/generated/assets/assets.gen.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'package:prayers_times/prayers_times.dart';
import 'package:provider/provider.dart';

class PrayerList extends StatelessWidget {
  const PrayerList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();
    final pt = provider.prayerTimes;
    final now = DateTime.now();

    if (pt == null) return const SizedBox.shrink();
    final List<_PrayerItemData> items = [
      _PrayerItemData(
        'Tahajjud',
        provider.getTahajjudToday(),
        AppPrayerType.night,
      ),
      _PrayerItemData(
        AppPrayerType.dawn.labelPrayer,
        pt.fajrStartTime,
        AppPrayerType.dawn,
      ),
      _PrayerItemData('Terbit', pt.sunrise, AppPrayerType.dawn),
      _PrayerItemData(
        AppPrayerType.noon.labelPrayer,
        pt.dhuhrStartTime,
        AppPrayerType.noon,
      ),
      _PrayerItemData(
        AppPrayerType.afternoon.labelPrayer,
        pt.asrStartTime,
        AppPrayerType.afternoon,
      ),
      _PrayerItemData(
        AppPrayerType.sunset.labelPrayer,
        pt.maghribStartTime,
        AppPrayerType.sunset,
      ),
      _PrayerItemData(
        AppPrayerType.night.labelPrayer,
        pt.ishaStartTime,
        AppPrayerType.night,
      ),
    ];

    final List<DateTime> timeline = [
      ...items.where((e) => e.time != null).map((e) => e.time!.toLocal()),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(items.length, (i) {
          final p = items[i];
          final pTimeLocal = p.time?.toLocal();
          return _PrayerItemCard(
            data: p,
            isActive: pTimeLocal == absoluteNextTime,
            isNext: false,
            isPast: false,
            formattedTime: provider.formatTime(p.time),
          );
        }),
      ),
    );
  }
}

class _PrayerItemCard extends StatelessWidget {
  final _PrayerItemData data;
  final bool isActive;
  final bool isNext;
  final bool isPast;
  final String formattedTime;

  const _PrayerItemCard({
    required this.data,
    required this.isActive,
    required this.isNext,
    required this.isPast,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

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
                color: isActive ? c.gold.withValues(alpha: 0.18) : c.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: data.type.icon.svg(
                  height: 20,
                  colorFilter: ColorFilter.mode(c.gold, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : c.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'statusLabel',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isActive
                          ? Colors.white
                          : (isNext ? c.gold : c.inkMuted),
                      fontWeight: isNext ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formattedTime,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isActive ? c.gold : c.ink,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c.goldSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.goldSoft),
              ),
              child: Center(
                child: AppAssets.icons.icNotification.svg(
                  width: 15,
                  colorFilter: ColorFilter.mode(c.goldDeep, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerItemData {
  final String name;
  final DateTime? time;
  final AppPrayerType type;
  _PrayerItemData(this.name, this.time, this.type);
}
