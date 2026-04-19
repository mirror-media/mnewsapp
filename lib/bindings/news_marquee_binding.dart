import 'package:get/get.dart';
import 'package:tv/controller/news_marquee_controller.dart';
import 'package:tv/services/newsMarqueeService.dart';

class NewsMarqueeBinding extends Bindings {
  NewsMarqueeBinding(this.tag);

  final String tag;

  @override
  void dependencies() {
    if (!Get.isRegistered<NewsMarqueeServices>(tag: tag)) {
      Get.lazyPut(
        () => NewsMarqueeServices(),
        tag: tag,
      );
    }

    if (!Get.isRegistered<NewsMarqueeController>(tag: tag)) {
      Get.lazyPut(
        () => NewsMarqueeController(
          newsMarqueeService: Get.find<NewsMarqueeServices>(tag: tag),
        ),
        tag: tag,
      );
    }
  }
}
