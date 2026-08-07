import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muslimate/features/location/data/sources/location_local_data_source.dart';

enum LocationPermissionState { idle, loading, denied, blocked, granted }

class LocationPermissionProvider extends ChangeNotifier {
  final LocationLocalDataSource _localDataSource;
  LocationPermissionState _state = LocationPermissionState.idle;
  bool _disposed = false;

  LocationPermissionState get state => _state;

  LocationPermissionProvider({LocationLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? LocationLocalDataSourceImpl() {
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    final savedState = await _localDataSource.getPermissionState();
    if (savedState != null) {
      _state = savedState;
      notifyListeners();
    }
    // Sinkronkan dengan status sistem
    await checkPermissionStatus();
  }

  Future<void> checkPermissionStatus() async {
    final status = await Geolocator.checkPermission();

    if (status == LocationPermission.always ||
        status == LocationPermission.whileInUse) {
      _setState(LocationPermissionState.granted);
    } else if (status == LocationPermission.deniedForever) {
      _setState(LocationPermissionState.blocked);
    } else {
      // Jika statusnya 'denied' di sistem (bisa jadi baru install atau baru direset),
      // kita cek apakah kita punya state 'denied' atau 'blocked' yang sudah tersimpan.
      // Kita hanya reset ke 'idle' jika state sekarang bukan 'denied' dan bukan 'blocked'.
      if (_state != LocationPermissionState.denied &&
          _state != LocationPermissionState.blocked) {
        _setState(LocationPermissionState.idle);
      }
    }
  }

  Future<Position?> requestLocation() async {
    _setState(LocationPermissionState.loading);

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _setState(LocationPermissionState.denied);
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setState(LocationPermissionState.blocked);
        return null;
      }

      final position = await Geolocator.getCurrentPosition();
      _setState(LocationPermissionState.granted);
      return position;
    } catch (_) {
      _setState(LocationPermissionState.denied);
      return null;
    }
  }

  Future<void> openSettings() => Geolocator.openAppSettings();

  void reset() => _setState(LocationPermissionState.idle);

  void _setState(LocationPermissionState s) {
    if (_disposed) return;
    if (_state == s) return;
    _state = s;
    notifyListeners();
    _localDataSource.savePermissionState(s);
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
