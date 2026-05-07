import 'package:flutter/material.dart';
import 'package:muslimate/features/home/ui/widgets/home_hero_card.dart';
import 'package:muslimate/features/home/ui/widgets/home_location_permission.dart';
import 'package:muslimate/features/location/logic/location_permission_provider.dart';
import 'package:muslimate/features/location/ui/location_permission_screen.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/core/logic/location_provider.dart';
import 'package:provider/provider.dart';

class HomeHeaderSection extends StatefulWidget {
  const HomeHeaderSection({super.key});

  @override
  State<HomeHeaderSection> createState() => _HomeHeaderSectionState();
}

class _HomeHeaderSectionState extends State<HomeHeaderSection> {
  @override
  void initState() {
    super.initState();
    _autoFetchIfGranted();
  }

  void _autoFetchIfGranted() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final locProvider = context.read<LocationPermissionProvider>();
      if (locProvider.state == LocationPermissionState.granted) {
        _fetchLocation();
      }
    });
  }

  Future<void> _fetchLocation() async {
    final position = await context.read<LocationProvider>().fetchLocation();
    if (position != null && mounted) {
      context.read<PrayerProvider>().updateLocation(
        position.latitude,
        position.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locState = context.watch<LocationPermissionProvider>().state;

    if (locState == LocationPermissionState.granted) {
      return const HomeHeroCard();
    }

    if (locState == LocationPermissionState.loading) {
      // Placeholder while potentially requesting or checking
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return HomeLocationPermission(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationPermissionScreen(
              feature: LocationFeature.jadwal,
              onGranted: (position) {
                context.read<LocationProvider>().updatePosition(position);
                context.read<PrayerProvider>().updateLocation(
                  position.latitude,
                  position.longitude,
                );
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}
