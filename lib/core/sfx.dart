import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Runtime sound effects — no bundled audio files. Short tones are synthesized
/// into 16-bit PCM WAV bytes once, cached, then played via [AudioPlayer].
class Sfx {
  Sfx._();
  static final Sfx instance = Sfx._();

  bool enabled = true;
  final _player = AudioPlayer(playerId: 'tabiu_sfx')..setReleaseMode(ReleaseMode.stop);
  final _cache = <String, Uint8List>{};

  Future<void> _play(String key, Uint8List Function() build) async {
    if (!enabled) return;
    final bytes = _cache[key] ??= build();
    try {
      await _player.stop();
      await _player.play(BytesSource(bytes), volume: 0.7);
    } catch (_) {/* audio is a nicety; never let it crash the game */}
  }

  Future<void> correct() => _play('correct', () => _tone([_Seg(660, 90), _Seg(880, 130)]));
  Future<void> doubleCorrect() =>
      _play('double', () => _tone([_Seg(660, 80), _Seg(880, 80), _Seg(1175, 150)]));
  Future<void> tabu() => _play('tabu', () => _tone([_Seg(180, 260, square: true)]));
  Future<void> tick() => _play('tick', () => _tone([_Seg(1000, 40)], volume: 0.4));
  Future<void> win() => _play(
        'win',
        () => _tone([
          _Seg(523, 110),
          _Seg(659, 110),
          _Seg(784, 110),
          _Seg(1047, 240),
        ]),
      );

  void dispose() => _player.dispose();

  /// Builds a mono 44.1kHz 16-bit WAV from a sequence of tone segments with a
  /// short attack/decay envelope so notes don't click.
  static Uint8List _tone(List<_Seg> segs, {double volume = 1.0}) {
    const rate = 44100;
    final samples = <int>[];
    for (final s in segs) {
      final n = (rate * s.ms / 1000).round();
      for (var i = 0; i < n; i++) {
        final t = i / rate;
        final env = _envelope(i, n);
        double wave;
        if (s.square) {
          wave = sin(2 * pi * s.freq * t) >= 0 ? 1.0 : -1.0;
        } else {
          wave = sin(2 * pi * s.freq * t);
        }
        final v = (wave * env * volume * 0.9 * 32767).clamp(-32768, 32767).toInt();
        samples.add(v);
      }
    }
    return _wav(samples, rate);
  }

  static double _envelope(int i, int n) {
    const fade = 400; // samples
    if (i < fade) return i / fade;
    if (i > n - fade) return (n - i) / fade;
    return 1.0;
  }

  static Uint8List _wav(List<int> samples, int rate) {
    final dataBytes = samples.length * 2;
    final buffer = BytesBuilder();
    void str(String s) => buffer.add(s.codeUnits);
    void u32(int v) => buffer.add(Uint8List(4)..buffer.asByteData().setUint32(0, v, Endian.little));
    void u16(int v) => buffer.add(Uint8List(2)..buffer.asByteData().setUint16(0, v, Endian.little));

    str('RIFF');
    u32(36 + dataBytes);
    str('WAVE');
    str('fmt ');
    u32(16);
    u16(1); // PCM
    u16(1); // mono
    u32(rate);
    u32(rate * 2); // byte rate
    u16(2); // block align
    u16(16); // bits per sample
    str('data');
    u32(dataBytes);
    final data = Uint8List(dataBytes);
    final view = data.buffer.asByteData();
    for (var i = 0; i < samples.length; i++) {
      view.setInt16(i * 2, samples[i], Endian.little);
    }
    buffer.add(data);
    return buffer.toBytes();
  }
}

class _Seg {
  const _Seg(this.freq, this.ms, {this.square = false});
  final double freq;
  final int ms;
  final bool square;
}
