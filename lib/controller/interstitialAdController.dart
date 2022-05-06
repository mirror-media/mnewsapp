import 'dart:math';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';

class InterstitialAdController {
  var storyCounter = 0.obs;

  void openStory() async {
    storyCounter++;
    if (storyCounter.isOdd) {
      await showInterstitialAd(AdUnitIdHelper.getInterstitialAdUnitId('Story'));
    }
  }

  Future<void> ramdomShowInterstitialAd() async {
    final randomNumberGenerator = Random();
    final randomBoolean = randomNumberGenerator.nextBool();
    if (randomBoolean) {
      await showInterstitialAd(
          AdUnitIdHelper.getInterstitialAdUnitId('Others'));
    }
  }

  Future<void> showInterstitialAd(String adUnitId) async {
    await AdManagerInterstitialAd.load(
      adUnitId: adUnitId,
      request: AdManagerAdRequest(),
      adLoadCallback: AdManagerInterstitialAdLoadCallback(
        onAdLoaded: (AdManagerInterstitialAd interstitialAd) async {
          // Keep a reference to the ad so you can show it later.
          print('InterstitialAd loaded.');

          interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (AdManagerInterstitialAd ad) =>
                print('$ad onAdShowedFullScreenContent.'),
            onAdDismissedFullScreenContent: (AdManagerInterstitialAd ad) {
              print('$ad onAdDismissedFullScreenContent.');
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent:
                (AdManagerInterstitialAd ad, AdError error) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
            },
            onAdImpression: (AdManagerInterstitialAd ad) =>
                print('$ad impression occurred.'),
          );
          await interstitialAd.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }
}
