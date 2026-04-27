import 'package:get/get.dart';
import 'package:tv/controller/app_shell_controller.dart';

import 'widgets/podcast_sticky_panel/podcast_sticky_panel_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PodcastStickyPanelController.instance);
    Get.put(AppShellController(), permanent: true);
  }
}
