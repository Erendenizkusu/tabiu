import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Interstitial ads at the one natural break point in the game loop: the
/// Result screen, once per finished game. Never between rounds, never in
/// the lobby — so the revenue never comes at the cost of gameplay flow.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static const _androidInterstitialId = 'ca-app-pub-2707472203466324/1190714154';
  static const _iosInterstitialId = 'ca-app-pub-2707472203466324/8630934489';

  static String get _interstitialUnitId =>
      Platform.isIOS ? _iosInterstitialId : _androidInterstitialId;

  InterstitialAd? _ad;
  bool _loading = false;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _load();
  }

  void _load() {
    if (_loading || _ad != null) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _ad = ad;
        },
        onAdFailedToLoad: (_) {
          _loading = false;
        },
      ),
    );
  }

  /// Shows the preloaded interstitial if one is ready and waits for it to
  /// be dismissed, then preloads the next one. If nothing is ready yet,
  /// this is a no-op — gameplay never blocks waiting on an ad.
  Future<void> showIfReady() async {
    final ad = _ad;
    if (ad == null) {
      _load();
      return;
    }
    _ad = null;
    final done = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _load();
        if (!done.isCompleted) done.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _load();
        if (!done.isCompleted) done.complete();
      },
    );
    await ad.show();
    await done.future;
  }
}
