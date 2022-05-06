import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AnchoredBannerAdWidget extends StatefulWidget {
  final String adUnitId;
  AnchoredBannerAdWidget({required this.adUnitId});
  @override
  _AnchoredBannerAdWidgetState createState() => _AnchoredBannerAdWidgetState();
}

class _AnchoredBannerAdWidgetState extends State<AnchoredBannerAdWidget> {
  AdManagerBannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;
  bool _loadFailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = AdManagerBannerAd(
      adUnitId: widget.adUnitId,
      sizes: [size],
      request: AdManagerAdRequest(),
      listener: AdManagerBannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded.');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as AdManagerBannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
          setState(() {
            _loadFailed = true;
          });
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_anchoredAdaptiveAd != null && _isLoaded) {
      return SafeArea(
        child: Container(
          alignment: Alignment.center,
          width: _anchoredAdaptiveAd!.sizes.first.width.toDouble(),
          height: _anchoredAdaptiveAd!.sizes.first.height.toDouble(),
          child: AdWidget(ad: _anchoredAdaptiveAd!),
        ),
      );
    }

    if (_loadFailed) {
      return Container();
    }

    return SafeArea(
      child: Container(
        color: Colors.white,
        width: 320,
        height: 50,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }
}
