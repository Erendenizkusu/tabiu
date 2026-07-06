import 'package:flutter/material.dart';

import '../app/palette.dart';
import '../data/models/team.dart';

/// Signature red↔blue rivalry bar. A single track whose split shifts toward the
/// leading team; used on lobby, game, round-end and result screens.
class DuelScoreBar extends StatelessWidget {
  const DuelScoreBar({
    super.key,
    required this.red,
    required this.blue,
    this.height = 74,
    this.activeTeam,
  });

  final int red;
  final int blue;
  final double height;

  /// When set, that team's side gets a subtle "playing now" glow.
  final Team? activeTeam;

  @override
  Widget build(BuildContext context) {
    // Base weight keeps both sides visible at 0-0; scores tilt the split.
    final total = red + blue;
    final redFraction = total == 0 ? 0.5 : (red + 1) / (total + 2);

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  flex: (redFraction * 1000).round().clamp(120, 880),
                  child: _side(Team.red, red, Alignment.centerLeft),
                ),
                Expanded(
                  flex: ((1 - redFraction) * 1000).round().clamp(120, 880),
                  child: _side(Team.blue, blue, Alignment.centerRight),
                ),
              ],
            ),
            // Center divider.
            const Align(
              alignment: Alignment.center,
              child: _Divider(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _side(Team team, int score, Alignment align) {
    final active = activeTeam == team;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            team.color.withValues(alpha: active ? 0.95 : 0.8),
            team.color.withValues(alpha: active ? 0.7 : 0.5),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRect(
        child: Align(
        alignment: align,
        child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: align,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              team.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 10),
            TweenAnimationBuilder<double>(
              tween: Tween(end: score.toDouble()),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (_, v, _) => Text(
                v.round().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
        width: 4,
        color: AppColors.cardPaper.withValues(alpha: 0.9),
      );
}
