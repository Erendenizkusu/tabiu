import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game_settings.dart';
import '../models/player_model.dart';
import '../models/room_model.dart';
import '../models/team.dart';
import 'card_repository.dart';

/// User-facing error with a Turkish message.
class RoomException implements Exception {
  RoomException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Rooms live ~6h after last activity; a Firestore TTL policy on `expireAt`
/// reaps anything the client-side cleanup misses.
const _kRoomTtl = Duration(hours: 6);
const _kCodeChars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; // no I,L,O,0,1

/// Creates, joins, streams and drives game rooms. This is the game engine:
/// scoring, card draws, round advancement and cleanup all live here.
class RoomRepository {
  RoomRepository(this._db, this._cards);

  final FirebaseFirestore _db;
  final CardRepository _cards;
  final _rng = Random();

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');

  Timestamp get _expireAt =>
      Timestamp.fromDate(DateTime.now().add(_kRoomTtl));

  // ---- Streams -------------------------------------------------------------

  Stream<Room?> watchRoom(String code) => _rooms
      .doc(code)
      .snapshots()
      .map((d) => d.exists ? Room.fromDoc(d) : null);

  Stream<List<Player>> watchPlayers(String code) => _rooms
      .doc(code)
      .collection('players')
      .orderBy('joinedAt')
      .snapshots()
      .map((s) => s.docs.map(Player.fromDoc).toList());

  // ---- Lobby ---------------------------------------------------------------

  Future<String> createRoom({
    required String uid,
    required String name,
    required GameSettings settings,
  }) async {
    unawaited(_cleanupExpired());
    final code = await _uniqueCode();
    final ref = _rooms.doc(code);
    await ref.set({
      'hostId': uid,
      'status': RoomStatus.lobby.name,
      'settings': settings.toMap(),
      'currentRound': 1,
      'turnTeam': Team.red.name,
      'scores': {'red': 0, 'blue': 0},
      'winner': null,
      'usedCardIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'expireAt': _expireAt,
    });
    await ref.collection('players').doc(uid).set(
          Player(id: uid, name: name, team: Team.red, isHost: true, joinedAt: null)
              .toMap(),
        );
    return code;
  }

  Future<void> joinRoom({
    required String code,
    required String uid,
    required String name,
  }) async {
    final ref = _rooms.doc(code);
    final snap = await ref.get();
    if (!snap.exists) throw RoomException('Bu kodla bir oda bulamadık.');
    final room = Room.fromDoc(snap);
    if (room.status != RoomStatus.lobby) {
      throw RoomException('Bu oda çoktan oyuna başlamış.');
    }
    // Default to the smaller team; the player can switch in the lobby.
    final players =
        (await ref.collection('players').get()).docs.map(Player.fromDoc);
    final red = players.where((p) => p.team == Team.red).length;
    final blue = players.where((p) => p.team == Team.blue).length;
    final team = red <= blue ? Team.red : Team.blue;
    await ref.collection('players').doc(uid).set(
          Player(id: uid, name: name, team: team, isHost: false, joinedAt: null)
              .toMap(),
        );
    await _touch(ref);
  }

  Future<void> setTeam({
    required String code,
    required String uid,
    required Team team,
  }) async {
    await _rooms.doc(code).collection('players').doc(uid).update({
      'team': team.name,
    });
    await _touch(_rooms.doc(code));
  }

  // ---- Game flow -----------------------------------------------------------

  Future<void> startGame({required String code, required String uid}) async {
    final ref = _rooms.doc(code);
    final room = Room.fromDoc(await ref.get());
    if (room.hostId != uid) {
      throw RoomException('Oyunu yalnızca oda sahibi başlatabilir.');
    }
    final players =
        (await ref.collection('players').get()).docs.map(Player.fromDoc).toList();
    final hasRed = players.any((p) => p.team == Team.red);
    final hasBlue = players.any((p) => p.team == Team.blue);
    if (!hasRed || !hasBlue) {
      throw RoomException('Her iki takımda da en az bir oyuncu olmalı.');
    }
    await _cards.loadAll();
    await _beginTurn(ref, settings: room.settings, round: 1, players: players,
        used: room.usedCardIds);
  }

  /// Narrator flips the physical card between its front and back word.
  Future<void> flipCard({required String code, required bool showingBack}) =>
      _rooms.doc(code).update({
        'turnState.showingBack': showingBack,
        'expireAt': _expireAt,
      });

  Future<void> markCorrect(String code) => _applyScore(code, 1);
  Future<void> markDoubleCorrect(String code) => _applyScore(code, 2);
  Future<void> markTabu(String code) => _applyScore(code, -1);

  Future<void> passCard(String code) async {
    await _cards.loadAll();
    final ref = _rooms.doc(code);
    await _db.runTransaction((tx) async {
      final room = Room.fromDoc(await tx.get(ref));
      final turn = room.turn;
      if (room.status != RoomStatus.playing || turn == null) return;
      if (turn.passesUsed >= room.settings.passRights) return;
      final (pair, used) = _nextPair(room);
      tx.update(ref, {
        'usedCardIds': used,
        'turnState.passesUsed': turn.passesUsed + 1,
        'turnState.pair': pair,
        'turnState.showingBack': false,
        'expireAt': _expireAt,
      });
    });
  }

  /// Called when the round timer reaches zero.
  Future<void> endTurn(String code) async {
    final ref = _rooms.doc(code);
    await _db.runTransaction((tx) async {
      final room = Room.fromDoc(await tx.get(ref));
      if (room.status != RoomStatus.playing) return;
      tx.update(ref, {
        'status': RoomStatus.roundEnd.name,
        'expireAt': _expireAt,
      });
    });
  }

