import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/features/prayer/ui/prayer_settings_screen.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'package:provider/provider.dart';

class PrayerReminderSettings extends StatelessWidget {
  const PrayerReminderSettings({super.key});

  // Hidden for SCRUM-8. Keep this implementation metadata so the adhan sound
  // setting can be restored after the MVP without recreating its configuration.
  static const hiddenAdhanSoundSetting = ('Suara Adzan', 'Makkah');

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<PrayerProvider>();
    final rows = <({String label, String value, VoidCallback onTap})>[
      (
        label: l10n.prayerReminderBefore,
        value: l10n.prayerMinutes(provider.reminderMinutes),
        onTap: () => _openSettings(context, PrayerSettingsTab.reminder),
      ),
      (
        label: l10n.prayerAsrMadhhab,
        value: provider.asrMadhhab == AsrMadhhab.shafi
            ? l10n.prayerMadhhabShafi
            : l10n.prayerMadhhabHanafi,
        onTap: () => _openSettings(context, PrayerSettingsTab.madhhab),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: l10n.prayerSettings),
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
                  child: InkWell(
                    onTap: rows[i].onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              rows[i].label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: c.ink,
                              ),
                            ),
                          ),
                          Text(
                            rows[i].value,
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
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context, PrayerSettingsTab tab) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PrayerSettingsScreen(initialTab: tab),
      ),
    );
  }
}
