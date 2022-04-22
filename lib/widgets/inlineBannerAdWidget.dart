import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InlineBannerAdWidget extends StatefulWidget {
  final String adUnitId;
  final List<AdSize> sizes;
  InlineBannerAdWidget({
    required this.adUnitId,
    required this.sizes,
    Key? key,
  }) : super(key: key);
  @override
  _InlineBannerAdWidgetState createState() => _InlineBannerAdWidgetState();
}

class _InlineBannerAdWidgetState extends State<InlineBannerAdWidget>
    with AutomaticKeepAliveClientMixin {
  AdManagerBannerAd? _inlineAdaptiveAd;
  bool _isLoaded = false;
  AdSize? _adSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    await _inlineAdaptiveAd?.dispose();
    setState(() {
      _inlineAdaptiveAd = null;
      _isLoaded = false;
    });

    _inlineAdaptiveAd = AdManagerBannerAd(
      adUnitId: widget.adUnitId,
      sizes: widget.sizes,
      request: AdManagerAdRequest(),
      listener: AdManagerBannerAdListener(
        onAdLoaded: (Ad ad) async {
          print('Inline adaptive banner loaded');

          // After the ad is loaded, get the platform ad size and use it to
          // update the height of the container. This is necessary because the
          // height can change after the ad is loaded.
          AdManagerBannerAd bannerAd = (ad as AdManagerBannerAd);
          final AdSize? size = await bannerAd.getPlatformAdSize();
          if (size == null) {
            print('Error: getPlatformAdSize() returned null for $bannerAd');
            return;
          }

          setState(() {
            _inlineAdaptiveAd = bannerAd;
            _isLoaded = true;
            _adSize = size;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Inline adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    await _inlineAdaptiveAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoaded) {
      double horizontalMargin =
          (MediaQuery.of(context).size.width - _adSize!.width.toDouble()) / 2;
      return Container(
        alignment: Alignment.center,
        width: _adSize!.width.toDouble(),
        height: _adSize!.height.toDouble(),
        child: AdWidget(ad: _inlineAdaptiveAd!),
        margin: EdgeInsets.symmetric(
          vertical: 24,
          horizontal: horizontalMargin,
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      width: 300,
      height: 250,
      margin: EdgeInsets.symmetric(
        vertical: 24,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _inlineAdaptiveAd?.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
