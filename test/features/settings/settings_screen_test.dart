import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/core/logic/location_provider.dart';
import 'package:muslimate/core/logic/settings_provider.dart';
import 'package:muslimate/features/location/logic/location_permission_provider.dart';
import 'package:muslimate/features/prayer/data/prayer_notification_scheduler.dart';
import 'package:muslimate/features/settings/data/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/settings_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('language', () {
    testWidgets('picking a language updates and persists it', (tester) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness();

      await tester.pumpWidget(harness.build());
      await tester.pump();

      expect(find.text('Ikuti sistem (en)'), findsOneWidget);

      await tester.tap(find.text('Bahasa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(harness.settingsProvider.language, AppLanguage.english);
      expect(harness.settingsProvider.locale, const Locale('en'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'english');
    });

    testWidgets('dismissing the picker keeps the current language', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness();

      await tester.pumpWidget(harness.build());
      await tester.pump();

      await tester.tap(find.text('Bahasa'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(harness.settingsProvider.language, AppLanguage.system);
    });

    testWidgets('the system option names the locale the device resolves to', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      tester.platformDispatcher.localesTestValue = const [Locale('id', 'ID')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final harness = SettingsTestHarness();

      await tester.pumpWidget(harness.build());
      await tester.pump();

      expect(find.text('Ikuti sistem (id)'), findsOneWidget);
    });

    testWidgets(
      'an unsupported device language falls back to the first locale',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        useTallTestSurface(tester);
        tester.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
        addTearDown(tester.platformDispatcher.clearLocalesTestValue);
        final harness = SettingsTestHarness();

        await tester.pumpWidget(harness.build());
        await tester.pump();

        // MaterialApp renders English for an unsupported device language, so the
        // label has to say en rather than fr.
        expect(find.text('Ikuti sistem (en)'), findsOneWidget);
      },
    );

    testWidgets('the code tracks the device, not the chosen override', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final harness = SettingsTestHarness();

      await tester.pumpWidget(harness.build());
      await tester.pump();

      // Stand in for a user who overrode the language on an English device.
      await harness.settingsProvider.setLanguage(AppLanguage.indonesian);
      await tester.pump();
      expect(find.text('Bahasa Indonesia'), findsOneWidget);

      await tester.tap(find.text('Bahasa'));
      await tester.pumpAndSettle();

      // The system option still reports the device locale, not the override.
      expect(find.text('Ikuti sistem (en)'), findsOneWidget);
    });
  });

  group('location', () {
    testWidgets('shows the stored place and refreshes it on tap', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness(
        permission: LocationPermissionState.granted,
        locationState: LocationState.done,
        address: 'Bandung, ID',
        fetchResult: testPosition(),
      );

      await tester.pumpWidget(harness.build());
      await tester.pump();

      expect(find.text('Bandung, ID'), findsOneWidget);

      await tester.tap(find.text('Lokasi'));
      await tester.pumpAndSettle();

      expect(harness.locationProvider.fetchCount, 1);
      expect(harness.prayerProvider.coordinates, isNotNull);
      expect(
        harness.prayerProvider.coordinates!.latitude,
        closeTo(-6.9175, 1e-4),
      );
      // A successful refresh speaks through the row itself, not a snackbar.
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('reports a failed refresh instead of failing silently', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness(
        permission: LocationPermissionState.granted,
        locationState: LocationState.done,
        address: 'Bandung, ID',
      );

      await tester.pumpWidget(harness.build());
      await tester.pump();

      await tester.tap(find.text('Lokasi'));
      await tester.pumpAndSettle();

      expect(harness.locationProvider.fetchCount, 1);
      expect(
        find.text('Lokasi belum dapat diperbarui. Silakan coba lagi.'),
        findsOneWidget,
      );

      await settleSnackBar(tester);
    });

    testWidgets('surfaces the permission state and opens the permission flow', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness(
        permission: LocationPermissionState.blocked,
      );

      await tester.pumpWidget(harness.build());
      await tester.pump();

      expect(find.text('Diblokir di sistem'), findsOneWidget);

      await tester.tap(find.text('Lokasi'));
      await tester.pumpAndSettle();

      // The shared permission screen took over rather than a silent refresh.
      expect(harness.locationProvider.fetchCount, 0);
      expect(find.text('Akses lokasi diblokir'), findsOneWidget);
    });

    testWidgets('stops the spinner once the position resolves', (tester) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness(
        permission: LocationPermissionState.granted,
        locationState: LocationState.done,
        address: 'Bandung, ID',
        fetchResult: testPosition(),
      );

      // Hold the prayer reschedule open, standing in for the hundreds of
      // alarm calls the real Android scheduler makes.
      final reschedule = Completer<void>();
      harness.scheduler.scheduleGate = reschedule;

      await tester.pumpWidget(harness.build());
      await tester.pump();

      await tester.tap(find.text('Lokasi'));
      await tester.pump();
      await tester.pump();

      // The reschedule is still running...
      expect(harness.scheduler.scheduleCalls, 1);
      expect(reschedule.isCompleted, isFalse);

      // ...but the lookup is done, so the row must not still look busy.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Bandung, ID'), findsOneWidget);

      reschedule.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows a not-set label before any location exists', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness(
        permission: LocationPermissionState.granted,
      );

      await tester.pumpWidget(harness.build());
      await tester.pump();

      expect(find.text('Belum diatur'), findsOneWidget);
    });
  });

  group('prayer reminder', () {
    testWidgets('reads its state from the prayer provider', (tester) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness();

      await tester.pumpWidget(harness.build());
      await tester.pump();

      // Fajr and Maghrib are on by default.
      expect(find.text('Aktif'), findsOneWidget);

      await harness.prayerProvider.toggleReminder(PrayerReminderType.fajr);
      await harness.prayerProvider.toggleReminder(PrayerReminderType.maghrib);
      await tester.pump();

      expect(find.text('Nonaktif'), findsOneWidget);
    });

    testWidgets('opens the prayer reminder settings tab', (tester) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness();

      await tester.pumpWidget(harness.build());
      await tester.pump();

      await tester.tap(find.text('Pengingat shalat'));
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan Jadwal'), findsOneWidget);
      expect(find.text('Pengingat global'), findsOneWidget);
    });
  });

  group('external actions', () {
    testWidgets('each action opens its configured destination', (tester) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness();

      await tester.pumpWidget(harness.build());
      await tester.pump();

      await tester.tap(find.text('Kirim masukan'));
      await tester.pumpAndSettle();
      expect(harness.actions.emailedAddresses, [AppLinks.feedbackEmail]);

      await tester.tap(find.text('Beri rating'));
      await tester.pumpAndSettle();
      expect(harness.actions.openedUrls.last, AppLinks.storeUri());

      await tester.tap(find.text('Bagikan aplikasi'));
      await tester.pumpAndSettle();
      expect(harness.actions.sharedTexts.single, contains(AppLinks.websiteUrl));

      await tester.tap(find.text('Bantuan'));
      await tester.pumpAndSettle();
      expect(harness.actions.openedUrls.last, AppLinks.helpUri);

      await tester.tap(find.text('Privasi'));
      await tester.pumpAndSettle();
      expect(harness.actions.openedUrls.last, AppLinks.privacyUri);
    });

    testWidgets('social media sheet opens the tapped account', (tester) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness();

      await tester.pumpWidget(harness.build());
      await tester.pump();

      await tester.tap(find.text('Ikuti media sosial'));
      await tester.pumpAndSettle();

      for (final account in AppLinks.socialAccounts) {
        expect(find.text(account.name), findsOneWidget);
      }

      await tester.tap(find.text('Instagram'));
      await tester.pumpAndSettle();

      expect(
        harness.actions.openedUrls.last,
        AppLinks.socialAccounts.first.uri,
      );
    });

    testWidgets('a failed action tells the user instead of crashing', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness();
      harness.actions.succeed = false;

      await tester.pumpWidget(harness.build());
      await tester.pump();

      await tester.tap(find.text('Privasi'));
      await tester.pumpAndSettle();
      expect(find.text('Tautan ini tidak dapat dibuka.'), findsOneWidget);
      await settleSnackBar(tester);

      await tester.tap(find.text('Kirim masukan'));
      await tester.pumpAndSettle();
      expect(
        find.text('Tidak ada aplikasi email yang dapat dibuka.'),
        findsOneWidget,
      );
      await settleSnackBar(tester);

      await tester.tap(find.text('Bagikan aplikasi'));
      await tester.pumpAndSettle();
      expect(find.text('Menu bagikan tidak dapat dibuka.'), findsOneWidget);
      await settleSnackBar(tester);
    });
  });

  group('layout', () {
    testWidgets('every row keeps its chevron on the same right edge', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester);
      final harness = SettingsTestHarness(
        permission: LocationPermissionState.granted,
        locationState: LocationState.done,
        address: 'Bandung, ID',
      );

      await tester.pumpWidget(harness.build());
      await tester.pump();

      final chevrons = find.byIcon(Icons.chevron_right_rounded);
      final count = chevrons.evaluate().length;
      expect(count, greaterThan(1));

      // Rows carrying a value must not indent their chevron relative to the
      // rows without one.
      final rightEdges = <String>{
        for (var i = 0; i < count; i++)
          tester.getRect(chevrons.at(i)).right.toStringAsFixed(2),
      };
      expect(rightEdges, hasLength(1));
    });

    testWidgets(
      'a long location name shortens instead of pushing the chevron',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        useTallTestSurface(tester);
        final harness = SettingsTestHarness(
          permission: LocationPermissionState.granted,
          locationState: LocationState.done,
          address: 'Kecamatan Coblong, Kota Bandung, Jawa Barat, Indonesia',
        );

        await tester.pumpWidget(harness.build());
        await tester.pump();

        final chevrons = find.byIcon(Icons.chevron_right_rounded);
        final count = chevrons.evaluate().length;
        final rightEdges = <String>{
          for (var i = 0; i < count; i++)
            tester.getRect(chevrons.at(i)).right.toStringAsFixed(2),
        };
        expect(rightEdges, hasLength(1));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('a cramped row shortens the value and never the label', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      useTallTestSurface(tester, width: 460);
      final harness = SettingsTestHarness(
        permission: LocationPermissionState.granted,
        locationState: LocationState.done,
        address: 'Kecamatan Coblong, Kota Bandung, Jawa Barat, Indonesia',
      );

      await tester.pumpWidget(harness.build());
      await tester.pump();

      // The label the emulator clipped to "Pengingat sh..." must stay whole.
      for (final label in ['Bahasa', 'Lokasi', 'Pengingat shalat']) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(label),
        );
        expect(
          paragraph.didExceedMaxLines,
          isFalse,
          reason: '"$label" was clipped',
        );
      }

      // The address is the side that gives way instead.
      final address = tester.renderObject<RenderParagraph>(
        find.text('Kecamatan Coblong, Kota Bandung, Jawa Barat, Indonesia'),
      );
      expect(address.didExceedMaxLines, isTrue);

      expect(tester.takeException(), isNull);
    });
  });
}
