import 'package:prayers_times/prayers_times.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class PrayerProvider extends ChangeNotifier {
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

  PrayerProvider() {
    params.madhab = PrayerMadhab.shafi;
  }

  Future<void> updateLocation(double lat, double lng, {String? name}) async {
    _coordinates = Coordinates(lat, lng);
    if (name != null) {
      _locationName = name;
    } else {
      _locationName = 'Mencari alamat...';
      notifyListeners();
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          // Format: "Kecamatan, Kota" atau yang tersedia
          final subLocality = p.subLocality ?? '';
          final locality = p.locality ?? '';
          _locationName = [subLocality, locality].where((s) => s.isNotEmpty).join(', ');
          if (_locationName.isEmpty) _locationName = 'Lokasi Terdeteksi';
        }
      } catch (_) {
        _locationName = 'Lokasi Terdeteksi';
      }
    }
    _calculatePrayerTimes();
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
}
