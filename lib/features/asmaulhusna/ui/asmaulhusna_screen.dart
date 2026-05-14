import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:muslimate/shared/widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../data/asmaul_husna_model.dart';
import '../logic/asmaul_husna_provider.dart';

class AsmaulHusnaScreen extends StatefulWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  State<AsmaulHusnaScreen> createState() => _AsmaulHusnaScreenState();
}

class _AsmaulHusnaScreenState extends State<AsmaulHusnaScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: l10n.asmaulHusnaTitle,
              subtitle: l10n.asmaulHusnaSubtitle,
            ),
            Expanded(
              child: Consumer<AsmaulHusnaProvider>(
                builder: (context, provider, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth > 700;
                      final horizontalPadding = constraints.maxWidth > 1200 ? (constraints.maxWidth - 1000) / 2 : 20.0;

                      return ListView(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        children: [
                          _buildHadithCard(context, c, l10n),
                          _buildSearch(context, c, l10n, provider),
                          _buildListHeader(context, c, l10n, provider),
                          if (provider.isLoading)
                            const Center(child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ))
                          else if (isTablet)
                            _buildGrid(context, c, provider.names)
                          else
                            _buildList(context, c, provider.names),
                          const SizedBox(height: 28),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithCard(BuildContext context, AppColors c, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: c.navy,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -25,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.18,
                  child: CustomPaint(
                    size: const Size(190, 190),
                    painter: _StarBorderPainter(c.gold, points: 16, innerRadiusRatio: 0.65),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.asmaulHusnaHadithTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: c.gold,
                        letterSpacing: 0.6,
                      )),
                  const SizedBox(height: 10),
                  Text('“${l10n.asmaulHusnaHadithQuote}”',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.5,
                      )),
                  const SizedBox(height: 12),
                  Text(l10n.asmaulHusnaHadithSource,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(BuildContext context, AppColors c, AppLocalizations l10n, AsmaulHusnaProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.hairline),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: provider.search,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.ink),
          decoration: InputDecoration(
            icon: Icon(Icons.search_rounded, color: c.inkMuted, size: 20),
            hintText: l10n.asmaulHusnaSearchHint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: c.inkMuted,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, AppColors c, AppLocalizations l10n, AsmaulHusnaProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.asmaulHusnaListHeader,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.ink,
              )),
          Text('${provider.names.length} ${l10n.asmaulHusnaListCounter.split(' ').last}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: c.inkMuted,
              )),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, AppColors c, List<AsmaulHusna> names) {
    return Column(
      children: names.map((n) => _buildNameItem(context, c, n)).toList(),
    );
  }

  Widget _buildGrid(BuildContext context, AppColors c, List<AsmaulHusna> names) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: names.length,
      itemBuilder: (context, index) => _buildNameItem(context, c, names[index], isGrid: true),
    );
  }

  Widget _buildNameItem(BuildContext context, AppColors c, AsmaulHusna n, {bool isGrid = false}) {
    final locale = Localizations.localeOf(context).languageCode;
    final translation = locale == 'id' ? n.translationId : n.translationEn;

    return Container(
      margin: EdgeInsets.only(bottom: isGrid ? 0 : 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.hairline),
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
                  painter: _StarBorderPainter(c.goldSoft, points: 16),
                ),
                Text(
                  '${n.index}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.goldDeep,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(n.latin,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: c.ink,
                    )),
                const SizedBox(height: 2),
                Text(
                  translation,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: c.inkMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppArabicText(
            text: n.arabic,
            fontSize: 22,
            color: c.gold,
          ),
        ],
      ),
    );
  }
}

class _StarBorderPainter extends CustomPainter {
  final Color color;
  final int points;
  final double innerRadiusRatio;
  _StarBorderPainter(this.color, {this.points = 16, this.innerRadiusRatio = 0.75});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = (size.width - 2) / 2;
    final inner = outer * innerRadiusRatio;

    final path = Path();
    for (int i = 0; i < points; i++) {
      final angle = (i * 360 / points - 90) * math.pi / 180;
      final r = i.isOdd ? inner : outer;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarBorderPainter old) =>
      old.color != color || old.points != points || old.innerRadiusRatio != innerRadiusRatio;
}
