abstract class ConfigState {}

class ConfigInitState extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  final bool isSuccess;
  ConfigLoaded({this.isSuccess});
}

class ConfigError extends ConfigState {
  final error;
  ConfigError({this.error});
}
