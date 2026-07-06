import 'package:cloud_firestore/cloud_firestore.dart';

import 'team.dart';

/// A player inside a room (`rooms/{code}/players/{uid}`).
class Player {
  const Player({
    required this.id,
    required this.name,
    required this.team,
    required this.isHost,
    required this.joinedAt,
  });

  final String id;
  final String name;
  final Team team;
  final bool isHost;
  final DateTime? joinedAt;

  /// First letter for the avatar chip.
  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  factory Player.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Player(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      team: Team.fromId(data['team']?.toString()),
      isHost: data['isHost'] == true,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'team': team.name,
        'isHost': isHost,
        'joinedAt': FieldValue.serverTimestamp(),
      };
}
