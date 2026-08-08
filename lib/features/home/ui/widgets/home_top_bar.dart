import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
// Hidden for SCRUM-5. Restore this import with the notification action below.
// import 'package:muslimate/generated/assets/assets.gen.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Hidden for SCRUM-5. Restore when Notifications return to scope.
          // Stack(
          //   children: [
          //     Container(
          //       width: 40,
          //       height: 40,
          //       decoration: BoxDecoration(
          //         color: c.surfaceAlt,
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: Center(
          //         child: AppAssets.icons.icNotification.svg(
          //           colorFilter: ColorFilter.mode(c.ink, BlendMode.srcIn),
          //         ),
          //       ),
          //     ),
          //     Positioned(
          //       top: 9,
          //       right: 9,
          //       child: Container(
          //         width: 8,
          //         height: 8,
          //         decoration: BoxDecoration(
          //           shape: BoxShape.circle,
          //           color: c.gold,
          //           border: Border.all(color: c.surfaceAlt, width: 2),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
