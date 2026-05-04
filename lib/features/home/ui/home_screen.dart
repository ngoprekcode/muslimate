import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNotification;

  const HomeScreen({super.key, this.onNotification});

  static const _prayers = [
    _Prayer('Subuh', '04:32', AppPrayerTime.fajr, false),
    _Prayer('Dzuhur', '11:58', AppPrayerTime.dhuhr, true),
    _Prayer('Ashar', '15:21', AppPrayerTime.asr, false),
    _Prayer('Maghrib', '17:54', AppPrayerTime.maghrib, false),
    _Prayer('Isya', '19:06', AppPrayerTime.isha, false),
  ];

  static const _quickActions = [
    _QuickAction('quran', "Al-Qur'an", Icons.menu_book_outlined),
    _QuickAction('qibla', 'Kiblat', Icons.explore_outlined),
    _QuickAction('calendar', 'Kalender', Icons.calendar_today_outlined),
    _QuickAction('dhikr', 'Wirid & Doa', Icons.spa_outlined),
    _QuickAction('hadith', 'Hadist', Icons.format_quote_outlined),
    _QuickAction('schedule', 'Jadwal', Icons.access_time_outlined),
    _QuickAction('mosque', 'Masjid', Icons.mosque_outlined),
    _QuickAction('asmaul', "Asma'ul Husna", Icons.auto_awesome_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: ListView(
          children: [
            _buildTopBar(context, c),
            _buildHeroCard(context, c),
            _buildPrayerRail(context, c),
            _buildQuickActions(context, c),
            _buildAyatCard(context, c),
            _buildHadistSlider(context, c),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.hairline)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.surfaceAlt,
            ),
            child: Center(child: AppBrandMark(size: 26, color: c.gold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Assalamu'alaikum",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: c.inkMuted,
                  ),
                ),
                Text(
                  'Sahabat Muslimate',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.ink,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.notifications_outlined, color: c.ink, size: 20),
              ),
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.gold,
                    border: Border.all(color: c.surfaceAlt, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.navy,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            // decorative arch
            Positioned(
              top: -20,
              right: -30,
              child: Opacity(
                opacity: 0.55,
                child: CustomPaint(
                  size: const Size(150, 170),
                  painter: _ArchPainter(c.gold),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: const Color(0xFFE6D9B4), size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Bandung, ID',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE6D9B4),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Shalat berikutnya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFFC7D3E0),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Dzuhur',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '11:58',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.12)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tersisa', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFC7D3E0))),
                          const SizedBox(height: 2),
                          Text(
                            '02:14:08',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFeatures: [const FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 28, color: Colors.white.withOpacity(0.15), margin: const EdgeInsets.symmetric(horizontal: 14)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hijriah', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFC7D3E0))),
                          const SizedBox(height: 2),
                          Text(
                            '14 Syawal 1447',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerRail(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: _prayers.map((p) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: p == _prayers.last ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: p.active ? c.goldSoft : c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: p.active ? c.goldSoft : c.hairline,
                ),
              ),
              child: Column(
                children: [
                  AppPrayerIcon(
                    prayer: p.prayerTime,
                    size: 20,
                    color: p.active ? c.goldDeep : c.inkSoft,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: p.active ? c.goldDeep : c.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.time,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: p.active ? c.goldDeep : c.ink,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: 'Fitur'),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
            children: _quickActions.map((qa) => _QuickActionButton(action: qa)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAyatCard(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: 'Ayat Hari Ini', action: 'Lihat semua'),
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppArabicText(
                  text: 'وَمَن يَتَّقِ ٱللَّهَ يَجۡعَل لَّهُۥ مَخۡرَجٗا',
                  fontSize: 22,
                  color: AppColors.of(context).ink,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                Text(
                  '"Dan barangsiapa bertakwa kepada Allah, niscaya Dia akan mengadakan baginya jalan keluar."',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.55,
                    color: c.inkSoft,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const AppPill(text: 'QS. At-Talaq : 2', tone: AppPillTone.navy),
                    const Spacer(),
                    _ActionBtn(icon: Icons.favorite_outline_rounded, color: c.inkSoft),
                    const SizedBox(width: 8),
                    _ActionBtn(icon: Icons.bookmark_outline_rounded, color: c.inkSoft),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadistSlider(BuildContext context, AppColors c) {
    final hadiths = [
      ('HR. Bukhari', 'Sebaik-baik manusia adalah yang paling bermanfaat bagi orang lain.'),
      ('HR. Muslim', 'Senyummu di hadapan saudaramu adalah sedekah.'),
      ('HR. Tirmidzi', 'Sebaik-baik kalian adalah yang paling baik akhlaknya.'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: AppSectionTitle(title: 'Hadith Pilihan'),
          ),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              itemCount: hadiths.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                return Container(
                  width: 240,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: i == 0 ? c.surfaceAlt : c.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.hairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote_rounded, color: c.gold, size: 20),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          '"${hadiths[i].$2}"',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            height: 1.55,
                            color: c.ink,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hadiths[i].$1.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: c.inkMuted,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _ActionBtn({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: () => _navigate(context, action.id),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.hairline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action.icon, color: c.gold, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: c.ink,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String id) {
    switch (id) {
      case 'quran':
        Navigator.of(context).pushNamed('/quran');
        break;
      case 'qibla':
        Navigator.of(context).pushNamed('/qibla');
        break;
      case 'calendar':
        Navigator.of(context).pushNamed('/calendar');
        break;
      case 'hadith':
        Navigator.of(context).pushNamed('/hadith');
        break;
      case 'schedule':
        Navigator.of(context).pushNamed('/prayer-schedule');
        break;
    }
  }
}

class _Prayer {
  final String name;
  final String time;
  final AppPrayerTime prayerTime;
  final bool active;
  const _Prayer(this.name, this.time, this.prayerTime, this.active);
}

class _QuickAction {
  final String id;
  final String label;
  final IconData icon;
  const _QuickAction(this.id, this.label, this.icon);
}

// Decorative arch painter (matches the design's arch lines in the hero card)
class _ArchPainter extends CustomPainter {
  final Color color;
  _ArchPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final w = size.width;
    final h = size.height;

    // outer arch
    final outer = Path()
      ..moveTo(10, h)
      ..lineTo(10, h * 0.44)
      ..arcToPoint(Offset(w - 10, h * 0.44),
          radius: Radius.circular(w * 0.42), clockwise: false)
      ..lineTo(w - 10, h);
    canvas.drawPath(outer, paint..color = color.withOpacity(0.6));

    // inner arch
    final inner = Path()
      ..moveTo(22, h)
      ..lineTo(22, h * 0.45)
      ..arcToPoint(Offset(w - 22, h * 0.45),
          radius: Radius.circular(w * 0.32), clockwise: false)
      ..lineTo(w - 22, h);
    canvas.drawPath(inner, paint..color = color.withOpacity(0.36));
  }

  @override
  bool shouldRepaint(_ArchPainter old) => old.color != color;
}
