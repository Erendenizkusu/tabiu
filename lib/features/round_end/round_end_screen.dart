import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/models/room_model.dart';
import '../../data/models/team.dart';
import '../../data/providers.dart';
import '../../widgets/app_background.dart';
import '../../widgets/buttons.dart';
import '../../widgets/duel_score_bar.dart';

class RoundEndScreen extends ConsumerWidget {
  const RoundEndScreen({super.key, required this.code, required this.room});
  final String code;
  final Room room;

  Future<void> _next(BuildContext context, WidgetRef ref, String uid) async {
    try {
      await ref.read(roomRepositoryProvider).nextRound(code: code, uid: uid);
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
    final isLast = room.currentRound >= room.settings.totalRounds;
    final nextTeam = (room.currentRound + 1).isOdd ? Team.red : Team.blue;
    final leader = room.scoreRed == room.scoreBlue
        ? null
        : (room.scoreRed > room.scoreBlue ? Team.red : Team.blue);

    return AppBackground(
      appBar: AppBar(title: Text('Round ${room.currentRound} bitti')),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            const Spacer(),
            Text('Round Bitti', style: context.texts.displaySmall)
                .animate()
                .fadeIn()
                .scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 4),
            Text('Round ${room.currentRound} / ${room.settings.totalRounds}',
                style: TextStyle(color: context.tokens.textDim, fontSize: 15)),
            const SizedBox(height: 28),
            Text(
              leader == null
                  ? 'Skor eşit: ${room.scoreRed} - ${room.scoreBlue}'
                  : '${leader.label} önde: ${room.scoreOf(leader)} - ${room.scoreOf(leader.other)}',
              style: TextStyle(
                color: leader?.color ?? context.tokens.textDim,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 14),
            DuelScoreBar(red: room.scoreRed, blue: room.scoreBlue, height: 80),
            const SizedBox(height: 24),
            if (!isLast)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: nextTeam.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Sıradaki takım: ${nextTeam.label}',
                    style: TextStyle(color: nextTeam.color, fontWeight: FontWeight.w700)),
              ),
            const Spacer(flex: 2),
            if (isHost)
              PrimaryButton(
                label: isLast ? 'Sonuçları Gör' : 'Devam Et (Round ${room.currentRound + 1})',
                icon: isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
                onPressed: () => _next(context, ref, uid),
              )
            else
              Text('Oda sahibinin devam etmesi bekleniyor…',
                  style: TextStyle(color: context.tokens.textDim)),
          ],
        ),
      ),
    );
  }
}
