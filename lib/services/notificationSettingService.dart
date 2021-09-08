import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/notificationSetting.dart';
import 'package:tv/models/notificationSettingList.dart';

abstract class NotificationSettingRepos {
  Future<NotificationSettingList> getNotificationSettingList();
  NotificationSettingList onExpansionChanged(
      NotificationSettingList notificationSettingList, int index, bool value);
  NotificationSettingList onCheckBoxChanged(
    NotificationSettingList notificationSettingList,
    NotificationSettingList checkboxList,
    int index,
    bool isRepeatable,
  );
}

class NotificationSettingServices implements NotificationSettingRepos {
  final LocalStorage _storage = LocalStorage('setting');

  @override
  Future<NotificationSettingList> getNotificationSettingList() async {
    NotificationSettingList notificationSettingList;
    NotificationSettingList? storageNotification;
    if (await _storage.ready) {
      var notificationMapList = await _storage.getItem("notification");
      storageNotification = notificationMapList != null
          ? NotificationSettingList.fromJson(notificationMapList)
          : null;
    }

    if (storageNotification == null) {
      notificationSettingList = await _fetchDefaultNotificationList();
      _storage.setItem("notification", notificationSettingList.toJson());
    } else {
      notificationSettingList =
          NotificationSettingList.fromJson(_storage.getItem("notification"));
      NotificationSettingList notificationSettingListFromAsset =
          await _fetchDefaultNotificationList();
      checkAndSyncNotificationSettingList(
          notificationSettingListFromAsset, notificationSettingList);
      notificationSettingList = notificationSettingListFromAsset;
      _storage.setItem("notification", notificationSettingList.toJson());
    }

    return notificationSettingList;
  }

  Future<NotificationSettingList> _fetchDefaultNotificationList() async {
    var jsonSetting = await rootBundle.loadString(defaultNotificationListJson);
    var jsonSettingList = json.decode(jsonSetting)['defaultNotificationList'];

    NotificationSettingList notificationSettingList =
        NotificationSettingList.fromJson(jsonSettingList);

    return notificationSettingList;
  }

  /// assetList is from defaultNotificationList.json
  /// userList is from storage notification
  /// change the title and topic from assetList
  /// keep the subscription value from userList
  checkAndSyncNotificationSettingList(NotificationSettingList? assetList,
      NotificationSettingList? userList) async {
    if (assetList != null) {
      assetList.forEach((asset) {
        NotificationSetting? user = userList?.getById(asset.id);
        if (user != null && user.id == asset.id) {
          // if(user.topic != asset.topic && user.value) {
          //   _firebaseMessangingHelper.unsubscribeFromTopic(user.topic);
          //   _firebaseMessangingHelper.subscribeToTopic(asset.topic);
          // }
          asset.value = user.value;

          if (asset.notificationSettingList != null ||
              user.notificationSettingList != null) {
            checkAndSyncNotificationSettingList(
                asset.notificationSettingList, user.notificationSettingList);
          }
        }
      });
    }

    // if(userList != null) {
    //   userList.forEach(
    //     (user) {
    //       NotificationSetting asset = assetList?.getById(user.id);
    //       if(asset == null && user.topic != null && user.value) {
    //         _firebaseMessangingHelper.unsubscribeFromTopic(user.topic);
    //       }
    //     }
    //   );
    // }
  }

  @override
  NotificationSettingList onExpansionChanged(
      NotificationSettingList notificationSettingList, int index, bool value) {
    notificationSettingList[index].value = value;
    _storage.setItem("notification", notificationSettingList.toJson());
    //_firebaseMessangingHelper.subscribeTheNotification(notificationSettingList[index]);
    return notificationSettingList;
  }

  @override
  NotificationSettingList onCheckBoxChanged(
      NotificationSettingList notificationSettingList,
      NotificationSettingList checkboxList,
      int index,
      bool isRepeatable) {
    if (isRepeatable) {
      checkboxList[index].value = !checkboxList[index].value;
    } else {
      checkboxList.forEach((element) {
        element.value = false;
      });
      checkboxList[index].value = true;
    }
    _storage.setItem("notification", notificationSettingList.toJson());
    //_firebaseMessangingHelper.subscribeTheNotification(notificationSetting);
    return notificationSettingList;
  }
}