  Future<void> nextRound({required String code, required String uid}) async {
    final ref = _rooms.doc(code);
    final room = Room.fromDoc(await ref.get());
    if (room.hostId != uid) return;
    final next = room.currentRound + 1;
    if (next > room.settings.totalRounds) {
      await ref.update({
        'status': RoomStatus.finished.name,
        'winner': _winner(room.scoreRed, room.scoreBlue),
        'expireAt': _expireAt,
      });
      return;
    }
    await _cards.loadAll();
    final players =
        (await ref.collection('players').get()).docs.map(Player.fromDoc).toList();
    await _beginTurn(ref, settings: room.settings, round: next, players: players,
        used: room.usedCardIds);
  }

  /// Reset scores and return to the lobby, keeping [Room.usedCardIds] so the
  /// next game serves different words.
  Future<void> rematch({required String code, required String uid}) async {
    final ref = _rooms.doc(code);
    final room = Room.fromDoc(await ref.get());
    if (room.hostId != uid) return;
    await ref.update({
      'status': RoomStatus.lobby.name,
      'currentRound': 1,
      'turnTeam': Team.red.name,
      'scores': {'red': 0, 'blue': 0},
      'winner': null,
      'turnState': FieldValue.delete(),
      'expireAt': _expireAt,
    });
  }

  Future<void> leaveRoom({required String code, required String uid}) async {
    final ref = _rooms.doc(code);
    final snap = await ref.get();
    if (!snap.exists) return;
    if (Room.fromDoc(snap).hostId == uid) {
      await _deleteRoom(ref);
    } else {
      await ref.collection('players').doc(uid).delete();
      await _touch(ref);
    }
  }

  // ---- Internals -----------------------------------------------------------

  Future<void> _beginTurn(
    DocumentReference<Map<String, dynamic>> ref, {
    required GameSettings settings,
    required int round,
    required List<Player> players,
    required List<String> used,
  }) async {
    final team = round.isOdd ? Team.red : Team.blue;
    final teamPlayers = players.where((p) => p.team == team).toList()
      ..sort((a, b) => (a.joinedAt ?? DateTime(2000))
          .compareTo(b.joinedAt ?? DateTime(2000)));
    final roster = teamPlayers.isEmpty ? players : teamPlayers;
    // Rotate the narrator across the team's turns ((round-1)~/2 counts prior
    // turns for each side when red starts on round 1).
    final narrator = roster[((round - 1) ~/ 2) % roster.length];

    final pool = used.toSet();
    final pair = _cards.drawPair(pool);
    final newUsed = [...used, pair.front.id, pair.back.id];
    final endsAt =
        Timestamp.fromDate(DateTime.now().add(Duration(seconds: settings.roundSeconds)));

    await ref.update({
      'status': RoomStatus.playing.name,
      'currentRound': round,
      'turnTeam': team.name,
      'usedCardIds': newUsed,
      'turnState': {
        'narratorId': narrator.id,
        'endsAt': endsAt,
        'passesUsed': 0,
        'roundScore': 0,
        'pair': {'frontCardId': pair.front.id, 'backCardId': pair.back.id},
        'showingBack': false,
      },
      'expireAt': _expireAt,
    });
  }

  Future<void> _applyScore(String code, int delta) async {
    await _cards.loadAll();
    final ref = _rooms.doc(code);
    await _db.runTransaction((tx) async {
      final room = Room.fromDoc(await tx.get(ref));
      final turn = room.turn;
      if (room.status != RoomStatus.playing || turn == null) return;
      final (pair, used) = _nextPair(room);
      final team = room.turnTeam;
      final scores = {'red': room.scoreRed, 'blue': room.scoreBlue};
      scores[team.name] = (scores[team.name]! + delta).clamp(0, 1 << 30);
      tx.update(ref, {
        'scores': scores,
        'usedCardIds': used,
        'turnState.roundScore': turn.roundScore + delta,
        'turnState.pair': pair,
        'turnState.showingBack': false,
        'expireAt': _expireAt,
      });
    });
  }

  /// Draws the next pair and returns (pairMap, grownUsedList).
  (Map<String, String>, List<String>) _nextPair(Room room) {
    final used = List<String>.from(room.usedCardIds);
    final pair = _cards.drawPair(used.toSet());
    used.addAll([pair.front.id, pair.back.id]);
    return (
      {'frontCardId': pair.front.id, 'backCardId': pair.back.id},
      used,
    );
  }

  String _winner(int red, int blue) =>
      red == blue ? 'tie' : (red > blue ? 'red' : 'blue');

  Future<void> _touch(DocumentReference<Map<String, dynamic>> ref) async {
    try {
      await ref.update({'expireAt': _expireAt});
    } catch (_) {/* room may be gone */}
  }

  Future<void> _deleteRoom(DocumentReference<Map<String, dynamic>> ref) async {
    final players = await ref.collection('players').get();
    final batch = _db.batch();
    for (final p in players.docs) {
      batch.delete(p.reference);
    }
    batch.delete(ref);
    await batch.commit();
  }

  Future<void> _cleanupExpired() async {
    try {
      final stale = await _rooms
          .where('expireAt', isLessThan: Timestamp.now())
          .limit(5)
          .get();
      for (final d in stale.docs) {
        await _deleteRoom(d.reference);
      }
    } catch (_) {/* best effort; needs the composite index-free single field */}
  }

  Future<String> _uniqueCode() async {
    for (var attempt = 0; attempt < 12; attempt++) {
      final code = List.generate(
        4,
        (_) => _kCodeChars[_rng.nextInt(_kCodeChars.length)],
      ).join();
      final exists = (await _rooms.doc(code).get()).exists;
      if (!exists) return code;
    }
    throw RoomException('Oda kodu oluşturulamadı, tekrar dener misin?');
  }
}
