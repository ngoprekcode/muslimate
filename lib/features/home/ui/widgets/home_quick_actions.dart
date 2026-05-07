import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionTitle(title: 'Fitur'),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
            children: _quickActions
                .map((qa) => _QuickActionButton(action: qa))
                .toList(),
          ),
        ],
      ),
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

class _QuickAction {
  final String id;
  final String label;
  final IconData icon;
  const _QuickAction(this.id, this.label, this.icon);
}
