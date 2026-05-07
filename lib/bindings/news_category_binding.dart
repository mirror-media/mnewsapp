import 'package:get/get.dart';
import 'package:tv/controller/news_category_controller.dart';
import 'package:tv/services/categoryService.dart';

class NewsCategoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CategoryServices>()) {
      Get.lazyPut(() => CategoryServices());
    }

    if (!Get.isRegistered<NewsCategoryController>()) {
      Get.lazyPut(
        () => NewsCategoryController(
          categoryService: Get.find<CategoryServices>(),
        ),
      );
    }
  }
}
