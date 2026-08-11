import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/palette.dart';
import 'app/router.dart';
import 'app/settings.dart';
import 'app/theme.dart';
import 'core/ads.dart';
import 'data/providers.dart';
import 'firebase_options.dart';
import 'widgets/app_background.dart';
import 'widgets/buttons.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BootApp());
  // Independent of the Firebase/auth bootstrap below — ads are a bonus, not
  // a blocker, so a slow or failed ad init must never hold up the game.
  unawaited(AdsService.instance.init());
}

class _BootResult {
  const _BootResult({required this.uid, required this.prefs});
  final String uid;
  final SharedPreferences prefs;
}

/// Boots Firebase + anonymous auth before mounting [TabiuApp]. A device with
/// no network on first launch (no cached session yet) would otherwise hang
/// forever on a blank splash — this surfaces a retry screen instead.
class _BootApp extends StatefulWidget {
  const _BootApp();

  @override
  State<_BootApp> createState() => _BootAppState();
}

class _BootAppState extends State<_BootApp> {
  late Future<_BootResult> _boot = _bootstrap();

  Future<_BootResult> _bootstrap() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Anonymous auth gives every player a stable id ("Oyuncu ID").
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    final uid = auth.currentUser!.uid;

    final prefs = await SharedPreferences.getInstance();
    return _BootResult(uid: uid, prefs: prefs);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootResult>(
      future: _boot,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            darkTheme: AppTheme.dark(),
            home: _BootErrorScreen(
              onRetry: () => setState(() => _boot = _bootstrap()),
            ),
          );
        }
        final result = snapshot.data;
        if (result == null) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            darkTheme: AppTheme.dark(),
            home: const Scaffold(
              backgroundColor: AppSurface.darkBg,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return ProviderScope(
          overrides: [
            currentUidProvider.overrideWithValue(result.uid),
            prefsProvider.overrideWithValue(result.prefs),
          ],
          child: const TabiuApp(),
        );
      },
    );
  }
}

class _BootErrorScreen extends StatelessWidget {
  const _BootErrorScreen({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56, color: context.tokens.textDim),
            const SizedBox(height: 18),
            Text(
              'Bağlantı kurulamadı',
              style: context.texts.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'İnternet bağlantını kontrol edip tekrar dene.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.tokens.textDim),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Tekrar Dene',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class TabiuApp extends ConsumerWidget {
  const TabiuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Tabiu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
