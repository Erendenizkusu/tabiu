import 'package:shared_preferences/shared_preferences.dart';

/// Device-local memory of recently-seen card IDs.
///
/// Rooms otherwise start with an empty `usedCardIds`, so every fresh room is an
/// independent random sample of the whole bank — which makes the same words
/// recur across rooms as a family plays several quick games. Seeding a new room
/// with what this device has recently seen lets the next game skip those cards
/// and draw from the still-fresh part of the bank instead.
///
/// Purely local (SharedPreferences); the shared `cards` collection stays
/// read-only.
class SeenCardsStore {
  SeenCardsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'seenCardIds';

  /// Always keep at least this many cards of the bank out of the "seen" set, so
  /// a new room still has a large fresh pool and never has to reshuffle
  /// (repeat) mid-game. With a ~750-card bank this excludes at most ~450 recent
  /// cards while leaving ~300 fresh.
  static const _freshFloor = 300;

  /// Recently-seen card IDs, oldest first. Safe to hand straight to a new
  /// room's `usedCardIds`.
  List<String> ids() => _prefs.getStringList(_key) ?? const <String>[];

  /// Records [seen] as the most-recently used cards (moving repeats to the end
  /// so they refresh their recency) and trims the history from the front so at
  /// least [_freshFloor] cards of a [bankSize] bank stay unseen.
  Future<void> remember(Iterable<String> seen, {required int bankSize}) async {
    final cap = bankSize - _freshFloor;
    if (cap <= 0) return; // bank too small to bother excluding anything
    final list = _prefs.getStringList(_key) ?? <String>[];
    for (final id in seen) {
      if (id.isEmpty) continue;
      list.remove(id);
      list.add(id);
    }
    if (list.length > cap) {
      list.removeRange(0, list.length - cap);
    }
    await _prefs.setStringList(_key, list);
  }
}
