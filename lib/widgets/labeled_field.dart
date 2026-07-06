import 'package:flutter/material.dart';

import '../app/theme.dart';

/// A bold section label above an input or content block.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.texts.titleLarge?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
