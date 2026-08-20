import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muslimate/core/app_theme.dart';
import 'package:muslimate/core/logic/location_provider.dart';
import 'package:muslimate/core/logic/settings_provider.dart';
import 'package:muslimate/features/location/data/sources/location_local_data_source.dart';
import 'package:muslimate/features/location/logic/location_permission_provider.dart';
import 'package:muslimate/features/notifications/logic/notification_permission_provider.dart';
import 'package:muslimate/features/prayer/data/prayer_notification_scheduler.dart';
import 'package:muslimate/features/prayer/logic/prayer_provider.dart';
import 'package:muslimate/features/qibla/logic/qibla_provider.dart';
import 'package:muslimate/features/settings/data/external_action_service.dart';
import 'package:muslimate/features/settings/ui/settings_screen.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:prayers_times/prayers_times.dart';
import 'package:provider/provider.dart';

/// Wiring for Settings widget tests.
///
/// Every provider the screen depends on is replaced with an in-memory double so
/// no test reaches geolocation, the compass, notifications, or the share sheet.
/// Call `SharedPreferences.setMockInitialValues` before constructing this.
class SettingsTestHarness {
  SettingsTestHarness({
    LocationPermissionState permission = LocationPermissionState.idle,
    LocationState locationState = LocationState.idle,
    String? address,
    Position? fetchResult,
    bool notificationsGranted = true,
  }) : permissionProvider = FakeLocationPermissionProvider(permission),
       locationProvider = FakeLocationProvider(
         state: locationState,
         address: address,
         fetchResult: fetchResult,
       ),
       scheduler = FakePrayerNotificationScheduler(
         granted: notificationsGranted,
       ) {
    silenceCompass();
    prayerProvider = PrayerProvider(notificationScheduler: scheduler);
  }

  final FakeLocationPermissionProvider permissionProvider;
  final FakeLocationProvider locationProvider;
  final FakePrayerNotificationScheduler scheduler;
  final SettingsProvider settingsProvider = SettingsProvider();
  final RecordingExternalActionService actions =
      RecordingExternalActionService();

  late final PrayerProvider prayerProvider;

  Widget build({Locale locale = const Locale('id')}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<LocationProvider>.value(value: locationProvider),
        ChangeNotifierProvider<LocationPermissionProvider>.value(
          value: permissionProvider,
        ),
        ChangeNotifierProvider<PrayerProvider>.value(value: prayerProvider),
        ChangeNotifierProvider<NotificationPermissionProvider>(
          create: (_) => NotificationPermissionProvider(scheduler),
        ),
        ChangeNotifierProvider<QiblaProvider>(create: (_) => QiblaProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('id')],
        home: SettingsScreen(externalActions: actions),
      ),
    );
  }
}

/// Convenience for tests that only need the screen rendered.
Widget buildSettingsTestApp() => SettingsTestHarness().build();

/// Gives the test a surface tall enough to show the whole Settings list, so
/// assertions do not depend on scroll position.
///
/// [width] can be narrowed to check how a row behaves when space runs out.
/// Widget tests render with a fixed-width test font that is far wider than
/// Plus Jakarta Sans, so keep it wide enough for the labels to still fit.
void useTallTestSurface(WidgetTester tester, {double width = 1000}) {
  tester.view.physicalSize = Size(width, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Lets an open SnackBar time out so no timer outlives the test.
Future<void> settleSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

/// Stops `QiblaProvider` from reaching the compass event channel, which is not
/// registered in the test binding.
void silenceCompass() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockStreamHandler(
        const EventChannel('hemanthraj/flutter_compass'),
        MockStreamHandler.inline(onListen: (arguments, sink) {}),
      );
}

class FakeLocationPermissionProvider extends LocationPermissionProvider {
  FakeLocationPermissionProvider(this._state)
    : super(localDataSource: _NoopLocationLocalDataSource());

  LocationPermissionState _state;
  int requestCount = 0;

  @override
  LocationPermissionState get state => _state;

  void setState(LocationPermissionState value) {
    _state = value;
    notifyListeners();
  }

  @override
  Future<void> checkPermissionStatus() async {}

  @override
  Future<Position?> requestLocation() async {
    requestCount++;
    return null;
  }

  @override
  Future<void> openSettings() async {}
}

class FakeLocationProvider extends LocationProvider {
  FakeLocationProvider({
    LocationState state = LocationState.idle,
    String? address,
    Position? fetchResult,
  }) : _state = state,
       _address = address,
       _fetchResult = fetchResult;

  LocationState _state;
  String? _address;
  final Position? _fetchResult;

  int fetchCount = 0;

  @override
  LocationState get state => _state;

  @override
  String? get address => _address;

  @override
  bool get hasLocation => _fetchResult != null;

  @override
  Future<Position?> fetchLocation() async {
    fetchCount++;
    if (_fetchResult != null) {
      _state = LocationState.done;
      _address = _address ?? 'Bandung, ID';
    } else {
      _state = LocationState.error;
    }
    notifyListeners();
    return _fetchResult;
  }

  @override
  Future<void> updatePosition(Position position) async {
    _state = LocationState.done;
    _address = 'Bandung, ID';
    notifyListeners();
  }
}

class RecordingExternalActionService implements ExternalActionService {
  final List<Uri> openedUrls = [];
  final List<String> emailedAddresses = [];
  final List<String> sharedTexts = [];

  bool succeed = true;

  @override
  Future<bool> openUrl(Uri uri) async {
    openedUrls.add(uri);
    return succeed;
  }

  @override
  Future<bool> sendEmail({
    required String address,
    required String subject,
    required String body,
  }) async {
    emailedAddresses.add(address);
    return succeed;
  }

  @override
  Future<bool> shareText({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    sharedTexts.add(text);
    return succeed;
  }
}

class FakePrayerNotificationScheduler implements PrayerNotificationScheduler {
  FakePrayerNotificationScheduler({this.granted = true});

  final bool granted;
  int permissionRequests = 0;
  int scheduleCalls = 0;

  /// When set, [schedulePrayerNotifications] blocks until it completes, so a
  /// test can hold the reschedule open and inspect the UI meanwhile. It stands
  /// in for the hundreds of platform channel round trips the real Android
  /// scheduler makes.
  Completer<void>? scheduleGate;

  @override
  Future<bool> areNotificationsEnabled() async => granted;

  @override
  Future<bool> requestNotificationPermission() async {
    permissionRequests++;
    return granted;
  }

  @override
  Future<bool> openNotificationSettings() async => true;

  @override
  Future<void> schedulePrayerNotifications({
    required Coordinates coordinates,
    required PrayerCalculationParameters calculationParameters,
    required int reminderMinutes,
    required Set<PrayerReminderType> enabledReminders,
  }) async {
    scheduleCalls++;
    final gate = scheduleGate;
    if (gate != null) await gate.future;
  }
}

class _NoopLocationLocalDataSource implements LocationLocalDataSource {
  @override
  Future<LocationPermissionState?> getPermissionState() async => null;

  @override
  Future<void> savePermissionState(LocationPermissionState state) async {}
}

/// A stand-in position for tests that need a successful location fetch.
Position testPosition() {
  return Position(
    latitude: -6.9175,
    longitude: 107.6191,
    timestamp: DateTime.utc(2026, 1, 1),
    accuracy: 1,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}
