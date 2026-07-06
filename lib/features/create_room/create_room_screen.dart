import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/theme.dart';
import '../../data/models/game_settings.dart';
import '../../data/providers.dart';
import '../../widgets/app_background.dart';
import '../../widgets/buttons.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/option_picker.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  late final _name = TextEditingController(text: ref.read(playerNameProvider));
  var _settings = const GameSettings();
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      _snack('Önce bir takma ad gir.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(playerNameProvider.notifier).set(name);
      final uid = ref.read(currentUidProvider);
      final code = await ref
          .read(roomRepositoryProvider)
          .createRoom(uid: uid, name: name, settings: _settings);
      if (mounted) context.go('/room/$code');
    } catch (e) {
      if (mounted) _snack('Oda kurulamadı: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      appBar: AppBar(title: const Text('Oda Kur')),
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
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 18,
                      decoration: const InputDecoration(
                        hintText: 'Örneğin: Eren Baba',
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OptionPicker<int>(
                    label: 'Toplam round',
                    value: _settings.totalRounds,
                    options: GameSettings.roundOptions,
                    format: (v) => '$v',
                    onChanged: (v) =>
                        setState(() => _settings = _settings.copyWith(totalRounds: v)),
                  ),
                  const SizedBox(height: 18),
                  OptionPicker<int>(
                    label: 'Round süresi',
                    value: _settings.roundSeconds,
                    options: GameSettings.secondOptions,
                    format: (v) => '$v sn',
                    onChanged: (v) =>
                        setState(() => _settings = _settings.copyWith(roundSeconds: v)),
                  ),
                  const SizedBox(height: 18),
                  OptionPicker<int>(
                    label: 'Pas hakkı',
                    value: _settings.passRights,
                    options: GameSettings.passOptions,
                    format: (v) => '$v',
                    onChanged: (v) =>
                        setState(() => _settings = _settings.copyWith(passRights: v)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Odayı kurduktan sonra kodu arkadaşlarınla paylaş, '
                    'herkes takımını kendi seçsin.',
                    style: TextStyle(color: context.tokens.textDim, fontSize: 13.5, height: 1.4),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Oda Oluştur',
              icon: Icons.meeting_room_rounded,
              loading: _busy,
              onPressed: _busy ? null : _create,
            ),
          ],
        ),
      ),
    );
  }
}
