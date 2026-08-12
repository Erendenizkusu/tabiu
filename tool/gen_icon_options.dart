import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders several "stacked card / deck" launcher-icon concepts so we can pick
/// one. Run with:  flutter test tool/gen_icon_options.dart
/// Outputs 512x512 PNGs under tool/options/.
void main() {
  test('generate icon options', () async {
    Directory('tool/options').createSync(recursive: true);
    await _render('tool/options/opt_a_stack.png', _variantStack);
    await _render('tool/options/opt_b_fan.png', _variantFan);
    await _render('tool/options/opt_c_team.png', _variantTeam);
    await _render('tool/options/opt_d_two.png', _variantTwo);
    await _render('tool/options/opt_e_deck.png', _variantDeck);
  });
}

Future<void> _render(String path, void Function(Canvas, double) paint) async {
  const s = 512.0;
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec, const Rect.fromLTWH(0, 0, s, s));
  _background(canvas, s);
  paint(canvas, s);
  final img = await rec.endRecording().toImage(s.toInt(), s.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void _background(Canvas canvas, double s) {
  final rect = Rect.fromLTWH(0, 0, s, s);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3A1B6E), Color(0xFF160A2E)],
      ).createShader(rect),
  );
  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.radial(
        Offset(s * 0.5, s * 0.46),
        s * 0.5,
        [const Color(0x557A3FCF), const Color(0x00000000)],
      ),
  );
}

// A single rounded card, optionally rotated, with gloss / shadow / a white "T".
void _card(
  Canvas canvas,
  double s, {
  required Offset center,
  required double w,
  required double h,
  double rotation = 0,
  List<Color>? gradient,
  Color? solid,
  bool gloss = true,
  bool letter = false,
}) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotation);
  final r = Rect.fromCenter(center: Offset.zero, width: w, height: h);
  final radius = Radius.circular(w * 0.15);
  final rr = RRect.fromRectAndRadius(r, radius);

  // Shadow.
  canvas.drawRRect(
    rr.shift(Offset(0, h * 0.03)),
    Paint()
      ..color = const Color(0x4D000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.06),
  );
  // Face.
  final face = Paint();
  if (gradient != null) {
    face.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradient,
    ).createShader(r);
  } else {
    face.color = solid ?? Colors.white;
  }
  canvas.drawRRect(rr, face);
  // Gloss.
  if (gloss) {
    final gr = Rect.fromLTWH(r.left, r.top, r.width, r.height * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndCorners(gr, topLeft: radius, topRight: radius),
      Paint()..color = const Color(0x1AFFFFFF),
    );
  }
  // Hairline edge.
  canvas.drawRRect(
    rr.deflate(w * 0.012),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..color = const Color(0x22FFFFFF),
  );
  // T monogram.
  if (letter) {
    final lp = Paint()..color = Colors.white;
    final lr = Radius.circular(w * 0.05);
    final barW = w * 0.58;
    final barH = w * 0.17;
    final barRect = Rect.fromCenter(
      center: Offset(0, -h * 0.11),
      width: barW,
      height: barH,
    );
    final stemW = w * 0.185;
    final stemH = h * 0.46;
    final stemRect = Rect.fromCenter(
      center: Offset(0, -h * 0.11 + stemH / 2),
      width: stemW,
      height: stemH,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(barRect, lr), lp);
    canvas.drawRRect(RRect.fromRectAndRadius(stemRect, lr), lp);
  }
  canvas.restore();
}

const _pink = [Color(0xFFC46BFF), Color(0xFFFF4FB8)];
const _lavender = Color(0xFFCDB2F2);
const _lavender2 = Color(0xFFB98BEF);

// A) Straight-ish stack, backs peeking up-right, front pink with T.
void _variantStack(Canvas c, double s) {
  final center = Offset(s * 0.5, s * 0.52);
  final w = s * 0.44, h = s * 0.56;
  _card(c, s, center: center + Offset(s * 0.06, -s * 0.055), w: w, h: h, rotation: 0.14, solid: _lavender2, gloss: false, letter: false);
  _card(c, s, center: center + Offset(s * 0.03, -s * 0.028), w: w, h: h, rotation: 0.07, solid: _lavender, gloss: false, letter: false);
  _card(c, s, center: center, w: w, h: h, gradient: _pink, letter: true);
}

// B) Symmetric fan of three, front upright pink with T.
void _variantFan(Canvas c, double s) {
  final center = Offset(s * 0.5, s * 0.54);
  final w = s * 0.42, h = s * 0.54;
  _card(c, s, center: center + Offset(-s * 0.02, s * 0.01), w: w, h: h, rotation: -0.28, solid: _lavender, gloss: false);
  _card(c, s, center: center + Offset(s * 0.02, s * 0.01), w: w, h: h, rotation: 0.28, solid: _lavender2, gloss: false);
  _card(c, s, center: center, w: w, h: h, gradient: _pink, letter: true);
}

// C) Team fan — blue + red backs (Red vs Blue story), pink front with T.
void _variantTeam(Canvas c, double s) {
  final center = Offset(s * 0.5, s * 0.54);
  final w = s * 0.42, h = s * 0.54;
  _card(c, s, center: center + Offset(-s * 0.015, 0), w: w, h: h, rotation: -0.30, gradient: const [Color(0xFF6FC0FF), Color(0xFF3D8BFF)]);
  _card(c, s, center: center + Offset(s * 0.015, 0), w: w, h: h, rotation: 0.30, gradient: const [Color(0xFFFF7A93), Color(0xFFFF3D64)]);
  _card(c, s, center: center, w: w, h: h, gradient: _pink, letter: true);
}

// D) Minimal two-card, one back offset, front pink with T.
void _variantTwo(Canvas c, double s) {
  final center = Offset(s * 0.5, s * 0.52);
  final w = s * 0.46, h = s * 0.58;
  _card(c, s, center: center + Offset(s * 0.055, -s * 0.05), w: w, h: h, rotation: 0.11, solid: _lavender, gloss: false);
  _card(c, s, center: center, w: w, h: h, gradient: _pink, letter: true);
}

// E) Straight vertical deck — cards directly behind, peeking at the top.
void _variantDeck(Canvas c, double s) {
  final center = Offset(s * 0.5, s * 0.53);
  final w = s * 0.5, h = s * 0.54;
  _card(c, s, center: center + Offset(0, -s * 0.075), w: w * 0.9, h: h, solid: _lavender2, gloss: false);
  _card(c, s, center: center + Offset(0, -s * 0.038), w: w * 0.95, h: h, solid: _lavender, gloss: false);
  _card(c, s, center: center, w: w, h: h, gradient: _pink, letter: true);
}
