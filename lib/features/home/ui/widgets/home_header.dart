import 'package:flutter/material.dart';
import 'package:muslimate/features/location/logic/location_permission_provider.dart';
import 'package:muslimate/features/location/ui/location_permission_screen.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/features/qibla/logic/qibla_provider.dart';
import 'package:muslimate/core/logic/location_provider.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'package:provider/provider.dart';

import 'home_header_card.dart';
import 'home_header_loading.dart';
import 'home_header_permission.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late LocationPermissionProvider _locationPermissionProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocationListener();
    _checkInitialLocation();
  }

  void _initLocationListener() {
    _locationPermissionProvider = context.read<LocationPermissionProvider>();
    _locationPermissionProvider.addListener(_onPermissionChanged);
  }

  void _checkInitialLocation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_locationPermissionProvider.state == LocationPermissionState.granted) {
        _fetchLocation();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationPermissionProvider.removeListener(_onPermissionChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_locationPermissionProvider.state == LocationPermissionState.granted) {
        _fetchLocation();
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  void _onPermissionChanged() {
    if (!mounted) return;
    final state = _locationPermissionProvider.state;
    if (state == LocationPermissionState.granted) {
      _fetchLocation();
    }
  }

  Future<void> _fetchLocation() async {
    final locProvider = context.read<LocationProvider>();
    
    // If already has location and not in idle state, we skip redundant fetches.
    // But if it's idle and permission is granted, we MUST fetch.
    if (locProvider.hasLocation && locProvider.state != LocationState.idle) return;

    final position = await locProvider.fetchLocation();
    if (position != null && mounted) {
      context.read<PrayerProvider>().updateLocation(
        position.latitude,
        position.longitude,
        address: locProvider.address,
      );
      context.read<QiblaProvider>().updateLocation(
        position.latitude,
        position.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final locState = context.watch<LocationProvider>().state;
    final locPermissionState = context
        .watch<LocationPermissionProvider>()
        .state;

    Widget content;

    switch (locPermissionState) {
      case LocationPermissionState.loading:
        content = const HomeHeaderLoading(key: ValueKey('loading'));
        break;
      case LocationPermissionState.idle:
      case LocationPermissionState.denied:
      case LocationPermissionState.blocked:
        content = const _HomeLocationPermission(key: ValueKey('permission'));
        break;
      case LocationPermissionState.granted:
        switch (locState) {
          case LocationState.done:
            content = const HomeHeaderCard(key: ValueKey('hero'));
            break;
          case LocationState.error:
            content = const _HomeLocationPermission(key: ValueKey('error'));
            break;
          case LocationState.idle:
          case LocationState.loading:
            content = const HomeHeaderLoading(key: ValueKey('loading'));
            break;
        }
    }

    return AppAnimatedSwitcher(child: content);
  }
}

class _HomeLocationPermission extends StatelessWidget {
  const _HomeLocationPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeHeaderPermission(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationPermissionScreen(
              onGranted: (position) {
                final locProvider = context.read<LocationProvider>();
                locProvider.updatePosition(position);
                context.read<PrayerProvider>().updateLocation(
                  position.latitude,
                  position.longitude,
                  address: locProvider.address,
                );
                context.read<QiblaProvider>().updateLocation(
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
