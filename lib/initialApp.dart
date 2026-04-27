import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/initial_app_binding.dart';
import 'package:tv/controller/initial_app_controller.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/pages/configPage.dart';
import 'package:tv/pages/homePage.dart';
import 'package:upgrader/upgrader.dart';
import 'helpers/updateMessages.dart';

class InitialApp extends StatefulWidget {
  const InitialApp({super.key});

  @override
  State<InitialApp> createState() => _InitialAppState();
}

class _InitialAppState extends State<InitialApp> {
  late final InitialAppController controller;

  @override
  void initState() {
    super.initState();
    InitialAppBinding().dependencies();
    controller = Get.find<InitialAppController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.error.value;
      if (error != null) {
        print('ConfigError: ${error.message}');
        return _errorMessage();
      }

      if (controller.isConfigReady.value) {
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
