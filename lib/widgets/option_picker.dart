import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../core/haptics.dart';

/// A labeled row of selectable chips — replaces the old cramped dropdowns for
/// round count, duration and pass rights.
class OptionPicker<T> extends StatelessWidget {
  const OptionPicker({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> options;
  final String Function(T) format;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.texts.titleLarge?.copyWith(fontSize: 19)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((o) {
            final selected = o == value;
            return GestureDetector(
              onTap: () {
                if (!selected) {
                  Haptics.instance.selection();
                  onChanged(o);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? context.tokens.gold : context.tokens.surfaceHi,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? context.tokens.gold : context.tokens.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  format(o),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? const Color(0xFF241F2E)
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
