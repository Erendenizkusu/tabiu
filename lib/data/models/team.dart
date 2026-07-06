import 'package:flutter/material.dart';

import '../../app/palette.dart';

/// The two rival teams. Stored in Firestore as the lowercase name.
enum Team {
  red,
  blue;

  static Team fromId(String? id) =>
      Team.values.firstWhere((t) => t.name == id, orElse: () => Team.red);

  String get label => this == Team.red ? 'Kırmızı' : 'Mavi';

  Color get color => this == Team.red ? AppColors.red : AppColors.blue;

  Color tint(Brightness b) =>
      this == Team.red ? AppColors.redTint(b) : AppColors.blueTint(b);

  Team get other => this == Team.red ? Team.blue : Team.red;
}
