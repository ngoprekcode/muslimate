import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/data/prayer_notification_scheduler.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/generated/assets/assets.gen.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
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
        provider.isReminderEnabled(PrayerReminderType.tahajjud),
        'Tahajjud',
        provider.getTahajjudToday(),
        AppPrayerType.night,
        PrayerReminderType.tahajjud,
      ),
      _PrayerItemData(
        provider.isReminderEnabled(PrayerReminderType.fajr),
        AppPrayerType.dawn.labelPrayer,
        pt.fajrStartTime,
        AppPrayerType.dawn,
        PrayerReminderType.fajr,
      ),
      _PrayerItemData(
        provider.isReminderEnabled(PrayerReminderType.sunrise),
        'Terbit',
        pt.sunrise,
        AppPrayerType.dawn,
        PrayerReminderType.sunrise,
      ),
      _PrayerItemData(
        provider.isReminderEnabled(PrayerReminderType.dhuhr),
        AppPrayerType.noon.labelPrayer,
        pt.dhuhrStartTime,
        AppPrayerType.noon,
        PrayerReminderType.dhuhr,
      ),
      _PrayerItemData(
        provider.isReminderEnabled(PrayerReminderType.asr),
        AppPrayerType.afternoon.labelPrayer,
        pt.asrStartTime,
        AppPrayerType.afternoon,
        PrayerReminderType.asr,
      ),
      _PrayerItemData(
        provider.isReminderEnabled(PrayerReminderType.maghrib),
        AppPrayerType.sunset.labelPrayer,
        pt.maghribStartTime,
        AppPrayerType.sunset,
        PrayerReminderType.maghrib,
      ),
      _PrayerItemData(
        provider.isReminderEnabled(PrayerReminderType.isha),
        AppPrayerType.night.labelPrayer,
        pt.ishaStartTime,
        AppPrayerType.night,
        PrayerReminderType.isha,
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

    final isToday = DateUtils.isSameDay(provider.selectedDate, now);
    final isPastDay = provider.selectedDate.isBefore(
      DateTime(now.year, now.month, now.day),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(items.length, (i) {
          final p = items[i];
          final pTime = p.time?.toLocal();
          return _PrayerItemCard(
            data: p,
            isActive: isToday && pTime == absoluteCurrentTime,
            isNext: isToday && pTime == absoluteNextTime,
            isPast: pTime != null
                ? pTime.isBefore(absoluteCurrentTime) || isPastDay
                : true,
            formattedTime: provider.formatTime(p.time),
            onReminderTap: () => provider.toggleReminder(p.reminderType),
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
  final VoidCallback onReminderTap;

  const _PrayerItemCard({
    required this.data,
    required this.isActive,
    required this.isNext,
    required this.isPast,
    required this.formattedTime,
    required this.onReminderTap,
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
                      color: isActive ? AppColors.light.surface : c.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    () {
                      if (isActive) return 'Sekarang';
                      if (isNext) {
                        final now = DateTime.now();
                        final diff = data.time?.toLocal().difference(now);
                        if (diff != null) {
                          if (diff.inHours >= 1) {
                            return '${diff.inHours} jam lagi';
                          } else if (diff.inMinutes > 0) {
                            return '${diff.inMinutes} menit lagi';
                          }
                        }
                        return 'Berikutnya';
                      }
                      if (isPast) return 'Sudah lewat';
                      return 'Mendatang';
                    }(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isActive
                          ? AppColors.light.surface
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
            Semantics(
              button: true,
              toggled: data.isReminder,
              label: '${data.name} reminder',
              child: IconButton(
                onPressed: onReminderTap,
                tooltip: '${data.name} reminder',
                style: IconButton.styleFrom(
                  backgroundColor: data.isReminder
                      ? c.goldSoft
                      : Colors.transparent,
                  side: BorderSide(color: c.goldSoft),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: AppAssets.icons.icNotification.svg(
                  width: 15,
                  colorFilter: ColorFilter.mode(
                    data.isReminder ? c.goldDeep : c.inkMuted,
                    BlendMode.srcIn,
                  ),
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
  final bool isReminder;
  final String name;
  final DateTime? time;
  final AppPrayerType type;
  final PrayerReminderType reminderType;
  _PrayerItemData(
    this.isReminder,
    this.name,
    this.time,
    this.type,
    this.reminderType,
  );
}
