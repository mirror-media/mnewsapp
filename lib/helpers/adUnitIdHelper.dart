import 'package:get/get.dart';
import 'package:tv/configs/baseConfig.dart';
import 'package:tv/helpers/environment.dart';

class AdUnitIdHelper {
  static String getAdUnitId(String position) {
    if (Environment().config.flavor == Flavor.dev) {
      return '/6499/example/banner';
    }

    if (GetPlatform.isAndroid) {
      return _getAndroidAdUnitId(position);
    } else {
      return _getIosAdUnitId(position);
    }
  }

  static String _getAndroidAdUnitId(String position) {
    switch (position) {
      case 'AT1':
        return '';
      case 'AT2':
        return '';
      case 'AT3':
        return '';
      case 'LiveAT1':
        return '';
      case 'LiveAT2':
        return '';
      case 'LiveAT3':
        return '';
      case 'AnchorHD':
        return '';
      case 'AnchorAT1':
        return '';
      case 'AnchorAT2':
        return '';
      case 'StoryHD':
        return '';
      case 'StoryAT1':
        return '';
      case 'StoryAT2':
        return '';
      case 'TopicHD':
        return '';
      case 'TopicAT1':
        return '';
      case 'TopicAT2':
        return '';
      case 'ShowAT1':
        return '';
      case 'ShowAT2':
        return '';
      case 'ShowAT3':
        return '';
      default:
        return '';
    }
  }

  static String _getIosAdUnitId(String position) {
    switch (position) {
      case 'AT1':
        return '';
      case 'AT2':
        return '';
      case 'AT3':
        return '';
      case 'LiveAT1':
        return '';
      case 'LiveAT2':
        return '';
      case 'LiveAT3':
        return '';
      case 'AnchorHD':
        return '';
      case 'AnchorAT1':
        return '';
      case 'AnchorAT2':
        return '';
      case 'StoryHD':
        return '';
      case 'StoryAT1':
        return '';
      case 'StoryAT2':
        return '';
      case 'TopicHD':
        return '';
      case 'TopicAT1':
        return '';
      case 'TopicAT2':
        return '';
      case 'ShowAT1':
        return '';
      case 'ShowAT2':
        return '';
      case 'ShowAT3':
        return '';
      default:
        return '';
    }
  }
}
