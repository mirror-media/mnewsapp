import 'package:tv/models/notificationSettingList.dart';

abstract class NotificationSettingEvents {}

class GetNotificationSettingList extends NotificationSettingEvents {
  @override
  String toString() => 'GetNotificationSettingList';
}

class NotificationOnExpansionChanged extends NotificationSettingEvents {
  final NotificationSettingList inputNotificationSettingList;
  final int index;
  final bool value;
  NotificationOnExpansionChanged(
      this.inputNotificationSettingList, this.index, this.value);

  @override
  String toString() => 'NotificationOnExpansionChanged';
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
}
