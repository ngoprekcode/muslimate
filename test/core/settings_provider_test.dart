import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/core/logic/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('follows the device locale until a language is chosen', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = SettingsProvider();
    await Future<void>.delayed(Duration.zero);

    expect(provider.language, AppLanguage.system);
    expect(provider.locale, isNull);

    provider.dispose();
  });

  test('language choice survives a new provider instance', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = SettingsProvider();
    await Future<void>.delayed(Duration.zero);

    await provider.setLanguage(AppLanguage.english);
    expect(provider.locale, const Locale('en'));

    final restored = SettingsProvider();
    await Future<void>.delayed(Duration.zero);

    expect(restored.language, AppLanguage.english);
    expect(restored.locale, const Locale('en'));

    provider.dispose();
    restored.dispose();
  });

  test('Indonesian maps to the id locale', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = SettingsProvider();
    await Future<void>.delayed(Duration.zero);

    await provider.setLanguage(AppLanguage.indonesian);

    expect(provider.language, AppLanguage.indonesian);
    expect(provider.locale, const Locale('id'));

    provider.dispose();
  });

  test(
    'an unknown stored language falls back to following the device',
    () async {
      SharedPreferences.setMockInitialValues({
        'flutter.app_language': 'klingon',
      });
      final provider = SettingsProvider();
      await Future<void>.delayed(Duration.zero);

      expect(provider.language, AppLanguage.system);
      expect(provider.locale, isNull);

      provider.dispose();
    },
  );

  test('changing language does not disturb the other settings', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = SettingsProvider();
    await Future<void>.delayed(Duration.zero);

    await provider.completeOnboarding();
    await provider.setLanguage(AppLanguage.english);

    final restored = SettingsProvider();
    await Future<void>.delayed(Duration.zero);

    expect(restored.onboardingDone, isTrue);
    expect(restored.isDark, isFalse);
    expect(restored.language, AppLanguage.english);

    provider.dispose();
    restored.dispose();
  });
}
