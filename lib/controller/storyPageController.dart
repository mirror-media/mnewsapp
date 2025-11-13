import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/story.dart';
import 'package:tv/services/storyService.dart';
import '../services/comscoreService.dart';

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

  Future<void> loadStory(String slug) async {
    isLoading = true;
    isError = false;
    currentSlug = slug;
    update();

    try {
      story = await repository.fetchPublishedStoryBySlug(slug);

      if (slug == 'law') {
        ombudsLawFile = await DefaultCacheManager().getSingleFile(ombudsLaw);
      }

      final categoryName =
      (story.categoryList != null && story.categoryList!.isNotEmpty)
          ? story.categoryList!.first.name
          : 'unknown';

      ComscoreService.trackArticleView(
        articleId: slug,
        title: story.name ?? '無標題',
        category: categoryName,
      );

      isError = false;
    } catch (e) {
      error = determineException(e);
      isError = true;
    } finally {
      isLoading = false;
      update();
    }
  }
}
