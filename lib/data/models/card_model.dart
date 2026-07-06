import 'package:cloud_firestore/cloud_firestore.dart';

/// A single Taboo card from the `cards` collection.
///
/// Firestore shape: `{ id, main: "TERMOMETRE", forbidden: [...], category: "B" }`.
/// The `category` letters currently carry no meaning (reserved for a future
/// categorization feature) so nothing in the UI filters on them.
class TabooCard {
  const TabooCard({
    required this.id,
    required this.main,
    required this.forbidden,
    this.category,
  });

  final String id;
  final String main;
  final List<String> forbidden;
  final String? category;

  factory TabooCard.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return TabooCard(
      id: doc.id,
      main: (data['main'] ?? '').toString(),
      forbidden: (data['forbidden'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [],
      category: data['category']?.toString(),
    );
  }
}
