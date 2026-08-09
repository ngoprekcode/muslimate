import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/core/app_tokens.dart';
import 'package:muslimate/features/quran/data/quran_browse_repository.dart';
import 'package:muslimate/features/quran/logic/quran_browse_provider.dart';
import 'package:muslimate/features/quran/models/quran_browse_item.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'package:provider/provider.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key, this.repository});

  final QuranBrowseRepository? repository;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return ChangeNotifierProvider(
      key: ValueKey(languageCode),
      create: (_) => QuranBrowseProvider(
        repository ?? AssetQuranBrowseRepository(languageCode: languageCode),
      )..load(),
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
  static const _showLastRead = false;
  final _searchController = TextEditingController();
  QuranBrowseType _activeType = QuranBrowseType.surah;
  QuranBrowseItem? _readingPosition;

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
            position: position,
            onBack: () => setState(() => _readingPosition = null),
          );
  }

  Widget _buildBrowse(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: l10n.quranTitle,
              subtitle: l10n.quranSubtitle,
            ),
            Expanded(
              child: ListView(
                children: [
                  if (_showLastRead)
                    _LastReadCard(
                      onContinue: () => setState(
                        () => _readingPosition = const QuranBrowseItem(
                          type: QuranBrowseType.surah,
                          number: 18,
                          title: 'Al-Kahf',
                          surahNumber: 18,
                          ayahNumber: 10,
                          ayahCount: 110,
                          revelationType: 'Makkiyah',
                        ),
                      ),
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
                    onChanged: (value) => setState(() => _activeType = value),
                  ),
                  _BrowseResults(
                    type: _activeType,
                    onSelected: (item) =>
                        setState(() => _readingPosition = item),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastReadCard extends StatelessWidget {
  const _LastReadCard({required this.onContinue});

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
              'Al-Kahf',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.light.surface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.quranReadingPosition(10, 15),
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
  const _BrowseTabs({required this.activeType, required this.onChanged});

  final QuranBrowseType activeType;
  final ValueChanged<QuranBrowseType> onChanged;

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
        children: tabs.map((tab) {
          final selected = tab.$1 == activeType;
          return GestureDetector(
            onTap: () => onChanged(tab.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? colors.navy : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                tab.$2,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.light.surface : colors.inkSoft,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BrowseResults extends StatelessWidget {
  const _BrowseResults({required this.type, required this.onSelected});

  final QuranBrowseType type;
  final ValueChanged<QuranBrowseItem> onSelected;

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
    if (results.isEmpty) {
      return _MessageState(
        icon: Icons.search_off_rounded,
        message: l10n.quranNoResults,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: results.map((item) {
          final isSurah = item.type == QuranBrowseType.surah;
          final subtitle = isSurah
              ? '${item.meaning} • ${l10n.quranSurahMetadata(item.ayahCount!, item.revelationType!)}'
              : l10n.quranJuzStartsAt(item.surahNumber, item.ayahNumber);
          return GestureDetector(
            key: ValueKey('${item.type.name}-${item.number}'),
            onTap: () => onSelected(item),
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
  const _QuranReader({required this.position, required this.onBack});
  final QuranBrowseItem position;
  final VoidCallback onBack;

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
                const SizedBox(width: 52),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  if (position.surahNumber == 1) ...[
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
                              text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
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
                        children: _ayat.map((a) {
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: c.hairline),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                          '${a.number}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: c.goldDeep,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.bookmark_outline_rounded,
                                      color: c.inkMuted,
                                      size: 20,
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
                                  a.translation,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    height: 1.6,
                                    color: c.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
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
