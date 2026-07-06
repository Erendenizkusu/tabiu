import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models/room_model.dart';
import '../../data/providers.dart';
import '../../widgets/app_background.dart';
import '../../widgets/buttons.dart';
import '../game/game_screen.dart';
import '../lobby/lobby_screen.dart';
import '../result/result_screen.dart';
import '../round_end/round_end_screen.dart';

/// Watches the live room and renders the right screen for its status. Because
/// the room stream drives everything, status changes (e.g. host starts the
/// game) move every player forward automatically.
class RoomShell extends ConsumerWidget {
  const RoomShell({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomStreamProvider(code));

    return roomAsync.when(
      loading: () => const _Message(
        icon: Icons.hourglass_bottom_rounded,
        title: 'Odaya bağlanılıyor…',
        showSpinner: true,
      ),
      error: (e, _) => _Message(
        icon: Icons.wifi_off_rounded,
        title: 'Bağlantı hatası',
        subtitle: '$e',
        showHome: true,
      ),
      data: (room) {
        if (room == null) {
          return const _Message(
            icon: Icons.door_front_door_rounded,
            title: 'Oda kapandı',
            subtitle: 'Oda sahibi odayı kapattı ya da süresi doldu.',
            showHome: true,
          );
        }
        return switch (room.status) {
          RoomStatus.lobby => LobbyScreen(code: code, room: room),
          RoomStatus.playing => GameScreen(code: code, room: room),
          RoomStatus.roundEnd => RoundEndScreen(code: code, room: room),
          RoomStatus.finished => ResultScreen(code: code, room: room),
        };
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.subtitle,
    this.showHome = false,
    this.showSpinner = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool showHome;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: context.tokens.textDim),
            const SizedBox(height: 18),
            Text(title, style: context.texts.headlineSmall, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.tokens.textDim)),
            ],
            if (showSpinner) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
            if (showHome) ...[
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Ana Menü',
                icon: Icons.home_rounded,
                onPressed: () => context.go('/'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
