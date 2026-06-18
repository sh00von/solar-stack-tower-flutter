import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Handles interstitial (every 2 game-overs) and rewarded (revive) ads.
/// Uses AdMob test IDs in debug builds; swap constants for real IDs before release.
class AdManager {
  // Replace these with your real AdMob unit IDs before publishing.
  static const _interstitialId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // test
      : 'ca-app-pub-5775416244755872/1346949255';

  static const _rewardedId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // test
      : 'ca-app-pub-5775416244755872/2829515337';

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  int _gameOverCount = 0;
  static const _interstitialEvery = 2;

  bool get isRewardedReady => _rewarded != null;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) {
              _interstitial = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              _interstitial = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (_) => _loadInterstitial(),
      ),
    );
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) {
              _rewarded = null;
              _loadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              _rewarded = null;
              _loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (_) => _loadRewarded(),
      ),
    );
  }

  /// Call on every game over. Shows interstitial every 2nd game over.
  Future<void> onGameOver() async {
    _gameOverCount++;
    if (_gameOverCount % _interstitialEvery == 0 && _interstitial != null) {
      await _interstitial!.show();
    }
  }

  /// Show rewarded ad. Calls [onRewarded] if user earns the reward.
  Future<void> showRewarded({required VoidCallback onRewarded}) async {
    if (_rewarded == null) {
      onRewarded(); // fallback: grant reward if no ad loaded
      return;
    }
    await _rewarded!.show(
      onUserEarnedReward: (ad, reward) => onRewarded(),
    );
  }

  void dispose() {
    _interstitial?.dispose();
    _rewarded?.dispose();
  }
}
