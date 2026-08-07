import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/generated/assets/assets.gen.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class HomeHeaderPermission extends StatelessWidget {
  final VoidCallback? onPressed;

  const HomeHeaderPermission({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: CustomPaint(
        painter: AppDashedBorderPainter(
          color: c.hairline,
          borderRadius: 22,
          strokeWidth: 1.5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: AppAssets.icons.icLocation.svg(height: 22),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.homeLocPermTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: c.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.homeLocPermDesc,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: c.inkSoft,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAssets.icons.icLocation.svg(
                      width: 14,
                      colorFilter: ColorFilter.mode(
                        AppColors.light.surface,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.homeLocPermBtn,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.light.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
