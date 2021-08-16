import 'dart:io';

import 'package:tv/baseConfig.dart';

AdHelper? adHelper = _adHelper;
AdHelper? _adHelper;

class AdHelper {

  AdHelper();
  /// Sets up the top-level [adHelper] getter on the first call only.
  static void init() => _adHelper ??= AdHelper();

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return baseConfig!.iOSBannerAdUnitId;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.androidNativeAdUnitId;
    } else if (Platform.isIOS) {
      return baseConfig!.iOSNativeAdUnitId;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return baseConfig!.iOSInterstitialAdUnitId;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}