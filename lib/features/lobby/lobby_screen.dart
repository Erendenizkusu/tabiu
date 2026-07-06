import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models/game_settings.dart';
import '../../data/models/player_model.dart';
import '../../data/models/room_model.dart';
import '../../data/models/team.dart';
import '../../data/providers.dart';
import '../../widgets/app_background.dart';
import '../../widgets/buttons.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key, required this.code, required this.room});

  final String code;
  final Room room;

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(currentUidProvider);
    await ref.read(roomRepositoryProvider).leaveRoom(code: code, uid: uid);
    if (context.mounted) context.go('/');
  }

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(roomRepositoryProvider).startGame(
            code: code,
            uid: ref.read(currentUidProvider),
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.read(currentUidProvider);
    final isHost = room.hostId == uid;
    final playersAsync = ref.watch(playersStreamProvider(code));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave(context, ref);
      },
      child: AppBackground(
        appBar: AppBar(
          title: const Text('Bekleme Alanı'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => _leave(context, ref),
          ),
        ),
        child: playersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (players) {
            final me = players.where((p) => p.id == uid).firstOrNull;
            final red = players.where((p) => p.team == Team.red).toList();
            final blue = players.where((p) => p.team == Team.blue).toList();
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CodeCard(code: code, settings: room.settings),
                  const SizedBox(height: 18),
                  Text('Takımını seç',
                      style: context.texts.titleLarge?.copyWith(fontSize: 18)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _TeamColumn(
                            team: Team.red,
                            members: red,
                            meId: uid,
                            selected: me?.team == Team.red,
                            onTap: () => ref.read(roomRepositoryProvider).setTeam(
                                code: code, uid: uid, team: Team.red),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TeamColumn(
                            team: Team.blue,
                            members: blue,
                            meId: uid,
                            selected: me?.team == Team.blue,
                            onTap: () => ref.read(roomRepositoryProvider).setTeam(
                                code: code, uid: uid, team: Team.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isHost)
                    PrimaryButton(
                      label: 'Oyunu Başlat',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => _start(context, ref),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      alignment: Alignment.center,
                      child: Text(
                        'Oda sahibinin başlatması bekleniyor…',
                        style: TextStyle(color: context.tokens.textDim),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code, required this.settings});
  final String code;
  final GameSettings settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: context.tokens.surfaceHi,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.tokens.border),
      ),
      child: Column(
        children: [
          Text('ODA KODU',
              style: TextStyle(
                letterSpacing: 3,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: context.tokens.textDim,
              )),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                code,
                style: context.texts.displaySmall?.copyWith(
                  fontSize: 44,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(Icons.copy_rounded, color: context.tokens.gold),
                tooltip: 'Kodu kopyala',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Oda kodu kopyalandı')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Toplam: ${settings.totalRounds} round  ·  Süre: ${settings.roundSeconds} sn  ·  Pas: ${settings.passRights}',
            style: TextStyle(color: context.tokens.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({
    required this.team,
    required this.members,
    required this.meId,
    required this.selected,
    required this.onTap,
  });

  final Team team;
  final List<Player> members;
  final String meId;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: selected ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: team.color.withValues(alpha: selected ? 0.20 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? team.color : context.tokens.border,
            width: selected ? 2.4 : 1.4,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(color: team.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(team.label,
                    style: TextStyle(
                      color: team.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: members
                    .map((p) => _MemberTile(player: p, isMe: p.id == meId, team: team))
                    .toList(),
              ),
            ),
            if (!selected)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Katılmak için dokun',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.tokens.textDim, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.player, required this.isMe, required this.team});
  final Player player;
  final bool isMe;
  final Team team;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: team.color,
            child: Text(player.initial,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isMe ? '${player.name} (Sen)' : player.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (player.isHost)
            Icon(Icons.star_rounded, size: 16, color: context.tokens.gold),
        ],
      ),
    );
  }
}
