import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/features/quran/data/quran_bookmark_store.dart';
import 'package:muslimate/features/quran/logic/quran_bookmark_provider.dart';
import 'package:muslimate/features/quran/models/quran_bookmark.dart';

void main() {
  test(
    'toggles bookmarks without duplicates and restores persisted state',
    () async {
      final store = _MemoryBookmarkStore();
      final provider = QuranBookmarkProvider(store);
      await provider.load();

      await provider.toggleSurah(1);
      await provider.toggleSurah(1);
      await provider.toggleSurah(1);
      await provider.toggleAyah(1, 2);
      await provider.toggleAyah(1, 2);
      await provider.toggleAyah(1, 2);

      expect(provider.bookmarks, hasLength(2));
      expect(provider.containsSurah(1), isTrue);
      expect(provider.containsAyah(1, 2), isTrue);

      final restored = QuranBookmarkProvider(store);
      await restored.load();
      expect(restored.bookmarks, hasLength(2));
      expect(restored.containsSurah(1), isTrue);
      expect(restored.containsAyah(1, 2), isTrue);
    },
  );
}

class _MemoryBookmarkStore implements QuranBookmarkStore {
  final Map<String, QuranBookmark> values = {};

  @override
  Future<Set<QuranBookmark>> load() async => values.values.toSet();

  @override
  Future<void> save(Iterable<QuranBookmark> bookmarks) async {
    values
      ..clear()
      ..addEntries(
        bookmarks.map((bookmark) => MapEntry(bookmark.id, bookmark)),
      );
  }
}
