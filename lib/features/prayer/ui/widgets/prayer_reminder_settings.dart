import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
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
        onTap: () => _showReminderOptions(context),
      ),
      (
        label: l10n.prayerAsrMadhhab,
        value: provider.asrMadhhab == AsrMadhhab.shafi
            ? l10n.prayerMadhhabShafi
            : l10n.prayerMadhhabHanafi,
        onTap: () => _showMadhhabOptions(context),
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

  Future<void> _showReminderOptions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<PrayerProvider>();
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final minutes in const [5, 10, 15, 30])
              ListTile(
                title: Text(l10n.prayerMinutes(minutes)),
                trailing: provider.reminderMinutes == minutes
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(sheetContext, minutes),
              ),
          ],
        ),
      ),
    );
    if (selected != null && context.mounted) {
      await provider.setReminderMinutes(selected);
    }
  }

  Future<void> _showMadhhabOptions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<PrayerProvider>();
    final selected = await showModalBottomSheet<AsrMadhhab>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.prayerMadhhabShafi),
              trailing: provider.asrMadhhab == AsrMadhhab.shafi
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.pop(sheetContext, AsrMadhhab.shafi),
            ),
            ListTile(
              title: Text(l10n.prayerMadhhabHanafi),
              trailing: provider.asrMadhhab == AsrMadhhab.hanafi
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.pop(sheetContext, AsrMadhhab.hanafi),
            ),
          ],
        ),
      ),
    );
    if (selected != null && context.mounted) {
      await provider.setAsrMadhhab(selected);
    }
  }
}
