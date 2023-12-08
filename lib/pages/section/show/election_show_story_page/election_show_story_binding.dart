import 'package:get/get.dart';
import 'package:tv/pages/section/show/election_show_story_page/election_show_story_controller.dart';


class ElectionShowStoryBinding extends Bindings {

  String? tag;

  ElectionShowStoryBinding(String _tag)
  {
    tag =_tag;
  }

  void dependencies() {
    Get.put(ElectionShowStoryController(),tag: tag);
  }
}
