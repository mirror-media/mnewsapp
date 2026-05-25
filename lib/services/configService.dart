import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tv/helpers/firebaseMessagingHelper.dart';

abstract class ConfigRepos {
  Future<bool> loadTheConfig();
}

class ConfigServices implements ConfigRepos {
  @override
  Future<bool> loadTheConfig() async {
    // FCM 初始化（權限請求 / getInitialMessage / 註冊各種 listener）
    // 在 iOS Simulator 上偶爾會卡住，且本質上不該阻塞首頁顯示。
    // 改成 fire-and-forget：失敗也只記 log，不影響 App 啟動。
    final FirebaseMessagingHelper firebaseMessagingHelper =
        FirebaseMessagingHelper();
    unawaited(
      firebaseMessagingHelper.configFirebaseMessaging().catchError((Object e) {
        debugPrint('[fcm] configFirebaseMessaging failed (non-fatal): $e');
      }),
    );
    return true;
  }
}
