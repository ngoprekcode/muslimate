import 'package:flutter/foundation.dart';

/// Social platforms Muslimate publishes an account on.
enum SocialPlatform { instagram, tiktok, youtube, x }

/// A single Muslimate social media account.
class SocialAccount {
  const SocialAccount({
    required this.platform,
    required this.name,
    required this.handle,
    required this.url,
  });

  final SocialPlatform platform;
  final String name;
  final String handle;
  final String url;

  Uri get uri => Uri.parse(url);
}

/// Single source of truth for every destination the Settings screen opens.
///
/// The values below are placeholders for SCRUM-12. Replace them with the real
/// Muslimate channels before release — each one is read from exactly one place,
/// so editing this file updates the whole Settings screen.
abstract final class AppLinks {
  static const appVersion = '1.0.0';

  static const feedbackEmail = 'halo@muslimate.app';
  static const helpUrl = 'https://muslimate.app/bantuan';
  static const privacyUrl = 'https://muslimate.app/privasi';
  static const websiteUrl = 'https://muslimate.app';

  static const androidApplicationId = 'com.ngoprekcode.muslimate.muslimate';
  static const appStoreId = '0000000000';

  static Uri get helpUri => Uri.parse(helpUrl);
  static Uri get privacyUri => Uri.parse(privacyUrl);
  static Uri get websiteUri => Uri.parse(websiteUrl);

  static Uri get androidStoreUri => Uri.parse(
    'https://play.google.com/store/apps/details?id=$androidApplicationId',
  );

  static Uri get iosStoreUri =>
      Uri.parse('https://apps.apple.com/app/id$appStoreId');

  /// The store listing matching the platform the app is running on.
  static Uri storeUri([TargetPlatform? platform]) {
    return switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => iosStoreUri,
      _ => androidStoreUri,
    };
  }

  static const socialAccounts = <SocialAccount>[
    SocialAccount(
      platform: SocialPlatform.instagram,
      name: 'Instagram',
      handle: '@muslimate.app',
      url: 'https://www.instagram.com/muslimate.app',
    ),
    SocialAccount(
      platform: SocialPlatform.tiktok,
      name: 'TikTok',
      handle: '@muslimate.app',
      url: 'https://www.tiktok.com/@muslimate.app',
    ),
    SocialAccount(
      platform: SocialPlatform.youtube,
      name: 'YouTube',
      handle: '@muslimate',
      url: 'https://www.youtube.com/@muslimate',
    ),
    SocialAccount(
      platform: SocialPlatform.x,
      name: 'X',
      handle: '@muslimate',
      url: 'https://x.com/muslimate',
    ),
  ];
}
