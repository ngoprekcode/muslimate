import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/core/app_theme.dart';
import 'package:muslimate/features/prayer/data/prayer_notification_scheduler.dart';
import 'package:muslimate/features/notifications/logic/notification_permission_provider.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/features/prayer/ui/widgets/prayer_list.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:prayers_times/prayers_times.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('each prayer reminder can be toggled independently', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final scheduler = _FakePrayerNotificationScheduler();
    final provider = PrayerProvider(notificationScheduler: scheduler);
    await provider.updateLocation(-6.2, 106.816666);

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
          home: const Scaffold(
            body: SingleChildScrollView(child: PrayerList()),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(provider.isReminderEnabled(PrayerReminderType.dhuhr), isFalse);
    await tester.tap(find.byTooltip('Pengingat Zuhur'));
    await tester.pump();

    expect(provider.isReminderEnabled(PrayerReminderType.dhuhr), isTrue);
    expect(scheduler.lastEnabledReminders, contains(PrayerReminderType.dhuhr));

    await tester.pump(const Duration(minutes: 1));
    expect(find.byType(PrayerList), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _FakePrayerNotificationScheduler implements PrayerNotificationScheduler {
  Set<PrayerReminderType> lastEnabledReminders = {};

  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<bool> openNotificationSettings() async => true;

  @override
  Future<void> schedulePrayerNotifications({
    required Coordinates coordinates,
    required PrayerCalculationParameters calculationParameters,
    required int reminderMinutes,
    required Set<PrayerReminderType> enabledReminders,
  }) async {
    lastEnabledReminders = {...enabledReminders};
  }
}
