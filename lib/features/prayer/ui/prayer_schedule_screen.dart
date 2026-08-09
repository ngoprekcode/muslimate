import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muslimate/core/logic/location_provider.dart';
import 'package:muslimate/features/location/ui/location_permission_screen.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'widgets/prayer_day_strip.dart';
import 'widgets/prayer_hijri_card.dart';
import 'widgets/prayer_list.dart';
import 'widgets/prayer_reminder_settings.dart';

class PrayerScheduleScreen extends StatefulWidget {
  const PrayerScheduleScreen({super.key});

  @override
  State<PrayerScheduleScreen> createState() => _PrayerScheduleScreenState();
}

class _PrayerScheduleScreenState extends State<PrayerScheduleScreen> {
  bool _isRefreshingLocation = false;

  Future<void> _refreshLocation() async {
    if (_isRefreshingLocation) return;
    setState(() => _isRefreshingLocation = true);

    final locationProvider = context.read<LocationProvider>();
    final prayerProvider = context.read<PrayerProvider>();
    final position = await locationProvider.fetchLocation();

    if (position != null) {
      await prayerProvider.updateLocation(
        position.latitude,
        position.longitude,
        address: locationProvider.address,
      );
    }

    if (!mounted) return;
    setState(() => _isRefreshingLocation = false);
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.prayerLocationRefreshFailed,
          ),
        ),
      );
    }
  }

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
              showBackButton: false,
              subtitle: _isRefreshingLocation
                  ? '...'
                  : prayerProvider.locationName,
              trailing: GestureDetector(
                onTap: _isRefreshingLocation ? null : _refreshLocation,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _isRefreshingLocation
                          ? SizedBox(
                              key: const ValueKey('location-loading'),
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: c.gold,
                              ),
                            )
                          : Icon(
                              Icons.location_on_outlined,
                              key: const ValueKey('location-icon'),
                              color: c.ink,
                              size: 18,
                            ),
                    ),
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
