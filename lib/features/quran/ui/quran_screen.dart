import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/core/app_tokens.dart';
import 'package:muslimate/features/quran/data/quran_bookmark_store.dart';
import 'package:muslimate/features/quran/data/quran_browse_repository.dart';
import 'package:muslimate/features/quran/data/quran_last_read_store.dart';
import 'package:muslimate/features/quran/logic/quran_bookmark_provider.dart';
import 'package:muslimate/features/quran/logic/quran_browse_provider.dart';
import 'package:muslimate/features/quran/logic/quran_last_read_provider.dart';
import 'package:muslimate/features/quran/models/quran_bookmark.dart';
import 'package:muslimate/features/quran/models/quran_browse_item.dart';
import 'package:muslimate/features/quran/models/quran_last_read.dart';
import 'package:muslimate/features/quran/models/quran_verse.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({
    super.key,
    this.repository,
    this.bookmarkStore,
    this.lastReadStore,
    this.useSharedBookmarkProvider = false,
    this.useSharedLastReadProvider = false,
  });

  final QuranBrowseRepository? repository;
  final QuranBookmarkStore? bookmarkStore;
  final QuranLastReadStore? lastReadStore;
  final bool useSharedBookmarkProvider;
  final bool useSharedLastReadProvider;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final browseProvider = ChangeNotifierProvider(
      create: (_) => QuranBrowseProvider(
        repository ?? AssetQuranBrowseRepository(languageCode: languageCode),
      )..load(),
    );
    final providers = <SingleChildWidget>[browseProvider];
    if (!useSharedBookmarkProvider) {
      providers.add(
        ChangeNotifierProvider(
          create: (_) => QuranBookmarkProvider(
            bookmarkStore ?? SharedPreferencesQuranBookmarkStore(),
          )..load(),
        ),
      );
    }
    if (!useSharedLastReadProvider) {
      providers.add(
        ChangeNotifierProvider(
          create: (_) => QuranLastReadProvider(
            lastReadStore ?? SharedPreferencesQuranLastReadStore(),
          )..load(),
        ),
      );
    }
    return MultiProvider(
      key: ValueKey(languageCode),
      providers: providers,
      child: const _QuranView(),
    );
  }
}

class _QuranView extends StatefulWidget {
  const _QuranView();

  @override
  State<_QuranView> createState() => _QuranViewState();
}

