import 'package:flutter/material.dart';
import 'package:muslimate/features/home/ui/widgets/home_hero_card.dart';
import 'package:muslimate/features/home/ui/widgets/home_location_permission.dart';
import 'package:muslimate/features/location/logic/location_permission_provider.dart';
import 'package:muslimate/features/location/ui/location_permission_screen.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/core/logic/location_provider.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
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
    _initLocationListener();
  }

  void _initLocationListener() {
    final locPermissionProvider = context.read<LocationPermissionProvider>();
    if (locPermissionProvider.state == LocationPermissionState.granted) {
      _fetchLocation();
    }

    locPermissionProvider.addListener(_onPermissionChanged);
  }

  @override
  void dispose() {
    if (mounted) {
      context.read<LocationPermissionProvider>().removeListener(
        _onPermissionChanged,
      );
    }
    super.dispose();
  }

  void _onPermissionChanged() {
    if (!mounted) return;
    final state = context.read<LocationPermissionProvider>().state;
    if (state == LocationPermissionState.granted) {
      _fetchLocation();
    }
  }

  Future<void> _fetchLocation() async {
    final locProvider = context.read<LocationProvider>();
    if (locProvider.hasLocation) return;

    final position = await locProvider.fetchLocation();
    if (position != null && mounted) {
      context.read<PrayerProvider>().updateLocation(
        position.latitude,
        position.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locState = context.watch<LocationProvider>().state;
    final locPermissionState = context
        .watch<LocationPermissionProvider>()
        .state;

    switch (locPermissionState) {
      /// LocationPermission Check.
      case LocationPermissionState.idle:
      case LocationPermissionState.loading:
        return const _HomeHeaderSectionLoading();
      case LocationPermissionState.denied:
      case LocationPermissionState.blocked:
        return _HomeLocationPermission();
      case LocationPermissionState.granted:
        switch (locState) {
          /// LocationState (for get position and address detail)
          case LocationState.idle:
          case LocationState.loading:
            return const _HomeHeaderSectionLoading();
          case LocationState.done:
            return const HomeHeroCard();
          case LocationState.error:
            return _HomeLocationPermission();
        }
    }
  }
}

class _HomeLocationPermission extends StatelessWidget {
  const _HomeLocationPermission();

  @override
  Widget build(BuildContext context) {
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

class _HomeHeaderSectionLoading extends StatelessWidget {
  const _HomeHeaderSectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: AppShimmer(
        width: double.infinity,
        height: 180,
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    );
  }
}
