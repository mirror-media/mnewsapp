import 'dart:convert';

class NotificationSetting {
  final String type;
  final String id;
  final String title;
  final String? topic;
  bool value;
  final List<NotificationSetting>? notificationSettingList;

  NotificationSetting({
    required this.type,
    required this.id,
    required this.title,
    required this.topic,
    required this.value,
    required this.notificationSettingList,
  });

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    List<NotificationSetting>? notificationSettingList;
    if (json['notificationSettingList'] != null) {
      for (var notificationSetting in json['notificationSettingList']) {
        notificationSettingList = [];
        notificationSettingList
            .add(NotificationSetting.fromJson(notificationSetting));
      }
    }
    return new NotificationSetting(
      type: json['type'],
      id: json['id'],
      title: json['title'],
      topic: json['topic'],
      value: json['value'],
      notificationSettingList: notificationSettingList,
    );
  }

  Map<String, dynamic> toJson() {
    String? notificationSettingListJson;
    if (notificationSettingList != null) {
      List<Map> notificationSettingMaps = [];
      for (NotificationSetting notificationSetting
          in notificationSettingList!) {
        notificationSettingMaps.add(notificationSetting.toJson());
      }
      notificationSettingListJson = json.encode(notificationSettingMaps);
    }
    return {
      'type': type,
      'id': id,
      'title': title,
      'topic': topic,
      'value': value,
      'notificationSettingList': notificationSettingListJson,
    };
  }
}
