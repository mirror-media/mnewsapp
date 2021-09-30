import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/notificationSetting/events.dart';
import 'package:tv/blocs/notificationSetting/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/notificationSettingList.dart';
import 'package:tv/services/notificationSettingService.dart';

class NotificationSettingBloc
    extends Bloc<NotificationSettingEvents, NotificationSettingState> {
  final NotificationSettingRepos notificationSettingRepos;

  NotificationSettingBloc({required this.notificationSettingRepos})
      : super(NotificationSettingInitState());

  @override
  Stream<NotificationSettingState> mapEventToState(
      NotificationSettingEvents event) async* {
    print(event.toString());
    try {
      if (event is GetNotificationSettingList) {
        yield NotificationSettingLoading();
        NotificationSettingList notificationSettingList =
            await notificationSettingRepos.getNotificationSettingList();
        yield NotificationSettingLoaded(
            notificationSettingList: notificationSettingList);
      } else if (event is NotificationOnExpansionChanged) {
        NotificationSettingList notificationSettingList =
            notificationSettingRepos.onExpansionChanged(
          event.inputNotificationSettingList,
          event.index,
          event.value,
        );
        yield NotificationSettingLoaded(
            notificationSettingList: notificationSettingList);
      } else if (event is NotificationOnCheckBoxChanged) {
        NotificationSettingList notificationSettingList =
            notificationSettingRepos.onCheckBoxChanged(
          event.inputNotificationSettingList,
          event.checkboxList,
          event.index,
          event.isRepeatable,
        );
        yield NotificationSettingLoaded(
            notificationSettingList: notificationSettingList);
      }
    } on SocketException {
      yield NotificationSettingError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield NotificationSettingError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield NotificationSettingError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } catch (e) {
      print('${event.toString()} error: $e');
      yield NotificationSettingError(
        error: UnknownException(e.toString()),
      );
    }
  }
}
