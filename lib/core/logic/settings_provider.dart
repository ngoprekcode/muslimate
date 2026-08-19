import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The language the user picked in Settings.
///
/// [AppLanguage.system] keeps following the device locale, which is how the
/// app behaved before a language could be chosen.
enum AppLanguage { system, indonesian, english }

class SettingsProvider extends ChangeNotifier {
  static const _darkModeKey = 'dark_mode';
  static const _onboardingDoneKey = 'onboarding_done';
  static const _languageKey = 'app_language';

  bool _isDark = false;
  bool _onboardingDone = false;
  AppLanguage _language = AppLanguage.system;
  bool _disposed = false;

  bool get isDark => _isDark;
  bool get onboardingDone => _onboardingDone;
  AppLanguage get language => _language;

  /// The locale to hand to `MaterialApp`.
  ///
  /// `null` means "follow the device", which is what `MaterialApp` expects.
  Locale? get locale => switch (_language) {
    AppLanguage.system => null,
    AppLanguage.indonesian => const Locale('id'),
    AppLanguage.english => const Locale('en'),
  };

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (_disposed) return;
    _isDark = prefs.getBool(_darkModeKey) ?? false;
    _onboardingDone = prefs.getBool(_onboardingDoneKey) ?? false;
    _language = _languageFromName(prefs.getString(_languageKey));
    notifyListeners();
  }

  Future<void> toggleDark() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDark);
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingDoneKey, true);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.name);
  }

  /// Falls back to following the device when nothing valid is stored.
  AppLanguage _languageFromName(String? name) {
    return AppLanguage.values.firstWhere(
      (value) => value.name == name,
      orElse: () => AppLanguage.system,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
