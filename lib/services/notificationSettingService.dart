import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tv/models/notificationSetting.dart';
import 'package:tv/models/notificationSettingList.dart';

abstract class NotificationSettingRepos {
  Future<NotificationSettingList> getNotificationSettingList();
  NotificationSettingList onExpansionChanged(
    NotificationSettingList notificationSettingList, 
    int index, 
    bool value
  );
  NotificationSettingList onCheckBoxChanged(
    NotificationSettingList notificationSettingList, 
    NotificationSettingList checkboxList,
    int index, 
    bool isRepeatable,
  );
}

class NotificationSettingServices implements NotificationSettingRepos{ 
  final LocalStorage _storage = LocalStorage('setting');

  @override
  Future<NotificationSettingList> getNotificationSettingList() async{
    NotificationSettingList notificationSettingList;
    if (await _storage.ready) {
      notificationSettingList =
          NotificationSettingList.fromJson(_storage.getItem("notification"));
    }

    if (notificationSettingList == null) {
      notificationSettingList = await _fetchDefaultNotificationList();
      _storage.setItem("notification", notificationSettingList.toJson());
    } else {
      NotificationSettingList notificationSettingListFromAsset = await _fetchDefaultNotificationList();
      checkAndSyncNotificationSettingList(
        notificationSettingListFromAsset,
        notificationSettingList
      );
      notificationSettingList = notificationSettingListFromAsset;
      _storage.setItem("notification", notificationSettingList.toJson());
    }

    return notificationSettingList;
  }

  Future<NotificationSettingList> _fetchDefaultNotificationList() async {
    var jsonSetting =
        await rootBundle.loadString('assets/json/defaultNotificationList.json');
    var jsonSettingList = json.decode(jsonSetting)['defaultNotificationList'];

    NotificationSettingList notificationSettingList =
        NotificationSettingList.fromJson(jsonSettingList);
    
    return notificationSettingList;
  }
  
  /// assetList is from defaultNotificationList.json
  /// userList is from storage notification
  /// change the title and topic from assetList
  /// keep the subscription value from userList
  checkAndSyncNotificationSettingList(NotificationSettingList assetList, NotificationSettingList userList) async{
    if(assetList != null) {
      assetList.forEach(
        (asset) { 
          NotificationSetting user = userList?.getById(asset.id);
          if(user != null && user.id == asset.id) {
            asset.value = user.value;

            if(asset.notificationSettingList != null || user.notificationSettingList != null) {
              checkAndSyncNotificationSettingList(
                asset.notificationSettingList,
                user.notificationSettingList
              );
            }
          }
        }
      );
    }
  }

  @override
  NotificationSettingList onExpansionChanged(
    NotificationSettingList notificationSettingList, 
    int index, 
    bool value
  ) {
    notificationSettingList[index].value = value;
    _storage.setItem("notification", notificationSettingList.toJson());
    return notificationSettingList;
  }

  @override
  NotificationSettingList onCheckBoxChanged(
    NotificationSettingList notificationSettingList, 
    NotificationSettingList checkboxList,
    int index, 
    bool isRepeatable
  ) {
    if (isRepeatable) {
      checkboxList[index].value =
          !checkboxList[index].value;
    } else {
      checkboxList.forEach((element) {
        element.value = false;
      });
      checkboxList[index].value = true;
    }
    _storage.setItem("notification", notificationSettingList.toJson());
    return notificationSettingList;
  }
}