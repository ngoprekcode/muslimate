import 'package:muslimate/features/quran/models/quran_bookmark.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class QuranBookmarkStore {
  Future<Set<QuranBookmark>> load();
  Future<void> save(Iterable<QuranBookmark> bookmarks);
}

class SharedPreferencesQuranBookmarkStore implements QuranBookmarkStore {
  static const _bookmarksKey = 'quran.bookmarks.v1';

  @override
  Future<Set<QuranBookmark>> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences
            .getStringList(_bookmarksKey)
            ?.map(QuranBookmark.tryParse)
            .whereType<QuranBookmark>()
            .toSet() ??
        <QuranBookmark>{};
  }

  @override
  Future<void> save(Iterable<QuranBookmark> bookmarks) async {
    final preferences = await SharedPreferences.getInstance();
    final ids = bookmarks.map((bookmark) => bookmark.id).toSet().toList()
      ..sort();
    await preferences.setStringList(_bookmarksKey, ids);
  }
}
