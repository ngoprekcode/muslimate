import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  static const _slides = [
    _Slide(
      tag: 'Selamat Datang',
      title: 'Sahabat ibadah harian Anda',
      body:
          'Muslimate menemani aktivitas Anda dengan jadwal, bacaan, dan pengingat — sederhana dan tenang.',
      icon: Icons.mosque_outlined,
    ),
    _Slide(
      tag: 'Tepat Waktu',
      title: 'Jangan lewatkan shalat',
      body:
          'Jadwal akurat sesuai lokasi, lengkap dengan pengingat yang lembut sebelum waktu tiba.',
      icon: Icons.access_time_rounded,
    ),
    _Slide(
      tag: 'Bacaan Harian',
      title: "Al-Qur'an, hadist, dan doa",
      body:
          'Baca dengan tenang, bookmark ayat favorit, dengarkan murottal, simpan doa harian.',
      icon: Icons.menu_book_rounded,
    ),
    _Slide(
      tag: 'Mulai',
      title: 'Mari kita mulai',
      body:
          'Izinkan akses lokasi untuk jadwal yang akurat. Anda dapat mengubahnya kapan saja di Pengaturan.',
      icon: Icons.explore_outlined,
    ),
  ];

  void _next() {
    if (_step < _slides.length - 1) {
      setState(() => _step++);
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final slide = _slides[_step];
    final isLast = _step == _slides.length - 1;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  AppBrandMark(size: 28, color: c.gold),
                  const SizedBox(width: 8),
                  Text(
                    'MUSLIMATE',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.5,
                      color: c.ink,
                    ),
                  ),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: widget.onFinish,
                      child: Text(
                        'Lewati',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: c.inkMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // hero illustration
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // concentric rings
                    Container(
                      width: 244,
                      height: 244,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: c.hairline),
                      ),
                    ),
                    Container(
                      width: 212,
                      height: 212,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: c.hairline,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    // inner circle with icon
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.surfaceAlt,
                      ),
                      child: Icon(slide.icon, size: 68, color: c.gold),
                    ),
                  ],
                ),
              ),
            ),

            // copy + CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slide.tag.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: c.gold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    slide.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: c.ink,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.body,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      color: c.inkSoft,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      // dots
                      Row(
                        children: List.generate(_slides.length, (i) {
                          final active = i == _step;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 6),
                            width: active ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active ? c.gold : c.hairline,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                      const Spacer(),
                      // CTA button
                      ElevatedButton.icon(
                        onPressed: _next,
                        icon: const SizedBox.shrink(),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast ? 'Mulai' : 'Lanjut',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.navy,
                          foregroundColor: AppColors.light.surface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                      ),
                    ],
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

class _Slide {
  final String tag;
  final String title;
  final String body;
  final IconData icon;
  const _Slide({
    required this.tag,
    required this.title,
    required this.body,
    required this.icon,
  });
}
