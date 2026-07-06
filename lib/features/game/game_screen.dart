import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../core/haptics.dart';
import '../../core/sfx.dart';
import '../../data/models/room_model.dart';
import '../../data/models/team.dart';
import '../../data/providers.dart';
import '../../data/repositories/room_repository.dart';
import '../../widgets/app_background.dart';
import '../../widgets/score_pop.dart';
import '../../widgets/tabiu_card.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.code, required this.room});
  final String code;
  final Room room;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Timer? _ticker;
  bool _ended = false;
  bool _cardsReady = false;
  final _shakeKey = GlobalKey<_ShakerState>();

  @override
  void initState() {
    super.initState();
    _ensureCards();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_maybeEndTurn);
    });
  }

  @override
  void didUpdateWidget(GameScreen old) {
    super.didUpdateWidget(old);
    // A fresh turn started — re-arm the end-of-turn trigger.
    if (old.room.turn?.endsAt != widget.room.turn?.endsAt) _ended = false;
  }

  Future<void> _ensureCards() async {
    await ref.read(cardRepositoryProvider).loadAll();
    if (mounted) setState(() => _cardsReady = true);
  }

  int get _remaining {
    final endsAt = widget.room.turn?.endsAt;
    if (endsAt == null) return 0;
    return endsAt.difference(DateTime.now()).inSeconds.clamp(0, 1 << 20);
  }

  void _maybeEndTurn() {
    final uid = ref.read(currentUidProvider);
    final isNarrator = widget.room.isNarrator(uid);
    final isHost = widget.room.hostId == uid;
    if (_remaining <= 0 && !_ended && (isNarrator || isHost)) {
      _ended = true;
      ref.read(roomRepositoryProvider).endTurn(widget.code);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _leave() async {
    await ref
        .read(roomRepositoryProvider)
        .leaveRoom(code: widget.code, uid: ref.read(currentUidProvider));
    if (mounted) context.go('/');
  }

  RoomRepository get _repo => ref.read(roomRepositoryProvider);

  void _correct() {
    Haptics.instance.success();
    Sfx.instance.correct();
    showScorePop(context, text: '+1', color: AppColors.green, icon: Icons.check_rounded);
    _repo.markCorrect(widget.code);
  }

  void _double() {
    Haptics.instance.success();
    Sfx.instance.doubleCorrect();
    showScorePop(context, text: '+2', color: const Color(0xFF1F9E5A), icon: Icons.bolt_rounded);
    _repo.markDoubleCorrect(widget.code);
  }

  void _tabu() {
    Haptics.instance.error();
    Sfx.instance.tabu();
    _shakeKey.currentState?.shake();
    showScorePop(context, text: 'TABU!', color: AppColors.red, icon: Icons.block_rounded);
    _repo.markTabu(widget.code);
  }

  void _pass() {
    Haptics.instance.light();
    _repo.passCard(widget.code);
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final turn = room.turn;
    final uid = ref.read(currentUidProvider);
    final isNarrator = room.isNarrator(uid);
    final playersAsync = ref.watch(playersStreamProvider(widget.code));
    final narrator = playersAsync.maybeWhen(
      data: (players) => players.where((p) => p.id == turn?.narratorId).firstOrNull,
      orElse: () => null,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: AppBackground(
        appBar: AppBar(
          title: Text('Round ${room.currentRound}/${room.settings.totalRounds}'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _leave,
          ),
        ),
        child: turn == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: AspectRatio(
                            aspectRatio: 0.70,
                            child: _Shaker(
                              key: _shakeKey,
                              child: isNarrator
                                  ? _narratorCard(turn)
                                  : HiddenCard(
                                      message: narrator == null
                                          ? 'Anlatıcı kartı görüyor'
                                          : 'Anlatıcı: ${narrator.name}',
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoPanel(remaining: _remaining, room: room),
                    const SizedBox(height: 14),
                    if (isNarrator)
                      _NarratorControls(
                        passesLeft: room.settings.passRights - turn.passesUsed,
                        onCorrect: _correct,
                        onDouble: _double,
                        onTabu: _tabu,
                        onPass: _pass,
                      )
                    else
                      _SpectatorFooter(teamLabel: room.turnTeam.label),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _narratorCard(TurnState turn) {
    if (!_cardsReady) {
      return const SizedBox(height: 320, child: Center(child: CircularProgressIndicator()));
    }
    final cards = ref.read(cardRepositoryProvider);
    final front = cards.byId(turn.frontCardId);
    final back = cards.byId(turn.backCardId);
    if (front == null || back == null) {
      return const HiddenCard(message: 'Kart yükleniyor…');
    }
    return TabiuCard(
      front: front,
      back: back,
      showingBack: turn.showingBack,
      onTap: () {
        Haptics.instance.selection();
        ref
            .read(roomRepositoryProvider)
            .flipCard(code: widget.code, showingBack: !turn.showingBack);
      },
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.remaining, required this.room});
  final int remaining;
  final Room room;

  @override
  Widget build(BuildContext context) {
    final urgent = remaining <= 10;
    final passesLeft = room.settings.passRights - (room.turn?.passesUsed ?? 0);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: context.tokens.surfaceHi.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.tokens.border),
      ),
      child: Column(
        children: [
          // Timer row.
          Row(
            children: [
              Icon(Icons.timer_rounded,
                  size: 22, color: urgent ? AppColors.red : context.tokens.gold),
              const SizedBox(width: 8),
              Text('Süre: ',
                  style: context.texts.titleLarge?.copyWith(
                      fontSize: 20,
                      color: urgent ? AppColors.red : context.scheme.onSurface)),
              Text('$remaining sn',
                  style: context.texts.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: urgent ? AppColors.red : context.scheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()])),
              const Spacer(),
              Text('${room.settings.roundSeconds} sn',
                  style: TextStyle(color: context.tokens.textDim, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          // Two score boxes.
          Row(
            children: [
              Expanded(child: _ScoreBox(team: Team.red, score: room.scoreRed)),
              const SizedBox(width: 12),
              Expanded(child: _ScoreBox(team: Team.blue, score: room.scoreBlue)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.videogame_asset_rounded, size: 18, color: room.turnTeam.color),
              const SizedBox(width: 6),
              Text('${room.turnTeam.label} takımı oynuyor',
                  style: TextStyle(color: room.turnTeam.color, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.swap_horiz_rounded, size: 16, color: context.tokens.textDim),
              const SizedBox(width: 6),
              Text('Pas hakkı: $passesLeft',
                  style: TextStyle(color: context.tokens.textDim, fontSize: 13.5)),
              const Spacer(),
              Text('Takımının skoru: ${room.scoreOf(room.turnTeam)}',
                  style: TextStyle(
                      color: context.scheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  const _ScoreBox({required this.team, required this.score});
  final Team team;
  final int score;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: team.tint(b),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: team.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(team.label,
              style: TextStyle(color: team.color, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 2),
          TweenAnimationBuilder<double>(
            tween: Tween(end: score.toDouble()),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            builder: (_, v, _) => Text(
              v.round().toString(),
              style: TextStyle(
                color: team.color,
                fontWeight: FontWeight.w800,
                fontSize: 32,
                height: 1.05,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NarratorControls extends StatelessWidget {
  const _NarratorControls({
    required this.passesLeft,
    required this.onCorrect,
    required this.onDouble,
    required this.onTabu,
    required this.onPass,
  });

  final int passesLeft;
  final VoidCallback onCorrect;
  final VoidCallback onDouble;
  final VoidCallback onTabu;
  final VoidCallback onPass;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _ActionButton(label: 'Doğru', color: AppColors.green, onTap: onCorrect)),
            const SizedBox(width: 10),
            Expanded(child: _ActionButton(label: '2x Doğru', color: const Color(0xFF1F9E5A), onTap: onDouble)),
            const SizedBox(width: 10),
            Expanded(child: _ActionButton(label: 'Tabu', color: AppColors.red, onTap: onTabu)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: passesLeft > 0 ? onPass : null,
            icon: const Icon(Icons.swap_horiz_rounded),
            label: Text('Pas ($passesLeft)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.tokens.gold,
              side: BorderSide(color: context.tokens.border, width: 1.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Kartı çevirmek için üzerine dokun',
            style: TextStyle(color: context.tokens.textDim, fontSize: 12.5)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpectatorFooter extends StatelessWidget {
  const _SpectatorFooter({required this.teamLabel});
  final String teamLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        'Sıra $teamLabel takımında. Tahmin etmeye çalış!',
        style: TextStyle(color: context.tokens.textDim, fontSize: 14),
      ),
    );
  }
}

/// Wraps a child so it can be shaken (used on Tabu).
class _Shaker extends StatefulWidget {
  const _Shaker({super.key, required this.child});
  final Widget child;
  @override
  State<_Shaker> createState() => _ShakerState();
}

class _ShakerState extends State<_Shaker> {
  Key _key = UniqueKey();
  bool _shaking = false;

  void shake() => setState(() {
        _key = UniqueKey();
        _shaking = true;
      });

  @override
  Widget build(BuildContext context) {
    if (!_shaking) return widget.child;
    return widget.child
        .animate(key: _key, onComplete: (_) => setState(() => _shaking = false))
        .shakeX(hz: 6, amount: 6, duration: 400.ms);
  }
}
