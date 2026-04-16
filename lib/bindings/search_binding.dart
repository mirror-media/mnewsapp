import 'package:get/get.dart';
import 'package:tv/controller/search_controller.dart';
import 'package:tv/services/searchService.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchRepos>(() => SearchServices());
    Get.lazyPut<SearchController>(
      () => SearchController(searchRepos: Get.find<SearchRepos>()),
    );
  }
}
