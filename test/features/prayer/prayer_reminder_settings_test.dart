import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/core/app_theme.dart';
import 'package:muslimate/features/prayer/data/prayer_notification_scheduler.dart';
import 'package:muslimate/features/notifications/logic/notification_permission_provider.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/features/prayer/ui/widgets/prayer_reminder_settings.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:prayers_times/prayers_times.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('hides adhan sound and updates visible prayer settings', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final scheduler = _FakePrayerNotificationScheduler();
    final provider = PrayerProvider(notificationScheduler: scheduler);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider(
            create: (_) => NotificationPermissionProvider(scheduler),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('id'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('id')],
          home: const Scaffold(body: PrayerReminderSettings()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Suara Adzan'), findsNothing);
    expect(find.text('Notifikasi sebelum shalat'), findsOneWidget);
    expect(find.text('Mazhab Asar'), findsOneWidget);

    await tester.tap(find.text('10 menit'));
    await tester.pumpAndSettle();
    expect(find.text('Pengingat global'), findsOneWidget);
    expect(find.text('Adzan'), findsNothing);
    await tester.tap(find.text('15 menit'));
    await tester.pumpAndSettle();
    expect(provider.reminderMinutes, 15);
    expect(scheduler.permissionRequests, 0);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Syafi'i (standar)"));
    await tester.pumpAndSettle();
    expect(find.text("Syafi'i, Maliki, Hanbali"), findsOneWidget);
    await tester.tap(find.text('Hanafi'));
    await tester.pumpAndSettle();
    expect(provider.asrMadhhab, AsrMadhhab.hanafi);
  });
}

class _FakePrayerNotificationScheduler implements PrayerNotificationScheduler {
  int permissionRequests = 0;

  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<bool> requestNotificationPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<bool> openNotificationSettings() async => true;

  @override
  Future<void> schedulePrayerNotifications({
    required Coordinates coordinates,
    required PrayerCalculationParameters calculationParameters,
    required int reminderMinutes,
    required Set<PrayerReminderType> enabledReminders,
  }) async {}
}
