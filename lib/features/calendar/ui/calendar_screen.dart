import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/calendar/logic/calendar_provider.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: l10n.calendarTitle,
              subtitle: l10n.calendarSubtitle,
            ),
            Expanded(
              child: Consumer<CalendarProvider>(
                builder: (context, provider, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth > 600;
                      final days = provider.getDaysInMonth();
                      final events = days.where((d) => d.isCurrentMonth && d.holidayKey != null).toList();

                      return ListView(
                        children: [
                          _buildMonthSwitcher(context, provider, c, l10n),
                          const SizedBox(height: 16),
                          _buildCalendarGrid(context, days, c, l10n, isTablet),
                          _buildEvents(context, provider, events, c, l10n),
                          const SizedBox(height: 28),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSwitcher(
    BuildContext context,
    CalendarProvider provider,
    AppColors c,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _NavBtn(
            icon: Icons.chevron_left_rounded,
            onTap: provider.prevMonth,
            c: c,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_getMonthName(l10n, provider.month)} ${provider.year}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: c.ink,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  provider.getHijriDateRange(l10n),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.gold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _NavBtn(
            icon: Icons.chevron_right_rounded,
            onTap: provider.nextMonth,
            c: c,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    List<CalendarDay> days,
    AppColors c,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    final dayHeaders = [
      l10n.daySun,
      l10n.dayMon,
      l10n.dayTue,
      l10n.dayWed,
      l10n.dayThu,
      l10n.dayFri,
      l10n.daySat,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.hairline),
        ),
        child: Column(
          children: [
            Row(
              children: dayHeaders.map((d) {
                return Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: c.inkMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: isTablet ? 1.5 : 1,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isFri = day.date.weekday == DateTime.friday;
                final isSun = day.date.weekday == DateTime.sunday;
                final hasHoliday = day.holidayKey != null;

                return Container(
                  decoration: BoxDecoration(
                    color: day.isToday ? c.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: (hasHoliday && !day.isToday)
                        ? Border.all(color: c.goldSoft.withOpacity(0.5))
                        : null,
                  ),
                  child: Opacity(
                    opacity: day.isCurrentMonth ? 1.0 : 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.date.day}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: day.isToday
                                ? Colors.white
                                : (isFri || isSun || hasHoliday)
                                    ? c.goldDeep
                                    : c.ink,
                          ),
                        ),
                        Text(
                          '${day.hijriDate.hDay}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: day.isToday ? c.gold : c.inkMuted,
                          ),
                        ),
                        if (hasHoliday) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: day.isToday ? Colors.white : c.gold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvents(
    BuildContext context,
    CalendarProvider provider,
    List<CalendarDay> events,
    AppColors c,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.calendarImportantDays,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 10),
          if (events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  l10n.calendarNoEvents,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: c.inkMuted,
                  ),
                ),
              ),
            )
          else
            ...events.map((e) => _buildEventItem(context, provider, e, c, l10n)),
        ],
      ),
    );
  }

  Widget _buildEventItem(
    BuildContext context,
    CalendarProvider provider,
    CalendarDay day,
    AppColors c,
    AppLocalizations l10n,
  ) {
    final holidayName = provider.getHolidayName(l10n, day.holidayKey!);
    final holidayDesc = provider.getHolidayDescription(l10n, day.holidayKey!);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.hairline)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  _getMonthName(l10n, day.date.month).substring(0, 3),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    color: c.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${day.date.day}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        holidayName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: c.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.star_rounded, color: c.gold, size: 14),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${day.hijriDate.hDay} ${_getMonthNameHijri(l10n, day.hijriDate.hMonth)} ${day.hijriDate.hYear} H',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: c.inkMuted,
                  ),
                ),
                if (holidayDesc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    holidayDesc,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: c.inkSoft,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(AppLocalizations l10n, int month) {
    switch (month) {
      case 1: return l10n.monthJan;
      case 2: return l10n.monthFeb;
      case 3: return l10n.monthMar;
      case 4: return l10n.monthApr;
      case 5: return l10n.monthMay;
      case 6: return l10n.monthJun;
      case 7: return l10n.monthJul;
      case 8: return l10n.monthAug;
      case 9: return l10n.monthSep;
      case 10: return l10n.monthOct;
      case 11: return l10n.monthNov;
      case 12: return l10n.monthDec;
      default: return '';
    }
  }

  String _getMonthNameHijri(AppLocalizations l10n, int month) {
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

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final AppColors c;
  const _NavBtn({required this.icon, required this.onTap, required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: c.ink, size: 18),
      ),
    );
  }
}
