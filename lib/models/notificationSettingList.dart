import 'dart:convert';

import 'package:tv/models/customizedList.dart';
import 'package:tv/models/notificationSetting.dart';

class NotificationSettingList extends CustomizedList<NotificationSetting> {
  // constructor
  NotificationSettingList();

  factory NotificationSettingList.fromJson(List<dynamic> parsedJson) {
    NotificationSettingList notificationSettings = NotificationSettingList();
    List parseList =
        parsedJson.map((i) => NotificationSetting.fromJson(i)).toList();
    parseList.forEach((element) {
      notificationSettings.add(element);
    });

    return notificationSettings;
  }

  factory NotificationSettingList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return NotificationSettingList.fromJson(jsonData);
  }

  // your custom methods
  List<Map<dynamic, dynamic>> toJson() {
    List<Map> notificationSettingMaps = List.empty(growable: true);
    for (NotificationSetting notificationSetting in this) {
      notificationSettingMaps.add(notificationSetting.toJson());
    }
    return notificationSettingMaps;
  }

  String toJsonString() {
    List<Map> notificationSettingMaps = List.empty(growable: true);
    for (NotificationSetting notificationSetting in this) {
      notificationSettingMaps.add(notificationSetting.toJson());
    }
    return json.encode(notificationSettingMaps);
  }

  NotificationSetting? getById(String? id) {
    try {
      return this.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }
}
