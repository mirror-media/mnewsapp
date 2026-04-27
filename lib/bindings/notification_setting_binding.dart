import 'package:get/get.dart';
import 'package:tv/controller/notification_setting_controller.dart';
import 'package:tv/services/notificationSettingService.dart';

class NotificationSettingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationSettingRepos>()) {
      Get.lazyPut<NotificationSettingRepos>(
        () => NotificationSettingServices(),
      );
    }

    if (!Get.isRegistered<NotificationSettingController>()) {
      Get.lazyPut<NotificationSettingController>(
        () => NotificationSettingController(
          notificationSettingRepos: Get.find<NotificationSettingRepos>(),
        ),
      );
    }
  }
}
