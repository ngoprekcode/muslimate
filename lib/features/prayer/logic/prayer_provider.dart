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

  // Koordinat Bandung: -6.9175, 107.6191
  final coordinates = Coordinates(-6.9175, 107.6191);
  
  // Menggunakan Singapore (MUIS) karena sudutnya sama dengan Kemenag RI (Subuh 20, Isya 18)
  final params = PrayerCalculationMethod.singapore();

  PrayerProvider() {
    params.madhab = PrayerMadhab.shafi;
    _calculatePrayerTimes();
  }

  void updateDate(DateTime date) {
    _selectedDate = date;
    _calculatePrayerTimes();
  }

  void _calculatePrayerTimes() {
    _prayerTimes = PrayerTimes(
      coordinates: coordinates,
      calculationParameters: params,
      dateTime: selectedDate,
      locationName: 'Asia/Jakarta',
    );
    _sunnahTimes = SunnahInsights(_prayerTimes!);
    notifyListeners();
  }

  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    // Library prayers_times mengembalikan waktu dalam UTC.
    // Kita harus konversi ke local time HP agar sesuai dengan jam di Indonesia.
    return DateFormat('HH:mm').format(time);
  }

  String get nextPrayer => _prayerTimes?.nextPrayer() ?? 'none';
  String get currentPrayer => _prayerTimes?.currentPrayer() ?? 'none';

  Duration? get timeRemaining {
    if (_prayerTimes == null) return null;
    final next = _prayerTimes!.timeForPrayer(nextPrayer);
    if (next == null) return null;
    
    // Hitung selisih waktu untuk hitungan mundur
    final now = DateTime.now();
    return next.isAfter(now) 
        ? next.difference(now) 
        : null;
  }
}