class _QuranViewState extends State<_QuranView> {
  final _searchController = TextEditingController();
  QuranBrowseType _activeType = QuranBrowseType.surah;
  bool _showBookmarks = false;
  ({QuranBrowseItem surah, int ayah})? _readingPosition;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = _readingPosition;
    return position == null
        ? _buildBrowse(context)
        : _QuranReader(
            position: position.surah,
            initialAyah: position.ayah,
            onBack: () => setState(() => _readingPosition = null),
          );
  }

  Widget _buildBrowse(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final browse = context.watch<QuranBrowseProvider>();
    final lastRead = context.watch<QuranLastReadProvider>();
    final savedPosition = _validLastRead(lastRead.position, browse);
    final savedSurah = savedPosition == null
        ? null
        : browse.surah(savedPosition.surahNumber);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: l10n.quranTitle,
              subtitle: l10n.quranSubtitle,
              showBackButton: false,
            ),
            Expanded(
              child: ListView(
                children: [
                  if (savedPosition != null && savedSurah != null)
                    _LastReadCard(
                      position: savedPosition,
                      surahTitle: savedSurah.title,
                      onContinue: () =>
                          _openReader(savedSurah, savedPosition.ayahNumber),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.hairline),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: colors.inkMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                context.read<QuranBrowseProvider>().search(
                                  value,
                                );
                              },
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: colors.ink,
                              ),
                              decoration: InputDecoration.collapsed(
                                hintText: l10n.quranSearchHint,
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: colors.inkMuted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _BrowseTabs(
                    activeType: _activeType,
                    showBookmarks: _showBookmarks,
                    onChanged: (value) => setState(() {
                      _activeType = value;
                      _showBookmarks = false;
                    }),
                    onBookmarks: () => setState(() => _showBookmarks = true),
                  ),
                  if (_showBookmarks)
                    _BookmarkResults(onSelected: _openReader)
                  else
                    _BrowseResults(type: _activeType, onSelected: _openReader),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  QuranLastRead? _validLastRead(
    QuranLastRead? position,
    QuranBrowseProvider browse,
  ) {
    if (position == null || browse.status != QuranBrowseStatus.ready) {
      return null;
    }
    final surah = browse.surah(position.surahNumber);
    if (surah == null || position.ayahNumber > (surah.ayahCount ?? 0)) {
      return null;
    }
    return browse.juzFor(position.surahNumber, position.ayahNumber) ==
            position.juzNumber
        ? position
        : null;
  }

  void _openReader(QuranBrowseItem surah, int ayah) {
    final juz = context.read<QuranBrowseProvider>().juzFor(
      surah.surahNumber,
      ayah,
    );
    if (juz == null) return;
    context.read<QuranLastReadProvider>().update(
      QuranLastRead(
        surahNumber: surah.surahNumber,
        ayahNumber: ayah,
        juzNumber: juz,
      ),
    );
    setState(() => _readingPosition = (surah: surah, ayah: ayah));
  }
}

class _LastReadCard extends StatelessWidget {
  const _LastReadCard({
    required this.position,
    required this.surahTitle,
    required this.onContinue,
  });

  final QuranLastRead position;
  final String surahTitle;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.navy,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quranLastRead.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.dark.inkSoft,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              surahTitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.light.surface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.quranReadingPosition(
                position.ayahNumber,
                position.juzNumber,
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: colors.gold,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onContinue,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.gold,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.quranContinueReading,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: colors.navy,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.navy,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrowseTabs extends StatelessWidget {
  const _BrowseTabs({
    required this.activeType,
    required this.showBookmarks,
    required this.onChanged,
    required this.onBookmarks,
  });

  final QuranBrowseType activeType;
  final bool showBookmarks;
  final ValueChanged<QuranBrowseType> onChanged;
  final VoidCallback onBookmarks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final tabs = [
      (QuranBrowseType.surah, l10n.quranSurahTab),
      (QuranBrowseType.juz, l10n.quranJuzTab),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 14, AppSpacing.lg, 0),
      child: Row(
        children:
            tabs.map((tab) {
              final selected = !showBookmarks && tab.$1 == activeType;
              return GestureDetector(
                onTap: () => onChanged(tab.$1),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? colors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    tab.$2,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.light.surface
                          : colors.inkSoft,
                    ),
                  ),
                ),
              );
            }).toList()..add(
              GestureDetector(
                onTap: onBookmarks,
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: showBookmarks ? colors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    l10n.quranBookmarksTab,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: showBookmarks
                          ? AppColors.light.surface
                          : colors.inkSoft,
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

class _BrowseResults extends StatelessWidget {
  const _BrowseResults({required this.type, required this.onSelected});

  final QuranBrowseType type;
  final void Function(QuranBrowseItem item, int ayah) onSelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranBrowseProvider>();
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (provider.status == QuranBrowseStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.status == QuranBrowseStatus.error) {
      return _MessageState(
        icon: Icons.cloud_off_rounded,
        message: l10n.quranLoadError,
        action: TextButton(
          onPressed: provider.load,
          child: Text(l10n.quranRetry),
        ),
      );
    }

    final results = provider.results(type);
    final verseResults = provider.verseResults;
    if (results.isEmpty && verseResults.isEmpty) {
      return _MessageState(
        icon: Icons.search_off_rounded,
        message: l10n.quranNoResults,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          ...results.map((item) {
            final isSurah = item.type == QuranBrowseType.surah;
            final subtitle = isSurah
                ? '${item.meaning} • ${l10n.quranSurahMetadata(item.ayahCount!, item.revelationType!)}'
                : l10n.quranJuzStartsAt(item.surahNumber, item.ayahNumber);
            return GestureDetector(
              key: ValueKey('${item.type.name}-${item.number}'),
              onTap: () => onSelected(
                provider.surah(item.surahNumber)!,
                item.ayahNumber,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.hairline)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(38, 38),
                            painter: _StarBorderPainter(colors.goldSoft),
                          ),
                          Text(
                            '${item.number}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.goldDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: colors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSurah)
                      Text(
                        item.arabicTitle!,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.gold,
                        ),
                      )
                    else
                      Icon(Icons.chevron_right_rounded, color: colors.inkMuted),
                  ],
                ),
              ),
            );
          }),
          ...verseResults.map(
            (verse) => _VerseSearchResult(
              verse: verse,
              surah: provider.surah(verse.surahNumber)!,
              onTap: () => onSelected(
                provider.surah(verse.surahNumber)!,
                verse.ayahNumber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerseSearchResult extends StatelessWidget {
  const _VerseSearchResult({
    required this.verse,
    required this.surah,
    required this.onTap,
  });

  final QuranVerse verse;
  final QuranBrowseItem surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.hairline)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: Center(
                child: Text(
                  '${verse.ayahNumber}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.goldDeep,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${surah.title} ${verse.ayahNumber}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                  Text(
                    verse.transliteration,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: colors.goldDeep,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    verse.translation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: colors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkResults extends StatelessWidget {
  const _BookmarkResults({required this.onSelected});

  final void Function(QuranBrowseItem surah, int ayah) onSelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranBookmarkProvider>();
    final browse = context.watch<QuranBrowseProvider>();
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.bookmarks.isEmpty) {
      return _MessageState(
        icon: Icons.bookmark_border_rounded,
        message: l10n.quranNoBookmarks,
      );
    }
    final normalizedQuery = browse.query.trim().toLowerCase();
    if (normalizedQuery.isNotEmpty && !browse.versesReady) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final bookmarks = provider.bookmarks
        .where((bookmark) {
          if (normalizedQuery.isEmpty) return true;
          final surah = browse.surah(bookmark.surahNumber);
          if (surah == null) return false;
          if (surah.searchText.contains(normalizedQuery)) return true;
          final ayahNumber = bookmark.ayahNumber;
          if (ayahNumber == null) return false;
          final verse = browse.verse(bookmark.surahNumber, ayahNumber);
          return verse?.searchText.contains(normalizedQuery) ?? false;
        })
        .toList(growable: false);
    if (bookmarks.isEmpty) {
      return _MessageState(
        icon: Icons.search_off_rounded,
        message: l10n.quranNoResults,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: bookmarks.map((bookmark) {
          final surah = browse.surah(bookmark.surahNumber)!;
          final isAyah = bookmark.type == QuranBookmarkType.ayah;
          return GestureDetector(
            onTap: () => onSelected(surah, bookmark.ayahNumber ?? 1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.hairline)),
              ),
              child: Row(
                children: [
                  Icon(
                    isAyah
                        ? Icons.format_quote_rounded
                        : Icons.menu_book_rounded,
                    color: colors.goldDeep,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      isAyah
                          ? '${surah.title} ${bookmark.ayahNumber}'
                          : surah.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: colors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => isAyah
                        ? provider.toggleAyah(
                            bookmark.surahNumber,
                            bookmark.ayahNumber!,
                          )
                        : provider.toggleSurah(bookmark.surahNumber),
                    icon: Icon(
                      Icons.bookmark_remove_rounded,
                      color: colors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message, this.action});
  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Icon(icon, color: colors.inkMuted, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
          ),
          action ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _QuranReader extends StatelessWidget {
  const _QuranReader({
    required this.position,
    required this.initialAyah,
    required this.onBack,
  });
  final QuranBrowseItem position;
  final int initialAyah;
  final VoidCallback onBack;

  // Kept only as the archived reader prototype reference while real ayahs are
  // loaded from the approved Quran asset source.
  // ignore: unused_field
  static const _ayat = [
    _Ayah(
      1,
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
    ),
    _Ayah(
      2,
      'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'Segala puji bagi Allah, Tuhan semesta alam.',
    ),
    _Ayah(3, 'الرَّحْمَٰنِ الرَّحِيمِ', 'Yang Maha Pengasih, Maha Penyayang.'),
    _Ayah(4, 'مَالِكِ يَوْمِ الدِّينِ', 'Pemilik hari pembalasan.'),
    _Ayah(
      5,
      'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      'Hanya kepada Engkau kami menyembah dan hanya kepada Engkau kami mohon pertolongan.',
    ),
    _Ayah(
      6,
      'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      'Tunjukilah kami jalan yang lurus.',
    ),
    _Ayah(
      7,
      'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      'Yaitu jalan orang-orang yang telah Engkau anugerahkan nikmat kepada mereka.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final verses = context.watch<QuranBrowseProvider>().versesForSurah(
      position.surahNumber,
      fromAyah: initialAyah,
    );
    final bookmarks = context.watch<QuranBookmarkProvider>();
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: c.ink,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: c.ink,
                        ),
                      ),
                      Text(
                        position.type == QuranBrowseType.surah
                            ? l10n.quranSurahMetadata(
                                position.ayahCount!,
                                position.revelationType!,
                              )
                            : l10n.quranReaderPosition(
                                position.surahNumber,
                                position.ayahNumber,
                              ),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: c.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: ValueKey('surah-bookmark-${position.surahNumber}'),
                  tooltip: bookmarks.containsSurah(position.surahNumber)
                      ? l10n.quranRemoveBookmark
                      : l10n.quranAddBookmark,
                  onPressed: () => bookmarks.toggleSurah(position.surahNumber),
                  icon: Icon(
                    bookmarks.containsSurah(position.surahNumber)
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: c.inkMuted,
                  ),
                ),
              ],
            ),
            Expanded(
              child: verses.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        if (position.surahNumber == 1 && initialAyah == 1)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: c.navy,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [
                                  AppArabicText(
                                    text:
                                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                    fontSize: 26,
                                    color: c.gold,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppColors.dark.inkSoft,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                          child: Column(
                            children: verses.map((a) {
                              final bookmarked = bookmarks.containsAyah(
                                a.surahNumber,
                                a.ayahNumber,
                              );
                              return GestureDetector(
                                key: ValueKey(
                                  'ayah-${a.surahNumber}-${a.ayahNumber}',
                                ),
                                onTap: () {
                                  final juz = context
                                      .read<QuranBrowseProvider>()
                                      .juzFor(a.surahNumber, a.ayahNumber);
                                  if (juz == null) return;
                                  context.read<QuranLastReadProvider>().update(
                                    QuranLastRead(
                                      surahNumber: a.surahNumber,
                                      ayahNumber: a.ayahNumber,
                                      juzNumber: juz,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: c.hairline),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: c.goldSoft,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${a.ayahNumber}',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: c.goldDeep,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            key: ValueKey(
                                              'ayah-bookmark-${a.surahNumber}-${a.ayahNumber}',
                                            ),
                                            onPressed: () =>
                                                bookmarks.toggleAyah(
                                                  a.surahNumber,
                                                  a.ayahNumber,
                                                ),
                                            icon: Icon(
                                              bookmarked
                                                  ? Icons.bookmark_rounded
                                                  : Icons
                                                        .bookmark_outline_rounded,
                                              color: c.inkMuted,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      AppArabicText(
                                        text: a.arabic,
                                        fontSize: 26,
                                        color: c.ink,
                                        height: 2.2,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        a.transliteration,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          height: 1.6,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w500,
                                          color: c.goldDeep,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        a.translation,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          height: 1.6,
                                          color: c.inkSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ayah {
  const _Ayah(this.number, this.arabic, this.translation);

  final int number;
  final String arabic;
  final String translation;
}

class _StarBorderPainter extends CustomPainter {
  const _StarBorderPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path();
    const points = 12;
    for (var index = 0; index < points; index++) {
      final angle = (index * 360 / points - 90) * math.pi / 180;
      final radius = (size.width - 2) / 2 * (index.isOdd ? .75 : 1);
      final point = Offset(
        size.width / 2 + radius * math.cos(angle),
        size.height / 2 + radius * math.sin(angle),
      );
      index == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  @override
  bool shouldRepaint(covariant _StarBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
