import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  bool _readerMode = false;
  int _activeTab = 0;

  static const _tabs = ['Surat', 'Juz', 'Hafalan', 'Bookmark'];

  static const _surat = [
    _Surat(1, 'Al-Fatihah', 'Pembukaan', 7, 'Makkiyah', 'الفاتحة'),
    _Surat(2, 'Al-Baqarah', 'Sapi Betina', 286, 'Madaniyah', 'البقرة'),
    _Surat(3, "Ali 'Imran", 'Keluarga Imran', 200, 'Madaniyah', 'آل عمران'),
    _Surat(18, 'Al-Kahf', 'Goa', 110, 'Makkiyah', 'الكهف'),
    _Surat(36, 'Yasin', 'Yasin', 83, 'Makkiyah', 'يس'),
    _Surat(55, 'Ar-Rahman', 'Maha Pengasih', 78, 'Madaniyah', 'الرحمن'),
    _Surat(67, 'Al-Mulk', 'Kerajaan', 30, 'Makkiyah', 'الملك'),
    _Surat(112, 'Al-Ikhlas', 'Ikhlas', 4, 'Makkiyah', 'الإخلاص'),
  ];

  static const _ayat = [
    _Ayah(
      1,
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
    ),
    _Ayah(
      2,
      'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'Segala puji bagi Allah, Tuhan semesta alam.',
    ),
    _Ayah(3, 'الرَّحْمَٰنِ الرَّحِيمِ', 'Yang Maha Pengasih, Maha Penyayang.'),
    _Ayah(4, 'مَالِكِ يَوْمِ الدِّينِ', 'Pemilik hari pembalasan.'),
    _Ayah(
      5,
      'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      'Hanya kepada Engkau kami menyembah dan hanya kepada Engkau kami mohon pertolongan.',
    ),
    _Ayah(
      6,
      'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      'Tunjukilah kami jalan yang lurus.',
    ),
    _Ayah(
      7,
      'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      'Yaitu jalan orang-orang yang telah Engkau anugerahkan nikmat kepada mereka.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_readerMode) return _buildReader(context);
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(title: "Al-Qur'an", subtitle: '114 surat'),
            Expanded(
              child: ListView(
                children: [
                  _buildLastRead(context, c),
                  _buildSearch(context, c),
                  _buildTabs(context, c),
                  _buildSuratList(context, c),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastRead(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: c.navy,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TERAKHIR DIBACA',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.dark.inkSoft,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Al-Kahf',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.light.surface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Ayat 10 • Juz 15',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.gold),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => setState(() => _readerMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: c.gold,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lanjutkan membaca',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: c.navy,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, color: c.navy, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
            Text(
              'Cari surat, ayat, atau kata kunci...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: c.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final active = i == _activeTab;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = i),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? c.navy : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _tabs[i],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.light.surface : c.inkSoft,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSuratList(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: _surat.map((s) {
          return GestureDetector(
            onTap: () => setState(() => _readerMode = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: c.hairline)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(38, 38),
                          painter: _StarBorderPainter(c.goldSoft),
                        ),
                        Text(
                          '${s.number}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: c.goldDeep,
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
                        Text(
                          s.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: c.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${s.meaning} • ${s.ayatCount} ayat • ${s.type}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: c.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    s.arabic,
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.gold,
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

  Widget _buildReader(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _readerMode = false),
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: c.ink,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Al-Fatihah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: c.ink,
                        ),
                      ),
                      Text(
                        '7 ayat • Makkiyah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: c.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: c.gold,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: c.navy,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          AppArabicText(
                            text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            fontSize: 26,
                            color: c.gold,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.dark.inkSoft,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      children: _ayat.map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: c.hairline),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: c.goldSoft,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${a.number}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: c.goldDeep,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.play_arrow_outlined,
                                    color: c.inkMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.bookmark_outline_rounded,
                                    color: c.inkMuted,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              AppArabicText(
                                text: a.arabic,
                                fontSize: 26,
                                color: c.ink,
                                height: 2.2,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                a.translation,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  height: 1.6,
                                  color: c.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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

class _StarBorderPainter extends CustomPainter {
  final Color color;
  _StarBorderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = (size.width - 2) / 2;
    final inner = outer * 0.75;

    final path = Path();
    const points = 12;
    for (int i = 0; i < points; i++) {
      final angle = (i * 360 / points - 90) * math.pi / 180;
      final r = i.isOdd ? inner : outer;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarBorderPainter old) => old.color != color;
}

class _Surat {
  final int number;
  final String name;
  final String meaning;
  final int ayatCount;
  final String type;
  final String arabic;
  const _Surat(
    this.number,
    this.name,
    this.meaning,
    this.ayatCount,
    this.type,
    this.arabic,
  );
}

class _Ayah {
  final int number;
  final String arabic;
  final String translation;
  const _Ayah(this.number, this.arabic, this.translation);
}
