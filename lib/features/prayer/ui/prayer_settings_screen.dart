import 'package:flutter/material.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/prayer/data/prayer_notification_scheduler.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

enum PrayerSettingsTab { madhhab, reminder }

class PrayerSettingsScreen extends StatelessWidget {
  final PrayerSettingsTab initialTab;

  const PrayerSettingsScreen({super.key, required this.initialTab});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final initialIndex = initialTab == PrayerSettingsTab.madhhab ? 0 : 1;

    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Column(
            children: [
              _SettingsHeader(
                title: l10n.prayerScheduleSettingsTitle,
                subtitles: [
                  l10n.prayerMadhhabSettingsSubtitle,
                  l10n.prayerReminderSettingsSubtitle,
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: c.ink,
                    unselectedLabelColor: c.inkMuted,
                    labelStyle: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    indicator: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: c.hairline),
                    ),
                    tabs: [
                      Tab(text: l10n.prayerMadhhabTab),
                      Tab(text: l10n.prayerReminderTab),
                    ],
                  ),
                ),
              ),
              const Expanded(
                child: TabBarView(children: [_MadhhabTab(), _ReminderTab()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatefulWidget {
  final String title;
  final List<String> subtitles;

  const _SettingsHeader({required this.title, required this.subtitles});

  @override
  State<_SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<_SettingsHeader> {
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DefaultTabController.of(context);
    if (_controller == controller) return;
    _controller?.removeListener(_refresh);
    _controller = controller..addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final index = _controller?.index ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left_rounded),
            color: c.ink,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.ink,
                  ),
                ),
                Text(
                  widget.subtitles[index],
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MadhhabTab extends StatelessWidget {
  const _MadhhabTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<PrayerProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        _InfoBanner(text: l10n.prayerMadhhabInfo),
        const SizedBox(height: 12),
        _SelectionCard(
          selected: provider.asrMadhhab == AsrMadhhab.shafi,
          title: l10n.prayerMadhhabShafiTitle,
          subtitle: l10n.prayerMadhhabShafiDescription,
          detail: l10n.prayerMadhhabShafiRule,
          onTap: () => provider.setAsrMadhhab(AsrMadhhab.shafi),
        ),
        const SizedBox(height: 10),
        _SelectionCard(
          selected: provider.asrMadhhab == AsrMadhhab.hanafi,
          title: l10n.prayerMadhhabHanafi,
          subtitle: l10n.prayerMadhhabHanafiDescription,
          detail: l10n.prayerMadhhabHanafiRule,
          onTap: () => provider.setAsrMadhhab(AsrMadhhab.hanafi),
        ),
      ],
    );
  }
}

class _ReminderTab extends StatelessWidget {
  const _ReminderTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<PrayerProvider>();
    final reminderTypes = <(PrayerReminderType, String)>[
      (PrayerReminderType.tahajjud, l10n.prayerNameTahajjud),
      (PrayerReminderType.fajr, l10n.prayerNameFajr),
      (PrayerReminderType.sunrise, l10n.prayerNameSunrise),
      (PrayerReminderType.dhuhr, l10n.prayerNameDhuhr),
      (PrayerReminderType.asr, l10n.prayerNameAsr),
      (PrayerReminderType.maghrib, l10n.prayerNameMaghrib),
      (PrayerReminderType.isha, l10n.prayerNameIsha),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        _SectionLabel(l10n.prayerGlobalReminder),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            for (final minutes in const [0, 5, 10, 15, 30])
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Icon(
                  provider.reminderMinutes == minutes
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
                title: Text(
                  minutes == 0
                      ? l10n.prayerReminderExactTime
                      : l10n.prayerMinutes(minutes),
                ),
                trailing: minutes == 10
                    ? _RecommendedBadge(l10n.prayerRecommended)
                    : null,
                onTap: () => provider.setReminderMinutes(minutes),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionLabel(l10n.prayerPerPrayerTime),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            for (final item in reminderTypes)
              SwitchListTile.adaptive(
                value: provider.isReminderEnabled(item.$1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                dense: true,
                title: Text(item.$2),
                onChanged: (_) => provider.toggleReminder(item.$1),
              ),
          ],
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: c.inkSoft),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: c.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final String detail;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? c.gold : c.hairline,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? c.gold : c.inkMuted,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: c.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: c.inkMuted),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        detail,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: c.inkSoft),
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

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    // A Material rather than a decorated Container: the rows inside are
    // ListTiles, which paint their background and ink splashes on the nearest
    // Material ancestor and would otherwise be hidden behind the decoration.
    return Material(
      color: c.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: c.hairline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, indent: 12, endIndent: 12, color: c.hairline),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: c.ink,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RecommendedBadge extends StatelessWidget {
  final String text;
  const _RecommendedBadge(this.text);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.goldSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: c.goldDeep,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
