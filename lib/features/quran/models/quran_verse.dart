class QuranVerse {
  const QuranVerse({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabic,
    required this.translation,
  });

  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String arabic;
  final String translation;

  String get verseKey => '$surahNumber:$ayahNumber';

  String get searchText => '$verseKey $arabic $translation'.toLowerCase();
}
