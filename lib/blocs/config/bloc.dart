import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/config/events.dart';
import 'package:tv/blocs/config/states.dart';
import 'package:tv/services/configService.dart';

class ConfigBloc extends Bloc<ConfigEvents, ConfigState> {
  final ConfigRepos configRepos;

  ConfigBloc({required this.configRepos}) : super(ConfigInitState());

  @override
  Stream<ConfigState> mapEventToState(ConfigEvents event) async* {
    yield* event.run(configRepos);
  }
}
