import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders the Tabiu launcher icon to PNG via the Flutter engine.
/// Run with:  flutter test tool/gen_icon.dart
///
/// Brand mark: a rounded "word tile" in a pink→magenta gradient sitting on the
/// deep-violet party background, bearing a bold, hand-drawn white "T" monogram.
/// The T is drawn as vector paths (no font dependency) so it stays crisp and
/// legible at every launcher size.
///
/// Produces three files under tool/:
///   icon_full.png       — 1024x1024, full-bleed violet background
///                         (Android legacy + iOS + Play Store listing icon).
///   icon_foreground.png — 1024x1024, transparent bg, tile centered in the
///                         adaptive safe zone (Android adaptive foreground).
///   icon_monochrome.png — 1024x1024, white silhouette on transparent
///                         (Android 13+ themed icon).
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
    // Play Store hi-res listing icon (512x512, full-bleed).
    await _write('tool/play_store_icon.png', mode: _Mode.full, size: 512);
    // Play Store feature graphic (1024x500 banner).
    await _writeFeatureGraphic('tool/play_feature_graphic.png');
  });
}

enum _Mode { full, foreground, background, monochrome }

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

/// Play Store feature graphic: a 1024x500 banner with the violet gradient,
/// the tile+T mark on the left and the "Tabiu" wordmark + tagline beside it.
Future<void> _writeFeatureGraphic(String path) async {
  const w = 1024.0;
  const h = 500.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, w, h));
  final rect = const Rect.fromLTWH(0, 0, w, h);

  // Violet gradient background.
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3A1B6E), Color(0xFF160A2E)],
      ).createShader(rect),
  );
  // Glow behind the mark.
  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.radial(
        const Offset(300, 250),
        360,
        [const Color(0x55C46BFF), const Color(0x00000000)],
      ),
  );

  // The tile mark on the left (reuse the icon painter on a 360-box).
  const markSize = 360.0;
  canvas.save();
  canvas.translate(70, (h - markSize) / 2);
  _paintIcon(canvas, markSize, mode: _Mode.foreground);
  canvas.restore();

  // Wordmark "Tabiu".
  final title = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.left,
    fontFamily: 'Brand',
    fontSize: 120,
    fontWeight: FontWeight.w800,
  ))
    ..pushStyle(ui.TextStyle(color: Colors.white, fontWeight: FontWeight.w800))
    ..addText('Tabiu');
  final titlePara = title.build()..layout(const ui.ParagraphConstraints(width: 560));
  canvas.drawParagraph(titlePara, const Offset(470, 170));

  // Tagline.
  final tag = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.left,
    fontFamily: 'Brand',
    fontSize: 34,
    fontWeight: FontWeight.w500,
  ))
    ..pushStyle(ui.TextStyle(color: const Color(0xFFE9D9FF)))
    ..addText('Yasaklı kelimelere değmeden anlat');
  final tagPara = tag.build()..layout(const ui.ParagraphConstraints(width: 520));
  canvas.drawParagraph(tagPara, const Offset(474, 300));

  final picture = recorder.endRecording();
  final image = await picture.toImage(w.toInt(), h.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void _paintIcon(Canvas canvas, double size, {required _Mode mode}) {
  final rect = Rect.fromLTWH(0, 0, size, size);
  final monochrome = mode == _Mode.monochrome;

  if (mode == _Mode.full || mode == _Mode.background) {
    // Deep violet party background (matches the app's dark gradient).
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A1B6E), Color(0xFF160A2E)],
        ).createShader(rect),
    );
    // Soft radial glow behind the tile.
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

  // The adaptive background layer is just the violet field (no tile/letter).
  if (mode == _Mode.background) return;

  // ---- The word tile --------------------------------------------------------
  // Adaptive foreground must live inside the central safe zone, so it uses a
  // smaller tile; the full / monochrome icons fill more of the canvas.
  // The adaptive foreground/monochrome layers get a 16% inset applied by the
  // generated adaptive-icon XML, so their tile is drawn larger to compensate
  // (0.88 * 0.68 ≈ 0.60 of the final masked icon). The legacy/full square icon
  // fills less because it has no mask.
  final tileScale =
      (mode == _Mode.foreground || mode == _Mode.monochrome) ? 0.88 : 0.64;
  final t = size * tileScale;
  final center = Offset(size * 0.5, size * 0.5);
  final tileRect = Rect.fromCenter(center: center, width: t, height: t);
  final tileRadius = Radius.circular(t * 0.30);
  final tile = RRect.fromRectAndRadius(tileRect, tileRadius);

  if (!monochrome) {
    // Drop shadow for depth.
    canvas.drawRRect(
      tile.shift(Offset(0, t * 0.045)),
      Paint()
        ..color = const Color(0x4D000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, t * 0.06),
    );
    // Pink → magenta gradient tile face.
    canvas.drawRRect(
      tile,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC46BFF), Color(0xFFFF4FB8)],
        ).createShader(tileRect),
    );
    // Top gloss highlight.
    final glossRect = Rect.fromLTWH(
      tileRect.left,
      tileRect.top,
      tileRect.width,
      tileRect.height * 0.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        glossRect,
        topLeft: tileRadius,
        topRight: tileRadius,
      ),
      Paint()..color = const Color(0x1AFFFFFF),
    );
    // Inner hairline for a crisp edge.
    canvas.drawRRect(
      tile.deflate(t * 0.012),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = t * 0.012
        ..color = const Color(0x22FFFFFF),
    );
  }

  // ---- The "T" monogram -----------------------------------------------------
  // Drawn as two overlapping rounded bars so it is font-independent and reads
  // as a designed mark rather than typeset text.
  final letterColor = monochrome ? Colors.white : Colors.white;
  final letterPaint = Paint()..color = letterColor;
  final r = Radius.circular(t * 0.045);

  // Horizontal bar (top of the T).
  final barW = t * 0.56;
  final barH = t * 0.155;
  final barRect = Rect.fromCenter(
    center: Offset(center.dx, tileRect.top + t * 0.31),
    width: barW,
    height: barH,
  );
  // Vertical stem.
  final stemW = t * 0.17;
  final stemH = t * 0.50;
  final stemRect = Rect.fromCenter(
    center: Offset(center.dx, barRect.top + stemH / 2),
    width: stemW,
    height: stemH,
  );

  if (!monochrome) {
    // Subtle shadow under the letter for lift.
    final shadow = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, t * 0.015);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect.shift(Offset(0, t * 0.01)), r),
      shadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(stemRect.shift(Offset(0, t * 0.01)), r),
      shadow,
    );
  }

  canvas.drawRRect(RRect.fromRectAndRadius(barRect, r), letterPaint);
  canvas.drawRRect(RRect.fromRectAndRadius(stemRect, r), letterPaint);
}
