import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // ─── Singleton ───────────────────────────────────
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // ─── Ad Unit IDs ─────────────────────────────────
  // Using real IDs in release, test IDs in debug so
  // you never accidentally click your own live ads
  // (Google bans accounts for that).
  static String get bannerAdUnitId {
    if (kDebugMode) {
      // Google's official test banner ID — always use
      // this during development and testing
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return 'ca-app-pub-6304115589019119/5494027493';
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      // Google's official test interstitial ID
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    return 'ca-app-pub-6304115589019119/2560742392';
  }

  // ─── Interstitial Ad ─────────────────────────────
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;

  /// Call this once when the app starts (or after showing an ad)
  /// to pre-load the interstitial so it's ready instantly.
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          debugPrint('[AdService] Interstitial loaded');

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              // Pre-load the next one immediately
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint(
              '[AdService] Interstitial failed to load: $error');
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  /// Shows the interstitial ad if it's ready.
  /// Returns true if the ad was shown, false if not ready yet.
  bool showInterstitialAd() {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      return true;
    }
    debugPrint('[AdService] Interstitial not ready yet');
    return false;
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}