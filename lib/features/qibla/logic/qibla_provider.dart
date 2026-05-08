import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:muslimate/features/qibla/logic/qibla_calculator.dart';

class QiblaProvider extends ChangeNotifier {
  double? _qiblaBearing;
  double? _heading;
  bool _disposed = false;

  double? get qiblaBearing => _qiblaBearing;
  double? get heading => _heading;

  StreamSubscription<CompassEvent>? _compassSubscription;

  QiblaProvider() {
    _initCompass();
  }

  void _initCompass() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (_disposed) return;
      _heading = event.heading;
      notifyListeners();
    });
  }

  void updateLocation(double lat, double lng) {
    _qiblaBearing = calculateQibla(lat, lng);
    notifyListeners();
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
