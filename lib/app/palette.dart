import 'package:flutter/material.dart';

/// Central color tokens — "Mor Parti" (purple premium party) identity.
///
/// Deep violet gradients, glowing atmosphere and glossy lavender cards, inspired
/// by the reference set. Red↔blue team rivalry still reads on the violet base.
class AppColors {
  const AppColors._();

  // Team colors — tuned to pop on violet, same across themes.
  static const Color red = Color(0xFFFF4D6D);
  static const Color blue = Color(0xFF4DA6FF);

  // Signature purple accents.
  static const Color violet = Color(0xFFB15CFF); // primary brand purple
  static const Color magenta = Color(0xFFFF5CC8); // pink pop (category pills)
  static const Color lavender = Color(0xFFE9DAFF); // bright CTA surface

  // Semantic accents.
  static const Color gold = Color(0xFFFFC24B); // winner / trophy
  static const Color green = Color(0xFF2BE39B); // correct (brighter for violet)
  static const Color danger = Color(0xFFFF4D6D); // tabu / warning (== red)

  // Glossy card face (lavender paper).
  static const Color cardPaper = Color(0xFFF4ECFF);
  static const Color cardInk = Color(0xFF2A1150);

  // Soft tints for team panels.
  static Color redTint(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF44173A) : const Color(0xFFFFDCE4);
  static Color blueTint(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF1B2C55) : const Color(0xFFD9ECFF);
}

/// Resolved surface colors that flip between light and dark.
class AppSurface {
  const AppSurface._();

  // Dark theme — deep violet party table.
  static const Color darkBg = Color(0xFF160A2E);
  static const Color darkBgTop = Color(0xFF3A1B6E); // top of the vertical gradient
  static const Color darkGlow = Color(0xFF6B2FB0); // radial glow blob
  static const Color darkSurface = Color(0xFF241247);
  static const Color darkSurfaceHi = Color(0xFF31195C);
  static const Color darkBorder = Color(0xFF432A70);
  static const Color darkText = Color(0xFFF3ECFF);
  static const Color darkTextDim = Color(0xFFA695CE);

  // Light theme — soft lavender paper.
  static const Color lightBg = Color(0xFFEDE6FB);
  static const Color lightBgTop = Color(0xFFF7F2FF);
  static const Color lightGlow = Color(0xFFCBB4F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceHi = Color(0xFFF3EDFF);
  static const Color lightBorder = Color(0xFFDCCFF3);
  static const Color lightText = Color(0xFF2A1150);
  static const Color lightTextDim = Color(0xFF7A6AA0);
}
