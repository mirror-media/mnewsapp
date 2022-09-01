abstract class ConfigState {}

class ConfigInitState extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  final bool isSuccess;
  final String minAppVersion;
  final String appVersion;
  ConfigLoaded({
    required this.isSuccess,
    required this.minAppVersion,
    required this.appVersion,
  });
}

class ConfigError extends ConfigState {
  final error;
  ConfigError({this.error});
}
