import 'package:flutter/foundation.dart';
import 'package:muslimate/features/quran/data/quran_browse_repository.dart';
import 'package:muslimate/features/quran/models/quran_browse_item.dart';

enum QuranBrowseStatus { loading, ready, error }

class QuranBrowseProvider extends ChangeNotifier {
  QuranBrowseProvider(this._repository);

  final QuranBrowseRepository _repository;
  QuranBrowseStatus status = QuranBrowseStatus.loading;
  List<QuranBrowseItem> _surahs = const [];
  List<QuranBrowseItem> _juz = const [];
  String _query = '';

  String get query => _query;

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
      final values = await Future.wait([
        _repository.getSurahs(),
        _repository.getJuz(),
      ]);
      _surahs = values[0];
      _juz = values[1];
      status = QuranBrowseStatus.ready;
    } catch (_) {
      status = QuranBrowseStatus.error;
    }
    notifyListeners();
  }

  void search(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }
}
