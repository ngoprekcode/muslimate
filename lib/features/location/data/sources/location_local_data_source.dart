import 'package:muslimate/features/location/logic/location_permission_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocationLocalDataSource {
  Future<void> savePermissionState(LocationPermissionState state);
  Future<LocationPermissionState?> getPermissionState();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  static const _prefKey = 'location_permission_state';

  @override
  Future<void> savePermissionState(LocationPermissionState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, state.index);
  }

  @override
  Future<LocationPermissionState?> getPermissionState() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_prefKey);
    if (index != null &&
        index >= 0 &&
        index < LocationPermissionState.values.length) {
      return LocationPermissionState.values[index];
    }
    return null;
  }
}
