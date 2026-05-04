import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  int _activeCategory = 0;

  static const _categories = ['Semua', 'Akhlak', 'Ibadah', 'Keluarga', 'Ilmu', 'Niat'];

  static const _hadith = [
    _Hadith(
      category: 'Akhlak',
      source: 'HR. Bukhari & Muslim',
      arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      body: 'Sesungguhnya setiap amal perbuatan itu tergantung pada niatnya.',
      narrator: "— 'Umar bin Khattab r.a.",
    ),
    _Hadith(
      category: 'Akhlak',
      source: 'HR. Tirmidzi',
      arabic: 'الْمُؤْمِنُ لِلْمُؤْمِنِ كَالْبُنْيَانِ',
      body:
          'Seorang mukmin terhadap mukmin lainnya bagaikan satu bangunan, sebagiannya menguatkan sebagian yang lain.',
      narrator: "— Abu Musa al-Asy'ari r.a.",
    ),
    _Hadith(
      category: 'Ibadah',
      source: 'HR. Muslim',
      arabic: 'الطُّهُورُ شَطْرُ الإِيمَانِ',
      body: 'Bersuci itu sebagian dari iman.',
      narrator: "— Abu Malik al-Asy'ari r.a.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: 'Hadist Pilihan',
              subtitle: "40 hadist Arba'in & lainnya",
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildSearch(context, c),
                  _buildCategories(context, c),
                  _buildFeatured(context, c),
                  _buildList(context, c),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.hairline),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: c.inkMuted, size: 18),
            const SizedBox(width: 10),
            Text('Cari hadist...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: c.inkMuted,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, AppColors c) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final active = i == _activeCategory;
          return GestureDetector(
            onTap: () => setState(() => _activeCategory = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? c.navy : c.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: active ? c.navy : c.hairline),
              ),
              child: Text(
                _categories[i],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : c.inkSoft,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatured(BuildContext context, AppColors c) {
    final h = _hadith[0];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.navy,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.format_quote_rounded, color: c.gold, size: 26),
            const SizedBox(height: 8),
            AppArabicText(
              text: h.arabic,
              fontSize: 22,
              color: c.gold,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Text(
              '"${h.body}"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                height: 1.55,
                color: const Color(0xFFF1ECDD),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              h.source.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFC7D3E0),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: _hadith.skip(1).map((h) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppPill(text: h.category, tone: AppPillTone.gold),
                    Text(
                      h.source,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: c.inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppArabicText(
                  text: h.arabic,
                  fontSize: 20,
                  color: c.ink,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 10),
                Text(
                  '"${h.body}"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    height: 1.55,
                    color: c.inkSoft,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  h.narrator,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: c.inkMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.hairline)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ActionBtn(icon: Icons.favorite_outline_rounded, c: c),
                      const SizedBox(width: 4),
                      _ActionBtn(icon: Icons.bookmark_outline_rounded, c: c),
                      const SizedBox(width: 4),
                      _ActionBtn(icon: Icons.share_outlined, c: c),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final AppColors c;
  const _ActionBtn({required this.icon, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: c.inkSoft, size: 15),
    );
  }
}

class _Hadith {
  final String category;
  final String source;
  final String arabic;
  final String body;
  final String narrator;
  const _Hadith({
    required this.category,
    required this.source,
    required this.arabic,
    required this.body,
    required this.narrator,
  });
}
