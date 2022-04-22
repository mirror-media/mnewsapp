import 'package:get/get.dart';
import 'package:tv/configs/baseConfig.dart';
import 'package:tv/helpers/environment.dart';

class AdUnitIdHelper {
  static String getBannerAdUnitId(String position) {
    if (Environment().config.flavor == Flavor.dev) {
      return '/6499/example/banner';
    }

    if (GetPlatform.isAndroid) {
      return '/22699107359/' + _getAndroidBannerAdUnitId(position);
    } else {
      return '/22699107359/' + _getIosBannerAdUnitId(position);
    }
  }

  static String _getAndroidBannerAdUnitId(String position) {
    switch (position) {
      case 'NewsAT1':
        return 'mnews_app_news_top_list_Android';
      case 'NewsAT2':
        return 'mnews_app_news_middle_list_Android';
      case 'NewsAT3':
        return 'mnews_app_news_end_list_Android';
      case 'VideoAT1':
        return 'mnews_app_live_top_Android';
      case 'VideoAT2':
        return 'mnews_app_live_middle_Android';
      case 'VideoAT3':
        return 'mnews_app_live_end_Android';
      case 'AnchorHD':
        return 'mnews_app_anchor_top_Android';
      case 'AnchorAT1':
        return 'mnews_app_anchor_middle_Android';
      case 'AnchorAT2':
        return 'mnews_app_anchor_end_Android';
      case 'StoryHD':
        return 'mnews_app_article_top_Android';
      case 'StoryAT1':
        return 'mnews_app_article_middle_Android';
      case 'StoryAT2':
        return 'mnews_app_article_end_Android';
      case 'TopicHD':
        return 'mnews_app_topic_top_Android';
      case 'TopicAT1':
        return 'mnews_app_topic_middle_Android';
      case 'TopicAT2':
        return 'mnews_app_topic_end_Android';
      case 'ShowAT1':
        return 'mnews_app_global_top_Android';
      case 'ShowAT2':
        return 'mnews_app_global_middle_Android';
      case 'ShowAT3':
        return 'mnews_app_global_end_Android';
      default:
        return 'mnews_app_news_top_list_Android';
    }
  }

  static String _getIosBannerAdUnitId(String position) {
    switch (position) {
      case 'NewsAT1':
        return 'mnews_app_news_top_list_ios';
      case 'NewsAT2':
        return 'mnews_app_news_middle_list_ios';
      case 'NewsAT3':
        return 'mnews_app_news_end_list_ios';
      case 'VideoAT1':
        return 'mnews_app_live_top_ios';
      case 'VideoAT2':
        return 'mnews_app_live_middle_ios';
      case 'VideoAT3':
        return 'mnews_app_live_end_ios';
      case 'AnchorHD':
        return 'mnews_app_anchor_top__ios';
      case 'AnchorAT1':
        return 'mnews_app_anchor_middle_ios';
      case 'AnchorAT2':
        return 'mnews_app_anchor_end_ios';
      case 'StoryHD':
        return 'mnews_app_article_top_ios';
      case 'StoryAT1':
        return 'mnews_app_article_middle_ios';
      case 'StoryAT2':
        return 'mnews_app_article_end_ios';
      case 'TopicHD':
        return 'mnews_app_topic_top_ios';
      case 'TopicAT1':
        return 'mnews_app_topic_middle_ios';
      case 'TopicAT2':
        return 'mnews_app_topic_end_ios';
      case 'ShowAT1':
        return 'mnews_app_global_top_ios';
      case 'ShowAT2':
        return 'mnews_app_global_middle_ios';
      case 'ShowAT3':
        return 'mnews_app_global_end_ios';
      default:
        return 'mnews_app_news_top_list_ios';
    }
  }

  static String getInterstitialAdUnitId(String position) {
    if (Environment().config.flavor == Flavor.dev) {
      return '/6499/example/interstitial';
    }

    if (GetPlatform.isAndroid) {
      return '/22699107359/' + _getAndroidInterstitialAdUnitId(position);
    } else {
      return '/22699107359/' + _getIosInterstitialAdUnitId(position);
    }
  }

  static String _getAndroidInterstitialAdUnitId(String position) {
    switch (position) {
      case 'Home':
        return '';
      case 'Story':
        return '';
      default:
        return '';
    }
  }

  static String _getIosInterstitialAdUnitId(String position) {
    switch (position) {
      case 'Home':
        return '';
      case 'Story':
        return '';
      default:
        return '';
    }
  }
}
