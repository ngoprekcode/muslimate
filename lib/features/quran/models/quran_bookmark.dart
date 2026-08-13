enum QuranBookmarkType { surah, ayah }

class QuranBookmark {
  const QuranBookmark._(this.type, this.surahNumber, this.ayahNumber);

  const QuranBookmark.surah(int surahNumber)
    : this._(QuranBookmarkType.surah, surahNumber, null);

  const QuranBookmark.ayah(int surahNumber, int ayahNumber)
    : this._(QuranBookmarkType.ayah, surahNumber, ayahNumber);

  final QuranBookmarkType type;
  final int surahNumber;
  final int? ayahNumber;

  String get id => type == QuranBookmarkType.surah
      ? 'surah:$surahNumber'
      : 'ayah:$surahNumber:$ayahNumber';

  static QuranBookmark? tryParse(String value) {
    final parts = value.split(':');
    if (parts.length == 2 && parts[0] == 'surah') {
      final surah = int.tryParse(parts[1]);
      if (surah != null && surah >= 1 && surah <= 114) {
        return QuranBookmark.surah(surah);
      }
    }
    if (parts.length == 3 && parts[0] == 'ayah') {
      final surah = int.tryParse(parts[1]);
      final ayah = int.tryParse(parts[2]);
      if (surah != null &&
          surah >= 1 &&
          surah <= 114 &&
          ayah != null &&
          ayah >= 1) {
        return QuranBookmark.ayah(surah, ayah);
      }
    }
    return null;
  }
}
