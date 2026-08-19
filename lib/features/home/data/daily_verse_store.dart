import 'package:muslimate/features/home/models/daily_verse_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class DailyVerseStore {
  Future<DailyVerseSelection?> load();
  Future<void> save(DailyVerseSelection selection);
}

class SharedPreferencesDailyVerseStore implements DailyVerseStore {
  static const _selectionKey = 'home.daily_verse.v1';

  @override
  Future<DailyVerseSelection?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_selectionKey);
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final verseId = int.tryParse(parts[1]);
    if (parts[0].length != 8 || verseId == null || verseId < 1) return null;
    return DailyVerseSelection(dateKey: parts[0], verseId: verseId);
  }

  @override
  Future<void> save(DailyVerseSelection selection) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _selectionKey,
      '${selection.dateKey}:${selection.verseId}',
    );
  }
}
