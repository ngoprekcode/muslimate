import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/features/quran/data/quran_bookmark_store.dart';
import 'package:muslimate/features/quran/data/quran_last_read_store.dart';
import 'package:muslimate/features/quran/logic/quran_bookmark_provider.dart';
import 'package:muslimate/features/quran/logic/quran_last_read_provider.dart';
import 'package:muslimate/main.dart';
import 'package:muslimate/shared/widgets/app_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/settings_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('back returns to Home before asking for exit confirmation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var exitRequested = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'SystemNavigator.pop') exitRequested = true;
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    final harness = SettingsTestHarness();
    await tester.pumpWidget(
      harness.build(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  QuranBookmarkProvider(SharedPreferencesQuranBookmarkStore())
                    ..load(),
            ),
            ChangeNotifierProvider(
              create: (_) =>
                  QuranLastReadProvider(SharedPreferencesQuranLastReadStore())
                    ..load(),
            ),
          ],
          child: const MainShell(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Shalat'));
    await tester.pump();
    expect(
      tester.widget<AppBottomNavBar>(find.byType(AppBottomNavBar)).currentIndex,
      1,
    );

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(
      tester.widget<AppBottomNavBar>(find.byType(AppBottomNavBar)).currentIndex,
      0,
    );
    expect(find.text('Keluar dari Muslimate?'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Keluar dari Muslimate?'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(exitRequested, isFalse);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Keluar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(exitRequested, isTrue);
  });
}
