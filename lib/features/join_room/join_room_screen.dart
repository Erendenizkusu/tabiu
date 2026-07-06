import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../data/providers.dart';
import '../../widgets/app_background.dart';
import '../../widgets/buttons.dart';
import '../../widgets/labeled_field.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  late final _name = TextEditingController(text: ref.read(playerNameProvider));
  final _code = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final name = _name.text.trim();
    final code = _code.text.trim().toUpperCase();
    if (name.isEmpty) return _snack('Önce bir takma ad gir.');
    if (code.length < 4) return _snack('4 haneli oda kodunu gir.');
    setState(() => _busy = true);
    try {
      await ref.read(playerNameProvider.notifier).set(name);
      final uid = ref.read(currentUidProvider);
      await ref
          .read(roomRepositoryProvider)
          .joinRoom(code: code, uid: uid, name: name);
      if (mounted) context.go('/room/$code');
    } catch (e) {
      if (mounted) _snack('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      appBar: AppBar(title: const Text('Odaya Katıl')),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  LabeledField(
                    label: 'Takma adın',
                    child: TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 18,
                      decoration: const InputDecoration(
                        hintText: 'Örneğin: Eren Baba',
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  LabeledField(
                    label: 'Oda kodu',
                    child: TextField(
                      controller: _code,
                      textAlign: TextAlign.center,
                      maxLength: 4,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                        _UpperCaseFormatter(),
                      ],
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 16,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'M5D7',
                        counterText: '',
                      ),
                      onSubmitted: (_) => _join(),
                    ),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Katıl',
              icon: Icons.login_rounded,
              loading: _busy,
              onPressed: _busy ? null : _join,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue _, TextEditingValue next) {
    return next.copyWith(text: next.text.toUpperCase());
  }
}
