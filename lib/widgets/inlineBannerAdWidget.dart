import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InlineBannerAdWidget extends StatelessWidget{

  late final BannerAd bannerAd;
  InlineBannerAdWidget({required this.bannerAd});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(
          key: UniqueKey(),
          ad: bannerAd),
      margin: EdgeInsets.symmetric(vertical: 24, horizontal: 37),
    );
  }
}