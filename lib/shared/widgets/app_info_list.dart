import 'package:flutter/material.dart';
import 'package:muslimate/core/app_theme.dart';
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
      padding: const EdgeInsets.all(AppSpacing.md),
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
            padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: c.goldSoft,
              shape: BoxShape.circle,
            ),
            child: AppAssets.icons.icCheck.svg(),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMd.copyWith(
                color: c.inkSoft,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMd.copyWith(color: c.inkSoft),
      ),
    );
  }
}
