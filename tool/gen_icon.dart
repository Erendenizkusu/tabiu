import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders the Tabiu launcher icon to PNG via the Flutter engine.
/// Run with:  flutter test tool/gen_icon.dart
///
/// Brand mark ("Deste"): a stack of rounded cards on the deep-violet party
/// background — two lavender cards peeking out to the upper-right and a front
/// pink→magenta card bearing a bold, hand-drawn white "T" monogram. Everything
/// is drawn as vector paths (no font dependency) so it stays crisp at every
/// launcher size.
///
/// Produces, under tool/:
///   icon_full.png        — 1024, full-bleed violet bg (legacy/iOS/listing).
///   icon_foreground.png  — 1024, transparent, deck sized for the adaptive
///                          safe zone (Android adaptive foreground).
///   icon_background.png  — 1024, the violet field only (adaptive background).
///   icon_monochrome.png  — 1024, white card+T silhouette (Android 13 themed).
///   play_store_icon.png  — 512, hi-res Play Store listing icon.
///   play_feature_graphic.png — 1024x500 feature graphic banner.
enum _Mode { full, foreground, background, monochrome }

/// Loads a real bold TTF from the host so ParagraphBuilder renders glyphs
/// instead of tofu boxes (the flutter_test engine ships no Latin fallback).
Future<void> _loadBrandFont() async {
  const candidates = [
    r'C:\Windows\Fonts\segoeuib.ttf',
    r'C:\Windows\Fonts\arialbd.ttf',
    '/System/Library/Fonts/SFNSDisplay.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
  ];
  for (final p in candidates) {
    final f = File(p);
    if (f.existsSync()) {
      await ui.loadFontFromList(f.readAsBytesSync(), fontFamily: 'Brand');
      return;
    }
  }
}

void main() {
  test('generate launcher icon', () async {
    await _loadBrandFont();
    await _write('tool/icon_full.png', mode: _Mode.full);
    await _write('tool/icon_foreground.png', mode: _Mode.foreground);
    await _write('tool/icon_background.png', mode: _Mode.background);
    await _write('tool/icon_monochrome.png', mode: _Mode.monochrome);
    await _write('tool/play_store_icon.png', mode: _Mode.full, size: 512);
    await _writeFeatureGraphic('tool/play_feature_graphic.png');
  });
}

Future<void> _write(String path,
    {required _Mode mode, double size = 1024}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));
  _paintIcon(canvas, size, mode: mode);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

const _pink = [Color(0xFFC46BFF), Color(0xFFFF4FB8)];
const _lavender = Color(0xFFCDB2F2);
const _lavender2 = Color(0xFFB98BEF);

void _paintIcon(Canvas canvas, double size, {required _Mode mode}) {
  final rect = Rect.fromLTWH(0, 0, size, size);

  if (mode == _Mode.full || mode == _Mode.background) {
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
          Offset(size * 0.5, size * 0.46),
          size * 0.5,
          [const Color(0x557A3FCF), const Color(0x00000000)],
        ),
    );
  }
  if (mode == _Mode.background) return;

  // The adaptive foreground / monochrome layers get a 16% inset applied by the
  // generated adaptive-icon XML, so their deck is drawn larger to compensate.
  final grow = (mode == _Mode.foreground || mode == _Mode.monochrome) ? 1.32 : 1.0;
  final center = Offset(size * 0.5, size * 0.52);
  final w = size * 0.44 * grow;
  final h = size * 0.56 * grow;

  if (mode == _Mode.monochrome) {
    // Single white card silhouette with the T knocked out — recognizable and
    // clean when the system tints it.
    canvas.saveLayer(Rect.fromLTWH(0, 0, size, size), Paint());
    _cardShape(canvas, center: center, w: w, h: h, paint: Paint()..color = Colors.white);
    _drawT(canvas, center: center, w: w, h: h,
        paint: Paint()..blendMode = BlendMode.clear);
    canvas.restore();
    return;
  }

  // Two lavender cards peeking to the upper-right, then the pink front card.
  _card(canvas,
      center: center + Offset(size * 0.06, -size * 0.055),
      w: w, h: h, rotation: 0.14, solid: _lavender2, gloss: false);
  _card(canvas,
      center: center + Offset(size * 0.03, -size * 0.028),
      w: w, h: h, rotation: 0.07, solid: _lavender, gloss: false);
  _card(canvas, center: center, w: w, h: h, gradient: _pink, letter: true);
}

