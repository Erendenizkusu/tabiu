import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders App Store / Play marketing screenshots for Tabiu via the Flutter
/// engine. Run with:  flutter test tool/gen_screenshots.dart
///
/// Each frame = the deep-violet "Mor Parti" background, a Fredoka caption up
/// top (the app's own font), and the raw device screenshot below with rounded
/// corners and a soft drop shadow. Output size 1242x2688 (App Store 6.5"/6.7"
/// portrait), which Play Store also accepts.
///
/// Source screenshots live in store/screenshots/raw/ and outputs are written
/// to store/screenshots/ios/.

const _w = 1242.0;
const _h = 2688.0;

/// (source file, line 1, line 2) — captions are two Fredoka lines.
const _shots = <List<String>>[
  ['1_home.png', 'Arkadaşlarınla', 'gerçek zamanlı oyna'],
  ['2_setup.png', 'Round, süre ve pas', 'hakkını sen ayarla'],
  ['3_lobby.png', 'Oda kur,', 'kodu paylaş'],
  ['4_play.png', 'Yasaklı kelimelere', 'değmeden anlat'],
  ['5_score.png', 'Kıran kırana', 'takım rekabeti'],
  ['6_win.png', 'Kazananı', 'konfetiyle kutla!'],
];

Future<void> _loadFredoka() async {
  final f = File('tool/fredoka.ttf');
  await ui.loadFontFromList(f.readAsBytesSync(), fontFamily: 'Fredoka');
}

Future<ui.Image> _decode(String path) async {
  final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
  return (await codec.getNextFrame()).image;
}

void main() {
  test('generate store screenshots', () async {
    await _loadFredoka();
    Directory('store/screenshots/ios').createSync(recursive: true);
    for (var i = 0; i < _shots.length; i++) {
      final s = _shots[i];
      final shot = await _decode('store/screenshots/raw/${s[0]}');
      final out = 'store/screenshots/ios/${(i + 1).toString().padLeft(2, '0')}_'
          '${s[0].substring(2)}';
      await _writeFrame(out, shot: shot, line1: s[1], line2: s[2]);
    }
  });
}

Future<void> _writeFrame(String path,
    {required ui.Image shot,
    required String line1,
    required String line2}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, _w, _h));
  const rect = Rect.fromLTWH(0, 0, _w, _h);

  // Deep-violet party gradient + a magenta glow up top behind the caption.
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
        const Offset(_w * 0.5, 300),
        _w * 0.75,
        [const Color(0x55C46BFF), const Color(0x00000000)],
      ),
  );

  // Caption — two lines of Fredoka SemiBold, centred.
  final caption = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.center,
    fontFamily: 'Fredoka',
    fontSize: 86,
    height: 1.14,
  ))
    ..pushStyle(ui.TextStyle(
      color: Colors.white,
      fontVariations: const [ui.FontVariation('wght', 600)],
      shadows: const [
        Shadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6)),
      ],
    ))
    ..addText('$line1\n$line2');
  final para = caption.build()
    ..layout(const ui.ParagraphConstraints(width: _w - 140));
  canvas.drawParagraph(para, const Offset(70, 150));

  // Pink→magenta accent bar under the caption (echoes the in-game card divider).
  final barY = 150 + para.height + 40;
  final barRect =
      Rect.fromCenter(center: Offset(_w / 2, barY), width: 132, height: 12);
  canvas.drawRRect(
    RRect.fromRectAndRadius(barRect, const Radius.circular(6)),
    Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFC46BFF), Color(0xFFFF4FB8)])
          .createShader(barRect),
  );

  // Device screenshot: fixed rendered height, centred, rounded + shadowed.
  const ssHeight = 2040.0;
  const ssTop = 486.0;
  final scale = ssHeight / shot.height;
  final ssWidth = shot.width * scale;
  final dst = Rect.fromLTWH((_w - ssWidth) / 2, ssTop, ssWidth, ssHeight);
  final rr = RRect.fromRectAndRadius(dst, const Radius.circular(46));

  // Soft drop shadow.
  canvas.drawRRect(
    rr.shift(const Offset(0, 26)),
    Paint()
      ..color = const Color(0x66000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 46),
  );
  // Clip to rounded corners and paint the screenshot.
  canvas.save();
  canvas.clipRRect(rr);
  canvas.drawImageRect(
    shot,
    Rect.fromLTWH(0, 0, shot.width.toDouble(), shot.height.toDouble()),
    dst,
    Paint()..filterQuality = FilterQuality.high,
  );
  canvas.restore();
  // Hairline edge so screens that share the violet bg still read as a card.
  canvas.drawRRect(
    rr.deflate(1),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0x33FFFFFF),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(_w.toInt(), _h.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}
