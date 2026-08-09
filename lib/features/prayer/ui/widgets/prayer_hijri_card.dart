import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class PrayerHijriCard extends StatelessWidget {
  const PrayerHijriCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<PrayerProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.goldSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: c.goldDeep,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.prayerHijriDateLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: c.inkMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    provider.getHijriDate(l10n),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.ink,
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
}
