import 'dart:io';

import 'package:tv/baseConfig.dart';

class AdHelper {

  AdHelper();

  String get stickyBannerAdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndRos320x50ST;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosRos320x50ST;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get homeAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndHome300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosHome300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get homeAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndHome300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosHome300x250AT2;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get homeAT3AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndHome300x250AT3;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosHome300x250AT3;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get polAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndPol300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosPol300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get polAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndPol300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosPol300x250AT2;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get polAT3AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndPol300x250AT3;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosPol300x250AT3;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get intAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndInt300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosInt300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get intAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndInt300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosInt300x250AT2;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get intAT3AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndInt300x250AT3;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosInt300x250AT3;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get finAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndFin300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosFin300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get finAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndFin300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosFin300x250AT2;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get finAT3AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndFin300x250AT3;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosFin300x250AT3;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get socAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndSoc300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosSoc300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get socAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndSoc300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosSoc300x250AT2;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get socAT3AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndSoc300x250AT3;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosSoc300x250AT3;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get lifAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndLif300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosLif300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get lifAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndLif300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosLif300x250AT2;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get lifAT3AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndLif300x250AT3;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosLif300x250AT3;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get entAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndEnt300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosEnt300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get entAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndEnt300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosEnt300x250AT2;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get entAT3AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndEnt300x250AT3;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosEnt300x250AT3;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get uncAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndUnc300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosUnc300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get uncAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndUnc300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosUnc300x250AT2;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get uncAT3AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndUnc300x250AT3;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosUnc300x250AT3;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get storyHDAdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndStory300x250HD;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosStory300x250HD;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get storyAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndStory300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosStory300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get storyAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndStory300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosStory300x250AT2;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get storyAT3AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndStory300x250AT3;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosStory300x250AT3;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get storyE1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndStory300x250E1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosStory300x250E1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get storyFTAdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndStory300x250FT;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosStory300x250FT;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get liveAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndLive300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosLive300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get liveAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndLive300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosLive300x250AT2;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get liveAT3AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndLive300x250AT3;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosLive300x250AT3;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get vdoAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndVdo300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosVdo300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get vdoAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndVdo300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosVdo300x250AT2;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get vdoAT3AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndVdo300x250AT3;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosVdo300x250AT3;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get showAT1AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndShow300x250AT1;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosShow300x250AT1;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  String get showAT2AdUnitId {
    if (Platform.isAndroid) {
      return baseConfig!.tvAndShow300x250AT2;
    } else if (Platform.isIOS) {
      return baseConfig!.tvIosShow300x250AT2;
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