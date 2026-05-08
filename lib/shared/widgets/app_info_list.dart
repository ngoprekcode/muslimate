import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/generated/assets/assets.gen.dart';

/// Reusable card that contains a list of information or trust points.
class AppInfoListCard extends StatelessWidget {
  final List<Widget> children;

  const AppInfoListCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// A single item for [AppInfoListCard].
/// Can be a primary item (with a check icon) or a secondary one (plain text).
class AppInfoItem extends StatelessWidget {
  final String text;
  final bool isPrimary;

  const AppInfoItem({
    super.key,
    required this.text,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    if (isPrimary) {
      return Row(
        children: [
          Container(
            width: 20,
            height: 20,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: c.goldSoft,
              shape: BoxShape.circle,
            ),
            child: AppAssets.icons.icCheck.svg(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: c.inkSoft,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: c.inkSoft,
          height: 1.5,
        ),
      ),
    );
  }
}
