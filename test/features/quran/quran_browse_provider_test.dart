import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/features/quran/data/quran_browse_repository.dart';
import 'package:muslimate/features/quran/logic/quran_browse_provider.dart';
import 'package:muslimate/features/quran/models/quran_browse_item.dart';
import 'package:muslimate/features/quran/models/quran_verse.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuranBrowseProvider', () {
    test('loads all surahs and all 30 juz in order', () async {
      final provider = QuranBrowseProvider(
        AssetQuranBrowseRepository(languageCode: 'id'),
      );

      await provider.load();

      final surahs = provider.results(QuranBrowseType.surah);
      final juz = provider.results(QuranBrowseType.juz);
      expect(provider.status, QuranBrowseStatus.ready);
      expect(surahs, hasLength(114));
      expect(surahs.first.title, 'Al-Fatihah');
      expect(surahs.first.arabicTitle, 'الفاتحة');
      expect(surahs.first.meaning, 'Pembukaan');
      expect(surahs.last.title, 'An-Nas');
      expect(juz, hasLength(30));
      expect(
        juz.map((item) => item.number),
        orderedEquals(List.generate(30, (index) => index + 1)),
      );
    });

    test('search is case-insensitive and supports numbers', () async {
      final provider = QuranBrowseProvider(
        AssetQuranBrowseRepository(languageCode: 'id'),
      );
      await provider.load();

      provider.search('KAHF');
      expect(provider.results(QuranBrowseType.surah).single.title, 'Al-Kahf');

      provider.search('30');
      expect(provider.results(QuranBrowseType.juz).single.title, 'Juz 30');

      provider.search('not present');
      expect(provider.results(QuranBrowseType.surah), isEmpty);
    });

    test('reports an error when the repository fails', () async {
      final provider = QuranBrowseProvider(_FailingRepository());

      await provider.load();

      expect(provider.status, QuranBrowseStatus.error);
    });

    test('loads localized Surah meanings for English', () async {
      final provider = QuranBrowseProvider(
        AssetQuranBrowseRepository(languageCode: 'en'),
      );

      await provider.load();

      final first = provider.results(QuranBrowseType.surah).first;
      expect(first.meaning, 'The Opener');
      expect(first.revelationType, 'Meccan');
    });

    test('searches Quran translation content', () async {
      final provider = QuranBrowseProvider(
        AssetQuranBrowseRepository(languageCode: 'id'),
      );
      await provider.load();

      provider.search('seluruh alam');

      expect(provider.verseResults, isNotEmpty);
      expect(provider.verseResults.first.verseKey, '1:2');
    });

    test('loads the active language ayah translation package', () async {
      final indonesian = QuranBrowseProvider(
        AssetQuranBrowseRepository(languageCode: 'id'),
      );
      final english = QuranBrowseProvider(
        AssetQuranBrowseRepository(languageCode: 'en'),
      );

      await Future.wait([indonesian.load(), english.load()]);

      expect(
        indonesian.versesForSurah(1).first.translation,
        'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
      );
      expect(
        english.versesForSurah(1).first.translation,
        startsWith('In the name of Allāh'),
      );
    });
  });
}

class _FailingRepository implements QuranBrowseRepository {
  @override
  Future<List<QuranBrowseItem>> getJuz() => Future.error(StateError('failed'));

  @override
  Future<List<QuranBrowseItem>> getSurahs() =>
      Future.error(StateError('failed'));

  @override
  Future<List<QuranVerse>> getVerses() => Future.error(StateError('failed'));
}
