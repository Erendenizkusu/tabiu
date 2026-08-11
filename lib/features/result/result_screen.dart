import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../core/ads.dart';
import '../../core/haptics.dart';
import '../../core/sfx.dart';
import '../../data/models/team.dart';
import '../../data/models/room_model.dart';
import '../../data/providers.dart';
import '../../widgets/app_background.dart';
import '../../widgets/buttons.dart';
import '../../widgets/duel_score_bar.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.code, required this.room});
  final String code;
  final Room room;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late final _confetti = ConfettiController(duration: const Duration(seconds: 3));
  bool _isTie = false;

  @override
  void initState() {
    super.initState();
    _isTie = widget.room.winner == 'tie';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // One ad per finished game, right at this natural break — then the
      // celebration plays once it's dismissed (or immediately if none was
      // ready in time, so a slow ad load never holds up the result reveal).
      await AdsService.instance.showIfReady();
      if (!mounted) return;
      if (!_isTie) {
        _confetti.play();
        Haptics.instance.celebrate();
        Sfx.instance.win();
      }
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    await ref
        .read(roomRepositoryProvider)
        .leaveRoom(code: widget.code, uid: ref.read(currentUidProvider));
    if (mounted) context.go('/');
  }

  Future<void> _rematch(String uid) async {
    try {
      await ref.read(roomRepositoryProvider).rematch(code: widget.code, uid: uid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final uid = ref.read(currentUidProvider);
    final isHost = room.hostId == uid;
    final winner = _isTie ? null : Team.fromId(room.winner);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Stack(
        children: [
          AppBackground(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  const Spacer(),
                  Icon(
                    _isTie ? Icons.handshake_rounded : Icons.emoji_events_rounded,
                    size: 84,
                    color: winner?.color ?? context.tokens.gold,
                  ).animate().scale(
                        begin: const Offset(0.3, 0.3),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(height: 20),
                  Text(
                    _isTie ? 'Berabere!' : 'Kazanan',
                    style: TextStyle(color: context.tokens.textDim, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isTie ? '${room.scoreRed} - ${room.scoreBlue}' : '${winner!.label} Takımı',
                    style: context.texts.displayMedium?.copyWith(
                      color: winner?.color ?? context.tokens.textDim,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(delay: 200.ms).moveY(begin: 12, end: 0),
                  const SizedBox(height: 32),
                  DuelScoreBar(red: room.scoreRed, blue: room.scoreBlue, height: 84),
                  const Spacer(flex: 2),
                  if (isHost) ...[
                    PrimaryButton(
                      label: 'Rövanş',
                      icon: Icons.replay_rounded,
                      onPressed: () => _rematch(uid),
                    ),
                    const SizedBox(height: 12),
                    GhostButton(
                      label: 'Ana Menü',
                      icon: Icons.home_rounded,
                      onPressed: _leave,
                    ),
                  ] else ...[
                    Text('Oda sahibi rövanş başlatabilir.',
                        style: TextStyle(color: context.tokens.textDim)),
                    const SizedBox(height: 12),
                    GhostButton(
                      label: 'Ana Menü',
                      icon: Icons.home_rounded,
                      onPressed: _leave,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 24,
              maxBlastForce: 22,
              minBlastForce: 8,
              gravity: 0.25,
              colors: const [AppColors.red, AppColors.blue, AppColors.gold, AppColors.green],
            ),
          ),
        ],
      ),
    );
  }
}
