import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muslimate/features/location/ui/location_permission_screen.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'widgets/prayer_day_strip.dart';
import 'widgets/prayer_hijri_card.dart';
import 'widgets/prayer_list.dart';
import 'widgets/prayer_reminder_settings.dart';

class PrayerScheduleScreen extends StatelessWidget {
  const PrayerScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final prayerProvider = context.watch<PrayerProvider>();

    if (prayerProvider.coordinates == null) {
      return LocationPermissionScreen(
        hideAppBar: true,
        onGranted: (pos) {
          prayerProvider.updateLocation(pos.latitude, pos.longitude);
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
                    prayerProvider.updateLocation(pos.latitude, pos.longitude);
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
                children: const [
                  PrayerDayStrip(),
                  SizedBox(height: 8),
                  PrayerHijriCard(),
                  SizedBox(height: 16),
                  PrayerList(),
                  SizedBox(height: 12),
                  PrayerReminderSettings(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
