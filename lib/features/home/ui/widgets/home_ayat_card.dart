import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/home/logic/daily_verse_provider.dart';
import 'package:muslimate/features/quran/logic/quran_bookmark_provider.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeAyatCard extends StatelessWidget {
  const HomeAyatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dailyVerse = context.watch<DailyVerseProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(
            title: l10n.homeDailyVerseTitle,
            action: l10n.homeDailyVerseSeeAll,
            onAction: () => Navigator.of(context).pushNamed('/quran'),
          ),
          AppCard(
            padding: const EdgeInsets.all(18),
            child: _buildContent(context, dailyVerse, c, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DailyVerseProvider provider,
    AppColors c,
    AppLocalizations l10n,
  ) {
    if (provider.status == DailyVerseStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (provider.status == DailyVerseStatus.error) {
      return _MessageState(
        message: l10n.homeDailyVerseError,
        action: l10n.quranRetry,
        onAction: provider.load,
      );
    }
    if (provider.status == DailyVerseStatus.empty) {
      return _MessageState(message: l10n.homeDailyVerseEmpty);
    }

    final verse = provider.verse!;
    final surah = provider.surah!;
    final bookmarks = context.watch<QuranBookmarkProvider>();
    final isBookmarked = bookmarks.containsAyah(
      verse.surahNumber,
      verse.ayahNumber,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppArabicText(
          text: verse.arabic,
          fontSize: 22,
          color: AppColors.of(context).ink,
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 12),
        Text(
          verse.transliteration,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.55,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: c.goldDeep,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          verse.translation,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.55,
            color: c.inkSoft,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            AppPill(
              text: 'QS. ${surah.title} : ${verse.ayahNumber}',
              tone: AppPillTone.navy,
            ),
            const Spacer(),
            _ActionBtn(
              icon: isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: c.inkSoft,
              tooltip: isBookmarked
                  ? l10n.quranRemoveBookmark
                  : l10n.quranAddBookmark,
              onPressed: bookmarks.isLoading
                  ? null
                  : () => bookmarks.toggleAyah(
                      verse.surahNumber,
                      verse.ayahNumber,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SizedBox.square(
      dimension: 40,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: c.surfaceAlt,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.action, this.onAction});

  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}
