import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/haptics.dart';
import '../core/sfx.dart';

/// Overridden in `main()` with the loaded instance.
final prefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('prefsProvider must be overridden in main()');
});

const _kThemeKey = 'themeMode';
const _kSoundKey = 'soundEnabled';
const _kNameKey = 'playerName';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final raw = ref.read(prefsProvider).getString(_kThemeKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.dark,
    );
  }

  Future<void> toggle() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await ref.read(prefsProvider).setString(_kThemeKey, state.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class SoundEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final on = ref.read(prefsProvider).getBool(_kSoundKey) ?? true;
    Haptics.instance.enabled = on;
    Sfx.instance.enabled = on;
    return on;
  }

  Future<void> toggle() async {
    state = !state;
    Haptics.instance.enabled = state;
    Sfx.instance.enabled = state;
    await ref.read(prefsProvider).setBool(_kSoundKey, state);
  }
}

final soundEnabledProvider =
    NotifierProvider<SoundEnabledNotifier, bool>(SoundEnabledNotifier.new);

/// Remembers the last name the player used, prefilled into forms.
class PlayerNameNotifier extends Notifier<String> {
  @override
  String build() => ref.read(prefsProvider).getString(_kNameKey) ?? '';

  Future<void> set(String name) async {
    state = name.trim();
    await ref.read(prefsProvider).setString(_kNameKey, state);
  }
}

final playerNameProvider =
    NotifierProvider<PlayerNameNotifier, String>(PlayerNameNotifier.new);
