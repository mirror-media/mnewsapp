import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/helpers/adHelper.dart';

class AnchoredBannerAdWidget extends StatefulWidget {
  final bool isKeepAlive;
  AnchoredBannerAdWidget({this.isKeepAlive = true});
  @override
  _AnchoredBannerAdWidgetState createState() => _AnchoredBannerAdWidgetState();
}

class _AnchoredBannerAdWidgetState extends State<AnchoredBannerAdWidget> with AutomaticKeepAliveClientMixin{
  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  Future<void> _createAnchoredBanner(BuildContext context) async {
    final BannerAd banner = BannerAd(
      size: AdSize.banner,
      request: AdRequest(),
      adUnitId: AdHelper().stickyBannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    _loadingAnchoredBanner = true;
    return banner.load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }

    if(_anchoredBanner != null){
      return Container(
        alignment: Alignment.center,
        width: _anchoredBanner!.size.width.toDouble(),
        height: _anchoredBanner!.size.height.toDouble(),
        child: AdWidget(ad: _anchoredBanner!),
        margin: EdgeInsets.only(bottom: 18),
      );
    }
    else{
      return Container();
    }

  }

  @override
  void dispose(){
    super.dispose();
    _anchoredBanner?.dispose();
  }

  @override
  bool get wantKeepAlive => widget.isKeepAlive;
}