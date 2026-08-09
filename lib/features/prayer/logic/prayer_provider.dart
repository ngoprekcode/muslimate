import 'package:prayers_times/prayers_times.dart';
import 'package:flutter/material.dart';
import 'package:muslimate/features/prayer/data/prayer_notification_scheduler.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AsrMadhhab { shafi, hanafi }

class PrayerProvider extends ChangeNotifier {
  static const _reminderMinutesKey = 'prayer_reminder_minutes';
  static const _asrMadhhabKey = 'prayer_asr_madhhab';
  static const _latitudeKey = 'prayer_last_latitude';
  static const _longitudeKey = 'prayer_last_longitude';
  static const _enabledRemindersKey = 'prayer_enabled_reminders';
  static const _defaultEnabledReminders = {
    PrayerReminderType.fajr,
    PrayerReminderType.maghrib,
  };

  PrayerTimes? _prayerTimes;
  PrayerTimes? get prayerTimes => _prayerTimes;

  SunnahInsights? _sunnahTimes;
  SunnahInsights? get sunnahTimes => _sunnahTimes;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  Coordinates? _coordinates;
  Coordinates? get coordinates => _coordinates;

  String _locationName = 'Mencari lokasi...';
  String get locationName => _locationName;

  final params = PrayerCalculationMethod.singapore();

  int _reminderMinutes = 10;
  int get reminderMinutes => _reminderMinutes;

  AsrMadhhab _asrMadhhab = AsrMadhhab.shafi;
  AsrMadhhab get asrMadhhab => _asrMadhhab;

  Set<PrayerReminderType> _enabledReminders = {..._defaultEnabledReminders};
  bool isReminderEnabled(PrayerReminderType type) =>
      _enabledReminders.contains(type);

  bool _disposed = false;
  final PrayerNotificationScheduler _notificationScheduler;

  PrayerProvider({PrayerNotificationScheduler? notificationScheduler})
    : _notificationScheduler =
          notificationScheduler ?? const NoopPrayerNotificationScheduler() {
    params.madhab = PrayerMadhab.shafi;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (_disposed) return;
    _reminderMinutes = prefs.getInt(_reminderMinutesKey) ?? 10;
    final storedReminders = prefs.getStringList(_enabledRemindersKey);
    if (storedReminders != null) {
      _enabledReminders = PrayerReminderType.values
          .where((type) => storedReminders.contains(type.name))
          .toSet();
    }
    final latitude = prefs.getDouble(_latitudeKey);
    final longitude = prefs.getDouble(_longitudeKey);
    if (latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180) {
      _coordinates = Coordinates(latitude, longitude);
    }
    final storedMadhhab = prefs.getString(_asrMadhhabKey);
    _asrMadhhab = storedMadhhab == AsrMadhhab.hanafi.name
        ? AsrMadhhab.hanafi
        : AsrMadhhab.shafi;
    params.madhab = _prayerMadhabFor(_asrMadhhab);
    _calculatePrayerTimes();
    await _schedulePrayerNotifications();
    if (!_disposed) notifyListeners();
  }

