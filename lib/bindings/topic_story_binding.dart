import 'package:get/get.dart';
import 'package:tv/controller/topic_story_controller.dart';
import 'package:tv/services/topicService.dart';

class TopicStoryBinding extends Bindings {
  TopicStoryBinding(this.slug);

  final String slug;

  @override
  void dependencies() {
    if (!Get.isRegistered<TopicService>()) {
      Get.lazyPut(() => TopicService());
    }

    if (!Get.isRegistered<TopicStoryController>(tag: slug)) {
      Get.lazyPut(
        () => TopicStoryController(
          topicSlug: slug,
          topicService: Get.find<TopicService>(),
        ),
        tag: slug,
      );
    }
  }
}
