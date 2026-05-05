import 'package:get/get.dart';
import 'package:tv/controller/news_election_controller.dart';
import 'package:tv/services/electionService.dart';

class NewsElectionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ElectionRepos>()) {
      Get.lazyPut<ElectionRepos>(() => ElectionService());
    }

    if (!Get.isRegistered<NewsElectionController>()) {
      Get.lazyPut<NewsElectionController>(
        () => NewsElectionController(
          repos: Get.find<ElectionRepos>(),
        ),
      );
    }
  }
}
