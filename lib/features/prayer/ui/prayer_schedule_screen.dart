import 'package:prayers_times/prayers_times.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muslimate/features/location/ui/location_permission_screen.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class PrayerScheduleScreen extends StatelessWidget {
  const PrayerScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final prayerProvider = context.watch<PrayerProvider>();

    if (prayerProvider.coordinates == null) {
      return LocationPermissionScreen(
        feature: LocationFeature.jadwal,
        onGranted: (pos) {
          prayerProvider.updateLocation(
            pos.latitude,
            pos.longitude,
          );
        },
      );
    }

    final pt = prayerProvider.prayerTimes;

    if (pt == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: 'Jadwal Shalat',
              subtitle: prayerProvider.locationName,
              trailing: GestureDetector(
                onTap: () async {
                  try {
                    final pos = await Geolocator.getCurrentPosition();
                    prayerProvider.updateLocation(
                      pos.latitude,
                      pos.longitude,
                    );
                  } catch (_) {}
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: c.ink,
                    size: 18,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildDayStrip(context, c, prayerProvider),
                  _buildHijriCard(context, c),
                  _buildPrayerList(context, c, pt, prayerProvider),
                  _buildReminderSettings(context, c),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayStrip(
    BuildContext context,
    AppColors c,
    PrayerProvider provider,
  ) {
    final now = DateTime.now();
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final date = now.add(Duration(days: i - 2));
          final isSelected = DateUtils.isSameDay(date, provider.selectedDate);

          return GestureDetector(
            onTap: () => provider.updateDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              decoration: BoxDecoration(
                color: isSelected ? c.navy : c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? c.navy : c.hairline),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : c.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? c.gold : c.ink,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHijriCard(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.goldSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: c.goldDeep,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TANGGAL HIJRIAH',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: c.inkMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Jadwal Otomatis (Prayers Times)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.ink,
                    ),
                  ),
                ],
              ),
            ),
            const AppPill(text: 'Live', tone: AppPillTone.gold),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerList(
    BuildContext context,
    AppColors c,
    PrayerTimes pt,
    PrayerProvider provider,
  ) {
    final now = DateTime.now();
    final isSelectedToday = DateUtils.isSameDay(provider.selectedDate, now);

    // 1. Ambil Tahajjud dini hari untuk TANGGAL YANG DIPILIH
    final tahajjudThisDate = provider.getTahajjudToday();

    final List<_PrayerItem> items = [
      _PrayerItem('Tahajjud', tahajjudThisDate, AppPrayerTime.tahajjud),
      _PrayerItem('Subuh', pt.fajrStartTime, AppPrayerTime.fajr),
      _PrayerItem('Terbit', pt.sunrise, AppPrayerTime.dhuhr),
      _PrayerItem('Dzuhur', pt.dhuhrStartTime, AppPrayerTime.dhuhr),
      _PrayerItem('Ashar', pt.asrStartTime, AppPrayerTime.asr),
      _PrayerItem('Maghrib', pt.maghribStartTime, AppPrayerTime.maghrib),
      _PrayerItem('Isya', pt.ishaStartTime, AppPrayerTime.isha),
    ];

    // Logika pencarian "Sekarang" dan "Berikutnya" secara GLOBAL (lintas hari)
    // 1. Cari shalat terakhir yang sudah dimulai sebelum 'now'
    // 2. Cari shalat pertama yang akan dimulai setelah 'now'

    // Kita butuh pembanding: Shalat berikutnya yang mutlak (bisa hari ini, bisa besok)
    final tomorrowPT = PrayerTimes(
      coordinates: provider.coordinates!,
      calculationParameters: provider.params,
      dateTime: now.add(const Duration(days: 1)),
      locationName: 'Asia/Jakarta',
    );
    final tahajjudTomorrow = SunnahInsights(tomorrowPT).lastThirdOfTheNight;

    // Gabungkan list untuk mencari shalat Aktif & Berikutnya secara global
    // (Bisa diperluas ke kemarin & besok jika perlu, tapi hari ini + besok cukup untuk case Isya)
    final List<DateTime> timeline = [
      ...items.map((e) => e.time!.toLocal()),
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
          final pTimeLocal = p.time!.toLocal();

          bool isActive = pTimeLocal == absoluteCurrentTime;
          bool isNext = pTimeLocal == absoluteNextTime;
          bool isPast = pTimeLocal.isBefore(absoluteCurrentTime);

          String statusLabel = 'Mendatang';
          if (isActive) {
            statusLabel = 'Sekarang';
          } else if (isNext) {
            final diff = pTimeLocal.difference(now);
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

  Widget _buildReminderSettings(BuildContext context, AppColors c) {
    final rows = [
      ('Calculation Method', 'Singapore (MUIS)'),
      ('Asr Madhab', 'Shafi'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: 'Settings'),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.hairline),
            ),
            child: Column(
              children: List.generate(rows.length, (i) {
                return Container(
                  decoration: BoxDecoration(
                    border: i < rows.length - 1
                        ? Border(bottom: BorderSide(color: c.hairline))
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            rows[i].$1,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: c.ink,
                            ),
                          ),
                        ),
                        Text(
                          rows[i].$2,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: c.inkSoft,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: c.inkMuted,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerItem {
  final String name;
  final DateTime? time;
  final AppPrayerTime icon;
  _PrayerItem(this.name, this.time, this.icon);
}
