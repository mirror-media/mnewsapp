import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InlineBannerAdWidget extends StatefulWidget {
  final String adUnitId;
  InlineBannerAdWidget({ required this.adUnitId});
  @override
  _InlineBannerAdWidgetState createState() => _InlineBannerAdWidgetState();
}

class _InlineBannerAdWidgetState extends State<InlineBannerAdWidget>{
  BannerAd? _inlineBanner;
  bool _loadingInlineBanner = false;
  late String _currentAdUnitId;

  @override
  void initState() {
    super.initState();
    _currentAdUnitId = widget.adUnitId;
    _createInlineBanner(context);
  }

  Future<void> _createInlineBanner(BuildContext context) async {
    final BannerAd banner = BannerAd(
      size: AdSize.mediumRectangle,
      request: AdRequest(),
      adUnitId: _currentAdUnitId,
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