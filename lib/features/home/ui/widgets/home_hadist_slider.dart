import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class HomeHadistSlider extends StatelessWidget {
  const HomeHadistSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final hadiths = [
      (
        'HR. Bukhari',
        'Sebaik-baik manusia adalah yang paling bermanfaat bagi orang lain.',
      ),
      ('HR. Muslim', 'Senyummu di hadapan saudaramu adalah sedekah.'),
      ('HR. Tirmidzi', 'Sebaik-baik kalian adalah yang paling baik akhlaknya.'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
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
