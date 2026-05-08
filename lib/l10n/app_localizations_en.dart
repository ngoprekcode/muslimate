// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get qiblaTitle => 'Qibla Finder';

  @override
  String get qiblaSubtitle => 'Point your phone toward the Kaaba';

  @override
  String qiblaLocation(String location, String bearing) {
    return '$location • $bearing° from North';
  }

  @override
  String get qiblaAligned => '✓ Facing Qibla';

  @override
  String qiblaRotate(String deg, String dir) {
    return '$deg° $dir';
  }

  @override
  String get qiblaRight => 'to the right';

  @override
  String get qiblaLeft => 'to the left';

  @override
  String get qiblaInstruction =>
      'Slowly rotate your phone until the Kaaba is at the peak of the gold marker.';

  @override
  String get qiblaTipTitle => 'Calibration tips: ';

  @override
  String get qiblaTipContent =>
      'keep away from metal objects, move your phone in a figure-8 pattern for best accuracy.';

  @override
  String get qiblaPermissionDenied => 'Location permission denied';

  @override
  String get qiblaPermissionPermanentlyDenied =>
      'Location permission permanently denied';

  @override
  String get qiblaLoading => 'Loading location...';

  @override
  String get north => 'N';

  @override
  String get east => 'E';

  @override
  String get south => 'S';

  @override
  String get west => 'W';
}
