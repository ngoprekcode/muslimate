import 'package:flutter/foundation.dart';
import 'package:muslimate/features/quran/data/quran_bookmark_store.dart';
import 'package:muslimate/features/quran/models/quran_bookmark.dart';

class QuranBookmarkProvider extends ChangeNotifier {
  QuranBookmarkProvider(this._store);

  final QuranBookmarkStore _store;
  final Map<String, QuranBookmark> _bookmarks = {};
  bool _disposed = false;
  bool isLoading = true;

  List<QuranBookmark> get bookmarks => List.unmodifiable(_bookmarks.values);

  bool containsSurah(int surahNumber) =>
      _bookmarks.containsKey(QuranBookmark.surah(surahNumber).id);

  bool containsAyah(int surahNumber, int ayahNumber) =>
      _bookmarks.containsKey(QuranBookmark.ayah(surahNumber, ayahNumber).id);

  Future<void> load() async {
    final stored = await _store.load();
    if (_disposed) return;
    _bookmarks
      ..clear()
      ..addEntries(stored.map((bookmark) => MapEntry(bookmark.id, bookmark)));
    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleSurah(int surahNumber) =>
      _toggle(QuranBookmark.surah(surahNumber));

  Future<void> toggleAyah(int surahNumber, int ayahNumber) =>
      _toggle(QuranBookmark.ayah(surahNumber, ayahNumber));

  Future<void> _toggle(QuranBookmark bookmark) async {
    if (_bookmarks.containsKey(bookmark.id)) {
      _bookmarks.remove(bookmark.id);
    } else {
      _bookmarks[bookmark.id] = bookmark;
    }
    notifyListeners();
    await _store.save(_bookmarks.values);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
