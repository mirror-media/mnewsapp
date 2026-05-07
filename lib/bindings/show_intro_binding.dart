import 'package:get/get.dart';
import 'package:tv/controller/show_intro_controller.dart';
import 'package:tv/services/showService.dart';

class ShowIntroBinding extends Bindings {
  ShowIntroBinding(this.showCategoryId);

  final String showCategoryId;

  @override
  void dependencies() {
    if (!Get.isRegistered<ShowServices>()) {
      Get.lazyPut(() => ShowServices());
    }

    if (!Get.isRegistered<ShowIntroController>(tag: showCategoryId)) {
      Get.lazyPut(
        () => ShowIntroController(
          showCategoryId: showCategoryId,
          showService: Get.find<ShowServices>(),
        ),
        tag: showCategoryId,
      );
    }
  }
}
