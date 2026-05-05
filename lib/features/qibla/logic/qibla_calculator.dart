import 'dart:math';

/// Kaaba coordinates (approx)
const double _kaabaLat = 21.422487;
const double _kaabaLng = 39.826206;

/// Hitung bearing (derajat) dari titik (lat1, lon1) ke Kaaba.
/// Output: 0..360 (derajat), 0 = Utara, 90 = Timur
double calculateQibla(double lat1Deg, double lon1Deg) {
  // convert to radians
  final lat1 = _degToRad(lat1Deg);
  final lon1 = _degToRad(lon1Deg);
  final lat2 = _degToRad(_kaabaLat);
  final lon2 = _degToRad(_kaabaLng);

  final dLon = lon2 - lon1;

  final y = sin(dLon) * cos(lat2);
  final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

  double bearingRad = atan2(y, x);
  double bearingDeg = _radToDeg(bearingRad);

  // Normalize to 0..360
  bearingDeg = (bearingDeg + 360) % 360;
  return bearingDeg;
}

double _degToRad(double deg) => deg * pi / 180.0;
double _radToDeg(double rad) => rad * 180.0 / pi;
