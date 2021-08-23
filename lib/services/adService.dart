import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/helpers/adHelper.dart';

class AdService {

  AdService();

  Future<List<BannerAd>> createInlineBanner(String section, {String? slug}) async {
    List<BannerAd> _bannerAdList = [];
    switch (section){
      case 'news':
        BannerAd bannerAT1;
        BannerAd bannerAT2;
        BannerAd bannerAT3;
        switch (slug){
          case 'ent':
          case 'entertainment':
            bannerAT1 = await _createBannerAd(adHelper!.entAT1AdUnitId);
            bannerAT2 = await _createBannerAd(adHelper!.entAT2AdUnitId);
            bannerAT3 = await _createBannerAd(adHelper!.entAT3AdUnitId);
            break;
          case 'unc':
            bannerAT1 = await _createBannerAd(adHelper!.uncAT1AdUnitId);
            bannerAT2 = await _createBannerAd(adHelper!.uncAT2AdUnitId);
            bannerAT3 = await _createBannerAd(adHelper!.uncAT3AdUnitId);
            break;
          case 'lif':
          case 'life':
            bannerAT1 = await _createBannerAd(adHelper!.lifAT1AdUnitId);
            bannerAT2 = await _createBannerAd(adHelper!.lifAT2AdUnitId);
            bannerAT3 = await _createBannerAd(adHelper!.lifAT3AdUnitId);
            break;
          case 'soc':
          case 'society':
            bannerAT1 = await _createBannerAd(adHelper!.socAT1AdUnitId);
            bannerAT2 = await _createBannerAd(adHelper!.socAT2AdUnitId);
            bannerAT3 = await _createBannerAd(adHelper!.socAT3AdUnitId);
            break;
          case 'fin':
          case 'financial':
          case 'finance':
            bannerAT1 = await _createBannerAd(adHelper!.finAT1AdUnitId);
            bannerAT2 = await _createBannerAd(adHelper!.finAT2AdUnitId);
            bannerAT3 = await _createBannerAd(adHelper!.finAT3AdUnitId);
            break;
          case 'int':
          case 'international':
            bannerAT1 = await _createBannerAd(adHelper!.intAT1AdUnitId);
            bannerAT2 = await _createBannerAd(adHelper!.intAT2AdUnitId);
            bannerAT3 = await _createBannerAd(adHelper!.intAT3AdUnitId);
            break;
          case 'pol':
          case 'politic':
            bannerAT1 = await _createBannerAd(adHelper!.polAT1AdUnitId);
            bannerAT2 = await _createBannerAd(adHelper!.polAT2AdUnitId);
            bannerAT3 = await _createBannerAd(adHelper!.polAT3AdUnitId);
            break;
          default:
            bannerAT1 = await _createBannerAd(adHelper!.homeAT1AdUnitId);
            bannerAT2 = await _createBannerAd(adHelper!.homeAT2AdUnitId);
            bannerAT3 = await _createBannerAd(adHelper!.homeAT3AdUnitId);
        }
        bannerAT1.load();
        bannerAT2.load();
        bannerAT3.load();
        _bannerAdList.add(bannerAT1);
        _bannerAdList.add(bannerAT2);
        _bannerAdList.add(bannerAT3);
        break;
      case 'live':
        BannerAd bannerAT1 = await _createBannerAd(adHelper!.liveAT1AdUnitId);
        BannerAd bannerAT2 = await _createBannerAd(adHelper!.liveAT2AdUnitId);
        BannerAd bannerAT3 = await _createBannerAd(adHelper!.liveAT3AdUnitId);
        bannerAT1.load();
        bannerAT2.load();
        bannerAT3.load();
        _bannerAdList.add(bannerAT1);
        _bannerAdList.add(bannerAT2);
        _bannerAdList.add(bannerAT3);
        break;
      case 'video':
        BannerAd bannerAT1 = await _createBannerAd(adHelper!.vdoAT1AdUnitId);
        BannerAd bannerAT2 = await _createBannerAd(adHelper!.vdoAT2AdUnitId);
        BannerAd bannerAT3 = await _createBannerAd(adHelper!.vdoAT3AdUnitId);
        bannerAT1.load();
        bannerAT2.load();
        bannerAT3.load();
        _bannerAdList.add(bannerAT1);
        _bannerAdList.add(bannerAT2);
        _bannerAdList.add(bannerAT3);
        break;
      case 'show1':
        BannerAd bannerAT1 = await _createBannerAd(adHelper!.showAT1AdUnitId);
        bannerAT1.load();
        _bannerAdList.add(bannerAT1);
        break;
      case 'show2':
        BannerAd bannerAT2 = await _createBannerAd(adHelper!.showAT2AdUnitId);
        bannerAT2.load();
        _bannerAdList.add(bannerAT2);
        break;
      case 'story':
        BannerAd bannerAT1 = await _createBannerAd(adHelper!.storyAT1AdUnitId);
        BannerAd bannerAT2 = await _createBannerAd(adHelper!.storyAT2AdUnitId);
        BannerAd bannerAT3 = await _createBannerAd(adHelper!.storyAT3AdUnitId);
        BannerAd bannerHD = await _createBannerAd(adHelper!.storyHDAdUnitId);
        BannerAd bannerE1 = await _createBannerAd(adHelper!.storyE1AdUnitId);
        BannerAd bannerFT = await _createBannerAd(adHelper!.storyFTAdUnitId);
        bannerAT1.load();
        bannerAT2.load();
        bannerAT3.load();
        bannerHD.load();
        bannerE1.load();
        bannerFT.load();
        _bannerAdList.add(bannerHD);
        _bannerAdList.add(bannerAT1);
        _bannerAdList.add(bannerAT2);
        _bannerAdList.add(bannerAT3);
        _bannerAdList.add(bannerE1);
        _bannerAdList.add(bannerFT);
        break;
    }
    return _bannerAdList;
  }

  Future<BannerAd> _createBannerAd(String adUnitId) async{
    final BannerAd banner = BannerAd(
      size: AdSize.mediumRectangle,
      request: AdRequest(),
      adUnitId: adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('InlineBannerAd loaded.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('InlineBannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('InlineBannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('InlineBannerAd onAdClosed.'),
      ),
    );
    return banner;
  }
}