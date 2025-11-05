import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/notificationSetting.dart';

abstract class NotificationSettingRepos {
  Future<List<NotificationSetting>> getNotificationSettingList();
  List<NotificationSetting> onExpansionChanged(
      List<NotificationSetting> notificationSettingList,
      int index,
      bool value,
      );
  List<NotificationSetting> onCheckBoxChanged(
      List<NotificationSetting> notificationSettingList,
      List<NotificationSetting> checkboxList,
      int index,
      bool isRepeatable,
      );
}

class NotificationSettingServices implements NotificationSettingRepos {
  static const _kKey = 'notification';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  @override
  Future<List<NotificationSetting>> getNotificationSettingList() async {
    final prefs = await _prefs;
    final stored = prefs.getString(_kKey);

    // 1) 沒有舊資料 → 讀取預設檔
    if (stored == null) {
      final defaults = await _fetchDefaultNotificationList();
      await _save(defaults);
      return defaults;
    }

    // 2) 有舊資料 → 解析 JSON → 合併預設（以預設的結構為準，保留使用者勾選值）
    List<dynamic> decoded;
    try {
      decoded = json.decode(stored) as List<dynamic>;
    } catch (_) {
      // 若資料壞掉就回到預設
      final defaults = await _fetchDefaultNotificationList();
      await _save(defaults);
      return defaults;
    }

    final userList = List<NotificationSetting>.from(
      decoded.map((e) => NotificationSetting.fromJson(e as Map<String, dynamic>)),
    );

    final assetList = await _fetchDefaultNotificationList();
    await checkAndSyncNotificationSettingList(assetList, userList);
    await _save(assetList);
    return assetList;
  }

  Future<void> _save(List<NotificationSetting> list) async {
    final prefs = await _prefs;
    final maps = list.map((e) => e.toJson()).toList();
    await prefs.setString(_kKey, json.encode(maps));
  }

  Future<List<NotificationSetting>> _fetchDefaultNotificationList() async {
    final jsonSetting = await rootBundle.loadString(defaultNotificationListJson);
    final jsonSettingList = json.decode(jsonSetting)['defaultNotificationList'] as List<dynamic>;
    return List<NotificationSetting>.from(
      jsonSettingList.map((e) => NotificationSetting.fromJson(e as Map<String, dynamic>)),
    );
  }

  /// assetList 來自 assets 的 defaultNotificationList.json
  /// userList 來自本地儲存
  /// 規則：以 asset 的結構（title/topic/id）為準，保留 user 的勾選 value
  Future<void> checkAndSyncNotificationSettingList(
      List<NotificationSetting>? assetList,
      List<NotificationSetting>? userList,
      ) async {
    if (assetList == null) return;

    for (final asset in assetList) {
      final user = userList?.firstWhere(
            (u) => u.id == asset.id,
        orElse: () => null as NotificationSetting, // 只為了讓編譯器過；下一行會檢查 null
      );
      if (user != null && user.id == asset.id) {
        asset.value = user.value;

        if (asset.notificationSettingList != null ||
            user.notificationSettingList != null) {
          await checkAndSyncNotificationSettingList(
            asset.notificationSettingList,
            user.notificationSettingList,
          );
        }
      }
    }
  }

  @override
  List<NotificationSetting> onExpansionChanged(
      List<NotificationSetting> notificationSettingList,
      int index,
      bool value,
      ) {
    notificationSettingList[index].value = value;

    // 非同步保存（不影響回傳型別）
    _save(notificationSettingList);
    return notificationSettingList;
  }

  @override
  List<NotificationSetting> onCheckBoxChanged(
      List<NotificationSetting> notificationSettingList,
      List<NotificationSetting> checkboxList,
      int index,
      bool isRepeatable,
      ) {
    if (isRepeatable) {
      checkboxList[index].value = !checkboxList[index].value;
    } else {
      for (final e in checkboxList) {
        e.value = false;
      }
      checkboxList[index].value = true;
    }

    // 非同步保存（不影響回傳型別）
    _save(notificationSettingList);
    return notificationSettingList;
  }
}
