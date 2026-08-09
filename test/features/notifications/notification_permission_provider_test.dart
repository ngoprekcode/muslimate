import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/features/notifications/logic/notification_permission_provider.dart';
import 'package:muslimate/features/prayer/data/prayer_notification_scheduler.dart';
import 'package:prayers_times/prayers_times.dart';

void main() {
  test('permission provider exposes denied and granted outcomes', () async {
    final scheduler = _FakeScheduler();
    final provider = NotificationPermissionProvider(scheduler);

    expect(await provider.checkPermissionStatus(), isFalse);
    expect(provider.state, NotificationPermissionState.idle);

    expect(await provider.requestPermission(), isFalse);
    expect(provider.state, NotificationPermissionState.denied);

    scheduler.granted = true;
    expect(await provider.requestPermission(), isTrue);
    expect(provider.state, NotificationPermissionState.granted);
  });
}

class _FakeScheduler implements PrayerNotificationScheduler {
  bool granted = false;

  @override
  Future<bool> areNotificationsEnabled() async => granted;

  @override
  Future<bool> requestNotificationPermission() async => granted;

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
