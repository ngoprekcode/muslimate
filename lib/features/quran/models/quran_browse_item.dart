enum QuranBrowseType { surah, juz }

class QuranBrowseItem {
  const QuranBrowseItem({
    required this.type,
    required this.number,
    required this.title,
    required this.surahNumber,
    required this.ayahNumber,
    this.arabicTitle,
    this.meaning,
    this.ayahCount,
    this.revelationType,
  });

  final QuranBrowseType type;
  final int number;
  final String title;
  final int surahNumber;
  final int ayahNumber;
  final String? arabicTitle;
  final String? meaning;
  final int? ayahCount;
  final String? revelationType;

  String get searchText =>
      '$number $title ${arabicTitle ?? ''} ${meaning ?? ''}'.toLowerCase();
}
