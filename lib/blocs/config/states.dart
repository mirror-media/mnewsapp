import 'package:tv/models/topic.dart';

abstract class ConfigState {}

class ConfigInitState extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  final bool isSuccess;
  final String minAppVersion;
  final List<Topic> topics;
  ConfigLoaded({
    required this.isSuccess,
    required this.minAppVersion,
    required this.topics,
  });
}

class ConfigError extends ConfigState {
  final error;
  ConfigError({this.error});
}
