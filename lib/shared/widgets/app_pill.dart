import 'package:flutter/material.dart';
import 'package:muslimate/core/app_theme.dart';

enum AppPillTone { gold, navy, muted }

class AppPill extends StatelessWidget {
  final String text;
  final AppPillTone tone;

  const AppPill({super.key, required this.text, this.tone = AppPillTone.gold});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Color bg, fg;
    switch (tone) {
      case AppPillTone.gold:
        bg = c.goldSoft;
        fg = c.goldDeep;
        break;
      case AppPillTone.navy:
        bg = c.surfaceAlt;
        fg = c.navy;
        break;
      case AppPillTone.muted:
        bg = c.surfaceMuted;
        fg = c.inkSoft;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMd.copyWith(color: fg),
      ),
    );
  }
}
