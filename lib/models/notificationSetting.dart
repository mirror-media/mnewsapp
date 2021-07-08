import 'package:tv/models/notificationSettingList.dart';

class NotificationSetting {
  final String type;
  final String id;
  final String title;
  final String? topic;
  bool value;
  final NotificationSettingList? notificationSettingList;

  NotificationSetting({
    required this.type,
    required this.id,
    required this.title,
    required this.topic,
    required this.value,
    required this.notificationSettingList,
  });

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    return new NotificationSetting(
      type: json['type'],
      id: json['id'],
      title: json['title'],
      topic: json['topic'],
      value: json['value'],
      notificationSettingList: json['notificationSettingList'] != null
        ? NotificationSettingList.fromJson(json['notificationSettingList'])
        : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'title': title,
        'topic': topic,
        'value': value,
        'notificationSettingList': notificationSettingList?.toJson(),
      };
}
