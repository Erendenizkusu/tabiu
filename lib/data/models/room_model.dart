import 'package:cloud_firestore/cloud_firestore.dart';

import 'game_settings.dart';
import 'team.dart';

enum RoomStatus {
  lobby,
  playing,
  roundEnd,
  finished;

  static RoomStatus fromId(String? id) => RoomStatus.values
      .firstWhere((s) => s.name == id, orElse: () => RoomStatus.lobby);
}

/// The active turn's live state. Present while [RoomStatus.playing].
class TurnState {
  const TurnState({
    required this.narratorId,
    required this.endsAt,
    required this.passesUsed,
    required this.roundScore,
    required this.frontCardId,
    required this.backCardId,
    required this.showingBack,
  });

  final String narratorId;
  final DateTime? endsAt;
  final int passesUsed;
  final int roundScore;
  final String frontCardId;
  final String backCardId;
  final bool showingBack;

  /// The card id currently facing the narrator.
  String get visibleCardId => showingBack ? backCardId : frontCardId;

  factory TurnState.fromMap(Map<String, dynamic> m) {
    final pair = (m['pair'] as Map?)?.cast<String, dynamic>() ?? const {};
    return TurnState(
      narratorId: (m['narratorId'] ?? '').toString(),
      endsAt: (m['endsAt'] as Timestamp?)?.toDate(),
      passesUsed: (m['passesUsed'] as num?)?.toInt() ?? 0,
      roundScore: (m['roundScore'] as num?)?.toInt() ?? 0,
      frontCardId: (pair['frontCardId'] ?? '').toString(),
      backCardId: (pair['backCardId'] ?? '').toString(),
      showingBack: m['showingBack'] == true,
    );
  }
}

/// A full game room document (`rooms/{code}`).
class Room {
  const Room({
    required this.code,
    required this.hostId,
    required this.status,
    required this.settings,
    required this.currentRound,
    required this.turnTeam,
    required this.scoreRed,
    required this.scoreBlue,
    required this.turn,
    required this.winner,
    required this.usedCardIds,
  });

  final String code;
  final String hostId;
  final RoomStatus status;
  final GameSettings settings;
  final int currentRound;
  final Team turnTeam;
  final int scoreRed;
  final int scoreBlue;
  final TurnState? turn;

  /// "red" | "blue" | "tie" | null (only set when finished).
  final String? winner;

  /// Every card id already shown in this room; grows across rounds and
  /// rematches so the same group keeps seeing fresh words.
  final List<String> usedCardIds;

  int scoreOf(Team t) => t == Team.red ? scoreRed : scoreBlue;

  bool isNarrator(String uid) => turn?.narratorId == uid;

  factory Room.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final scores = (data['scores'] as Map?)?.cast<String, dynamic>() ?? const {};
    final turnMap = (data['turnState'] as Map?)?.cast<String, dynamic>();
    return Room(
      code: doc.id,
      hostId: (data['hostId'] ?? '').toString(),
      status: RoomStatus.fromId(data['status']?.toString()),
      settings: GameSettings.fromMap(
          (data['settings'] as Map?)?.cast<String, dynamic>()),
      currentRound: (data['currentRound'] as num?)?.toInt() ?? 1,
      turnTeam: Team.fromId(data['turnTeam']?.toString()),
      scoreRed: (scores['red'] as num?)?.toInt() ?? 0,
      scoreBlue: (scores['blue'] as num?)?.toInt() ?? 0,
      turn: turnMap == null ? null : TurnState.fromMap(turnMap),
      winner: data['winner']?.toString(),
      usedCardIds: (data['usedCardIds'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [],
    );
  }
}
