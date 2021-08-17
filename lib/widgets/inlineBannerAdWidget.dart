import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/helpers/adHelper.dart';

class InlineBannerAdWidget extends StatefulWidget {
  @override
  _InlineBannerAdWidgetState createState() => _InlineBannerAdWidgetState();
}

class _InlineBannerAdWidgetState extends State<InlineBannerAdWidget>{
  BannerAd? _inlineBanner;
  bool _loadingInlineBanner = false;

  @override
  void initState() {
    super.initState();
    _createInlineBanner(context);
  }

  Future<void> _createInlineBanner(BuildContext context) async {
    final BannerAd banner = BannerAd(
      size: AdSize.mediumRectangle,
      request: AdRequest(),
      adUnitId: adHelper!.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('InlineBannerAd loaded.');
          setState(() {
            _inlineBanner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('InlineBannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('InlineBannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('InlineBannerAd onAdClosed.'),
      ),
    );
    _loadingInlineBanner = true;
    return banner.load();
  }

  @override
  Widget build(BuildContext context) {
    if(!_loadingInlineBanner){
      _loadingInlineBanner = true;
      _createInlineBanner(context);
    }

    if(_inlineBanner != null){
      return Container(
        alignment: Alignment.center,
        width: _inlineBanner!.size.width.toDouble(),
        height: _inlineBanner!.size.height.toDouble(),
        child: AdWidget(ad: _inlineBanner!),
        margin: EdgeInsets.symmetric(vertical: 24, horizontal: 37),
      );
    }
    else{
      return Container();
    }

  }

  @override
  void dispose(){
    super.dispose();
    if(_inlineBanner != null)
      _inlineBanner!.dispose();
  }
}