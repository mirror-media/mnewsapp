import 'package:get/get.dart';
import 'package:tv/controller/live_widget_controller.dart';
import 'package:tv/services/liveService.dart';

class LiveWidgetBinding extends Bindings {
  LiveWidgetBinding(this.livePostId);

  final String livePostId;

  @override
  void dependencies() {
    if (!Get.isRegistered<LiveRepos>()) {
      Get.lazyPut<LiveRepos>(() => LiveServices());
    }

    if (!Get.isRegistered<LiveWidgetController>(tag: livePostId)) {
      Get.lazyPut<LiveWidgetController>(
        () => LiveWidgetController(
          livePostId: livePostId,
          liveRepos: Get.find<LiveRepos>(),
        ),
        tag: livePostId,
      );
    }
  }
}
