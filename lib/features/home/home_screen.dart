import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../widgets/app_background.dart';
import '../../widgets/buttons.dart';
import '../../widgets/settings_actions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      appBar: AppBar(actions: const [SettingsActions(), SizedBox(width: 6)]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 3),
            const _Wordmark(),
            const SizedBox(height: 14),
            Text(
              'Yasaklı kelimelere değmeden anlat,\ntakımını kazandır.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: context.tokens.textDim,
              ),
            ),
            const Spacer(flex: 3),
            PrimaryButton(
              label: 'Oda Kur',
              icon: Icons.add_rounded,
              onPressed: () => context.push('/create'),
            ).animate().fadeIn(delay: 150.ms).moveY(begin: 16, end: 0),
            const SizedBox(height: 14),
            GhostButton(
              label: 'Odaya Katıl',
              icon: Icons.login_rounded,
              onPressed: () => context.push('/join'),
            ).animate().fadeIn(delay: 260.ms).moveY(begin: 16, end: 0),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final mark = Stack(
      alignment: Alignment.center,
      children: [
        // Glow halo behind the letters.
        Text(
          'Tabiu',
          style: GoogleFonts.fredoka(
            fontSize: 84,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            foreground: Paint()
              ..color = AppColors.violet.withValues(alpha: 0.55)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
          ),
        ),
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), AppColors.lavender, AppColors.magenta],
          ).createShader(rect),
          child: Text(
            'Tabiu',
            style: GoogleFonts.fredoka(
              fontSize: 84,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
      ],
    );
    return mark
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1, end: 1.03, duration: 2400.ms, curve: Curves.easeInOut);
  }
}
