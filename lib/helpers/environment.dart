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

  void initConfig(
      BuildFlavor buildFlavor, {
        ProdRouteMode routeMode = ProdRouteMode.normal,
      }) {
    config = _getConfig(
      buildFlavor,
      routeMode: routeMode,
    );
  }

  BaseConfig _getConfig(
      BuildFlavor buildFlavor, {
        ProdRouteMode routeMode = ProdRouteMode.normal,
      }) {
    switch (buildFlavor) {
      case BuildFlavor.production:
        return ProdConfig(routeMode: routeMode);
      case BuildFlavor.development:
      default:
        return DevConfig();
    }
  }
}