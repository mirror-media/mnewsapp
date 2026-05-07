import 'package:get/get.dart';
import 'package:tv/controller/tag_controller.dart';
import 'package:tv/services/tagStoryListService.dart';

class TagBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TagStoryListRepos>(() => TagStoryListServices());
  }

  void bindTagController(String slug) {
    if (!Get.isRegistered<TagController>(tag: slug)) {
      Get.lazyPut<TagController>(
        () => TagController(
          tagSlug: slug,
          tagStoryListRepos: Get.find<TagStoryListRepos>(),
        ),
        tag: slug,
      );
    }
  }
}
