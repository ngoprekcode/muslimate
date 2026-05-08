import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/home/data/models/home_prayer_type.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/generated/assets/assets.gen.dart';
import 'package:muslimate/features/calendar/logic/calendar_provider.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'home_header_loading.dart';

class HomeHeaderCard extends StatefulWidget {
  const HomeHeaderCard({super.key});

  @override
  State<HomeHeaderCard> createState() => _HomeHeaderCardState();
}

class _HomeHeaderCardState extends State<HomeHeaderCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final prayerProvider = context.read<PrayerProvider>();
      final nextTime = prayerProvider.getNextPrayerTime();
      if (nextTime != null) {
        final diff = nextTime.difference(DateTime.now());
        if (diff.isNegative) {
          setState(() => _remaining = Duration.zero);
        } else {
          setState(() => _remaining = diff);
        }
      }
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final prayerProvider = context.watch<PrayerProvider>();

    final nextPrayerStr = prayerProvider.getNextPrayer();
    if (nextPrayerStr == null) {
      return HomeHeaderLoading();
    }

    final type = HomePrayerType.fromPrayerType(nextPrayerStr);
    final nextTime = prayerProvider.getNextPrayerTime();
    final address = prayerProvider.locationName;

    final today = CalendarDay(date: DateTime.now(), isCurrentMonth: true);
    final hijriDateStr = '${today.hijriDate.hDay} ${_getHijriMonthName(l10n, today.hijriDate.hMonth)} ${today.hijriDate.hYear}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
        child: Stack(
          children: [
            Positioned.fill(child: type.background.svg(fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppAssets.icons.icLocation.svg(
                        height: 13,
                        colorFilter: ColorFilter.mode(
                          type.colorSecondary(c).withValues(alpha: 0.78),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: type
                                .colorSecondary(c)
                                .withValues(alpha: 0.78),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Shalat berikutnya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: type.colorSecondary(c).withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        type.labelPrayer,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: type.colorMain(c),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        prayerProvider.formatTime(nextTime),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: type.colorTimePrayer(c),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: type.colorDivider(c).withValues(alpha: 0.14),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tersisa',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: type
                                    .colorSecondary(c)
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDuration(_remaining),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: type.colorMain(c),
                                fontFeatures: [
                                  const FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: type.colorDivider(c).withValues(alpha: 0.14),
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.hijri,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: type
                                      .colorSecondary(c)
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hijriDateStr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: type.colorMain(c),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  String _getHijriMonthName(AppLocalizations l10n, int month) {
    switch (month) {
      case 1: return l10n.hijriMonth1;
      case 2: return l10n.hijriMonth2;
      case 3: return l10n.hijriMonth3;
      case 4: return l10n.hijriMonth4;
      case 5: return l10n.hijriMonth5;
      case 6: return l10n.hijriMonth6;
      case 7: return l10n.hijriMonth7;
      case 8: return l10n.hijriMonth8;
      case 9: return l10n.hijriMonth9;
      case 10: return l10n.hijriMonth10;
      case 11: return l10n.hijriMonth11;
      case 12: return l10n.hijriMonth12;
      default: return '';
    }
  }
}
