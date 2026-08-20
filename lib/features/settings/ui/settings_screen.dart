import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/core/logic/location_provider.dart';
import 'package:muslimate/core/logic/settings_provider.dart';
import 'package:muslimate/features/location/logic/location_permission_provider.dart';
import 'package:muslimate/features/location/ui/location_permission_screen.dart';
import 'package:muslimate/features/notifications/ui/notification_permission_screen.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/features/prayer/ui/prayer_settings_screen.dart';
import 'package:muslimate/features/qibla/logic/qibla_provider.dart';
import 'package:muslimate/features/settings/data/app_links.dart';
import 'package:muslimate/features/settings/data/external_action_service.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.externalActions = const PlatformExternalActionService(),
  });

  /// Injectable so the external actions can be exercised in tests without
  /// leaving the app.
  final ExternalActionService externalActions;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Anchors the share sheet popover on iPad and macOS.
  final GlobalKey _shareRowKey = GlobalKey();

  /// Drives the row spinner and guards re-entry. Prayer alarm rescheduling no
  /// longer runs inside this window, so it ends when the location does.
  bool _refreshInFlight = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final locationPermission = context.watch<LocationPermissionProvider>();
    final location = context.watch<LocationProvider>();
    final prayer = context.watch<PrayerProvider>();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                l10n.settingsTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: c.ink,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  // Hidden for SCRUM-5.
                  // _buildProfileCard(context, c),
                  _buildSection(context, c, l10n.settingsSectionDisplay, [
                    // Hidden for SCRUM-5. Restore these display settings when
                    // they return to the release scope.
                    // _buildDarkToggle(context, c, settings),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.language_rounded,
                      l10n.settingsLanguage,
                      _languageLabel(l10n, settings.language),
                      true,
                      onTap: _showLanguagePicker,
                    ),
                    // _buildSettingsRow(
                    //   context,
                    //   c,
                    //   Icons.text_fields_rounded,
                    //   'Tipografi Arab',
                    //   'Naskh',
                    //   true,
                    // ),
                  ]),
                  _buildSection(context, c, l10n.settingsSectionWorship, [
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.location_on_outlined,
                      l10n.settingsLocation,
                      _locationLabel(l10n, locationPermission.state, location),
                      false,
                      onTap: _handleLocationTap,
                      isBusy: _refreshInFlight,
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.notifications_outlined,
                      l10n.settingsPrayerReminder,
                      prayer.hasEnabledReminder
                          ? l10n.settingsPrayerReminderOn
                          : l10n.settingsPrayerReminderOff,
                      true,
                      onTap: _openPrayerReminderSettings,
                    ),
                    // Hidden for SCRUM-5. Restore when Calculation Method
                    // returns to the Settings menu.
                    // _buildSettingsRow(
                    //   context,
                    //   c,
                    //   Icons.info_outline_rounded,
                    //   'Metode kalkulasi',
                    //   'Kemenag',
                    //   true,
                    // ),
                  ]),
                  _buildSection(context, c, l10n.settingsSectionOther, [
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.message_outlined,
                      l10n.settingsSendFeedback,
                      null,
                      false,
                      onTap: _sendFeedback,
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.favorite_outline_rounded,
                      l10n.settingsRateApp,
                      null,
                      false,
                      onTap: () => _openLink(AppLinks.storeUri()),
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.share_outlined,
                      l10n.settingsShareApp,
                      null,
                      false,
                      onTap: _shareApp,
                      rowKey: _shareRowKey,
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.star_outline_rounded,
                      l10n.settingsFollowSocial,
                      null,
                      false,
                      onTap: _showSocialAccounts,
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.help_outline_rounded,
                      l10n.settingsHelp,
                      null,
                      false,
                      onTap: () => _openLink(AppLinks.helpUri),
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.lock_outline_rounded,
                      l10n.settingsPrivacy,
                      null,
                      true,
                      onTap: () => _openLink(AppLinks.privacyUri),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Text(
                      l10n.settingsFooter(AppLinks.appVersion),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: c.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Language ------------------------------------------------------------

  String _languageLabel(AppLocalizations l10n, AppLanguage language) {
    return switch (language) {
      AppLanguage.system => l10n.settingsLanguageSystem(
        _systemLocale().languageCode,
      ),
      AppLanguage.indonesian => l10n.settingsLanguageIndonesian,
      AppLanguage.english => l10n.settingsLanguageEnglish,
    };
  }

  /// The locale the app falls back to while the language follows the device.
  ///
  /// Resolved from the device's preferred locales with the same algorithm
  /// `MaterialApp` applies, so the code shown matches the language actually
  /// rendered. Reading `Localizations.localeOf` instead would report the
  /// user's own override once they picked one.
  Locale _systemLocale() {
    return basicLocaleListResolution(
      WidgetsBinding.instance.platformDispatcher.locales,
      AppLocalizations.supportedLocales,
    );
  }

  Future<void> _showLanguagePicker() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.read<SettingsProvider>();

    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SettingsSheet(
        title: l10n.settingsLanguageSheetTitle,
        children: [
          for (final language in AppLanguage.values)
            _SheetOption(
              label: _languageLabel(l10n, language),
              selected: settings.language == language,
              onTap: () => Navigator.of(sheetContext).pop(language),
            ),
        ],
      ),
    );

    if (selected == null) return;
    await settings.setLanguage(selected);
  }

  // --- Location ------------------------------------------------------------

  String _locationLabel(
    AppLocalizations l10n,
    LocationPermissionState permission,
    LocationProvider location,
  ) {
    return switch (permission) {
      LocationPermissionState.loading => '...',
      LocationPermissionState.blocked => l10n.locPermBlockedInSystem,
      LocationPermissionState.denied => l10n.settingsLocationDenied,
      LocationPermissionState.idle => l10n.settingsLocationNotSet,
      LocationPermissionState.granted => switch (location.state) {
        LocationState.done =>
          location.address ?? l10n.settingsLocationUnavailable,
        LocationState.loading => '...',
        LocationState.error => l10n.settingsLocationUnavailable,
        LocationState.idle => l10n.settingsLocationNotSet,
      },
    };
  }

  Future<void> _handleLocationTap() async {
    final permission = context.read<LocationPermissionProvider>().state;
    if (permission == LocationPermissionState.granted) {
      await _refreshLocation();
      return;
    }
    await _openLocationPermission();
  }

  /// Reuses the same permission screen the Home header opens, so the app has
  /// one location permission flow.
  Future<void> _openLocationPermission() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => LocationPermissionScreen(
          onGranted: (position) {
            Navigator.of(routeContext).pop();
            _applyPosition(position);
          },
        ),
      ),
    );
  }

  Future<void> _refreshLocation() async {
    if (_refreshInFlight) return;
    setState(() => _refreshInFlight = true);

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
    setState(() => _refreshInFlight = false);
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

  /// Resolves the address for [position] first so the prayer schedule shows the
  /// place name rather than the previously stored one.
  Future<void> _applyPosition(Position position) async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.updatePosition(position);
    if (!mounted) return;
    await _updateDependentProviders(position, locationProvider.address);
  }

  Future<void> _updateDependentProviders(
    Position position,
    String? address,
  ) async {
    final prayerProvider = context.read<PrayerProvider>();
    final qiblaProvider = context.read<QiblaProvider>();
    await prayerProvider.updateLocation(
      position.latitude,
      position.longitude,
      address: address,
    );
    qiblaProvider.updateLocation(position.latitude, position.longitude);
  }

  // --- Prayer reminder -----------------------------------------------------

  Future<void> _openPrayerReminderSettings() async {
    if (!await NotificationPermissionScreen.ensureGranted(context) ||
        !mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            const PrayerSettingsScreen(initialTab: PrayerSettingsTab.reminder),
      ),
    );
  }

  // --- External actions ----------------------------------------------------

  Future<void> _sendFeedback() async {
    final l10n = AppLocalizations.of(context)!;
    final opened = await widget.externalActions.sendEmail(
      address: AppLinks.feedbackEmail,
      subject: l10n.settingsFeedbackSubject,
      body: '${l10n.settingsFeedbackBody}\n\n',
    );
    if (!opened) _showMessage(l10n.settingsEmailFailed);
  }

  Future<void> _openLink(Uri uri) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final opened = await widget.externalActions.openUrl(uri);
    if (!opened) _showMessage(l10n.settingsLinkFailed);
  }

  Future<void> _shareApp() async {
    final l10n = AppLocalizations.of(context)!;
    final opened = await widget.externalActions.shareText(
      text: l10n.settingsShareMessage(AppLinks.websiteUrl),
      subject: l10n.settingsShareSubject,
      sharePositionOrigin: _shareOrigin(),
    );
    if (!opened) _showMessage(l10n.settingsShareFailed);
  }

  Rect? _shareOrigin() {
    final box = _shareRowKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _showSocialAccounts() async {
    final l10n = AppLocalizations.of(context)!;

    final account = await showModalBottomSheet<SocialAccount>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SettingsSheet(
        title: l10n.settingsSocialSheetTitle,
        children: [
          for (final account in AppLinks.socialAccounts)
            _SheetOption(
              icon: _socialIcon(account.platform),
              label: account.name,
              trailingText: account.handle,
              onTap: () => Navigator.of(sheetContext).pop(account),
            ),
        ],
      ),
    );

    if (account == null) return;
    await _openLink(account.uri);
  }

  IconData _socialIcon(SocialPlatform platform) {
    return switch (platform) {
      SocialPlatform.instagram => Icons.camera_alt_outlined,
      SocialPlatform.tiktok => Icons.music_note_rounded,
      SocialPlatform.youtube => Icons.play_circle_outline_rounded,
      SocialPlatform.x => Icons.alternate_email_rounded,
    };
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // --- Layout --------------------------------------------------------------

  Widget _buildProfileCard(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.navy,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.goldSoft,
              ),
              child: Center(child: AppBrandMark(size: 32, color: c.goldDeep)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sahabat Muslimate',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.light.surface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mode tamu • Belum masuk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: c.gold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: c.gold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Masuk',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hidden for SCRUM-5. Restore this method with the Dark Mode setting.
  // Widget _buildDarkToggle(
  //   BuildContext context,
  //   AppColors c,
  //   SettingsProvider settings,
  // ) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  //     decoration: BoxDecoration(
  //       border: Border(bottom: BorderSide(color: c.hairline)),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 32,
  //           height: 32,
  //           decoration: BoxDecoration(
  //             color: c.surfaceAlt,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(
  //             settings.isDark
  //                 ? Icons.nights_stay_rounded
  //                 : Icons.wb_sunny_rounded,
  //             color: c.gold,
  //             size: 17,
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Text(
  //             'Tema gelap',
  //             style: GoogleFonts.plusJakartaSans(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: c.ink,
  //             ),
  //           ),
  //         ),
  //         AppToggle(
  //           value: settings.isDark,
  //           onChanged: (_) => settings.toggleDark(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSection(
    BuildContext context,
    AppColors c,
    String title,
    List<Widget> rows,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: c.inkMuted,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.hairline),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context,
    AppColors c,
    IconData icon,
    String label,
    String? value,
    bool isLast, {
    required Future<void> Function() onTap,
    bool isBusy = false,
    Key? rowKey,
  }) {
    return Container(
      key: rowKey,
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: c.hairline)),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isBusy ? null : () => onTap(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: c.gold, size: 17),
                ),
                const SizedBox(width: 12),
                // The label is inflexible so it always renders in full; the
                // value takes whatever is left and shortens instead. That
                // Expanded is tight, which also keeps the trailing icon pinned
                // to the right edge of every row.
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: c.ink,
                        ),
                      ),
                      if (value != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            value,
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: c.inkSoft,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                if (isBusy)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.gold,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: c.inkMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet shell shared by the language and social media pickers.
class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.hairline),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.ink,
                ),
              ),
            ),
            Divider(height: 1, color: c.hairline),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      children[i],
                      if (i < children.length - 1)
                        Divider(height: 1, color: c.hairline),
                    ],
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

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.label,
    required this.onTap,
    this.icon,
    this.trailingText,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? trailingText;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: c.gold, size: 17),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: c.ink,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: c.inkSoft,
                  ),
                ),
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_rounded, size: 18, color: c.gold),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
