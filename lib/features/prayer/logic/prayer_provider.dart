import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerProvider extends ChangeNotifier {
  PrayerTimes? _prayerTimes;
  PrayerTimes? get prayerTimes => _prayerTimes;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  // Default to Bandung, Indonesia
  final coordinates = Coordinates(-6.9175, 107.6191);
  final params = CalculationMethod.singapore.getParameters();

  PrayerProvider() {
    params.madhab = Madhab.shafi;
    _calculatePrayerTimes();
  }

  void updateDate(DateTime date) {
    _selectedDate = date;
    _calculatePrayerTimes();
  }

  void _calculatePrayerTimes() {
    final dateComponents = DateComponents.from(selectedDate);
    _prayerTimes = PrayerTimes(coordinates, dateComponents, params);
    notifyListeners();
  }

  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat.Hm().format(time.toLocal());
  }

  Prayer? get nextPrayer => _prayerTimes?.nextPrayer();
  Prayer? get currentPrayer => _prayerTimes?.currentPrayer();

  Duration? get timeRemaining {
    final next = _prayerTimes?.timeForPrayer(nextPrayer ?? Prayer.none);
    if (next == null) return null;
    return next.difference(DateTime.now());
  }
}
