import 'package:flutter/material.dart';
import 'package:tv/blocs/config/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/services/configService.dart';

abstract class ConfigEvents {
  Stream<ConfigState> run(ConfigRepos configRepos);
}

class LoadingConfig extends ConfigEvents {
  final BuildContext context;
  LoadingConfig(this.context);

  @override
  String toString() => 'LoadingConfig';

  @override
  Stream<ConfigState> run(ConfigRepos configRepos) async* {
    print(this.toString());
    try {
      yield ConfigLoading();
      bool isSuccess = await configRepos.loadTheConfig(context);
      yield ConfigLoaded(isSuccess: isSuccess);
    } catch (e) {
      yield ConfigError(
        error: UnknownException(e.toString()),
      );
    }
  }
}
