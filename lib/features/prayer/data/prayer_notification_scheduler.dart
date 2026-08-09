import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:prayers_times/prayers_times.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum PrayerReminderType { tahajjud, fajr, sunrise, dhuhr, asr, maghrib, isha }

extension PrayerReminderTypeBehavior on PrayerReminderType {
  bool get playsAdhan => switch (this) {
    PrayerReminderType.tahajjud || PrayerReminderType.sunrise => false,
    _ => true,
  };
}

abstract interface class PrayerNotificationScheduler {
  Future<bool> areNotificationsEnabled();

  Future<bool> requestNotificationPermission();

  Future<bool> openNotificationSettings();

  Future<void> schedulePrayerNotifications({
    required Coordinates coordinates,
    required PrayerCalculationParameters calculationParameters,
    required int reminderMinutes,
    required Set<PrayerReminderType> enabledReminders,
  });
}

class NoopPrayerNotificationScheduler implements PrayerNotificationScheduler {
  const NoopPrayerNotificationScheduler();

  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<bool> openNotificationSettings() async => false;

  @override
  Future<void> schedulePrayerNotifications({
    required Coordinates coordinates,
    required PrayerCalculationParameters calculationParameters,
    required int reminderMinutes,
    required Set<PrayerReminderType> enabledReminders,
  }) async {}
}

