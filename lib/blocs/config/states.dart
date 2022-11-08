abstract class ConfigState {}

class ConfigInitState extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  final bool isSuccess;
  final String minAppVersion;
  final String appVersion;
  final String electionJsonApi;
  ConfigLoaded({
    required this.isSuccess,
    required this.minAppVersion,
    required this.appVersion,
    required this.electionJsonApi,
  });
}

class ConfigError extends ConfigState {
  final error;
  ConfigError({this.error});
}
