// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get qiblaTitle => 'Cek Kiblat';

  @override
  String get qiblaSubtitle => 'Arahkan ponsel Anda ke Ka\'bah';

  @override
  String qiblaLocation(String location, String bearing) {
    return '$location • $bearing° dari Utara';
  }

  @override
  String get qiblaAligned => '✓ Lurus ke Kiblat';

  @override
  String qiblaRotate(String deg, String dir) {
    return '$deg° $dir';
  }

  @override
  String get qiblaRight => 'ke kanan';

  @override
  String get qiblaLeft => 'ke kiri';

  @override
  String get qiblaInstruction =>
      'Putar ponsel perlahan hingga Ka\'bah berada di puncak penanda emas.';

  @override
  String get qiblaTipTitle => 'Tips kalibrasi: ';

  @override
  String get qiblaTipContent =>
      'jauhkan dari benda logam, gerakkan ponsel membentuk angka 8 untuk akurasi terbaik.';

  @override
  String get qiblaPermissionDenied => 'Izin lokasi ditolak';

  @override
  String get qiblaPermissionPermanentlyDenied =>
      'Izin lokasi ditolak secara permanen';

  @override
  String get qiblaLoading => 'Memuat lokasi...';

  @override
  String get north => 'U';

  @override
  String get east => 'T';

  @override
  String get south => 'S';

  @override
  String get west => 'B';
}
