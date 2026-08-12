import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pops a floating bubble (e.g. "+1", "+2", "TABU!") that rises out of the
/// action button that triggered it, drifts up and fades — the tactile reward
/// for an action.
///
/// [alignX] places the bubble horizontally over the pressed button, in the
/// [-1, 1] range (-1 = left edge, 0 = centre, 1 = right edge), matching the
/// three-column control row.
void showScorePop(
  BuildContext context, {
  required String text,
  required Color color,
  IconData? icon,
  double alignX = 0.0,
}) {
  final overlay = Overlay.of(context);
  final mq = MediaQuery.of(context);
  // Sit just above the narrator control row (action buttons + pass + hint),
  // accounting for the bottom safe-area inset, then float upward.
  final bottomOffset = mq.padding.bottom + 188;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: bottomOffset,
      left: 20,
      right: 20,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment(alignX, 0),
          child: _Bubble(text: text, color: color, icon: icon)
              .animate(onComplete: (_) => entry.remove())
              .scale(
                begin: const Offset(0.4, 0.4),
                end: const Offset(1, 1),
                duration: 240.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 140.ms)
              .then(delay: 220.ms)
              .moveY(begin: 0, end: -120, duration: 640.ms, curve: Curves.easeOut)
              .fadeOut(duration: 640.ms),
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
