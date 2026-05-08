import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import 'package:muslimate/generated/l10n/app_localizations.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime _focusedDay = DateTime.now();
  
  DateTime get focusedDay => _focusedDay;

  int get month => _focusedDay.month;
  int get year => _focusedDay.year;

  void nextMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    notifyListeners();
  }

  void prevMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    notifyListeners();
  }

  String getHijriDateRange(AppLocalizations l10n) {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    
    final hijriFirst = HijriCalendar.fromDate(firstDay);
    final hijriLast = HijriCalendar.fromDate(lastDay);

    if (hijriFirst.hMonth == hijriLast.hMonth) {
      return '${_getHijriMonthName(l10n, hijriFirst.hMonth)} ${hijriFirst.hYear} H';
    } else {
      return '${_getHijriMonthName(l10n, hijriFirst.hMonth)} — ${_getHijriMonthName(l10n, hijriLast.hMonth)} ${hijriLast.hYear} H';
    }
  }

  String _getHijriMonthName(AppLocalizations l10n, int month) {
    switch (month) {
      case 1: return l10n.hijriMonth1;
      case 2: return l10n.hijriMonth2;
      case 3: return l10n.hijriMonth3;
      case 4: return l10n.hijriMonth4;
      case 5: return l10n.hijriMonth5;
      case 6: return l10n.hijriMonth6;
      case 7: return l10n.hijriMonth7;
      case 8: return l10n.hijriMonth8;
      case 9: return l10n.hijriMonth9;
      case 10: return l10n.hijriMonth10;
      case 11: return l10n.hijriMonth11;
      case 12: return l10n.hijriMonth12;
      default: return '';
    }
  }

  String getHolidayName(AppLocalizations l10n, String key) {
    switch (key) {
      case 'holidayIslamicNewYear': return l10n.holidayIslamicNewYear;
      case 'holidayAshura': return l10n.holidayAshura;
      case 'holidayMawlid': return l10n.holidayMawlid;
      case 'holidayIsraMiraj': return l10n.holidayIsraMiraj;
      case 'holidayRamadan': return l10n.holidayRamadan;
      case 'holidayNuzululQuran': return l10n.holidayNuzululQuran;
      case 'holidayEidAlFitr': return l10n.holidayEidAlFitr;
      case 'holidayArafah': return l10n.holidayArafah;
      case 'holidayEidAlAdha': return l10n.holidayEidAlAdha;
      case 'holidayShawwalFast': return l10n.holidayShawwalFast;
      case 'holidayTasua': return l10n.holidayTasua;
      case 'holidayTasyrik': return l10n.holidayTasyrik;
      default: return '';
    }
  }

  String getHolidayDescription(AppLocalizations l10n, String key) {
    switch (key) {
      case 'holidayIslamicNewYear': return l10n.holidayIslamicNewYearDesc;
      case 'holidayAshura': return l10n.holidayAshuraDesc;
      case 'holidayMawlid': return l10n.holidayMawlidDesc;
      case 'holidayIsraMiraj': return l10n.holidayIsraMirajDesc;
      case 'holidayRamadan': return l10n.holidayRamadanDesc;
      case 'holidayNuzululQuran': return l10n.holidayNuzululQuranDesc;
      case 'holidayEidAlFitr': return l10n.holidayEidAlFitrDesc;
      case 'holidayArafah': return l10n.holidayArafahDesc;
      case 'holidayEidAlAdha': return l10n.holidayEidAlAdhaDesc;
      case 'holidayShawwalFast': return l10n.holidayShawwalFastDesc;
      case 'holidayTasua': return l10n.holidayTasuaDesc;
      case 'holidayTasyrik': return l10n.holidayTasyrikDesc;
      default: return '';
    }
  }

  List<CalendarDay> getDaysInMonth() {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    
    final daysCount = lastDay.day;
    final offset = firstDay.weekday % 7; // Sunday = 0

    List<CalendarDay> days = [];
    
    // Previous month days for padding
    final prevMonthLastDay = DateTime(_focusedDay.year, _focusedDay.month, 0).day;
    for (int i = offset - 1; i >= 0; i--) {
      days.add(CalendarDay(
        date: DateTime(_focusedDay.year, _focusedDay.month - 1, prevMonthLastDay - i),
        isCurrentMonth: false,
      ));
    }

    // Current month days
    for (int i = 1; i <= daysCount; i++) {
      days.add(CalendarDay(
        date: DateTime(_focusedDay.year, _focusedDay.month, i),
        isCurrentMonth: true,
      ));
    }

    // Next month days for padding to complete the grid (usually 42 days total for 6 rows)
    final remaining = 42 - days.length;
    for (int i = 1; i <= remaining; i++) {
      days.add(CalendarDay(
        date: DateTime(_focusedDay.year, _focusedDay.month + 1, i),
        isCurrentMonth: false,
      ));
    }

    return days;
  }
}

class CalendarDay {
  final DateTime date;
  final bool isCurrentMonth;
  final HijriCalendar hijriDate;
  String? holidayKey;

  CalendarDay({required this.date, required this.isCurrentMonth})
      : hijriDate = HijriCalendar.fromDate(date) {
    holidayKey = _getHolidayKey();
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String? _getHolidayKey() {
    final m = hijriDate.hMonth;
    final d = hijriDate.hDay;

    if (m == 1 && d == 1) return 'holidayIslamicNewYear';
    if (m == 1 && d == 9) return 'holidayTasua';
    if (m == 1 && d == 10) return 'holidayAshura';
    if (m == 3 && d == 12) return 'holidayMawlid';
    if (m == 7 && d == 27) return 'holidayIsraMiraj';
    if (m == 9 && d == 1) return 'holidayRamadan';
    if (m == 9 && d == 17) return 'holidayNuzululQuran';
    if (m == 10 && d == 1) return 'holidayEidAlFitr';
    if (m == 10 && d == 2) return 'holidayShawwalFast';
    if (m == 12 && d == 9) return 'holidayArafah';
    if (m == 12 && d == 10) return 'holidayEidAlAdha';
    if (m == 12 && (d == 11 || d == 12 || d == 13)) return 'holidayTasyrik';
    return null;
  }
}
