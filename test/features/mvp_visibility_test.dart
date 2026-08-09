import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/core/app_theme.dart';
import 'package:muslimate/features/home/ui/widgets/home_quick_actions.dart';
import 'package:muslimate/features/home/ui/widgets/home_top_bar.dart';
import 'package:muslimate/features/settings/ui/settings_screen.dart';
import 'package:muslimate/shared/widgets/app_bottom_nav_bar.dart';

void main() {
  Widget testApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }

  testWidgets('home hides non-MVP actions and notifications', (tester) async {
    await tester.pumpWidget(
      testApp(
        const SingleChildScrollView(
          child: Column(children: [HomeTopBar(), HomeQuickActions()]),
        ),
      ),
    );

    expect(find.text('Kalender'), findsNothing);
    expect(find.text('Wirid'), findsNothing);
    expect(find.text('Hadist'), findsNothing);
    expect(find.text('Masjid'), findsNothing);
    expect(find.text("Al-Qur'an"), findsOneWidget);
    expect(find.text('Kiblat'), findsOneWidget);
    expect(find.text('Jadwal'), findsOneWidget);
    expect(find.text("Asma'ul"), findsOneWidget);
  });

  testWidgets('bottom navigation hides Wirid without breaking remaining tabs', (
    tester,
  ) async {
    var selectedIndex = -1;

    await tester.pumpWidget(
      testApp(
        AppBottomNavBar(
          currentIndex: 0,
          onTap: (index) => selectedIndex = index,
        ),
      ),
    );

    expect(find.text('Wirid'), findsNothing);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Shalat'), findsOneWidget);
    expect(find.text("Al-Qur'an"), findsOneWidget);
    expect(find.text('Lainnya'), findsOneWidget);

    await tester.tap(find.text('Lainnya'));
    expect(selectedIndex, 3);
  });

  testWidgets('settings hides non-MVP options', (tester) async {
    await tester.pumpWidget(testApp(const SettingsScreen()));

    expect(find.text('Tema gelap'), findsNothing);
    expect(find.text('Tipografi Arab'), findsNothing);
    expect(find.text('Metode kalkulasi'), findsNothing);
    expect(find.text('Bahasa'), findsOneWidget);
    expect(find.text('Lokasi'), findsOneWidget);
    expect(find.text('Pengingat shalat'), findsOneWidget);
  });
}
