import 'package:flutter/material.dart';

import '../app/palette.dart';
import '../app/theme.dart';
import '../core/haptics.dart';

/// Primary filled call-to-action (gold). The signature button of the app.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.lavender;
    final enabled = onPressed != null && !loading;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: c.withValues(alpha: 0.45),
                    blurRadius: 26,
                    spreadRadius: -2,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: SizedBox(
      height: 62,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(c, Colors.white, 0.35)!, c],
            ),
          ),
          child: InkWell(
          onTap: enabled
              ? () {
                  Haptics.instance.light();
                  onPressed!();
                }
              : null,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Color(0xFF241F2E),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: const Color(0xFF241F2E), size: 22),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF241F2E),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
          ),
        ),
      ),
      ),
      ),
    );
  }
}

/// Secondary outlined button.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.lavender;
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed == null
            ? null
            : () {
                Haptics.instance.light();
                onPressed!();
              },
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20, color: c),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: c,
          side: BorderSide(color: context.tokens.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
