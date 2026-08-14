import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/palette.dart';
import '../data/models/card_model.dart';

/// The signature flippable Taboo card. Tapping flips between the front and back
/// word (each a real card with its own forbidden list), with a 3D Y-axis turn.
class TabiuCard extends StatefulWidget {
  const TabiuCard({
    super.key,
    required this.front,
    required this.back,
    required this.showingBack,
    this.onTap,
  });

  final TabooCard front;
  final TabooCard back;
  final bool showingBack;
  final VoidCallback? onTap;

  @override
  State<TabiuCard> createState() => _TabiuCardState();
}

class _TabiuCardState extends State<TabiuCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
    value: widget.showingBack ? 1 : 0,
  );

  @override
  void didUpdateWidget(TabiuCard old) {
    super.didUpdateWidget(old);
    if (old.showingBack != widget.showingBack) {
      _c.animateTo(widget.showingBack ? 1 : 0, curve: Curves.easeInOutCubic);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final angle = _c.value * math.pi;
          final showBack = angle > math.pi / 2;
          final card = showBack ? widget.back : widget.front;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: Transform(
              alignment: Alignment.center,
              // Un-mirror the back face.
              transform: showBack ? (Matrix4.identity()..rotateY(math.pi)) : Matrix4.identity(),
              child: _CardFace(card: card, isBack: showBack),
            ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.card, required this.isBack});

  final TabooCard card;
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    // Everything scales off the card's own height so the layout is identical
    // at any size — a tiny card on a short/large-font screen and a big card on
    // a tall one both stay perfectly proportioned, and nothing ever clips.
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight.isFinite ? c.maxHeight : 460.0;
        final w = c.maxWidth.isFinite ? c.maxWidth : 320.0;
        final s = (h / 460).clamp(0.68, 1.3); // scale factor vs. design card
        final pad = 24.0 * s;
        final radius = (28.0 * s).clamp(20.0, 34.0);

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, AppColors.cardPaper],
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.violet.withValues(alpha: 0.5),
                blurRadius: 44,
                spreadRadius: -8,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, pad * 0.9, pad, pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _ribbon(s),
                      const Spacer(),
                      _sideChip(isBack ? 'ARKA' : 'ÖN', s),
                    ],
                  ),
                  // Word block: flexible so it shares space with the forbidden
                  // list, centred, and shrink-to-fit on both axes.
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'BU KELİMEYİ ANLAT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11 * s,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: AppColors.violet.withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: 10 * s),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                card.main.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.archivo(
                                  fontSize: 46 * s,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  height: 1.0,
                                  color: AppColors.cardInk,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 14 * s),
                          Container(
                            height: 5 * s,
                            width: 64 * s,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.violet, AppColors.magenta],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  Text(
                    'YASAK KELİMELER',
                    style: TextStyle(
                      fontSize: 10.5 * s,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.red.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  // Forbidden list: the whole column is scaled down to fit its
                  // slot, so any number of words always fits — no clipping.
                  Flexible(
                    flex: 4,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: (w - pad * 2).clamp(1.0, double.infinity),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final word in card.forbidden)
                              _forbiddenRow(word, s),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ribbon(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.violet, AppColors.magenta],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'TABİU',
        style: GoogleFonts.fredoka(
          fontSize: 14 * s,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _sideChip(String label, double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: AppColors.cardInk.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flip_camera_android_rounded,
              size: 14 * s, color: AppColors.cardInk.withValues(alpha: 0.5)),
          SizedBox(width: 5 * s),
          Text(
            label,
            style: TextStyle(
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.cardInk.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _forbiddenRow(String word, double s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5 * s),
      child: Row(
        children: [
          Icon(Icons.not_interested_rounded, size: 20 * s, color: AppColors.red),
          SizedBox(width: 12 * s),
          Expanded(
            child: Text(
              word,
              style: TextStyle(
                fontSize: 19 * s,
                fontWeight: FontWeight.w600,
                color: AppColors.cardInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The spectator-facing card back — hides the word from non-narrators.
class HiddenCard extends StatelessWidget {
  const HiddenCard({super.key, this.message = 'Anlatıcı kartı görüyor'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A1B6E), Color(0xFF241247)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.35),
            blurRadius: 34,
            spreadRadius: -8,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.violet, AppColors.magenta]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'TABİU',
                style: GoogleFonts.fredoka(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
