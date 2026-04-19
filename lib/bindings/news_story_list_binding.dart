import 'package:get/get.dart';
import 'package:tv/controller/news_story_list_controller.dart';
import 'package:tv/services/editorChoiceService.dart';
import 'package:tv/services/tabStoryListService.dart';

class NewsStoryListBinding extends Bindings {
  NewsStoryListBinding({
    required this.controllerTag,
    required this.categorySlug,
    required this.needCarousel,
    this.isPopular = false,
  });

  final String controllerTag;
  final String categorySlug;
  final bool needCarousel;
  final bool isPopular;

  @override
  void dependencies() {
    if (!Get.isRegistered<TabStoryListServices>(tag: controllerTag)) {
      Get.lazyPut(
        () => TabStoryListServices(),
        tag: controllerTag,
      );
    }

    if (!Get.isRegistered<EditorChoiceServices>(tag: controllerTag)) {
      Get.lazyPut(
        () => EditorChoiceServices(),
        tag: controllerTag,
      );
    }

    if (!Get.isRegistered<NewsStoryListController>(tag: controllerTag)) {
      Get.lazyPut(
        () => NewsStoryListController(
          categorySlug: categorySlug,
          needCarousel: needCarousel,
          isPopular: isPopular,
          tabStoryListService: Get.find<TabStoryListServices>(
            tag: controllerTag,
          ),
          editorChoiceService: Get.find<EditorChoiceServices>(
            tag: controllerTag,
          ),
        ),
        tag: controllerTag,
      );
    }
  }
}
