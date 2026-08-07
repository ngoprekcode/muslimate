import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:provider/provider.dart';

class PrayerDayStrip extends StatelessWidget {
  const PrayerDayStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final provider = context.watch<PrayerProvider>();
    final now = DateTime.now();
    const double minItemWidth = 46.0;
    const double gap = 6.0;
    const double padding = 16.0;

    return SizedBox(
      height: 74,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalNeeded =
              (minItemWidth * 7) + (gap * 6) + (padding * 2);

          if (constraints.maxWidth >= totalNeeded) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(padding, 4, padding, 8),
              child: Row(
                children: List.generate(7, (i) {
                  final isLast = i == 6;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : gap),
                      child: PrayerDayItem(
                        date: now.add(Duration(days: i - 2)),
                        provider: provider,
                        c: c,
                      ),
                    ),
                  );
                }),
              ),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(padding, 4, padding, 8),
            itemCount: 7,
            separatorBuilder: (_, __) => const SizedBox(width: gap),
            itemBuilder: (context, i) => PrayerDayItem(
              date: now.add(Duration(days: i - 2)),
              provider: provider,
              c: c,
              width: minItemWidth,
            ),
          );
        },
      ),
    );
  }
}

class PrayerDayItem extends StatelessWidget {
  final DateTime date;
  final PrayerProvider provider;
  final AppColors c;
  final double? width;

  const PrayerDayItem({
    super.key,
    required this.date,
    required this.provider,
    required this.c,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = DateUtils.isSameDay(date, provider.selectedDate);
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    Color borderColor = c.hairline;
    if (isSelected) {
      borderColor = c.ink;
    } else if (isToday) {
      borderColor = c.inkMuted;
    }

    return GestureDetector(
      onTap: () => provider.updateDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        decoration: BoxDecoration(
          color: isSelected ? c.navy : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('E').format(date),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.light.surface.withValues(alpha: 0.8)
                    : c.inkSoft,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? c.gold : c.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
