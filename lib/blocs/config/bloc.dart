import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tv/blocs/config/events.dart';
import 'package:tv/blocs/config/states.dart';
import 'package:tv/configs/prodConfig.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/provider/articles_api_provider.dart';
import 'package:tv/services/configService.dart';

class ConfigBloc extends Bloc<ConfigEvents, ConfigState> {
  final ConfigRepos configRepos;

  ConfigBloc({required this.configRepos}) : super(ConfigInitState()) {
    on<ConfigEvents>(
          (event, emit) async {
        print(event.toString());

        try {
          emit(ConfigLoading());

          final FirebaseRemoteConfig remoteConfig =
              FirebaseRemoteConfig.instance;

          await remoteConfig.setConfigSettings(
            RemoteConfigSettings(
              fetchTimeout: const Duration(seconds: 10),
              minimumFetchInterval: const Duration(minutes: 10),
            ),
          );

          await remoteConfig.setDefaults({
            'min_version_number': '',
            'use_temporary_k6_routes': false,
          });

          await remoteConfig.fetchAndActivate();

          final String minAppVersion =
          remoteConfig.getString('min_version_number');

          final bool useTemporaryK6Routes =
          remoteConfig.getBool('use_temporary_k6_routes');

          Environment().initConfig(
            BuildFlavor.production,
            routeMode: useTemporaryK6Routes
                ? ProdRouteMode.temporaryK6
                : ProdRouteMode.normal,
          );

          // 重新建立 GraphQL client，避免還綁舊網址
          ArticlesApiProvider.instance.initGraphQLLink();

          final bool isSuccess = await configRepos.loadTheConfig(event.context);

          final PackageInfo packageInfo = await PackageInfo.fromPlatform();
          final String appVersion =
              'v${packageInfo.version}(${packageInfo.buildNumber})';

          emit(
            ConfigLoaded(
              isSuccess: isSuccess,
              minAppVersion: minAppVersion,
              appVersion: appVersion,
            ),
          );
        } catch (e) {
          emit(
            ConfigError(
              error: UnknownException(e.toString()),
            ),
          );
        }
      },
    );
  }
}