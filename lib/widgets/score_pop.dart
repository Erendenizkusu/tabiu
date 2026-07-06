import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pops a floating bubble (e.g. "+1", "+2", "TABU!") near the top of the game
/// area that scales in, drifts up and fades — the tactile reward for an action.
void showScorePop(
  BuildContext context, {
  required String text,
  required Color color,
  IconData? icon,
}) {
  final overlay = Overlay.of(context);
  final size = MediaQuery.of(context).size;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: size.height * 0.30,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: _Bubble(text: text, color: color, icon: icon)
              .animate(onComplete: (_) => entry.remove())
              .scale(
                begin: const Offset(0.3, 0.3),
                end: const Offset(1, 1),
                duration: 260.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 160.ms)
              .then(delay: 260.ms)
              .moveY(begin: 0, end: -90, duration: 620.ms, curve: Curves.easeOut)
              .fadeOut(duration: 620.ms),
        ),
      ),
    ),
  );
  overlay.insert(entry);
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.color, this.icon});
  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
