import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/notifications/logic/notification_permission_provider.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'package:provider/provider.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  static Future<bool> ensureGranted(BuildContext context) async {
    final permission = context.read<NotificationPermissionProvider>();
    if (await permission.checkPermissionStatus()) return true;
    if (!context.mounted) return false;
    return await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => const NotificationPermissionScreen(),
          ),
        ) ??
        false;
  }

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen>
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
    if (state == AppLifecycleState.resumed) _checkAfterResume();
  }

  Future<void> _checkAfterResume() async {
    final granted = await context
        .read<NotificationPermissionProvider>()
        .checkPermissionStatus();
    if (granted && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<NotificationPermissionProvider>().state;
    final denied = state == NotificationPermissionState.denied;
    final loading = state == NotificationPermissionState.loading;

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton.icon(
            onPressed: loading
                ? null
                : denied
                ? _openSettings
                : _requestPermission,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.gold,
                    ),
                  )
                : Icon(
                    denied
                        ? Icons.settings_outlined
                        : Icons.notifications_active_outlined,
                    size: 14,
                  ),
            label: Text(
              denied
                  ? l10n.notificationPermissionSettings
                  : l10n.notificationPermissionAllow,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: l10n.notificationPermissionScreenTitle,
              subtitle: l10n.notificationPermissionScreenSubtitle,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PermissionIllustration(denied: denied),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: denied ? c.surfaceMuted : c.goldSoft,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                denied
                                    ? l10n.notificationPermissionDeniedChip
                                    : l10n.notificationPermissionRequiredChip,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: denied ? c.inkSoft : c.goldDeep,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              denied
                                  ? l10n.notificationPermissionDeniedTitle
                                  : l10n.notificationPermissionTitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: c.ink,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              denied
                                  ? l10n.notificationPermissionDeniedDescription
                                  : l10n.notificationPermissionDescription,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: c.inkSoft,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 12),
                            AppInfoListCard(
                              children: [
                                AppInfoItem(
                                  isPrimary: true,
                                  text: l10n.notificationPermissionBenefitAdhan,
                                ),
                                Divider(color: c.hairline),
                                AppInfoItem(
                                  isPrimary: true,
                                  text: l10n.notificationPermissionBenefitLocal,
                                ),
                                Divider(color: c.hairline),
                                AppInfoItem(
                                  isPrimary: true,
                                  text:
                                      l10n.notificationPermissionBenefitControl,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    final granted = await context
        .read<NotificationPermissionProvider>()
        .requestPermission();
    if (granted && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _openSettings() async {
    final opened = await context
        .read<NotificationPermissionProvider>()
        .openSettings();
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.notificationPermissionSettingsUnavailable,
          ),
        ),
      );
    }
  }
}

class _PermissionIllustration extends StatelessWidget {
  const _PermissionIllustration({required this.denied});

  final bool denied;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: c.hairline.withValues(alpha: 0.35)),
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.hairline.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surfaceAlt,
                border: Border.all(color: c.hairline.withValues(alpha: 0.65)),
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? c.surfaceAlt : c.ink,
                    boxShadow: [
                      BoxShadow(
                        color: c.gold.withValues(alpha: 0.55),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    denied
                        ? Icons.notifications_off_outlined
                        : Icons.notifications_active_outlined,
                    color: c.gold,
                    size: 32,
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