// Draws just the rounded-rect card body (used for the monochrome silhouette).
void _cardShape(Canvas canvas,
    {required Offset center,
    required double w,
    required double h,
    required Paint paint}) {
  final r = Rect.fromCenter(center: center, width: w, height: h);
  canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(w * 0.15)), paint);
}

// Draws the T monogram centered on a card of the given size.
void _drawT(Canvas canvas,
    {required Offset center,
    required double w,
    required double h,
    required Paint paint}) {
  final lr = Radius.circular(w * 0.05);
  final barRect = Rect.fromCenter(
    center: Offset(center.dx, center.dy - h * 0.11),
    width: w * 0.58,
    height: w * 0.17,
  );
  final stemH = h * 0.46;
  final stemRect = Rect.fromCenter(
    center: Offset(center.dx, center.dy - h * 0.11 + stemH / 2),
    width: w * 0.185,
    height: stemH,
  );
  canvas.drawRRect(RRect.fromRectAndRadius(barRect, lr), paint);
  canvas.drawRRect(RRect.fromRectAndRadius(stemRect, lr), paint);
}

// A single rounded card, optionally rotated, with gloss / shadow / a white "T".
void _card(
  Canvas canvas, {
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

  canvas.drawRRect(
    rr.shift(Offset(0, h * 0.03)),
    Paint()
      ..color = const Color(0x4D000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.06),
  );
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
  if (gloss) {
    final gr = Rect.fromLTWH(r.left, r.top, r.width, r.height * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndCorners(gr, topLeft: radius, topRight: radius),
      Paint()..color = const Color(0x1AFFFFFF),
    );
  }
  canvas.drawRRect(
    rr.deflate(w * 0.012),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..color = const Color(0x22FFFFFF),
  );
  if (letter) {
    _drawT(canvas, center: Offset.zero, w: w, h: h, paint: Paint()..color = Colors.white);
  }
  canvas.restore();
}

/// Play Store feature graphic: a 1024x500 banner with the violet gradient,
/// the card-deck mark on the left and the "Tabiu" wordmark + tagline beside it.
Future<void> _writeFeatureGraphic(String path) async {
  const w = 1024.0;
  const h = 500.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, w, h));
  final rect = const Rect.fromLTWH(0, 0, w, h);

  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3A1B6E), Color(0xFF160A2E)],
      ).createShader(rect),
  );
  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.radial(
        const Offset(300, 250),
        360,
        [const Color(0x55C46BFF), const Color(0x00000000)],
      ),
  );

  // The deck mark on the left (reuse the icon painter, foreground layout).
  const markSize = 380.0;
  canvas.save();
  canvas.translate(60, (h - markSize) / 2);
  _paintIcon(canvas, markSize, mode: _Mode.foreground);
  canvas.restore();

  final title = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.left,
    fontFamily: 'Brand',
    fontSize: 120,
    fontWeight: FontWeight.w800,
  ))
    ..pushStyle(ui.TextStyle(color: Colors.white, fontWeight: FontWeight.w800))
    ..addText('Tabiu');
  final titlePara = title.build()..layout(const ui.ParagraphConstraints(width: 560));
  canvas.drawParagraph(titlePara, const Offset(470, 168));

  final tag = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.left,
    fontFamily: 'Brand',
    fontSize: 34,
    fontWeight: FontWeight.w500,
  ))
    ..pushStyle(ui.TextStyle(color: const Color(0xFFE9D9FF)))
    ..addText('Yasaklı kelimelere değmeden anlat');
  final tagPara = tag.build()..layout(const ui.ParagraphConstraints(width: 520));
  canvas.drawParagraph(tagPara, const Offset(474, 298));

  final picture = recorder.endRecording();
  final image = await picture.toImage(w.toInt(), h.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}
