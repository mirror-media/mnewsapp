import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/initial_app_binding.dart';
import 'package:tv/controller/initial_app_controller.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/firebaseMessagingHelper.dart';
import 'package:tv/pages/config_page.dart';
import 'package:tv/pages/home_page.dart';
import 'package:tv/pages/story_page.dart';
import 'package:upgrader/upgrader.dart';
import 'helpers/updateMessages.dart';

class InitialApp extends StatefulWidget {
  const InitialApp({super.key});

  @override
  State<InitialApp> createState() => _InitialAppState();
}

class _InitialAppState extends State<InitialApp> {
  late final InitialAppController controller;
  bool _deepLinkHandled = false;

  @override
  void initState() {
    super.initState();
    InitialAppBinding().dependencies();
    controller = Get.find<InitialAppController>();
  }

  /// 在 HomePage 掛載後執行：消化 cold-start 通知帶過來的 deep link slug。
  /// 只會成功一次：[FirebaseMessagingHelper.consumePendingStorySlug] 取出後即清空，
  /// 同時 `_deepLinkHandled` 保證 Obx rebuild 也不會重複 push。
  void _handlePendingDeepLink() {
    if (_deepLinkHandled) return;
    _deepLinkHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final slug = FirebaseMessagingHelper.consumePendingStorySlug();
      if (slug != null && slug.isNotEmpty) {
        debugPrint('[initial-app] Navigating to pending story: $slug');
        Get.to(() => StoryPage(slug: slug));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.error.value;
      if (error != null) {
        debugPrint('[initial-app] Showing error state: ${error.message}');
        return _errorMessage();
      }

      if (controller.isConfigReady.value) {
        debugPrint(
          '[initial-app] Config ready, showing HomePage with min version ${controller.minAppVersion.value}',
        );
        _handlePendingDeepLink();
        return UpgradeAlert(
          upgrader: Upgrader(
            minAppVersion: controller.minAppVersion.value,
            messages: UpdateMessages(),
          ),
          child: HomePage(
            appVersion: controller.appVersion.value,
          ),
        );
      }

      debugPrint('[initial-app] Config not ready yet, showing ConfigPage');
      return ConfigPage();
    });
  }

  Widget _errorMessage() {
    return Scaffold(
      backgroundColor: themeColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              logoPng,
              scale: 4.0,
            ),
            const SizedBox(
              height: 20,
            ),
            Text('載入失敗',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                )),
            Text('請檢查網路連線後再重新開啟',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                )),
          ],
        ),
      ),
    );
  }
}
