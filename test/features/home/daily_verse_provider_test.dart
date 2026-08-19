import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/features/home/data/daily_verse_store.dart';
import 'package:muslimate/features/home/logic/daily_verse_provider.dart';
import 'package:muslimate/features/home/models/daily_verse_selection.dart';
import 'package:muslimate/features/quran/data/quran_browse_repository.dart';
import 'package:muslimate/features/quran/models/quran_browse_item.dart';
import 'package:muslimate/features/quran/models/quran_verse.dart';

void main() {
  final verses = [
    const QuranVerse(
      id: 1,
      surahNumber: 1,
      ayahNumber: 1,
      arabic: 'arabic one',
      translation: 'translation one',
    ),
    const QuranVerse(
      id: 2,
      surahNumber: 1,
      ayahNumber: 2,
      arabic: 'arabic two',
      translation: 'translation two',
    ),
  ];

  test('keeps the same valid verse throughout the local day', () async {
    final store = _MemoryDailyVerseStore();
    final repository = _FakeRepository(verses);
    final first = DailyVerseProvider(
      repository: repository,
      store: store,
      now: () => DateTime(2026, 8, 20, 8),
      random: _FirstRandom(),
    );
    await first.load();

    final restored = DailyVerseProvider(
      repository: repository,
      store: store,
      now: () => DateTime(2026, 8, 20, 23, 59),
      random: _LastRandom(),
    );
    await restored.load();

    expect(first.status, DailyVerseStatus.ready);
    expect(first.verse?.id, 1);
    expect(restored.verse?.id, 1);
    expect(restored.surah?.title, 'Al-Fatihah');
  });

  test('selects a different verse on the next local day', () async {
    final store = _MemoryDailyVerseStore(
      const DailyVerseSelection(dateKey: '20260819', verseId: 1),
    );
    final provider = DailyVerseProvider(
      repository: _FakeRepository(verses),
      store: store,
      now: () => DateTime(2026, 8, 20),
      random: _FirstRandom(),
    );

    await provider.load();

    expect(provider.verse?.id, 2);
    expect(store.selection?.dateKey, '20260820');
    expect(store.selection?.verseId, 2);
  });

  test('reports empty and error states safely', () async {
    final empty = DailyVerseProvider(
      repository: _FakeRepository(const []),
      store: _MemoryDailyVerseStore(),
    );
    final failing = DailyVerseProvider(
      repository: _FailingRepository(),
      store: _MemoryDailyVerseStore(),
    );

    await Future.wait([empty.load(), failing.load()]);

    expect(empty.status, DailyVerseStatus.empty);
    expect(failing.status, DailyVerseStatus.error);
  });
}

class _MemoryDailyVerseStore implements DailyVerseStore {
  _MemoryDailyVerseStore([this.selection]);

  DailyVerseSelection? selection;

  @override
  Future<DailyVerseSelection?> load() async => selection;

  @override
  Future<void> save(DailyVerseSelection selection) async {
    this.selection = selection;
  }
}

class _FakeRepository implements QuranBrowseRepository {
  _FakeRepository(this.verses);

  final List<QuranVerse> verses;

  @override
  Future<List<QuranBrowseItem>> getSurahs() async => const [
    QuranBrowseItem(
      type: QuranBrowseType.surah,
      number: 1,
      title: 'Al-Fatihah',
      surahNumber: 1,
      ayahNumber: 1,
    ),
  ];

  @override
  Future<List<QuranVerse>> getVerses() async => verses;

  @override
  Future<List<QuranBrowseItem>> getJuz() async => const [];
}

class _FailingRepository implements QuranBrowseRepository {
  @override
  Future<List<QuranBrowseItem>> getSurahs() => Future.error(StateError('fail'));

  @override
  Future<List<QuranVerse>> getVerses() => Future.error(StateError('fail'));

  @override
  Future<List<QuranBrowseItem>> getJuz() => Future.error(StateError('fail'));
}

class _FirstRandom implements Random {
  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}

class _LastRandom implements Random {
  @override
  bool nextBool() => true;

  @override
  double nextDouble() => 0.999;

  @override
  int nextInt(int max) => max - 1;
}
