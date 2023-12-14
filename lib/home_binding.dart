import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:tv/provider/articles_api_provider.dart';

import 'widgets/podcast_sticky_panel/podcast_sticky_panel_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ArticlesApiProvider.instance);
    Get.put(PodcastStickyPanelController.instance);
  }
}
