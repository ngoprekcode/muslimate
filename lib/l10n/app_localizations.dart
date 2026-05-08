import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla Finder'**
  String get qiblaTitle;

  /// No description provided for @qiblaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point your phone toward the Kaaba'**
  String get qiblaSubtitle;

  /// No description provided for @qiblaLocation.
  ///
  /// In en, this message translates to:
  /// **'{location} • {bearing}° from North'**
  String qiblaLocation(String location, String bearing);

  /// No description provided for @qiblaAligned.
  ///
  /// In en, this message translates to:
  /// **'✓ Facing Qibla'**
  String get qiblaAligned;

  /// No description provided for @qiblaRotate.
  ///
  /// In en, this message translates to:
  /// **'{deg}° {dir}'**
  String qiblaRotate(String deg, String dir);

  /// No description provided for @qiblaRight.
  ///
  /// In en, this message translates to:
  /// **'to the right'**
  String get qiblaRight;

  /// No description provided for @qiblaLeft.
  ///
  /// In en, this message translates to:
  /// **'to the left'**
  String get qiblaLeft;

  /// No description provided for @qiblaInstruction.
  ///
  /// In en, this message translates to:
  /// **'Slowly rotate your phone until the Kaaba is at the peak of the gold marker.'**
  String get qiblaInstruction;

  /// No description provided for @qiblaTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibration tips: '**
  String get qiblaTipTitle;

  /// No description provided for @qiblaTipContent.
  ///
  /// In en, this message translates to:
  /// **'keep away from metal objects, move your phone in a figure-8 pattern for best accuracy.'**
  String get qiblaTipContent;

  /// No description provided for @qiblaPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get qiblaPermissionDenied;

  /// No description provided for @qiblaPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied'**
  String get qiblaPermissionPermanentlyDenied;

  /// No description provided for @qiblaLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading location...'**
  String get qiblaLoading;

  /// No description provided for @north.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get north;

  /// No description provided for @east.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get east;

  /// No description provided for @south.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get south;

  /// No description provided for @west.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get west;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
