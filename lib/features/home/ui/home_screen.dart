import 'package:flutter/material.dart';
import 'package:muslimate/core/app_colors.dart';

import 'widgets/home_ayat_card.dart';
// Hidden for SCRUM-5. Restore this import with HomeHadistSlider below.
// import 'widgets/home_hadist_slider.dart';
import 'widgets/home_header.dart';
import 'widgets/home_prayer_rail.dart';
import 'widgets/home_quick_actions.dart';
import 'widgets/home_top_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: ListView(
          children: const [
            HomeTopBar(),
            SizedBox(height: 16),
            HomeHeader(),
            SizedBox(height: 16),
            HomePrayerRail(),
            SizedBox(height: 16),
            HomeQuickActions(),
            HomeAyatCard(),
            // Hidden for SCRUM-5. Restore when Hadith returns to the MVP UI.
            // HomeHadistSlider(),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
