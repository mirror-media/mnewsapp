import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/notificationSetting/events.dart';
import 'package:tv/blocs/notificationSetting/states.dart';
import 'package:tv/services/notificationSettingService.dart';

class NotificationSettingBloc
    extends Bloc<NotificationSettingEvents, NotificationSettingState> {
  final NotificationSettingRepos notificationSettingRepos;

  NotificationSettingBloc({required this.notificationSettingRepos})
      : super(NotificationSettingInitState());

  @override
  Stream<NotificationSettingState> mapEventToState(
      NotificationSettingEvents event) async* {
    yield* event.run(notificationSettingRepos);
  }
}
