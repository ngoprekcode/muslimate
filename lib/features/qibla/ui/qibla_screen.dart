import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:muslimate/generated/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:muslimate/core/app_colors.dart';
import 'package:muslimate/features/qibla/logic/qibla_provider.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Consumer<QiblaProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.qiblaLoading, style: GoogleFonts.plusJakartaSans(color: c.inkSoft)),
                  ],
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: c.gold, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(color: c.inkSoft),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: provider.init,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final isTablet = maxWidth > 600;
                final compassSize = math.min(maxWidth * 0.7, 400.0);

                return RefreshIndicator(
                  onRefresh: () => provider.refreshLocation(),
                  color: c.gold,
                  backgroundColor: c.surface,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        children: [
                          AppScreenHeader(
                            title: l10n.qiblaTitle,
                            subtitle: l10n.qiblaSubtitle,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: c.gold, size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    l10n.qiblaLocation(
                                      provider.address ?? '...',
                                      provider.qiblaBearing?.toStringAsFixed(0) ?? '0',
                                    ),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: c.inkSoft,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isTablet ? 60 : 40),
                          _CompassView(
                            size: compassSize,
                            heading: provider.heading ?? 0,
                            qiblaBearing: provider.qiblaBearing ?? 0,
                          ),
                          SizedBox(height: isTablet ? 60 : 40),
                          _StatusView(
                            heading: provider.heading ?? 0,
                            qiblaBearing: provider.qiblaBearing ?? 0,
                          ),
                          const SizedBox(height: 20),
                          _TipView(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CompassView extends StatefulWidget {
  final double size;
  final double heading;
  final double qiblaBearing;

  const _CompassView({
    required this.size,
    required this.heading,
    required this.qiblaBearing,
  });

  @override
  State<_CompassView> createState() => _CompassViewState();
}

class _CompassViewState extends State<_CompassView> with SingleTickerProviderStateMixin {
  late double _lastHeading;
  
  @override
  void initState() {
    super.initState();
    _lastHeading = widget.heading;
  }

  double _getNormalizedHeading(double target) {
    double diff = target - _lastHeading;
    if (diff > 180) {
      _lastHeading += 360;
    } else if (diff < -180) {
      _lastHeading -= 360;
    }
    _lastHeading = target;
    return target;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final delta = ((widget.qiblaBearing - widget.heading + 540) % 360) - 180;
    final aligned = delta.abs() < 4;

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // glow ring when aligned
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: widget.size + 20,
              height: widget.size + 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: aligned
                    ? RadialGradient(colors: [
                        c.goldSoft.withOpacity(0.6),
                        Colors.transparent,
                      ])
                    : null,
              ),
            ),
            // outer ring
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surface,
                border: Border.all(color: c.hairline),
              ),
            ),
            // rotating tick marks and labels
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: widget.heading),
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: -value * math.pi / 180,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _CompassFacePainter(
                      tickColor: c.hairline,
                      majorColor: c.gold,
                      labelColor: c.inkMuted,
                      northColor: c.gold,
                      kiblatBearing: widget.qiblaBearing,
                      kiblatColor: c.gold,
                      kiblatNavyColor: c.navy,
                      headingForLabels: value,
                      radius: widget.size / 2,
                      labels: [
                        AppLocalizations.of(context)!.north,
                        AppLocalizations.of(context)!.east,
                        AppLocalizations.of(context)!.south,
                        AppLocalizations.of(context)!.west,
                      ],
                    ),
                  ),
                );
              },
            ),
            // fixed needle
            Positioned(
              top: widget.size * 0.04,
              child: Container(
                width: 4,
                height: widget.size * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [c.gold, c.goldDeep],
                  ),
                ),
              ),
            ),
            // center dot with kaaba icon
            Container(
              width: widget.size * 0.2,
              height: widget.size * 0.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.navy,
                boxShadow: [
                  BoxShadow(
                    color: c.navy.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(Icons.explore_rounded, color: c.gold, size: widget.size * 0.1),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  final double heading;
  final double qiblaBearing;

  const _StatusView({
    required this.heading,
    required this.qiblaBearing,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final delta = ((qiblaBearing - heading + 540) % 360) - 180;
    final aligned = delta.abs() < 4;
    final deg = delta.abs().round();
    final dir = delta > 0 ? l10n.qiblaRight : l10n.qiblaLeft;

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: AppPill(
            key: ValueKey(aligned),
            text: aligned ? l10n.qiblaAligned : l10n.qiblaRotate(deg.toString(), dir),
            tone: aligned ? AppPillTone.gold : AppPillTone.muted,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            l10n.qiblaInstruction,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: c.inkSoft,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _TipView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.hairline),
        ),
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: c.inkSoft,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: l10n.qiblaTipTitle,
                style: TextStyle(color: c.ink, fontWeight: FontWeight.w600),
              ),
              TextSpan(text: l10n.qiblaTipContent),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassFacePainter extends CustomPainter {
  final Color tickColor;
  final Color majorColor;
  final Color labelColor;
  final Color northColor;
  final double kiblatBearing;
  final Color kiblatColor;
  final Color kiblatNavyColor;
  final double headingForLabels;
  final double radius;
  final List<String> labels;

  _CompassFacePainter({
    required this.tickColor,
    required this.majorColor,
    required this.labelColor,
    required this.northColor,
    required this.kiblatBearing,
    required this.kiblatColor,
    required this.kiblatNavyColor,
    required this.headingForLabels,
    required this.radius,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = radius - 2;

    // tick marks
    for (int i = 0; i < 72; i++) {
      final major = i % 9 == 0;
      final a = i * 360 / 72 * math.pi / 180;
      final r1 = major ? outerR - 14 : outerR - 8;
      final x1 = center.dx + math.sin(a) * r1;
      final y1 = center.dy - math.cos(a) * r1;
      final x2 = center.dx + math.sin(a) * outerR;
      final y2 = center.dy - math.cos(a) * outerR;

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = major ? majorColor : tickColor
          ..strokeWidth = major ? 2 : 1,
      );
    }

    // cardinal labels
    final cardinals = [
      (labels[0], 0.0, northColor),
      (labels[1], 90.0, labelColor),
      (labels[2], 180.0, labelColor),
      (labels[3], 270.0, labelColor),
    ];

    final textStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: radius * 0.1,
    );

    for (final (label, bearing, color) in cardinals) {
      final a = bearing * math.pi / 180;
      final x = center.dx + math.sin(a) * (outerR - 30);
      final y = center.dy - math.cos(a) * (outerR - 30);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(headingForLabels * math.pi / 180);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: textStyle.copyWith(color: color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Kiblat marker
    final ka = kiblatBearing * math.pi / 180;
    final kx = center.dx + math.sin(ka) * (outerR - 30);
    final ky = center.dy - math.cos(ka) * (outerR - 30);

    canvas.save();
    canvas.translate(kx, ky);
    canvas.rotate(headingForLabels * math.pi / 180);

    canvas.drawCircle(
      Offset.zero,
      radius * 0.12,
      Paint()..color = kiblatColor,
    );

    final kPaint = Paint()
      ..color = kiblatNavyColor
      ..style = PaintingStyle.fill;
    final squareSize = radius * 0.07;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: squareSize * 2, height: squareSize * 1.4),
        const Radius.circular(1),
      ),
      kPaint,
    );

    final roofPaint = Paint()
      ..color = kiblatColor.withOpacity(0.8)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final roofPath = Path()
      ..moveTo(-squareSize * 1.2, -squareSize * 0.5)
      ..lineTo(0, -squareSize * 1.0)
      ..lineTo(squareSize * 1.2, -squareSize * 0.5);
    canvas.drawPath(roofPath, roofPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CompassFacePainter old) => true;
}
