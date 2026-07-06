import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/player_model.dart';
import 'models/room_model.dart';
import 'repositories/card_repository.dart';
import 'repositories/room_repository.dart';

/// The anonymous user id. Overridden in `main()` after sign-in.
final currentUidProvider = Provider<String>((ref) {
  throw UnimplementedError('currentUidProvider must be overridden in main()');
});

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final cardRepositoryProvider =
    Provider<CardRepository>((ref) => CardRepository(ref.watch(firestoreProvider)));

final roomRepositoryProvider = Provider<RoomRepository>((ref) => RoomRepository(
      ref.watch(firestoreProvider),
      ref.watch(cardRepositoryProvider),
    ));

/// Live room document. `null` payload means the room was deleted.
final roomStreamProvider =
    StreamProvider.autoDispose.family<Room?, String>((ref, code) {
  return ref.watch(roomRepositoryProvider).watchRoom(code);
});

/// Live players list for a room.
final playersStreamProvider =
    StreamProvider.autoDispose.family<List<Player>, String>((ref, code) {
  return ref.watch(roomRepositoryProvider).watchPlayers(code);
});
