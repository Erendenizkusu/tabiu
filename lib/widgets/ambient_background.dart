import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/palette.dart';

/// The glowing violet atmosphere behind every screen: a large soft radial glow
/// plus slow-drifting bokeh orbs. This is the premium "party" backdrop.
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({super.key});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  late final List<_Orb> _orbs = _buildOrbs();

  List<_Orb> _buildOrbs() {
    final rng = math.Random(7);
    const colors = [AppColors.violet, AppColors.magenta, AppColors.blue];
    // Few, subtle orbs — heavy bokeh reads as generic "AI gradient".
    return List.generate(4, (i) {
      return _Orb(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 60 + rng.nextDouble() * 70,
        speed: 0.3 + rng.nextDouble() * 0.5,
        phase: rng.nextDouble(),
        color: colors[i % colors.length],
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glow = isDark ? AppSurface.darkGlow : AppSurface.lightGlow;
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _AmbientPainter(
              t: _c.value,
              orbs: _orbs,
              glow: glow,
              opacity: isDark ? 1.0 : 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _Orb {
  const _Orb({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.color,
  });
  final double x, y, radius, speed, phase;
  final Color color;
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({
    required this.t,
    required this.orbs,
    required this.glow,
    required this.opacity,
  });

  final double t;
  final List<_Orb> orbs;
  final Color glow;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    // One restrained glow near the upper third (a deliberate light source, not
    // a generic all-over wash).
    final glowCenter = Offset(size.width * 0.5, size.height * 0.24);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [glow.withValues(alpha: 0.32 * opacity), glow.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: glowCenter, radius: size.width * 0.75));
    canvas.drawCircle(glowCenter, size.width * 0.75, glowPaint);

    // A few slow, subtle orbs.
    for (final o in orbs) {
      final drift = (t * o.speed + o.phase) % 1.0;
      final dy = (o.y - drift) % 1.0;
      final center = Offset(
        o.x * size.width + math.sin((t + o.phase) * 2 * math.pi) * 14,
        dy * size.height,
      );
      final paint = Paint()
        ..color = o.color.withValues(alpha: 0.09 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
      canvas.drawCircle(center, o.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter old) => old.t != t;
}

/// Static fine-grain / film-noise overlay. Painted once (not animated) — grain
/// is the cheapest way to make a flat gradient read as intentional, not "AI".
class GrainOverlay extends StatelessWidget {
  const GrainOverlay({super.key, this.opacity = 0.05});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(size: Size.infinite, painter: _GrainPainter(opacity)),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter(this.opacity);
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(1234);
    final count = ((size.width * size.height) / 900).clamp(400, 2600).toInt();
    final light = Paint()..color = Colors.white.withValues(alpha: opacity);
    final dark = Paint()..color = Colors.black.withValues(alpha: opacity * 1.4);
    for (var i = 0; i < count; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final s = rng.nextDouble() < 0.5 ? 1.0 : 1.4;
      canvas.drawRect(Rect.fromLTWH(dx, dy, s, s), rng.nextBool() ? light : dark);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter old) => old.opacity != opacity;
}
