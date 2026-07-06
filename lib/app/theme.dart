import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'palette.dart';

/// Extra design tokens not covered by [ColorScheme], surfaced through
/// `Theme.of(context).extension<TabiuTokens>()`.
@immutable
class TabiuTokens extends ThemeExtension<TabiuTokens> {
  const TabiuTokens({
    required this.bgTop,
    required this.bgBottom,
    required this.surfaceHi,
    required this.border,
    required this.textDim,
    required this.gold,
    required this.green,
  });

  final Color bgTop;
  final Color bgBottom;
  final Color surfaceHi;
  final Color border;
  final Color textDim;
  final Color gold;
  final Color green;

  /// Background gradient for full-screen scaffolds.
  LinearGradient get bgGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgTop, bgBottom],
      );

  @override
  TabiuTokens copyWith({
    Color? bgTop,
    Color? bgBottom,
    Color? surfaceHi,
    Color? border,
    Color? textDim,
    Color? gold,
    Color? green,
  }) =>
      TabiuTokens(
        bgTop: bgTop ?? this.bgTop,
        bgBottom: bgBottom ?? this.bgBottom,
        surfaceHi: surfaceHi ?? this.surfaceHi,
        border: border ?? this.border,
        textDim: textDim ?? this.textDim,
        gold: gold ?? this.gold,
        green: green ?? this.green,
      );

  @override
  TabiuTokens lerp(TabiuTokens? other, double t) {
    if (other == null) return this;
    return TabiuTokens(
      bgTop: Color.lerp(bgTop, other.bgTop, t)!,
      bgBottom: Color.lerp(bgBottom, other.bgBottom, t)!,
      surfaceHi: Color.lerp(surfaceHi, other.surfaceHi, t)!,
      border: Color.lerp(border, other.border, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      green: Color.lerp(green, other.green, t)!,
    );
  }
}

/// Builds the light and dark [ThemeData] for Tabiu.
class AppTheme {
  const AppTheme._();

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg = isDark ? AppSurface.darkBg : AppSurface.lightBg;
    final surface = isDark ? AppSurface.darkSurface : AppSurface.lightSurface;
    final text = isDark ? AppSurface.darkText : AppSurface.lightText;
    final textDim = isDark ? AppSurface.darkTextDim : AppSurface.lightTextDim;
    final border = isDark ? AppSurface.darkBorder : AppSurface.lightBorder;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.gold,
      onPrimary: const Color(0xFF241F2E),
      secondary: AppColors.blue,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
    );

    // Body / UI typeface: Plus Jakarta Sans. Applied as the base text theme;
    // display/headline get the Fredoka personality below.
    final baseText = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: text, displayColor: text);

    final textTheme = baseText.copyWith(
      displayLarge: GoogleFonts.fredoka(
        textStyle: baseText.displayLarge,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      displayMedium: GoogleFonts.fredoka(
        textStyle: baseText.displayMedium,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      displaySmall: GoogleFonts.fredoka(
        textStyle: baseText.displaySmall,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      headlineMedium: GoogleFonts.fredoka(
        textStyle: baseText.headlineMedium,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      headlineSmall: GoogleFonts.fredoka(
        textStyle: baseText.headlineSmall,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      titleLarge: GoogleFonts.fredoka(
        textStyle: baseText.titleLarge,
        fontWeight: FontWeight.w600,
        color: text,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: text,
        titleTextStyle: GoogleFonts.fredoka(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
      dividerColor: border,
      splashFactory: InkRipple.splashFactory,
      extensions: [
        TabiuTokens(
          bgTop: isDark ? AppSurface.darkBgTop : AppSurface.lightBgTop,
          bgBottom: bg,
          surfaceHi: isDark ? AppSurface.darkSurfaceHi : AppSurface.lightSurfaceHi,
          border: border,
          textDim: textDim,
          gold: AppColors.gold,
          green: AppColors.green,
        ),
      ],
    );
  }
}

/// Convenience accessor for [TabiuTokens].
extension TabiuThemeX on BuildContext {
  TabiuTokens get tokens => Theme.of(this).extension<TabiuTokens>()!;
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
}
