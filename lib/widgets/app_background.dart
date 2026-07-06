import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'ambient_background.dart';

/// Full-screen gradient scaffold used across the app. Keeps the warm
/// "card table" backdrop consistent everywhere.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.appBar,
    this.safeArea = true,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final body = DecoratedBox(
      decoration: BoxDecoration(gradient: context.tokens.bgGradient),
      child: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground()),
          const Positioned.fill(child: GrainOverlay()),
          Positioned.fill(child: safeArea ? SafeArea(child: child) : child),
        ],
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: body,
    );
  }
}