  Future<void> setReminderMinutes(int minutes) async {
    await _notificationScheduler.requestPermissions();
    if (_reminderMinutes == minutes) {
      await _schedulePrayerNotifications();
      return;
    }
    _reminderMinutes = minutes;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderMinutesKey, minutes);
    await _schedulePrayerNotifications();
  }

  Future<void> setAsrMadhhab(AsrMadhhab madhhab) async {
    if (_asrMadhhab == madhhab) return;
    _asrMadhhab = madhhab;
    params.madhab = _prayerMadhabFor(madhhab);
    _calculatePrayerTimes();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_asrMadhhabKey, madhhab.name);
    await _schedulePrayerNotifications();
  }

  Future<void> toggleReminder(PrayerReminderType type) async {
    final enabled = _enabledReminders.contains(type);
    if (enabled) {
      _enabledReminders.remove(type);
    } else {
      await _notificationScheduler.requestPermissions();
      _enabledReminders.add(type);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _enabledRemindersKey,
      _enabledReminders.map((type) => type.name).toList()..sort(),
    );
    await _schedulePrayerNotifications();
  }

  String _prayerMadhabFor(AsrMadhhab madhhab) {
    return madhhab == AsrMadhhab.hanafi
        ? PrayerMadhab.hanafi
        : PrayerMadhab.shafi;
  }

  Future<void> updateLocation(double lat, double lng, {String? address}) async {
    _coordinates = Coordinates(lat, lng);
    if (address != null) {
      _locationName = address;
    }
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setDouble(_latitudeKey, lat),
      prefs.setDouble(_longitudeKey, lng),
    ]);
    _calculatePrayerTimes();
    await _schedulePrayerNotifications();
  }

  Future<void> _schedulePrayerNotifications() async {
    if (_coordinates == null || _disposed) return;
    await _notificationScheduler.schedulePrayerNotifications(
      coordinates: _coordinates!,
      calculationParameters: params,
      reminderMinutes: _reminderMinutes,
      enabledReminders: _enabledReminders,
    );
  }

  void updateDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    _calculatePrayerTimes();
  }

  void _calculatePrayerTimes() {
    if (_coordinates == null) return;
    _prayerTimes = PrayerTimes(
      coordinates: _coordinates!,
      calculationParameters: params,
      dateTime: _selectedDate,
      locationName: 'Asia/Jakarta',
    );
    _sunnahTimes = SunnahInsights(_prayerTimes!);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  DateTime? getTahajjudToday() {
    if (_prayerTimes == null || _coordinates == null) return null;
    final yesterday = PrayerTimes(
      coordinates: _coordinates!,
      calculationParameters: params,
      dateTime: _selectedDate.subtract(const Duration(days: 1)),
      locationName: 'Asia/Jakarta',
    );
    return SunnahInsights(yesterday).lastThirdOfTheNight;
  }

  DateTime? getTahajjudTomorrow() {
    return _sunnahTimes?.lastThirdOfTheNight;
  }

  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('HH:mm').format(time);
  }

  String getHijriDate(AppLocalizations l10n, {DateTime? date}) {
    final h = HijriCalendar.fromDate(date ?? _selectedDate);
    return '${h.hDay} ${getHijriMonthName(l10n, h.hMonth)} ${h.hYear} H';
  }

  String getHijriMonthName(AppLocalizations l10n, int month) {
    switch (month) {
      case 1:
        return l10n.hijriMonth1;
      case 2:
        return l10n.hijriMonth2;
      case 3:
        return l10n.hijriMonth3;
      case 4:
        return l10n.hijriMonth4;
      case 5:
        return l10n.hijriMonth5;
      case 6:
        return l10n.hijriMonth6;
      case 7:
        return l10n.hijriMonth7;
      case 8:
        return l10n.hijriMonth8;
      case 9:
        return l10n.hijriMonth9;
      case 10:
        return l10n.hijriMonth10;
      case 11:
        return l10n.hijriMonth11;
      case 12:
        return l10n.hijriMonth12;
      default:
        return '';
    }
  }

  /// Mendapatkan prayer yang sedang berlangsung.
  String? getCurrentPrayer() {
    if (_prayerTimes == null) return null;
    final now = DateTime.now();

    if (now.isAfter(_prayerTimes!.ishaStartTime!)) return PrayerType.isha;
    if (now.isAfter(_prayerTimes!.maghribStartTime!)) return PrayerType.maghrib;
    if (now.isAfter(_prayerTimes!.asrStartTime!)) return PrayerType.asr;
    if (now.isAfter(_prayerTimes!.dhuhrStartTime!)) return PrayerType.dhuhr;
    if (now.isAfter(_prayerTimes!.fajrStartTime!)) return PrayerType.fajr;

    return PrayerType.isha;
  }

  /// Mendapatkan prayer berikutnya.
  String? getNextPrayer() {
    if (_prayerTimes == null) return null;
    final now = DateTime.now();

    if (now.isBefore(_prayerTimes!.fajrStartTime!)) return PrayerType.fajr;
    if (now.isBefore(_prayerTimes!.dhuhrStartTime!)) return PrayerType.dhuhr;
    if (now.isBefore(_prayerTimes!.asrStartTime!)) return PrayerType.asr;
    if (now.isBefore(_prayerTimes!.maghribStartTime!)) {
      return PrayerType.maghrib;
    }
    if (now.isBefore(_prayerTimes!.ishaStartTime!)) return PrayerType.isha;

    return PrayerType.fajr;
  }

  /// Mendapatkan waktu prayer berikutnya.
  DateTime? getNextPrayerTime() {
    final next = getNextPrayer();
    if (next == null || _prayerTimes == null) return null;

    switch (next) {
      case PrayerType.fajr:
        if (DateTime.now().isAfter(_prayerTimes!.ishaStartTime!)) {
          return _prayerTimes!.fajrStartTime!.add(const Duration(days: 1));
        }
        return _prayerTimes!.fajrStartTime;
      case PrayerType.dhuhr:
        return _prayerTimes!.dhuhrStartTime;
      case PrayerType.asr:
        return _prayerTimes!.asrStartTime;
      case PrayerType.maghrib:
        return _prayerTimes!.maghribStartTime;
      case PrayerType.isha:
        return _prayerTimes!.ishaStartTime;
      default:
        return null;
    }
  }
}
