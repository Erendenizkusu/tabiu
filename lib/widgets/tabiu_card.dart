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
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, AppColors.cardPaper],
        ),
        borderRadius: BorderRadius.circular(30),
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
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Soft glossy light blobs for depth (references' card look).
            Positioned(
              top: -70,
              right: -50,
              child: _blob(150, AppColors.magenta.withValues(alpha: 0.12)),
            ),
            Positioned(
              bottom: -60,
              left: -50,
              child: _blob(140, AppColors.violet.withValues(alpha: 0.10)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _ribbon(),
                      const Spacer(),
                      _sideChip(isBack ? 'ARKA' : 'ÖN'),
                    ],
                  ),
                  const Spacer(flex: 3),
                  Text(
                    'BU KELİMEYİ ANLAT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.violet.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      card.main.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.archivo(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        height: 1.0,
                        color: AppColors.cardInk,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      height: 5,
                      width: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.violet, AppColors.magenta],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'YASAK KELİMELER',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.red.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  ...card.forbidden.map(_forbiddenRow),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 20)],
        ),
      );

  Widget _ribbon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _sideChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardInk.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.flip_camera_android_rounded,
              size: 14, color: AppColors.cardInk.withValues(alpha: 0.5)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.cardInk.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _forbiddenRow(String word) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.not_interested_rounded,
              size: 20, color: AppColors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              word,
              style: const TextStyle(
                fontSize: 19,
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
