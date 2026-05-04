import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDark = false;
  bool _onboardingDone = false;

  bool get isDark => _isDark;
  bool get onboardingDone => _onboardingDone;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('dark_mode') ?? false;
    _onboardingDone = prefs.getBool('onboarding_done') ?? false;
    notifyListeners();
  }

  Future<void> toggleDark() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDark);
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
  }
}
