import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/features/prayer/data/prayer_notification_scheduler.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:prayers_times/prayers_times.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Tahajjud and sunrise notifications never play adhan', () {
    expect(PrayerReminderType.tahajjud.playsAdhan, isFalse);
    expect(PrayerReminderType.sunrise.playsAdhan, isFalse);
    expect(PrayerReminderType.fajr.playsAdhan, isTrue);
    expect(PrayerReminderType.dhuhr.playsAdhan, isTrue);
    expect(PrayerReminderType.asr.playsAdhan, isTrue);
    expect(PrayerReminderType.maghrib.playsAdhan, isTrue);
    expect(PrayerReminderType.isha.playsAdhan, isTrue);
  });

  test('prayer settings persist across provider instances', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = PrayerProvider();
    await Future<void>.delayed(Duration.zero);

    await provider.setReminderMinutes(15);
    await provider.setAsrMadhhab(AsrMadhhab.hanafi);
    await provider.updateLocation(-6.2, 106.816666);
    await provider.toggleReminder(PrayerReminderType.tahajjud);
    await provider.toggleReminder(PrayerReminderType.sunrise);

    final restored = PrayerProvider();
    await Future<void>.delayed(Duration.zero);

    expect(restored.reminderMinutes, 15);
    expect(restored.asrMadhhab, AsrMadhhab.hanafi);
    expect(restored.coordinates?.latitude, -6.2);
    expect(restored.coordinates?.longitude, 106.816666);
    expect(restored.isReminderEnabled(PrayerReminderType.tahajjud), isTrue);
    expect(restored.isReminderEnabled(PrayerReminderType.sunrise), isTrue);

    provider.dispose();
    restored.dispose();
  });

  test(
    'reminder changes do not alter prayer calculations or madhhab',
    () async {
      SharedPreferences.setMockInitialValues({});
      final scheduler = _FakePrayerNotificationScheduler();
      final provider = PrayerProvider(notificationScheduler: scheduler);
      await Future<void>.delayed(Duration.zero);
      await provider.updateLocation(-6.2, 106.816666);
      final prayerTimes = provider.prayerTimes;

      await provider.setReminderMinutes(30);
      await provider.toggleReminder(PrayerReminderType.dhuhr);

      expect(provider.prayerTimes, same(prayerTimes));
      expect(provider.asrMadhhab, AsrMadhhab.shafi);
      expect(provider.reminderMinutes, 30);
      expect(scheduler.permissionRequests, 0);
      expect(scheduler.scheduleRequests, greaterThan(0));
      expect(
        scheduler.lastEnabledReminders,
        containsAll([
          PrayerReminderType.fajr,
          PrayerReminderType.dhuhr,
          PrayerReminderType.maghrib,
        ]),
      );
      provider.dispose();
    },
  );
}

class _FakePrayerNotificationScheduler implements PrayerNotificationScheduler {
  int permissionRequests = 0;
  int scheduleRequests = 0;
  Set<PrayerReminderType> lastEnabledReminders = {};

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
  }) async {
    scheduleRequests++;
    lastEnabledReminders = {...enabledReminders};
  }
}
