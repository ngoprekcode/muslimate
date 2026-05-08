import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:muslimate/core/app_theme.dart';
import 'package:muslimate/core/logic/settings_provider.dart';
import 'package:muslimate/features/onboarding/ui/onboarding_screen.dart';
import 'package:muslimate/features/home/ui/home_screen.dart';
import 'package:muslimate/features/prayer/ui/prayer_schedule_screen.dart';
import 'package:muslimate/features/qibla/ui/qibla_screen.dart';
import 'package:muslimate/features/quran/ui/quran_screen.dart';
import 'package:muslimate/features/hadith/ui/hadith_screen.dart';
import 'package:muslimate/features/calendar/ui/calendar_screen.dart';
import 'package:muslimate/features/dhikr/ui/dhikr_screen.dart';
import 'package:muslimate/features/settings/ui/settings_screen.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/features/qibla/logic/qibla_provider.dart';
import 'package:muslimate/features/location/logic/location_permission_provider.dart';
import 'package:muslimate/core/logic/location_provider.dart';

import 'package:muslimate/features/calendar/logic/calendar_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        /// Global Provider
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(
          create: (_) => LocationPermissionProvider()..checkPermissionStatus(),
        ),

        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => QiblaProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: const MuslimateApp(),
    ),
  );
}

class MuslimateApp extends StatelessWidget {
  const MuslimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Muslimate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('id')],
      home: settings.onboardingDone
          ? const MainShell()
          : OnboardingScreen(onFinish: settings.completeOnboarding),
      onGenerateRoute: (routeSettings) {
        Widget page;
        switch (routeSettings.name) {
          case '/prayer-schedule':
            page = const PrayerScheduleScreen();
            break;
          case '/qibla':
            page = const QiblaScreen();
            break;
          case '/quran':
            page = const QuranScreen();
            break;
          case '/hadith':
            page = const HadithScreen();
            break;
          case '/calendar':
            page = const CalendarScreen();
            break;
          default:
            return null;
        }
        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTab = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PrayerScheduleScreen(),
    QuranScreen(),
    DhikrScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentTab, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
      ),
    );
  }
}
