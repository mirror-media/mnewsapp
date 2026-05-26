import 'package:tv/configs/baseConfig.dart';
import 'package:tv/configs/devConfig.dart';
import 'package:tv/configs/prodConfig.dart';

enum BuildFlavor { production, development }

class Environment {
  factory Environment() {
    return _singleton;
  }

  Environment._internal();

  static final Environment _singleton = Environment._internal();

  late BaseConfig config;

  void initConfig(BuildFlavor buildFlavor) {
    config = _getConfig(buildFlavor);
  }

  BaseConfig _getConfig(BuildFlavor buildFlavor) {
    switch (buildFlavor) {
      case BuildFlavor.production:
        return ProdConfig();
      case BuildFlavor.development:
        return DevConfig();
    }
  }
}
