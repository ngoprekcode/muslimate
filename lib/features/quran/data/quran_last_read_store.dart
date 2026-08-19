import 'package:muslimate/features/quran/models/quran_last_read.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class QuranLastReadStore {
  Future<QuranLastRead?> load();
  Future<void> save(QuranLastRead position);
}

class SharedPreferencesQuranLastReadStore implements QuranLastReadStore {
  static const _lastReadKey = 'quran.last_read.v1';

  @override
  Future<QuranLastRead?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_lastReadKey);
    return stored == null ? null : QuranLastRead.tryParse(stored);
  }

  @override
  Future<void> save(QuranLastRead position) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_lastReadKey, position.serialized);
  }
}
