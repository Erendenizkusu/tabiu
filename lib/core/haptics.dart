import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Thin wrapper around haptics. Falls back to [HapticFeedback] where a custom
/// vibration pattern isn't available (e.g. web), and can be globally muted.
class Haptics {
  Haptics._();
  static final Haptics instance = Haptics._();

  bool enabled = true;
  bool? _hasVibrator;

  Future<bool> get _canVibrate async =>
      _hasVibrator ??= await Vibration.hasVibrator();

  Future<void> light() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> selection() async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> success() async {
    if (!enabled) return;
    if (await _canVibrate) {
      await Vibration.vibrate(pattern: const [0, 22, 60, 22], intensities: const [0, 160, 0, 220]);
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  Future<void> error() async {
    if (!enabled) return;
    if (await _canVibrate) {
      await Vibration.vibrate(pattern: const [0, 120, 40, 120]);
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  Future<void> celebrate() async {
    if (!enabled) return;
    if (await _canVibrate) {
      await Vibration.vibrate(pattern: const [0, 60, 40, 60, 40, 180]);
    } else {
      await HapticFeedback.heavyImpact();
    }
  }
}
