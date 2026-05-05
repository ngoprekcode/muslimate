import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muslimate/features/qibla/logic/qibla_calculator.dart';

class QiblaProvider extends ChangeNotifier {
  double? _qiblaBearing;
  double? _heading;
  String? _address;
  String? _error;
  bool _isLoading = true;
  bool _disposed = false;

  double? get qiblaBearing => _qiblaBearing;
  double? get heading => _heading;
  String? get address => _address;
  String? get error => _error;
  bool get isLoading => _isLoading;

  StreamSubscription<CompassEvent>? _compassSubscription;

  QiblaProvider() {
    init();
  }

  Future<void> init() async {
    if (_disposed) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await _determinePosition();
      if (_disposed) return;

      _qiblaBearing = calculateQibla(position.latitude, position.longitude);
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (_disposed) return;

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _address = "${place.locality}, ${place.administrativeArea}";
        }
      } catch (e) {
        _address = "Unknown Location";
      }

      await _compassSubscription?.cancel();
      _compassSubscription = FlutterCompass.events?.listen((event) {
        if (_disposed) return;
        _heading = event.heading;
        notifyListeners();
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshLocation() async {
    await init();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    _disposed = true;
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
