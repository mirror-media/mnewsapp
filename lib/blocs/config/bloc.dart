import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tv/blocs/config/events.dart';
import 'package:tv/blocs/config/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/topic.dart';
import 'package:tv/services/configService.dart';
import 'package:tv/services/topicService.dart';

class ConfigBloc extends Bloc<ConfigEvents, ConfigState> {
  final ConfigRepos configRepos;

  ConfigBloc({required this.configRepos}) : super(ConfigInitState()) {
    on<ConfigEvents>(
      (event, emit) async {
        print(event.toString());
        try {
          emit(ConfigLoading());

          bool isSuccess = await configRepos.loadTheConfig(event.context);
          // fetch min app version setting in firebase_remote_config
          FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
          await remoteConfig.setConfigSettings(RemoteConfigSettings(
            fetchTimeout: Duration(seconds: 10),
            minimumFetchInterval: Duration(hours: 12),
          ));
          await remoteConfig.fetchAndActivate();
          String minAppVersion = remoteConfig.getString('min_version_number');
          // fetch topic list need to show in drawer
          List<Topic> topics = await TopicService().fetchFeaturedTopics();
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          String appVersion =
              'v${packageInfo.version}(${packageInfo.buildNumber})';
          emit(ConfigLoaded(
            isSuccess: isSuccess,
            minAppVersion: minAppVersion,
            topics: topics,
            appVersion: appVersion,
          ));
        } catch (e) {
          emit(ConfigError(
            error: UnknownException(e.toString()),
          ));
        }
      },
    );
  }
}
