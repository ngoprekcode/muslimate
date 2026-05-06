import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/features/location/logic/location_permission_provider.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

enum LocationFeature { kiblat, jadwal, masjid }

/// Reusable location-permission gate screen.
///
/// Shows one of three states — idle, denied, blocked — driven by
/// [LocationPermissionProvider].
class LocationPermissionScreen extends StatelessWidget {
  final LocationFeature feature;
  final ValueChanged<Position> onGranted;

  const LocationPermissionScreen({
    super.key,
    required this.feature,
    required this.onGranted,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocationPermissionProvider(),
      child: _LocationPermissionView(feature: feature, onGranted: onGranted),
    );
  }
}

// ---------------------------------------------------------------------------

class _LocationPermissionView extends StatelessWidget {
  final LocationFeature feature;
  final ValueChanged<Position> onGranted;

  const _LocationPermissionView({
    required this.feature,
    required this.onGranted,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<LocationPermissionProvider>().state;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(title: l10n.locPermScreenTitle),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Illustration(feature: feature, state: state),
                    const SizedBox(height: 28),
                    _FeatureCopy(feature: feature, state: state),
                    const SizedBox(height: 40),
                    _ActionButtons(
                      feature: feature,
                      state: state,
                      onGranted: onGranted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Illustration extends StatelessWidget {
  final LocationFeature feature;
  final LocationPermissionState state;

  const _Illustration({required this.feature, required this.state});

  IconData get _featureIcon => switch (feature) {
    LocationFeature.kiblat => Icons.explore_rounded,
    LocationFeature.jadwal => Icons.access_time_rounded,
    LocationFeature.masjid => Icons.mosque_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final (innerColor, icon, iconColor) = switch (state) {
      LocationPermissionState.denied => (
        c.goldDeep,
        Icons.location_off_rounded,
        c.surface,
      ),
      LocationPermissionState.blocked => (
        c.surfaceMuted,
        Icons.lock_outline_rounded,
        c.inkMuted,
      ),
      _ => (c.navy, _featureIcon, c.gold),
    };

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.surfaceAlt,
        border: Border.all(color: c.hairline, width: 1.5),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: innerColor,
            boxShadow: [
              BoxShadow(
                color: innerColor.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: state == LocationPermissionState.loading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: c.gold,
                    ),
                  )
                : Icon(icon, key: ValueKey(icon), color: iconColor, size: 32),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _FeatureCopy extends StatelessWidget {
  final LocationFeature feature;
  final LocationPermissionState state;

  const _FeatureCopy({required this.feature, required this.state});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final title = switch (state) {
      LocationPermissionState.denied => l10n.locPermDeniedTitle,
      LocationPermissionState.blocked => l10n.locPermBlockedTitle,
      _ => switch (feature) {
        LocationFeature.kiblat => l10n.locPermKiblatTitle,
        LocationFeature.jadwal => l10n.locPermJadwalTitle,
        LocationFeature.masjid => l10n.locPermMasjidTitle,
      },
    };

    final desc = switch (state) {
      LocationPermissionState.denied => l10n.locPermDeniedDesc,
      LocationPermissionState.blocked => l10n.locPermBlockedDesc,
      _ => switch (feature) {
        LocationFeature.kiblat => l10n.locPermKiblatDesc,
        LocationFeature.jadwal => l10n.locPermJadwalDesc,
        LocationFeature.masjid => l10n.locPermMasjidDesc,
      },
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Column(
        key: ValueKey('$state-$feature'),
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: c.ink,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: c.inkSoft,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  final LocationFeature feature;
  final LocationPermissionState state;
  final ValueChanged<Position> onGranted;

  const _ActionButtons({
    required this.feature,
    required this.state,
    required this.onGranted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<LocationPermissionProvider>();
    final isLoading = state == LocationPermissionState.loading;

    final primaryLabel = switch (state) {
      LocationPermissionState.denied => l10n.locPermRetryBtn,
      LocationPermissionState.blocked => l10n.locPermSettingsBtn,
      _ => l10n.locPermAllowBtn,
    };

    Future<void> handlePrimary() async {
      if (state == LocationPermissionState.blocked) {
        await provider.openSettings();
        // After returning from settings, reset so user can retry
        provider.reset();
        return;
      }
      final position = await provider.requestLocation();
      if (position != null) onGranted(position);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PrimaryButton(
          label: primaryLabel,
          isLoading: isLoading,
          onPressed: isLoading ? null : handlePrimary,
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: c.navy,
          foregroundColor: c.gold,
          disabledBackgroundColor: c.surfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('spinner'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.gold,
                  ),
                )
              : Text(
                  label,
                  key: ValueKey(label),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: c.gold,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }
}
