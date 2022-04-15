import 'package:tv/models/notificationSetting.dart';

abstract class NotificationSettingState {}

class NotificationSettingInitState extends NotificationSettingState {}

class NotificationSettingLoading extends NotificationSettingState {}

class NotificationSettingLoaded extends NotificationSettingState {
  final List<NotificationSetting> notificationSettingList;
  NotificationSettingLoaded({required this.notificationSettingList});
}

class NotificationSettingError extends NotificationSettingState {
  final error;
  NotificationSettingError({this.error});
}
