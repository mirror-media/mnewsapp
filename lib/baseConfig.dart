import 'package:tv/helpers/prodApiConstants.dart' as prod;
import 'package:tv/helpers/devApiConstants.dart' as dev;

enum BuildFlavor { production, development }

BaseConfig? baseConfig = _baseConfig;
BaseConfig? _baseConfig;

class BaseConfig {
  final BuildFlavor _flavor;
  BaseConfig(
    this._flavor
  );

  /// Sets up the top-level [baseConfig] getter on the first call only.
  static void init({required flavor}) => _baseConfig ??= BaseConfig(flavor);

  String get graphqlApi {
    switch(_flavor) {
      case BuildFlavor.production: 
        return prod.graphqlApi;
      case BuildFlavor.development:
        return dev.graphqlApi;
    }
  }

  String get searchApi {
    switch(_flavor) {
      case BuildFlavor.production: 
        return prod.searchApi;
      case BuildFlavor.development:
        return dev.searchApi;
    }
  }

  String get youtubeApi {
    switch(_flavor) {
      case BuildFlavor.production: 
        return prod.youtubeApi;
      case BuildFlavor.development:
        return dev.youtubeApi;
    }
  }

  String get mirrorNewsDefaultImageUrl {
    switch(_flavor) {
      case BuildFlavor.production: 
        return prod.mirrorNewsDefaultImageUrl;
      case BuildFlavor.development:
        return dev.mirrorNewsDefaultImageUrl;
    }
  }

  String get newsPopularListUrl {
    switch(_flavor) {
      case BuildFlavor.production: 
        return prod.newsPopularListUrl;
      case BuildFlavor.development:
        return dev.newsPopularListUrl;
    }
  }

  String get videoPopularListUrl {
    switch(_flavor) {
      case BuildFlavor.production: 
        return prod.videoPopularListUrl;
      case BuildFlavor.development:
        return dev.videoPopularListUrl;
    }
  }

  String get ombudsAppealUrl {
    switch(_flavor) {
      case BuildFlavor.production: 
        return prod.ombudsAppealUrl;
      case BuildFlavor.development:
        return dev.ombudsAppealUrl;
    }
  }

  String get ombudsvideoRecorderUrl {
    switch(_flavor) {
      case BuildFlavor.production: 
        return prod.ombudsvideoRecorderUrl;
      case BuildFlavor.development:
        return dev.ombudsvideoRecorderUrl;
    }
  }

  String get ombudsReportsUrl {
    switch(_flavor) {
      case BuildFlavor.production: 
        return prod.ombudsReportsUrl;
      case BuildFlavor.development:
        return dev.ombudsReportsUrl;
    }
  }

  String get privacyPolicyUrl {
    switch(_flavor) {
      case BuildFlavor.production: 
        return prod.privacyPolicyUrl;
      case BuildFlavor.development:
        return dev.privacyPolicyUrl;
    }
  }

  String get categoriesUrl {
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.categoriesUrl;
      case BuildFlavor.development:
        return dev.categoriesUrl;
    }
  }

  String get androidAdMobAppId {
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidAdMobAppId;
      case BuildFlavor.development:
        return dev.androidAdMobAppId;
    }
  }

  String get androidInterstitialAdUnitId {
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidInterstitialAdUnitId;
      case BuildFlavor.development:
        return dev.androidInterstitialAdUnitId;
    }
  }

  String get tvAndRos320x50ST{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndHome300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndHome300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndHome300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndPol300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndPol300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndPol300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndInt300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndInt300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndInt300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndFin300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndFin300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndFin300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndSoc300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndSoc300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndSoc300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndLif300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndLif300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndLif300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndEnt300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndEnt300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndEnt300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndUnc300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndUnc300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndUnc300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndStory300x250HD{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndStory300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndStory300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndStory300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndStory300x250E1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndStory300x250FT{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndLive300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndLive300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndLive300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndVdo300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndVdo300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndVdo300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndShow300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvAndShow300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get iOSAdMobAppId {
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.iOSAdMobAppId;
      case BuildFlavor.development:
        return dev.iOSAdMobAppId;
    }
  }

  String get iOSInterstitialAdUnitId {
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.iOSInterstitialAdUnitId;
      case BuildFlavor.development:
        return dev.iOSInterstitialAdUnitId;
    }
  }

  String get tvIosRos320x50ST{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosHome300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosHome300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosHome300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosPol300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosPol300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosPol300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosInt300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosInt300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosInt300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosFin300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosFin300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosFin300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosSoc300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosSoc300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosSoc300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosLif300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosLif300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosLif300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosEnt300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosEnt300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosEnt300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosUnc300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosUnc300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosUnc300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosStory300x250HD{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosStory300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosStory300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosStory300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosStory300x250E1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosStory300x250FT{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosLive300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosLive300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosLive300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosVdo300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosVdo300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosVdo300x250AT3{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosShow300x250AT1{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }

  String get tvIosShow300x250AT2{
    switch(_flavor) {
      case BuildFlavor.production:
        return prod.androidBannerAdUnitId;
      case BuildFlavor.development:
        return dev.androidBannerAdUnitId;
    }
  }
}