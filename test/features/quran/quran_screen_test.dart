import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/core/app_theme.dart';
import 'package:muslimate/features/quran/data/quran_browse_repository.dart';
import 'package:muslimate/features/quran/ui/quran_screen.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var attempt = 0; attempt < 200; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isNotEmpty) return;
    }
    final visibleText = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data)
        .whereType<String>()
        .join(' | ');
    fail('Timed out waiting for $finder. Text: $visibleText');
  }

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('id'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: QuranScreen(
        repository: AssetQuranBrowseRepository(
          languageCode: 'id',
          bundle: PlatformAssetBundle(),
        ),
      ),
    );
  }

  testWidgets('shows Surah and Juz tabs without Hafalan or play actions', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await pumpUntilFound(tester, find.text('Al-Fatihah'));

    expect(find.text('Surat'), findsOneWidget);
    expect(find.text('Juz'), findsOneWidget);
    expect(find.text('الفاتحة'), findsOneWidget);
    expect(find.text('Pembukaan • 7 ayat • Makkiyah'), findsOneWidget);
    expect(find.text('Bookmark'), findsOneWidget);
    expect(find.text('Hafalan'), findsNothing);
    expect(find.text('TERAKHIR DIBACA'), findsNothing);
    expect(find.text('Lanjutkan membaca'), findsNothing);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    expect(find.byIcon(Icons.play_arrow_outlined), findsNothing);
  });

  testWidgets('search presents a no-result state and can be cleared', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await pumpUntilFound(tester, find.text('Al-Fatihah'));

    await tester.enterText(find.byType(TextField), 'not present');
    await tester.pump();
    expect(
      find.text("Tidak ada hasil penelusuran Al-Qur'an yang cocok."),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(find.text('Al-Fatihah'), findsOneWidget);
  });

  testWidgets('opens the selected Surah reading position', (tester) async {
    await tester.pumpWidget(buildSubject());
    await pumpUntilFound(tester, find.text('Al-Fatihah'));

    await tester.tap(find.text('Al-Fatihah'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pumpUntilFound(
      tester,
      find.text('Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.'),
    );

    expect(find.text('7 ayat • Makkiyah'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_outline_rounded), findsWidgets);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
  });

  testWidgets('renders ayahs for a Surah other than Al-Fatihah', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await pumpUntilFound(tester, find.text('Al-Baqarah'));

    await tester.tap(find.text('Al-Baqarah'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pumpUntilFound(tester, find.textContaining('Alif Lām Mīm'));

    expect(find.text('286 ayat • Madaniyah'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('bookmarks a Surah and opens it from the existing tab style', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await pumpUntilFound(tester, find.text('Al-Baqarah'));
    await tester.tap(find.text('Al-Baqarah'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pumpUntilFound(tester, find.textContaining('Alif Lām Mīm'));

    await tester.tap(find.byTooltip('Tambahkan bookmark').first);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pump();
    await tester.tap(find.text('Bookmark'));
    await tester.pump();

    expect(find.text('Al-Baqarah'), findsWidgets);
  });

  testWidgets('opens a verse search result and persists its ayah bookmark', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await pumpUntilFound(tester, find.text('Al-Fatihah'));
    await tester.enterText(find.byType(TextField), 'seluruh alam');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pumpUntilFound(tester, find.text('Al-Fatihah 2'));

    await tester.tap(find.text('Al-Fatihah 2'));
    await tester.pump();
    await pumpUntilFound(
      tester,
      find.text('Segala puji bagi Allah, Tuhan seluruh alam,'),
    );
    await tester.tap(find.byKey(const ValueKey('ayah-bookmark-1-2')));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pump();
    await tester.tap(find.text('Bookmark'));
    await tester.pump();

    expect(find.text('Al-Fatihah 2'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(buildSubject());
    await pumpUntilFound(tester, find.text('Bookmark'));
    await tester.tap(find.text('Bookmark'));
    await pumpUntilFound(tester, find.text('Al-Fatihah 2'));

    await tester.enterText(find.byType(TextField), 'seluruh alam');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pumpUntilFound(tester, find.text('Al-Fatihah 2'));

    await tester.enterText(find.byType(TextField), 'Al-Baqarah');
    await tester.pump();
    expect(find.text('Al-Fatihah 2'), findsNothing);
    expect(
      find.text("Tidak ada hasil penelusuran Al-Qur'an yang cocok."),
      findsOneWidget,
    );
  });

  testWidgets('persists last read and continues at the exact saved ayah', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await pumpUntilFound(tester, find.text('Al-Fatihah'));

    await tester.tap(find.text('Juz'));
    await tester.pump();
    await tester.tap(find.text('Juz 2'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pumpUntilFound(tester, find.byKey(const ValueKey('ayah-2-142')));

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pump();
    expect(find.text('TERAKHIR DIBACA'), findsOneWidget);
    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('Ayat 142 • Juz 2'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(buildSubject());
    await pumpUntilFound(tester, find.text('Lanjutkan membaca'));

    await tester.tap(find.text('Lanjutkan membaca'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pumpUntilFound(tester, find.byKey(const ValueKey('ayah-2-142')));
    expect(find.byKey(const ValueKey('ayah-2-141')), findsNothing);
  });
}
