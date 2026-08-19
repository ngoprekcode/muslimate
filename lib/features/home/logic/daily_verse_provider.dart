import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:muslimate/features/home/data/daily_verse_store.dart';
import 'package:muslimate/features/home/models/daily_verse_selection.dart';
import 'package:muslimate/features/quran/data/quran_browse_repository.dart';
import 'package:muslimate/features/quran/models/quran_browse_item.dart';
import 'package:muslimate/features/quran/models/quran_verse.dart';

enum DailyVerseStatus { loading, ready, empty, error }

class DailyVerseProvider extends ChangeNotifier {
  DailyVerseProvider({
    required QuranBrowseRepository repository,
    required DailyVerseStore store,
    DateTime Function()? now,
    Random? random,
  }) : _repository = repository,
       _store = store,
       _now = now ?? DateTime.now,
       _random = random ?? Random();

  final QuranBrowseRepository _repository;
  final DailyVerseStore _store;
  final DateTime Function() _now;
  final Random _random;
  bool _disposed = false;

  DailyVerseStatus status = DailyVerseStatus.loading;
  QuranVerse? verse;
  QuranBrowseItem? surah;

  Future<void> load() async {
    status = DailyVerseStatus.loading;
    _notify();
    try {
      final stored = await _store.load();
      final values = await (
        _repository.getSurahs(),
        _repository.getVerses(),
      ).wait;
      if (_disposed) return;
      final surahs = values.$1;
      final verses = values.$2;
      if (surahs.isEmpty || verses.isEmpty) {
        status = DailyVerseStatus.empty;
        _notify();
        return;
      }

      final today = _dateKey(_now());
      QuranVerse? selected;
      if (stored?.dateKey == today) {
        selected = _findById(verses, stored!.verseId);
      }
      selected ??= _pickNewVerse(verses, stored?.verseId);
      final surahIndex = selected.surahNumber - 1;
      if (surahIndex < 0 || surahIndex >= surahs.length) {
        throw const FormatException('Daily verse has an invalid Surah');
      }

      verse = selected;
      surah = surahs[surahIndex];
      status = DailyVerseStatus.ready;
      await _store.save(
        DailyVerseSelection(dateKey: today, verseId: selected.id),
      );
    } catch (_) {
      if (_disposed) return;
      verse = null;
      surah = null;
      status = DailyVerseStatus.error;
    }
    _notify();
  }

  QuranVerse _pickNewVerse(List<QuranVerse> verses, int? previousId) {
    if (verses.length == 1) return verses.single;
    final candidates = previousId == null
        ? verses
        : verses.where((verse) => verse.id != previousId).toList();
    return candidates[_random.nextInt(candidates.length)];
  }

  QuranVerse? _findById(List<QuranVerse> verses, int id) {
    for (final verse in verses) {
      if (verse.id == id) return verse;
    }
    return null;
  }

  String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}'
      '${value.month.toString().padLeft(2, '0')}'
      '${value.day.toString().padLeft(2, '0')}';

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
