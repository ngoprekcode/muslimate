import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muslimate/generated/assets/assets.gen.dart';
import 'package:provider/provider.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/features/location/logic/location_permission_provider.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

/// Reusable location-permission gate screen.
///
/// Shows one of three states — idle, denied, blocked — driven by
/// [LocationPermissionProvider].
class LocationPermissionScreen extends StatelessWidget {
  final bool hideAppBar;
  final ValueChanged<Position> onGranted;

  const LocationPermissionScreen({
    super.key,
    required this.onGranted,
    this.hideAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return _LocationPermissionView(
      onGranted: onGranted,
      hideAppBar: hideAppBar,
    );
  }
}

// ---------------------------------------------------------------------------

class _LocationPermissionView extends StatefulWidget {
  final bool hideAppBar;
  final ValueChanged<Position> onGranted;

  const _LocationPermissionView({
    required this.onGranted,
    required this.hideAppBar,
  });

  @override
  State<_LocationPermissionView> createState() =>
      _LocationPermissionViewState();
}

class _LocationPermissionViewState extends State<_LocationPermissionView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final provider = context.read<LocationPermissionProvider>();
      // Jika statusnya blocked atau denied, cek ulang saat kembali ke aplikasi
      if (provider.state == LocationPermissionState.blocked ||
          provider.state == LocationPermissionState.denied) {
        _handleResumeStatus(provider);
      }
    }
  }

  Future<void> _handleResumeStatus(LocationPermissionProvider provider) async {
    await provider.checkPermissionStatus();
    if (provider.state != LocationPermissionState.blocked &&
        provider.state != LocationPermissionState.denied) {
      // Jika sudah tidak diblokir/denied, coba request lokasi (untuk popup atau ambil pos)
      final pos = await provider.requestLocation();
      if (pos != null && mounted) {
        widget.onGranted(pos);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<LocationPermissionProvider>().state;

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _ActionButtons(onGranted: widget.onGranted, state: state),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.hideAppBar)
              AppScreenHeader(
                title: l10n.locPermScreenTitle,
                subtitle: 'Arahkan ponsel Anda',
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _Illustration(state: state),
                              const SizedBox(height: 16),
                              _FeatureChip(state: state),
                              const SizedBox(height: 12),
                              _FeatureCopy(state: state),
                              const SizedBox(height: 12),
                              AppInfoListCard(
                                children: [
                                  AppInfoItem(
                                    isPrimary: true,
                                    text: l10n.locPermDataMatching,
                                  ),
                                  Divider(color: c.hairline),
                                  AppInfoItem(
                                    isPrimary: true,
                                    text: l10n.locPermOnlyActive,
                                  ),
                                  Divider(color: c.hairline),
                                  AppInfoItem(
                                    isPrimary: true,
                                    text: l10n.locPermNeverShared,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
  final LocationPermissionState state;
  const _Illustration({required this.state});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (innerColor, icon, iconColor) = switch (state) {
      LocationPermissionState.denied => (
        isDark ? c.surfaceAlt : c.ink,
        Icons.location_off_rounded,
        c.gold,
      ),
      LocationPermissionState.blocked => (
        c.surfaceMuted,
        Icons.lock_outline_rounded,
        c.inkMuted,
      ),
      _ => (isDark ? c.surfaceAlt : c.ink, Icons.location_on_outlined, c.gold),
    };

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: c.hairline.withValues(alpha: 0.35), width: 1),
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: c.hairline.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surfaceAlt,
                border: Border.all(
                  color: c.hairline.withValues(alpha: 0.65),
                  width: 1,
                ),
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
                        color: iconColor.withValues(alpha: 0.55),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: state == LocationPermissionState.loading
                        ? SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: c.gold,
                            ),
                          )
                        : Icon(
                            icon,
                            key: ValueKey(icon),
                            color: iconColor,
                            size: 32,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final LocationPermissionState state;
  const _FeatureChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final l10n = AppLocalizations.of(context)!;

    final label = switch (state) {
      LocationPermissionState.denied => l10n.locPermPreviouslyDenied,
      LocationPermissionState.blocked => l10n.locPermBlockedInSystem,
      _ => l10n.locPermRequired,
    };

    final (backgroundColor, textColor) = switch (state) {
      LocationPermissionState.denied => (c.surfaceMuted, c.inkSoft),
      LocationPermissionState.blocked => (c.surfaceMuted, c.inkSoft),
      _ => (c.goldSoft, c.goldDeep),
    };

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: backgroundColor,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _FeatureCopy extends StatelessWidget {
  final LocationPermissionState state;

  const _FeatureCopy({required this.state});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final title = switch (state) {
      LocationPermissionState.denied => l10n.locPermStillNeeded,
      LocationPermissionState.blocked => l10n.locPermAccessBlocked,
      _ => l10n.locPermEnableAccess,
    };

    final desc = switch (state) {
      LocationPermissionState.denied => l10n.locPermDeniedDesc,
      LocationPermissionState.blocked => l10n.locPermBlockedDesc,
      _ => l10n.locPermEnabledDesc,
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Column(
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
          const SizedBox(height: 6),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
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
  final LocationPermissionState state;
  final ValueChanged<Position> onGranted;

  const _ActionButtons({required this.state, required this.onGranted});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<LocationPermissionProvider>();
    final isLoading = state == LocationPermissionState.loading;

    final icon = switch (state) {
      LocationPermissionState.blocked => AppAssets.icons.icSettings,
      _ => AppAssets.icons.icLocation,
    };

    final primaryLabel = switch (state) {
      LocationPermissionState.denied => l10n.locPermRetryBtn,
      LocationPermissionState.blocked => l10n.locPermSettingsBtn,
      _ => l10n.locPermAllowBtn,
    };

    Future<void> handlePrimary() async {
      if (state == LocationPermissionState.blocked) {
        await provider.openSettings();
        return;
      }
      final position = await provider.requestLocation();
      if (position != null) onGranted(position);
    }

    return _PrimaryButton(
      icon: icon,
      label: primaryLabel,
      isLoading: isLoading,
      onPressed: isLoading ? null : handlePrimary,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final SvgGenImage icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: isLoading
            ? SizedBox(
                key: const ValueKey('spinner'),
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: c.gold),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon.svg(
                    width: 14,
                    colorFilter: ColorFilter.mode(c.gold, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.light.surface,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
