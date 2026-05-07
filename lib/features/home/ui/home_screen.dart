import 'package:flutter/material.dart';
import 'package:muslimate/core/app_colors.dart';

import 'widgets/home_ayat_card.dart';
import 'widgets/home_hadist_slider.dart';
import 'widgets/home_hero_card.dart';
import 'widgets/home_prayer_rail.dart';
import 'widgets/home_quick_actions.dart';
import 'widgets/home_top_bar.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNotification;

  const HomeScreen({super.key, this.onNotification});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: ListView(
          children: const [
            HomeTopBar(),
            HomeHeroCard(),
            HomePrayerRail(),
            HomeQuickActions(),
            HomeAyatCard(),
            HomeHadistSlider(),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
