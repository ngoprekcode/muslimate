class QuranLastRead {
  const QuranLastRead({
    required this.surahNumber,
    required this.ayahNumber,
    required this.juzNumber,
  });

  final int surahNumber;
  final int ayahNumber;
  final int juzNumber;

  String get serialized => '$surahNumber:$ayahNumber:$juzNumber';

  static QuranLastRead? tryParse(String value) {
    final parts = value.split(':');
    if (parts.length != 3) return null;
    final surah = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    final juz = int.tryParse(parts[2]);
    if (surah == null || surah < 1 || surah > 114) return null;
    if (ayah == null || ayah < 1) return null;
    if (juz == null || juz < 1 || juz > 30) return null;
    return QuranLastRead(surahNumber: surah, ayahNumber: ayah, juzNumber: juz);
  }

  @override
  bool operator ==(Object other) =>
      other is QuranLastRead &&
      other.surahNumber == surahNumber &&
      other.ayahNumber == ayahNumber &&
      other.juzNumber == juzNumber;

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber, juzNumber);
}
