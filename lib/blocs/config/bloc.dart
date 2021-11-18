import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/config/events.dart';
import 'package:tv/blocs/config/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/services/configService.dart';

class ConfigBloc extends Bloc<ConfigEvents, ConfigState> {
  final ConfigRepos configRepos;

  ConfigBloc({required this.configRepos}) : super(ConfigInitState());

  @override
  Stream<ConfigState> mapEventToState(ConfigEvents event) async* {
    print(event.toString());
    try {
      yield ConfigLoading();
      bool isSuccess = await configRepos.loadTheConfig(event.context);
      // fetch min app version setting in firebase_remote_config
      RemoteConfig remoteConfig = RemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration(hours: 12),
      ));
      await remoteConfig.fetchAndActivate();
      String minAppVersion = remoteConfig.getString('min_version_number');

      yield ConfigLoaded(isSuccess: isSuccess, minAppVersion: minAppVersion);
    } catch (e) {
      yield ConfigError(
        error: UnknownException(e.toString()),
      );
    }
  }
}
