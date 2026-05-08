import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum LocationState { idle, loading, done, error }

class LocationProvider extends ChangeNotifier {
  LocationState _state = LocationState.idle;
  Position? _currentPosition;
  String? _address;
  String? _error;
  bool _disposed = false;

  LocationState get state => _state;
  Position? get currentPosition => _currentPosition;
  String? get address => _address;
  String? get error => _error;
  bool get hasLocation => _currentPosition != null;

  Future<Position?> fetchLocation() async {
    if (_state == LocationState.loading) return _currentPosition;

    try {
      _setState(LocationState.loading);
      _error = null;

      final position = await Geolocator.getCurrentPosition();
      _currentPosition = position;

      // Get detail address.
      _address = await _getAddressFromCoordinates(position);
      _setState(LocationState.done);
      return position;
    } catch (e) {
      _error = e.toString();
      _setState(LocationState.error);
      return null;
    }
  }

  Future<Position?> fetchLocationIfNeeded() async {
    if (hasLocation) return _currentPosition;
    return fetchLocation();
  }

  Future<void> updatePosition(Position position) async {
    _currentPosition = position;
    _error = null;
    _setState(LocationState.loading);
    _address = await _getAddressFromCoordinates(position);
    _setState(LocationState.done);
  }

  Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.locality,
          p.subAdministrativeArea,
        ].where((s) => s != null && s.isNotEmpty).join(', ');

        return parts.isNotEmpty ? parts : 'Lokasi Terdeteksi';
      }
    } catch (_) {}
    return 'Lokasi Terdeteksi';
  }

  void reset() {
    _currentPosition = null;
    _address = null;
    _error = null;
    _setState(LocationState.idle);
  }

  void _setState(LocationState s) {
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
