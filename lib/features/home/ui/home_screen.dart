import 'package:flutter/material.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/home/data/daily_verse_store.dart';
import 'package:muslimate/features/home/logic/daily_verse_provider.dart';
import 'package:muslimate/features/quran/data/quran_browse_repository.dart';
import 'package:provider/provider.dart';

import 'widgets/home_ayat_card.dart';
// Hidden for SCRUM-5. Restore this import with HomeHadistSlider below.
// import 'widgets/home_hadist_slider.dart';
import 'widgets/home_header.dart';
import 'widgets/home_prayer_rail.dart';
import 'widgets/home_quick_actions.dart';
import 'widgets/home_top_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.dailyVerseRepository,
    this.dailyVerseStore,
  });

  final QuranBrowseRepository? dailyVerseRepository;
  final DailyVerseStore? dailyVerseStore;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return ChangeNotifierProvider(
      key: ValueKey(languageCode),
      create: (_) => DailyVerseProvider(
        repository:
            dailyVerseRepository ??
            AssetQuranBrowseRepository(languageCode: languageCode),
        store: dailyVerseStore ?? SharedPreferencesDailyVerseStore(),
      )..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

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
