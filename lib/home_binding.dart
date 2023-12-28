import 'package:get/get.dart';
import 'package:real_time_invoice_widget/data/provider/election_data_provider.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/provider/articles_api_provider.dart';

import 'widgets/podcast_sticky_panel/podcast_sticky_panel_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ArticlesApiProvider.instance);
    Get.put(PodcastStickyPanelController.instance);
    Get.put(ElectionDataProvider.create(Environment().config.electionPath));
  }
}
