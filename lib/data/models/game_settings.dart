/// Room configuration chosen on the "Oda Kur" screen.
class GameSettings {
  const GameSettings({
    this.totalRounds = 10,
    this.roundSeconds = 60,
    this.passRights = 3,
  });

  final int totalRounds;
  final int roundSeconds;
  final int passRights;

  static const roundOptions = [4, 6, 8, 10, 12, 16];
  static const secondOptions = [30, 45, 60, 90, 120];
  static const passOptions = [0, 1, 2, 3, 5];

  GameSettings copyWith({int? totalRounds, int? roundSeconds, int? passRights}) =>
      GameSettings(
        totalRounds: totalRounds ?? this.totalRounds,
        roundSeconds: roundSeconds ?? this.roundSeconds,
        passRights: passRights ?? this.passRights,
      );

  Map<String, dynamic> toMap() => {
        'totalRounds': totalRounds,
        'roundSeconds': roundSeconds,
        'passRights': passRights,
      };

  factory GameSettings.fromMap(Map<String, dynamic>? m) {
    m ??= const {};
    return GameSettings(
      totalRounds: (m['totalRounds'] as num?)?.toInt() ?? 10,
      roundSeconds: (m['roundSeconds'] as num?)?.toInt() ?? 60,
      passRights: (m['passRights'] as num?)?.toInt() ?? 3,
    );
  }
}
