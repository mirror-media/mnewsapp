import 'package:get/get.dart';
import 'package:tv/controller/ombuds_controller.dart';
import 'package:tv/services/storyService.dart';
import 'package:tv/services/videoService.dart';

class OmbudsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StoryServices>()) {
      Get.lazyPut(() => StoryServices());
    }

    if (!Get.isRegistered<VideoServices>()) {
      Get.lazyPut(() => VideoServices());
    }

    if (!Get.isRegistered<OmbudsController>()) {
      Get.lazyPut(
        () => OmbudsController(
          storyService: Get.find<StoryServices>(),
          videoService: Get.find<VideoServices>(),
        ),
      );
    }
  }
}
