import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tv/pages/story_page.dart';

/// Background message handler.
///
/// 必須是 top-level 或 static function，並標記 `@pragma('vm:entry-point')`
/// 以避免在 release / AOT build 下被 tree-shake 掉，造成背景推播完全收不到。
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 若日後需要在背景使用其他 Firebase 服務，記得先呼叫 Firebase.initializeApp()
  debugPrint('[fcm-bg] Handling a background message ${message.messageId}');
}

class FirebaseMessagingHelper {
  FirebaseMessagingHelper();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// 暫存 cold-start 時收到的 initialMessage 對應的 story slug。
  ///
  /// `configFirebaseMessaging()` 是非阻塞、在首頁顯示前不一定完成的流程；
  /// 即使取得到 `initialMessage`，當下 GetMaterialApp 的 navigator 也未必就緒，
  /// 直接 `Get.to(...)` 會 silent fail。因此把要導頁的 slug 暫存起來，
  /// 等 HomePage 掛載時再透過 [consumePendingStorySlug] 取出。
  static String? _pendingStorySlug;

  /// 取出並清空暫存的 deep link slug。連續呼叫只會成功一次。
  static String? consumePendingStorySlug() {
    final slug = _pendingStorySlug;
    _pendingStorySlug = null;
    return slug;
  }

  Future<void> configFirebaseMessaging() async {
    debugPrint('[fcm] Requesting notification permission');
    try {
      final NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          )
          .timeout(const Duration(seconds: 5));
      debugPrint(
          '[fcm] User granted permission: ${settings.authorizationStatus}');
    } on TimeoutException {
      debugPrint('[fcm] requestPermission timed out, continuing app launch');
    } catch (e) {
      debugPrint('[fcm] requestPermission failed: $e');
    }

    // initial message: 由 cold-start 通知點擊觸發
    RemoteMessage? initialMessage;
    try {
      debugPrint('[fcm] Waiting for initial message');
      initialMessage = await _firebaseMessaging
          .getInitialMessage()
          .timeout(const Duration(seconds: 3), onTimeout: () {
        debugPrint('[fcm] getInitialMessage timed out, continuing app launch');
        return null;
      });
      debugPrint('[fcm] Initial message resolved: ${initialMessage?.messageId}');
    } catch (e) {
      debugPrint('[fcm] getInitialMessage failed: $e');
    }

    final initialMessageData = initialMessage?.data;
    if (initialMessageData != null &&
        initialMessageData.containsKey('news_story_slug')) {
      // 不直接 Get.to：此時可能還在 ConfigPage，Navigator 還沒就緒。
      // 暫存 slug，由 HomePage 掛載後 (consumePendingStorySlug) 觸發導頁。
      _pendingStorySlug = initialMessageData['news_story_slug']?.toString();
      debugPrint('[fcm] Cached pending story slug: $_pendingStorySlug');
    }

    // 前景訊息（App 開著時收到）
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[fcm] onMessage received: ${message.messageId}, '
          'data=${message.data}, notification=${message.notification?.title}');
      // 預設 iOS 前景不會自動顯示 banner；若日後要做 in-app 提示，可在此擴充。
    });
    debugPrint('[fcm] Registered onMessage listener');

    // 點擊背景通知（App 在背景被通知喚醒並開啟）
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[fcm] onMessageOpenedApp: ${message.messageId}');
      final slug = message.data['news_story_slug']?.toString();
      if (slug != null && slug.isNotEmpty) {
        Get.to(
          () => StoryPage(slug: slug),
          preventDuplicates: false,
        );
      }
    });
    debugPrint('[fcm] Registered onMessageOpenedApp listener');
  }

  void subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  void unsubscribeFromTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  void dispose() {}
}
