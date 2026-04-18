import 'package:get/get.dart';
import 'package:tv/controller/show_category_controller.dart';
import 'package:tv/services/showService.dart';

class ShowBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ShowServices>()) {
      Get.lazyPut(() => ShowServices());
    }

    if (!Get.isRegistered<ShowCategoryController>()) {
      Get.lazyPut(
        () => ShowCategoryController(
          showService: Get.find<ShowServices>(),
        ),
      );
    }
  }
}
