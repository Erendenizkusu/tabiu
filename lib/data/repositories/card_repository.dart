import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/card_model.dart';

/// A drawn front/back pair for one hand.
class CardPair {
  const CardPair(this.front, this.back);
  final TabooCard front;
  final TabooCard back;
}

/// Reads the `cards` word bank and hands out fresh front/back pairs.
///
/// The full bank is loaded once and cached in memory; drawing then happens
/// locally so it can honor `usedCardIds` (which grows over a room's life,
/// rematches included) and keep serving different words.
class CardRepository {
  CardRepository(this._db);

  final FirebaseFirestore _db;
  final _rng = Random();

  List<TabooCard>? _cache;
  Map<String, TabooCard> _byId = const {};

  Future<List<TabooCard>> loadAll() async {
    if (_cache != null) return _cache!;
    final snap = await _db.collection('cards').get();
    final cards = snap.docs
        .map(TabooCard.fromDoc)
        .where((c) => c.main.trim().isNotEmpty)
        .toList();
    _cache = cards;
    _byId = {for (final c in cards) c.id: c};
    return cards;
  }

  TabooCard? byId(String id) => _byId[id];

  bool get isLoaded => _cache != null;

  /// Picks two distinct cards not in [used]. Falls back to the whole bank when
  /// fewer than two unused cards remain (deck reshuffle).
  CardPair drawPair(Set<String> used) {
    final all = _cache ?? const <TabooCard>[];
    if (all.length < 2) {
      throw StateError('Kart bankasında en az 2 kart olmalı.');
    }
    var pool = all.where((c) => !used.contains(c.id)).toList();
    if (pool.length < 2) pool = List.of(all);
    pool.shuffle(_rng);
    return CardPair(pool[0], pool[1]);
  }
}
