import 'package:flutter/foundation.dart';
import 'package:muslimate/features/quran/data/quran_browse_repository.dart';
import 'package:muslimate/features/quran/models/quran_browse_item.dart';
import 'package:muslimate/features/quran/models/quran_verse.dart';

enum QuranBrowseStatus { loading, ready, error }

class QuranBrowseProvider extends ChangeNotifier {
  QuranBrowseProvider(this._repository);

  final QuranBrowseRepository _repository;
  QuranBrowseStatus status = QuranBrowseStatus.loading;
  List<QuranBrowseItem> _surahs = const [];
  List<QuranBrowseItem> _juz = const [];
  List<QuranVerse> _verses = const [];
  String _query = '';
  bool _disposed = false;
  bool versesReady = false;

  String get query => _query;
  List<QuranBrowseItem> get surahs => _surahs;

  QuranBrowseItem? surah(int number) {
    if (number < 1 || number > _surahs.length) return null;
    return _surahs[number - 1];
  }

  QuranVerse? verse(int surahNumber, int ayahNumber) {
    for (final verse in _verses) {
      if (verse.surahNumber == surahNumber && verse.ayahNumber == ayahNumber) {
        return verse;
      }
    }
    return null;
  }

  List<QuranVerse> versesForSurah(int surahNumber, {int fromAyah = 1}) =>
      _verses
          .where(
            (verse) =>
                verse.surahNumber == surahNumber &&
                verse.ayahNumber >= fromAyah,
          )
          .toList(growable: false);

  List<QuranVerse> get verseResults {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    return _verses
        .where((verse) => verse.searchText.contains(normalized))
        .take(100)
        .toList(growable: false);
  }

  List<QuranBrowseItem> results(QuranBrowseType type) {
    final source = type == QuranBrowseType.surah ? _surahs : _juz;
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return source;
    return source
        .where((item) => item.searchText.contains(normalized))
        .toList(growable: false);
  }

  Future<void> load() async {
    status = QuranBrowseStatus.loading;
    notifyListeners();
    try {
      final values = await (_repository.getSurahs(), _repository.getJuz()).wait;
      _surahs = values.$1;
      _juz = values.$2;
      status = QuranBrowseStatus.ready;
      if (!_disposed) notifyListeners();
      _verses = await _repository.getVerses();
      versesReady = true;
    } catch (_) {
      status = QuranBrowseStatus.error;
      versesReady = false;
    }
    if (!_disposed) notifyListeners();
  }

  void search(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
