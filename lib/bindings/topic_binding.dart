import 'package:get/get.dart';
import 'package:tv/controller/topic_list_controller.dart';
import 'package:tv/services/topicService.dart';

class TopicBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TopicService>()) {
      Get.lazyPut(() => TopicService());
    }

    if (!Get.isRegistered<TopicListController>()) {
      Get.lazyPut(
        () => TopicListController(topicService: Get.find<TopicService>()),
      );
    }
  }
}
