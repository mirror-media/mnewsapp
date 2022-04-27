import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/story.dart';
import 'package:tv/services/storyService.dart';

class StoryPageController extends GetxController {
  final StoryRepos repository;
  String currentSlug;
  StoryPageController(this.repository, this.currentSlug);

  late Story story;
  late File ombudsLawFile;
  late MNewException error;
  bool isLoading = true;
  bool isError = false;

  @override
  void onInit() {
    super.onInit();
    loadStory(currentSlug);
  }

  static StoryPageController get to => Get.find();

  void loadStory(String slug) async {
    isLoading = true;
    currentSlug = slug;
    update();
    try {
      story = await repository.fetchPublishedStoryBySlug(slug);
      if (slug == 'law') {
        ombudsLawFile = await DefaultCacheManager().getSingleFile(ombudsLaw);
      }
      isError = false;
    } catch (e) {
      isError = true;
      error = determineException(e);
      print('StoryPageError: ${error.message}');
    }
    isLoading = false;
    update();
  }
}
