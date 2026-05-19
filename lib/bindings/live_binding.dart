import 'package:get/get.dart';
import 'package:tv/pages/section/live/live_page_controller.dart';
import 'package:tv/provider/articles_api_provider.dart';
import 'package:tv/services/promotionVideosService.dart';

class LiveBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PromotionVideosRepos>()) {
      Get.lazyPut<PromotionVideosRepos>(() => PromotionVideosServices());
    }

    if (!Get.isRegistered<LivePageController>()) {
      Get.lazyPut<LivePageController>(
        () => LivePageController(
          articlesApiProvider: Get.find<ArticlesApiProvider>(),
          promotionVideosRepos: Get.find<PromotionVideosRepos>(),
        ),
      );
    }
  }
}
