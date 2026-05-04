import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _month = 4; // April
  int _year = 2026;

  static const _dayHeaders = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
  static const _monthNames = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const _hijriMonths = [
    '', 'Muharram', 'Safar', 'Rabiul Awwal', 'Rabiul Akhir', 'Jumadil Awwal',
    'Jumadil Akhir', 'Rajab', 'Syaban', 'Ramadhan', 'Syawal', 'Dzulqaidah', 'Dzulhijjah',
  ];

  // April 2026: starts on Wednesday (offset=3), 30 days, today = 30
  final _events = {14: 'Nuzulul Qur\'an', 18: 'Idul Fitri', 30: 'Hari ini'};

  void _prev() => setState(() {
        if (_month == 1) {
          _month = 12;
          _year--;
        } else {
          _month--;
        }
      });

  void _next() => setState(() {
        if (_month == 12) {
          _month = 1;
          _year++;
        } else {
          _month++;
        }
      });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: 'Kalender',
              subtitle: 'Masehi & Hijriah',
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildMonthSwitcher(context, c),
                  const SizedBox(height: 16),
                  _buildCalendar(context, c),
                  _buildEvents(context, c),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSwitcher(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _NavBtn(icon: Icons.chevron_left_rounded, onTap: _prev, c: c),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_monthNames[_month]} $_year',
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
                  'Ramadhan — ${_hijriMonths[10]} 1447 H',
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
          _NavBtn(icon: Icons.chevron_right_rounded, onTap: _next, c: c),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, AppColors c) {
    const offset = 3; // April 1 = Wednesday
    const daysInMonth = 30;
    const today = 30;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.hairline),
        ),
        child: Column(
          children: [
            // Day headers
            Row(
              children: _dayHeaders.map((d) {
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
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: offset + daysInMonth,
              itemBuilder: (context, index) {
                if (index < offset) return const SizedBox.shrink();
                final day = index - offset + 1;
                final isToday = day == today;
                final hasEvent = _events.containsKey(day) && day != today;
                final hijriDay = day + 13;
                final hijriDisplay = hijriDay > 30 ? hijriDay - 30 : hijriDay;
                final colIndex = (index) % 7;
                final isFri = colIndex == 5;

                return Container(
                  decoration: BoxDecoration(
                    color: isToday ? c.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: hasEvent
                        ? Border.all(color: c.goldSoft)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isToday
                                  ? Colors.white
                                  : isFri
                                      ? c.goldDeep
                                      : c.ink,
                            ),
                          ),
                          Text(
                            '$hijriDisplay',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: isToday ? c.gold : c.inkMuted,
                            ),
                          ),
                        ],
                      ),
                      if (hasEvent)
                        Positioned(
                          bottom: 3,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.gold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvents(BuildContext context, AppColors c) {
    final events = [
      ('14 Apr', '27 Ramadhan 1447', 'Nuzulul Qur\'an', 'Peringatan turunnya Al-Qur\'an'),
      ('18 Apr', '1 Syawal 1447', 'Idul Fitri', 'Hari Raya'),
      ('24 Apr', '7 Syawal 1447', 'Puasa Syawal', 'Mulai puasa 6 hari Syawal'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hari penting bulan ini',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(events.length, (i) {
            final e = events[i];
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: i < events.length - 1
                    ? Border(bottom: BorderSide(color: c.hairline))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          e.$1.split(' ')[1],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            color: c.inkMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          e.$1.split(' ')[0],
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
                            Text(
                              e.$3,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: c.ink,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.star_rounded, color: c.gold, size: 12),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          e.$2,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: c.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.$4,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: c.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
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
