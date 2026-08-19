import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/features/quran/data/quran_last_read_store.dart';
import 'package:muslimate/features/quran/logic/quran_last_read_provider.dart';
import 'package:muslimate/features/quran/models/quran_last_read.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('last-read values validate their persisted representation', () {
    expect(
      QuranLastRead.tryParse('18:10:15'),
      const QuranLastRead(surahNumber: 18, ayahNumber: 10, juzNumber: 15),
    );
    expect(QuranLastRead.tryParse('0:1:1'), isNull);
    expect(QuranLastRead.tryParse('1:0:1'), isNull);
    expect(QuranLastRead.tryParse('1:1:31'), isNull);
    expect(QuranLastRead.tryParse('invalid'), isNull);
  });

  test('a newer position replaces the persisted previous position', () async {
    final store = SharedPreferencesQuranLastReadStore();
    final provider = QuranLastReadProvider(store);
    await provider.load();

    expect(provider.position, isNull);

    await provider.update(
      const QuranLastRead(surahNumber: 1, ayahNumber: 1, juzNumber: 1),
    );
    await provider.update(
      const QuranLastRead(surahNumber: 2, ayahNumber: 142, juzNumber: 2),
    );

    final restored = QuranLastReadProvider(store);
    await restored.load();
    expect(
      restored.position,
      const QuranLastRead(surahNumber: 2, ayahNumber: 142, juzNumber: 2),
    );
  });

  test('invalid stored data safely becomes an empty reading history', () async {
    SharedPreferences.setMockInitialValues({
      'quran.last_read.v1': 'not-a-position',
    });

    final provider = QuranLastReadProvider(
      SharedPreferencesQuranLastReadStore(),
    );
    await provider.load();

    expect(provider.position, isNull);
    expect(provider.isLoading, isFalse);
  });
}
