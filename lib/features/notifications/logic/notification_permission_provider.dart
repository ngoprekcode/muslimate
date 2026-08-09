import 'package:flutter/foundation.dart';
import 'package:muslimate/features/prayer/data/prayer_notification_scheduler.dart';

enum NotificationPermissionState { idle, loading, denied, granted }

class NotificationPermissionProvider extends ChangeNotifier {
  NotificationPermissionProvider(this._scheduler);

  final PrayerNotificationScheduler _scheduler;
  NotificationPermissionState _state = NotificationPermissionState.idle;
  NotificationPermissionState get state => _state;

  Future<bool> checkPermissionStatus() async {
    final enabled = await _scheduler.areNotificationsEnabled();
    _state = enabled
        ? NotificationPermissionState.granted
        : NotificationPermissionState.idle;
    notifyListeners();
    return enabled;
  }

  Future<bool> requestPermission() async {
    _state = NotificationPermissionState.loading;
    notifyListeners();
    final granted = await _scheduler.requestNotificationPermission();
    _state = granted
        ? NotificationPermissionState.granted
        : NotificationPermissionState.denied;
    notifyListeners();
    return granted;
  }

  Future<bool> openSettings() => _scheduler.openNotificationSettings();
}
