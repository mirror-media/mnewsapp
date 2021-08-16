import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/helpers/adHelper.dart';

class AnchoredBannerAdWidget extends StatefulWidget {
  @override
  _AnchoredBannerAdWidgetState createState() => _AnchoredBannerAdWidgetState();
}

class _AnchoredBannerAdWidgetState extends State<AnchoredBannerAdWidget>{
  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;
  late Future _loadAd;

  @override
  void initState() {
    super.initState();
    _loadAd = _createAnchoredBanner(context);
  }

  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: AdRequest(),
      adUnitId: adHelper!.bannerAdUnitId,
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
    return banner.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return FutureBuilder(
      future: _loadAd,
      builder: (context, AsyncSnapshot snapshot){

      },
    );
    if(_anchoredBanner != null){
      return Container(
        width: _anchoredBanner!.size.width.toDouble(),
        height: _anchoredBanner!.size.height.toDouble(),
        child: AdWidget(ad: _anchoredBanner!),
      );
    }
    else{
      return Container();
    }
  }

  @override
  void dispose(){
    super.dispose();
    _anchoredBanner!.dispose();
  }
}