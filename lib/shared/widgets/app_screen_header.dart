import 'package:flutter/material.dart';
import 'package:muslimate/core/app_theme.dart';

class AppScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AppScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.chevron_left_rounded, color: c.ink, size: 26),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.h3.copyWith(color: c.ink),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: Theme.of(context).textTheme.labelMd.copyWith(
                      color: c.inkMuted,
                    ),
                  ),

                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ?trailing,
        ],
      ),
    );
  }
}
