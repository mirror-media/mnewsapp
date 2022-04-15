import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/notificationSetting.dart';

abstract class NotificationSettingRepos {
  Future<List<NotificationSetting>> getNotificationSettingList();
  List<NotificationSetting> onExpansionChanged(
      List<NotificationSetting> notificationSettingList, int index, bool value);
  List<NotificationSetting> onCheckBoxChanged(
    List<NotificationSetting> notificationSettingList,
    List<NotificationSetting> checkboxList,
    int index,
    bool isRepeatable,
  );
}

class NotificationSettingServices implements NotificationSettingRepos {
  final LocalStorage _storage = LocalStorage('setting');

  @override
  Future<List<NotificationSetting>> getNotificationSettingList() async {
    List<NotificationSetting> notificationSettingList = [];
    List<NotificationSetting>? storageNotification;
    if (await _storage.ready) {
      var notificationMapList = await _storage.getItem("notification");
      if (notificationMapList != null) {
        storageNotification = List<NotificationSetting>.from(
            notificationMapList.map((notificationSetting) =>
                NotificationSetting.fromJson(notificationSetting)));
      }
    }

    if (storageNotification == null) {
      notificationSettingList = await _fetchDefaultNotificationList();
    } else {
      notificationSettingList = List<NotificationSetting>.from(_storage
          .getItem("notification")
          .map((notificationSetting) =>
              NotificationSetting.fromJson(notificationSetting)));
      List<NotificationSetting> notificationSettingListFromAsset =
          await _fetchDefaultNotificationList();
      checkAndSyncNotificationSettingList(
          notificationSettingListFromAsset, notificationSettingList);
      notificationSettingList = notificationSettingListFromAsset;
    }

    List<Map> notificationSettingMaps = List<Map>.from(notificationSettingList
        .map((notificationSetting) => notificationSetting.toJson()));
    _storage.setItem("notification", json.encode(notificationSettingMaps));

    return notificationSettingList;
  }

  Future<List<NotificationSetting>> _fetchDefaultNotificationList() async {
    var jsonSetting = await rootBundle.loadString(defaultNotificationListJson);
    var jsonSettingList = json.decode(jsonSetting)['defaultNotificationList'];

    List<NotificationSetting> notificationSettingList =
        List<NotificationSetting>.from(jsonSettingList.map(
            (notificationSetting) =>
                NotificationSetting.fromJson(notificationSetting)));

    return notificationSettingList;
  }

  /// assetList is from defaultNotificationList.json
  /// userList is from storage notification
  /// change the title and topic from assetList
  /// keep the subscription value from userList
  checkAndSyncNotificationSettingList(List<NotificationSetting>? assetList,
      List<NotificationSetting>? userList) async {
    if (assetList != null) {
      assetList.forEach((asset) {
        NotificationSetting? user =
            userList?.firstWhere((element) => element.id == asset.id);
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
  List<NotificationSetting> onExpansionChanged(
      List<NotificationSetting> notificationSettingList,
      int index,
      bool value) {
    notificationSettingList[index].value = value;
    List<Map> notificationSettingMaps = List<Map>.from(notificationSettingList
        .map((notificationSetting) => notificationSetting.toJson()));
    _storage.setItem("notification", json.encode(notificationSettingMaps));
    //_firebaseMessangingHelper.subscribeTheNotification(notificationSettingList[index]);
    return notificationSettingList;
  }

  @override
  List<NotificationSetting> onCheckBoxChanged(
      List<NotificationSetting> notificationSettingList,
      List<NotificationSetting> checkboxList,
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
    List<Map> notificationSettingMaps = List<Map>.from(notificationSettingList
        .map((notificationSetting) => notificationSetting.toJson()));
    _storage.setItem("notification", json.encode(notificationSettingMaps));
    //_firebaseMessangingHelper.subscribeTheNotification(notificationSetting);
    return notificationSettingList;
  }
}
