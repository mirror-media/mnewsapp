import 'dart:io';

import 'package:tv/blocs/notificationSetting/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/notificationSettingList.dart';
import 'package:tv/services/notificationSettingService.dart';

abstract class NotificationSettingEvents {
  Stream<NotificationSettingState> run(
      NotificationSettingRepos notificationSettingRepos);
}

class GetNotificationSettingList extends NotificationSettingEvents {
  GetNotificationSettingList();

  @override
  String toString() => 'GetNotificationSettingList';

  @override
  Stream<NotificationSettingState> run(
      NotificationSettingRepos notificationSettingRepos) async* {
    print(this.toString());
    try {
      yield NotificationSettingLoading();
      NotificationSettingList notificationSettingList =
          await notificationSettingRepos.getNotificationSettingList();
      yield NotificationSettingLoaded(
          notificationSettingList: notificationSettingList);
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
      yield NotificationSettingError(
        error: UnknownException(e.toString()),
      );
    }
  }
}

class NotificationOnExpansionChanged extends NotificationSettingEvents {
  final NotificationSettingList inputNotificationSettingList;
  final int index;
  final bool value;
  NotificationOnExpansionChanged(
      this.inputNotificationSettingList, this.index, this.value);

  @override
  String toString() => 'NotificationOnExpansionChanged';

  @override
  Stream<NotificationSettingState> run(
      NotificationSettingRepos notificationSettingRepos) async* {
    print(this.toString());
    try {
      NotificationSettingList notificationSettingList =
          notificationSettingRepos.onExpansionChanged(
        inputNotificationSettingList,
        index,
        value,
      );
      yield NotificationSettingLoaded(
          notificationSettingList: notificationSettingList);
    } catch (e) {
      print('NotificationOnExpansionChanged error: $e');
    }
  }
}

class NotificationOnCheckBoxChanged extends NotificationSettingEvents {
  final NotificationSettingList inputNotificationSettingList;
  final NotificationSettingList checkboxList;
  final int index;
  final bool isRepeatable;
  NotificationOnCheckBoxChanged(this.inputNotificationSettingList,
      this.checkboxList, this.index, this.isRepeatable);

  @override
  String toString() => 'NotificationOnCheckBoxChanged';

  @override
  Stream<NotificationSettingState> run(
      NotificationSettingRepos notificationSettingRepos) async* {
    print(this.toString());
    try {
      NotificationSettingList notificationSettingList =
          notificationSettingRepos.onCheckBoxChanged(
        inputNotificationSettingList,
        checkboxList,
        index,
        isRepeatable,
      );
      yield NotificationSettingLoaded(
          notificationSettingList: notificationSettingList);
    } catch (e) {
      print('NotificationOnCheckBoxChanged error: $e');
    }
  }
}
