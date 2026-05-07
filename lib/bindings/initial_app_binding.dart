import 'package:get/get.dart';
import 'package:tv/controller/initial_app_controller.dart';
import 'package:tv/provider/articles_api_provider.dart';
import 'package:tv/services/configService.dart';

class InitialAppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ArticlesApiProvider>()) {
      Get.put(ArticlesApiProvider.instance);
    }

    if (!Get.isRegistered<ConfigRepos>()) {
      Get.lazyPut<ConfigRepos>(() => ConfigServices());
    }

    if (!Get.isRegistered<InitialAppController>()) {
      Get.lazyPut<InitialAppController>(
        () => InitialAppController(
          configRepos: Get.find<ConfigRepos>(),
        ),
      );
    }
  }
}
