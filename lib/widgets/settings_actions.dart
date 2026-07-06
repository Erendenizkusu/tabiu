import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/settings.dart';

/// Theme + sound toggles for app bars.
class SettingsActions extends ConsumerWidget {
  const SettingsActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final sound = ref.watch(soundEnabledProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: sound ? 'Sesi kapat' : 'Sesi aç',
          icon: Icon(sound ? Icons.volume_up_rounded : Icons.volume_off_rounded),
          onPressed: () => ref.read(soundEnabledProvider.notifier).toggle(),
        ),
        IconButton(
          tooltip: isDark ? 'Aydınlık tema' : 'Karanlık tema',
          icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
        ),
      ],
    );
  }
}
