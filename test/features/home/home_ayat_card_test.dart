import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/core/app_theme.dart';
import 'package:muslimate/features/home/data/daily_verse_store.dart';
import 'package:muslimate/features/home/logic/daily_verse_provider.dart';
import 'package:muslimate/features/home/models/daily_verse_selection.dart';
import 'package:muslimate/features/home/ui/widgets/home_ayat_card.dart';
import 'package:muslimate/features/quran/data/quran_bookmark_store.dart';
import 'package:muslimate/features/quran/data/quran_browse_repository.dart';
import 'package:muslimate/features/quran/logic/quran_bookmark_provider.dart';
import 'package:muslimate/features/quran/models/quran_bookmark.dart';
import 'package:muslimate/features/quran/models/quran_browse_item.dart';
import 'package:muslimate/features/quran/models/quran_verse.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows Quran data and toggles its shared ayah bookmark', (
    tester,
  ) async {
    final dailyVerse = DailyVerseProvider(
      repository: _CardRepository(),
      store: _MemoryDailyVerseStore(),
      now: () => DateTime(2026, 8, 20),
    );
    final bookmarkStore = _MemoryBookmarkStore();
    final bookmarks = QuranBookmarkProvider(bookmarkStore);
    await Future.wait([dailyVerse.load(), bookmarks.load()]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: dailyVerse),
          ChangeNotifierProvider.value(value: bookmarks),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('id'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: HomeAyatCard()),
        ),
      ),
    );

    expect(find.text('Ayat Hari Ini'), findsOneWidget);
    expect(find.text('arabic verse'), findsOneWidget);
    expect(find.text('translated verse'), findsOneWidget);
    expect(find.text('QS. Al-Fatihah : 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Tambahkan bookmark'));
    await tester.pump();

    expect(bookmarks.containsAyah(1, 2), isTrue);
    expect(bookmarkStore.values, contains('ayah:1:2'));
    expect(find.byTooltip('Hapus bookmark'), findsOneWidget);
  });
}

class _CardRepository implements QuranBrowseRepository {
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
  Future<List<QuranVerse>> getVerses() async => const [
    QuranVerse(
      id: 2,
      surahNumber: 1,
      ayahNumber: 2,
      arabic: 'arabic verse',
      translation: 'translated verse',
    ),
  ];

  @override
  Future<List<QuranBrowseItem>> getJuz() async => const [];
}

class _MemoryDailyVerseStore implements DailyVerseStore {
  DailyVerseSelection? value;

  @override
  Future<DailyVerseSelection?> load() async => value;

  @override
  Future<void> save(DailyVerseSelection selection) async => value = selection;
}

class _MemoryBookmarkStore implements QuranBookmarkStore {
  final Set<String> values = {};

  @override
  Future<Set<QuranBookmark>> load() async =>
      values.map(QuranBookmark.tryParse).whereType<QuranBookmark>().toSet();

  @override
  Future<void> save(Iterable<QuranBookmark> bookmarks) async {
    values
      ..clear()
      ..addAll(bookmarks.map((bookmark) => bookmark.id));
  }
}
