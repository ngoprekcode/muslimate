import 'package:prayers_times/prayers_times.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerProvider extends ChangeNotifier {
  PrayerTimes? _prayerTimes;
  PrayerTimes? get prayerTimes => _prayerTimes;

  SunnahInsights? _sunnahTimes;
  SunnahInsights? get sunnahTimes => _sunnahTimes;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  final coordinates = Coordinates(-6.9175, 107.6191);
  final params = PrayerCalculationMethod.singapore();

  PrayerProvider() {
    params.madhab = PrayerMadhab.shafi;
    _calculatePrayerTimes();
  }

  void updateDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    _calculatePrayerTimes();
  }

  void _calculatePrayerTimes() {
    _prayerTimes = PrayerTimes(
      coordinates: coordinates,
      calculationParameters: params,
      dateTime: _selectedDate,
      locationName: 'Asia/Jakarta',
    );
    _sunnahTimes = SunnahInsights(_prayerTimes!);
    notifyListeners();
  }

  DateTime? getTahajjudToday() {
    if (_prayerTimes == null) return null;
    final yesterday = PrayerTimes(
      coordinates: coordinates,
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
}
