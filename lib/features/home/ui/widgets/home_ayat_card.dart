import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class HomeAyatCard extends StatelessWidget {
  const HomeAyatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionTitle(title: 'Ayat Hari Ini', action: 'Lihat semua'),
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
                    const AppPill(
                      text: 'QS. At-Talaq : 2',
                      tone: AppPillTone.navy,
                    ),
                    const Spacer(),
                    _ActionBtn(
                      icon: Icons.favorite_outline_rounded,
                      color: c.inkSoft,
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      icon: Icons.bookmark_outline_rounded,
                      color: c.inkSoft,
                    ),
                  ],
                ),
              ],
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
