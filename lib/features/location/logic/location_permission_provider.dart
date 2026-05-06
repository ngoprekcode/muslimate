import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationPermissionState { idle, loading, denied, blocked }

class LocationPermissionProvider extends ChangeNotifier {
  LocationPermissionState _state = LocationPermissionState.idle;
  bool _disposed = false;

  LocationPermissionState get state => _state;

  Future<Position?> requestLocation() async {
    _setState(LocationPermissionState.loading);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setState(LocationPermissionState.denied);
        return null;
      }

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
      _setState(LocationPermissionState.idle);
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
    _state = s;
    notifyListeners();
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
