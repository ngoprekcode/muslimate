import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimate/core/app_theme.dart';
import 'package:muslimate/features/quran/data/quran_browse_repository.dart';
import 'package:muslimate/features/quran/ui/quran_screen.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';

void main() {
  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var attempt = 0; attempt < 20; attempt++) {
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
    await tester.pumpAndSettle();

    expect(find.text('7 ayat • Makkiyah'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_outline_rounded), findsNWidgets(7));
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
  });
}