class AndroidPrayerNotificationScheduler
    implements PrayerNotificationScheduler {
  static const _settingsChannel = MethodChannel(
    'com.ngoprekcode.muslimate/notification_settings',
  );
  static const _scheduledIdsKey = 'prayer_scheduled_notification_ids';
  // Thirty days keeps reminders alive when the app is not opened frequently
  // while remaining below common Android OEM pending-alarm limits.
  static const _daysToSchedule = 30;
  static const _timezoneName = 'Asia/Jakarta';
  static const _adhanChannelId = 'prayer_time_adhan_v1';
  static const _reminderChannelId = 'prayer_reminder_v1';

  final FlutterLocalNotificationsPlugin _notifications;

  AndroidPrayerNotificationScheduler({
    FlutterLocalNotificationsPlugin? notifications,
  }) : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_timezoneName));
    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> areNotificationsEnabled() async =>
      await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<bool> requestNotificationPermission() async {
    final granted = await _android?.requestNotificationsPermission();
    if (granted ?? false) {
      await _android?.requestExactAlarmsPermission();
    }
    return granted ?? false;
  }

  @override
  Future<bool> openNotificationSettings() async {
    try {
      await _settingsChannel.invokeMethod<void>('openNotificationSettings');
      return true;
    } on MissingPluginException {
      // Native channels added during development require a full app restart.
      // Keep the permission flow safe if an older engine is still running.
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> schedulePrayerNotifications({
    required Coordinates coordinates,
    required PrayerCalculationParameters calculationParameters,
    required int reminderMinutes,
    required Set<PrayerReminderType> enabledReminders,
  }) async {
    final android = _android;
    if (android == null) return;

    final canScheduleExactly =
        await android.canScheduleExactNotifications() ?? false;
    final scheduleMode = canScheduleExactly
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final prefs = await SharedPreferences.getInstance();
    final previousIds = prefs.getStringList(_scheduledIdsKey) ?? const [];
    for (final id in previousIds.map(int.tryParse).whereType<int>()) {
      await _notifications.cancel(id);
    }

    final now = tz.TZDateTime.now(tz.local);
    final locale = PlatformDispatcher.instance.locale.languageCode == 'id'
        ? const Locale('id')
        : const Locale('en');
    final l10n = lookupAppLocalizations(locale);
    final scheduledIds = <String>[];
    for (var dayOffset = 0; dayOffset < _daysToSchedule; dayOffset++) {
      final date = DateTime(now.year, now.month, now.day + dayOffset);
      final times = PrayerTimes(
        coordinates: coordinates,
        calculationParameters: calculationParameters,
        dateTime: date,
        locationName: _timezoneName,
      );
      final previousDayTimes = PrayerTimes(
        coordinates: coordinates,
        calculationParameters: calculationParameters,
        dateTime: date.subtract(const Duration(days: 1)),
        locationName: _timezoneName,
      );
      final tahajjud = SunnahInsights(previousDayTimes).lastThirdOfTheNight;
      final prayers =
          <({PrayerReminderType type, String name, DateTime? time})>[
            (
              type: PrayerReminderType.tahajjud,
              name: l10n.prayerNameTahajjud,
              time: tahajjud,
            ),
            (
              type: PrayerReminderType.fajr,
              name: l10n.prayerNameFajr,
              time: times.fajrStartTime,
            ),
            (
              type: PrayerReminderType.sunrise,
              name: l10n.prayerNameSunrise,
              time: times.sunrise,
            ),
            (
              type: PrayerReminderType.dhuhr,
              name: l10n.prayerNameDhuhr,
              time: times.dhuhrStartTime,
            ),
            (
              type: PrayerReminderType.asr,
              name: l10n.prayerNameAsr,
              time: times.asrStartTime,
            ),
            (
              type: PrayerReminderType.maghrib,
              name: l10n.prayerNameMaghrib,
              time: times.maghribStartTime,
            ),
            (
              type: PrayerReminderType.isha,
              name: l10n.prayerNameIsha,
              time: times.ishaStartTime,
            ),
          ];

      for (var prayerIndex = 0; prayerIndex < prayers.length; prayerIndex++) {
        final prayer = prayers[prayerIndex];
        final prayerTime = prayer.time;
        if (prayerTime == null || !enabledReminders.contains(prayer.type)) {
          continue;
        }

        final zonedPrayerTime = tz.TZDateTime.from(prayerTime, tz.local);
        final baseId = 100000 + dayOffset * 30 + prayerIndex * 3;
        final reminderTime = zonedPrayerTime.subtract(
          Duration(minutes: reminderMinutes),
        );
        if (prayer.type.playsAdhan && reminderTime.isAfter(now)) {
          await _notifications.zonedSchedule(
            baseId,
            l10n.prayerReminderNotificationTitle(prayer.name),
            l10n.prayerReminderNotificationBody(reminderMinutes, prayer.name),
            reminderTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                _reminderChannelId,
                'Pengingat sebelum shalat',
                channelDescription: 'Pengingat beberapa menit sebelum shalat',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: scheduleMode,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'prayer-reminder',
          );
          scheduledIds.add('$baseId');
        }

        if (zonedPrayerTime.isAfter(now)) {
          final adhanId = baseId + 1;
          await _notifications.zonedSchedule(
            adhanId,
            l10n.prayerTimeNotificationTitle(prayer.name),
            l10n.prayerTimeNotificationBody(prayer.name),
            zonedPrayerTime,
            NotificationDetails(
              android: AndroidNotificationDetails(
                prayer.type.playsAdhan ? _adhanChannelId : _reminderChannelId,
                prayer.type.playsAdhan
                    ? 'Adzan waktu shalat'
                    : 'Pengingat waktu ibadah',
                channelDescription: prayer.type.playsAdhan
                    ? 'Adzan ketika waktu shalat tiba'
                    : 'Notifikasi waktu ibadah tanpa adzan',
                importance: prayer.type.playsAdhan
                    ? Importance.max
                    : Importance.high,
                priority: prayer.type.playsAdhan ? Priority.max : Priority.high,
                playSound: true,
                sound: prayer.type.playsAdhan
                    ? const RawResourceAndroidNotificationSound(
                        'adhan_cc0_original',
                      )
                    : null,
              ),
            ),
            androidScheduleMode: scheduleMode,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: prayer.type.playsAdhan
                ? 'prayer-time'
                : 'worship-time-notification',
          );
          scheduledIds.add('$adhanId');
        }
      }
    }
    await prefs.setStringList(_scheduledIdsKey, scheduledIds);
  }
}
