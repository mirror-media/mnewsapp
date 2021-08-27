import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InlineBannerAdWidget extends StatefulWidget {
  final String? adUnitId;
  final bool isKeepAlive;
  final bool isInArticle;
  InlineBannerAdWidget({
    required this.adUnitId,
    this.isKeepAlive = true,
    this.isInArticle = false,
  });
  @override
  _InlineBannerAdWidgetState createState() => _InlineBannerAdWidgetState();
}

class _InlineBannerAdWidgetState extends State<InlineBannerAdWidget> with AutomaticKeepAliveClientMixin{
  BannerAd? _inlineBanner;
  bool _loadingInlineBanner = false;

  @override
  bool get wantKeepAlive => widget.isKeepAlive;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _createInlineBanner(BuildContext context, String id) async {
    final BannerAd banner = BannerAd(
      size: AdSize.mediumRectangle,
      request: AdRequest(),
      adUnitId: id,
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
    super.build(context);
    double _horizontalPadding = 37.5;

    if(widget.isInArticle) {
      _horizontalPadding = 13.5;
    }

    if(!_loadingInlineBanner){
      _loadingInlineBanner = true;
      String? _adUnitId = widget.adUnitId;
      if(_adUnitId != null){
        _createInlineBanner(context,_adUnitId);
      }
      else{
        return Container(
          alignment: Alignment.center,
          width: 300,
          height: 250,
          margin: EdgeInsets.symmetric(vertical: 24, horizontal: _horizontalPadding),
        );
      }
    }

    if(_inlineBanner != null){
      return Container(
        alignment: Alignment.center,
        width: _inlineBanner!.size.width.toDouble(),
        height: _inlineBanner!.size.height.toDouble(),
        child: AdWidget(ad: _inlineBanner!),
        margin: EdgeInsets.symmetric(vertical: 24, horizontal: _horizontalPadding),
      );
    }

    return Container(
      alignment: Alignment.center,
      width: 300,
      height: 250,
      margin: EdgeInsets.symmetric(vertical: 24, horizontal: _horizontalPadding),
    );

  }

  @override
  void dispose(){
    super.dispose();
    _inlineBanner?.dispose();
  }
}